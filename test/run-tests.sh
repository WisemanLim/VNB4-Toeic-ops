#!/usr/bin/env bash
# Entrypoint — runs every scenarios/*.sh sequentially, aggregates TSV results,
# and emits TEST_RESULTS.md in this directory plus a per-run log archive.
#
# Usage:
#   ./run-tests.sh                 # run everything
#   ./run-tests.sh 01 03           # run subset by numeric prefix
#   API_URL=http://1.2.3.4 ./run-tests.sh   # override backend probe target
#
set -o pipefail
# (Avoiding `set -u` for portability with bash 3.2 — empty array expansion trips it.)

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TEST_LOG_DIR="$TEST_ROOT/logs"
export TEST_RUN_ID="$(date +%Y%m%d_%H%M%S)"
export OPS_ROOT="$(cd "$TEST_ROOT/.." && pwd)"
# REPO_ROOT = Web(Node,Script)/ — 4 컴포넌트 (backend/frontend/database/ops) 의 공통 부모
export REPO_ROOT="$(cd "$OPS_ROOT/.." && pwd)"
export BACKEND_ROOT="$REPO_ROOT/VNB4-Toeic-backend"
export FRONTEND_ROOT="$REPO_ROOT/VNB4-Toeic-frontend"
export DB_ROOT="$REPO_ROOT/VNB4-Toeic-database"
# App 은 별도 부모 (Apps(Android,iOS,...)/). 환경변수로 override 가능.
export APP_ROOT="${APP_ROOT:-/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app}"

mkdir -p "$TEST_LOG_DIR"

SUMMARY_TSV="$TEST_LOG_DIR/${TEST_RUN_ID}_summary.tsv"
RUN_LOG="$TEST_LOG_DIR/${TEST_RUN_ID}_run.log"
: > "$SUMMARY_TSV"
: > "$RUN_LOG"

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
else
  C_GREEN=""; C_RED=""; C_YELLOW=""; C_DIM=""; C_BOLD=""; C_RESET=""
fi

banner() {
  printf "\n%s════════════════════════════════════════%s\n" "$C_BOLD" "$C_RESET"
  printf "%s %s %s\n" "$C_BOLD" "$*" "$C_RESET"
  printf "%s════════════════════════════════════════%s\n" "$C_BOLD" "$C_RESET"
}

echo "VNB4 TOEIC — system test harness"   | tee -a "$RUN_LOG"
echo "run id:        $TEST_RUN_ID"          | tee -a "$RUN_LOG"
echo "repo root:     $REPO_ROOT"            | tee -a "$RUN_LOG"
echo "app root:      $APP_ROOT"             | tee -a "$RUN_LOG"
echo "backend root:  $BACKEND_ROOT"         | tee -a "$RUN_LOG"
echo "frontend root: $FRONTEND_ROOT"        | tee -a "$RUN_LOG"
echo "db root:       $DB_ROOT"              | tee -a "$RUN_LOG"
echo "ops root:      $OPS_ROOT"             | tee -a "$RUN_LOG"
echo "log dir:       $TEST_LOG_DIR"         | tee -a "$RUN_LOG"
echo "started:       $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$RUN_LOG"

# Pick scenarios (optional CLI filter by numeric prefix, e.g. "01" "03")
# Portable: no mapfile (bash 3.2 on macOS lacks it).
ALL_SCENARIOS=()
while IFS= read -r line; do
  ALL_SCENARIOS+=("$line")
done < <(find "$TEST_ROOT/scenarios" -maxdepth 1 -name "*.sh" -type f | sort)

SELECTED=()
if [ "$#" -gt 0 ]; then
  for s in "${ALL_SCENARIOS[@]}"; do
    base="$(basename "$s")"
    for r in "$@"; do
      case "$base" in
        "$r"*) SELECTED+=("$s"); break;;
      esac
    done
  done
else
  for s in "${ALL_SCENARIOS[@]}"; do
    SELECTED+=("$s")
  done
fi

if [ "${#SELECTED[@]}" -eq 0 ]; then
  echo "${C_RED}no scenarios matched${C_RESET}"
  exit 2
fi

echo "running ${#SELECTED[@]} scenario(s)" | tee -a "$RUN_LOG"

# Run each in a subshell so a sourced helper from one doesn't leak to the next
overall_rc=0
for sc in "${SELECTED[@]}"; do
  banner "$(basename "$sc")"
  if bash "$sc" 2>&1 | tee -a "$RUN_LOG"; then
    :
  else
    overall_rc=1
  fi
done

# ---- aggregate -----------------------------------------------------------
total=0; pass=0; fail=0; skip=0
declare -a ROWS=()
while IFS='|' read -r name status seconds details logfile; do
  [ -z "$name" ] && continue
  total=$((total+1))
  case "$status" in
    PASS) pass=$((pass+1));;
    FAIL) fail=$((fail+1));;
    SKIP) skip=$((skip+1));;
  esac
  ROWS+=("$name|$status|$seconds|$details|$logfile")
done < "$SUMMARY_TSV"

# ---- emit TEST_RESULTS.md ------------------------------------------------
REPORT="$TEST_ROOT/TEST_RESULTS.md"
{
  echo "# VNB4 TOEIC — System Test Results"
  echo ""
  echo "_Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) by \`test/run-tests.sh\`_"
  echo ""
  echo "**Run ID:** \`$TEST_RUN_ID\`"
  echo ""
  echo "## Summary"
  echo ""
  echo "| Total | Pass | Fail | Skip |"
  echo "|------:|-----:|-----:|-----:|"
  echo "| $total | $pass | $fail | $skip |"
  echo ""
  if [ "$fail" -gt 0 ]; then
    echo "> **Overall: FAIL** ($fail scenario(s) failed)"
  elif [ "$total" -eq 0 ]; then
    echo "> **Overall: NO RESULTS**"
  else
    echo "> **Overall: PASS**"
  fi
  echo ""
  echo "## Scenarios"
  echo ""
  echo "| # | Scenario | Status | Time (s) | Log |"
  echo "|--:|----------|:------:|---------:|-----|"
  i=1
  for row in "${ROWS[@]}"; do
    IFS='|' read -r name status seconds details logfile <<< "$row"
    badge="$status"
    case "$status" in
      PASS) badge="✅ PASS";;
      FAIL) badge="❌ FAIL";;
      SKIP) badge="➖ SKIP";;
    esac
    rel_log=$(basename "$logfile")
    echo "| $i | \`$name\` | $badge | $seconds | [\`logs/$rel_log\`](logs/$rel_log) |"
    i=$((i+1))
  done
  echo ""
  echo "## Scenario details"
  echo ""
  for row in "${ROWS[@]}"; do
    IFS='|' read -r name status seconds details logfile <<< "$row"
    echo "### \`$name\` — $status"
    echo ""
    echo "Duration: ${seconds}s · Log: \`logs/$(basename "$logfile")\`"
    echo ""
    echo "<details><summary>Checks</summary>"
    echo ""
    echo '```'
    if [ -f "$logfile" ]; then
      grep -E '^\s*[✔✘\-·]' "$logfile" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g' || cat "$logfile"
    fi
    echo '```'
    echo ""
    echo "</details>"
    echo ""
  done
  echo "## Environment"
  echo ""
  echo "| Key | Value |"
  echo "|-----|-------|"
  echo "| OS | $(uname -s) $(uname -r) |"
  echo "| Shell | $BASH_VERSION |"
  echo "| Node | $(command -v node >/dev/null && node -v || echo 'not installed') |"
  echo "| pnpm | $(command -v pnpm >/dev/null && pnpm -v || echo 'not installed') |"
  echo "| App root | \`$APP_ROOT\` |"
  echo "| Backend probe | \`${API_URL:-http://localhost:4000}\` |"
  echo ""
  echo "## Re-run"
  echo ""
  echo '```bash'
  echo "cd $OPS_ROOT/test"
  echo "./run-tests.sh                # all scenarios"
  echo "./run-tests.sh 05 10          # subset (typecheck + local DB integration)"
  echo "./run-tests.sh 09 10          # database-only (file checks + SQLite integration)"
  echo "API_URL=https://api.dev ./run-tests.sh 08   # override backend probe URL"
  echo '```'
} > "$REPORT"

# ---- console summary ----------------------------------------------------
banner "summary"
printf "  total: %d  ${C_GREEN}pass: %d${C_RESET}  ${C_RED}fail: %d${C_RESET}  ${C_YELLOW}skip: %d${C_RESET}\n" \
       "$total" "$pass" "$fail" "$skip"
echo  "  report: $REPORT"
echo  "  run log: $RUN_LOG"

# Cleanup empty .body files leftover from probe
find "$TEST_LOG_DIR" -name "*.body" -size 0 -delete 2>/dev/null

[ "$fail" -eq 0 ] && exit 0 || exit 1
