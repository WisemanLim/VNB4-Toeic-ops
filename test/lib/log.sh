#!/usr/bin/env bash
# Shared logging + assertion helpers for test scenarios.
# Source this from each scenario script: source "$(dirname "$0")/../lib/log.sh"

# --- env contract ---
# TEST_ROOT       absolute path to test/ dir
# TEST_LOG_DIR    absolute path to test/logs/
# TEST_RUN_ID     timestamp string set by run-tests.sh (or auto)
# TEST_RESULTS    appended scenario rows: "name|status|details|log"

: "${TEST_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
: "${TEST_LOG_DIR:=$TEST_ROOT/logs}"
: "${TEST_RUN_ID:=$(date +%Y%m%d_%H%M%S)}"
: "${OPS_ROOT:=$(cd "$TEST_ROOT/.." && pwd)}"
: "${REPO_ROOT:=$(cd "$OPS_ROOT/.." && pwd)}"
: "${BACKEND_ROOT:=$REPO_ROOT/VNB4-Toeic-backend}"
: "${FRONTEND_ROOT:=$REPO_ROOT/VNB4-Toeic-frontend}"
: "${DB_ROOT:=$REPO_ROOT/VNB4-Toeic-database}"
# App 은 별도 부모 디렉토리 (Apps(Android,iOS,...)/). 호스트 absolute path.
: "${APP_ROOT:=/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app}"

mkdir -p "$TEST_LOG_DIR"

# ANSI colors (only if stdout is a tty)
if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_DIM=""; C_RESET=""
fi

_scenario_name=""
_scenario_log=""
_scenario_started_at=""
_scenario_failed=0
_scenario_skipped=0
_scenario_passed=0
_scenario_details=()

scenario_begin() {
  _scenario_name="$1"
  _scenario_log="$TEST_LOG_DIR/${TEST_RUN_ID}_${_scenario_name}.log"
  _scenario_started_at=$(date +%s)
  _scenario_failed=0
  _scenario_skipped=0
  _scenario_passed=0
  _scenario_details=()
  : > "$_scenario_log"
  log_info "===== scenario: $_scenario_name ====="
  log_info "started at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

scenario_end() {
  local elapsed=$(( $(date +%s) - _scenario_started_at ))
  local status detail_msg
  if [ "$_scenario_failed" -gt 0 ]; then
    status="FAIL"
  elif [ "$_scenario_skipped" -gt 0 ] && [ "$_scenario_passed" -eq 0 ]; then
    status="SKIP"
  else
    status="PASS"
  fi
  detail_msg=$(IFS=";"; echo "${_scenario_details[*]}")
  log_info "===== finished $_scenario_name ($status, ${elapsed}s) ====="
  printf "%s|%s|%s|%s|%s\n" "$_scenario_name" "$status" "$elapsed" "${detail_msg//$'\n'/ }" "$_scenario_log" \
    >> "$TEST_LOG_DIR/${TEST_RUN_ID}_summary.tsv"
  [ "$status" = "FAIL" ] && return 1 || return 0
}

# Assertion helpers — call these from scenarios.
# Each appends a "check: PASS/FAIL — message" line to the scenario log and details[].

_record() {
  local kind="$1"; shift
  local msg="$*"
  case "$kind" in
    PASS) printf "  ${C_GREEN}✔${C_RESET} %s\n" "$msg" | tee -a "$_scenario_log"; _scenario_passed=$((_scenario_passed+1));;
    FAIL) printf "  ${C_RED}✘${C_RESET} %s\n" "$msg" | tee -a "$_scenario_log"; _scenario_failed=$((_scenario_failed+1));;
    SKIP) printf "  ${C_YELLOW}-${C_RESET} %s\n" "$msg" | tee -a "$_scenario_log"; _scenario_skipped=$((_scenario_skipped+1));;
    INFO) printf "  ${C_DIM}·${C_RESET} %s\n" "$msg" | tee -a "$_scenario_log";;
  esac
  _scenario_details+=("$kind:$msg")
}

log_info()  { _record INFO "$*"; }
log_pass()  { _record PASS "$*"; }
log_fail()  { _record FAIL "$*"; }
log_skip()  { _record SKIP "$*"; }

assert_file_exists() {
  local f="$1" desc="${2:-file $1}"
  if [ -f "$f" ]; then log_pass "$desc exists"; else log_fail "$desc missing ($f)"; fi
}

assert_dir_exists() {
  local d="$1" desc="${2:-directory $1}"
  if [ -d "$d" ]; then log_pass "$desc exists"; else log_fail "$desc missing ($d)"; fi
}

assert_json_valid() {
  local f="$1"
  if python3 -c "import json; json.load(open('$f'))" 2>>"$_scenario_log"; then
    log_pass "JSON valid: $(basename "$f")"
  else
    log_fail "JSON invalid: $f"
  fi
}

assert_json_has() {
  local f="$1" jq_path="$2"
  local out
  out=$(python3 -c "
import json, sys
data = json.load(open('$f'))
keys = '$jq_path'.strip('.').split('.')
cur = data
for k in keys:
    if isinstance(cur, dict) and k in cur:
        cur = cur[k]
    else:
        sys.exit(1)
print(cur)
" 2>>"$_scenario_log")
  if [ $? -eq 0 ]; then
    log_pass "$jq_path = $out  ($(basename "$f"))"
  else
    log_fail "$jq_path missing in $(basename "$f")"
  fi
}

assert_grep() {
  local pattern="$1" file="$2" desc="${3:-grep \"$pattern\" in $(basename "$file")}"
  if [ -f "$file" ] && grep -qE "$pattern" "$file"; then
    log_pass "$desc"
  else
    log_fail "$desc"
  fi
}

assert_cmd() {
  local desc="$1"; shift
  local out rc
  out=$("$@" 2>&1); rc=$?
  echo "$out" >> "$_scenario_log"
  if [ $rc -eq 0 ]; then log_pass "$desc"; else log_fail "$desc (exit $rc)"; fi
  return $rc
}
