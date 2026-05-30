#!/usr/bin/env bash
# Scenario 08 — backend reachability smoke (optional)
# Hits the local backend's health endpoint to confirm the app can reach it.
# Skips cleanly when backend isn't running — the app still passes structural checks.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "08-backend-reachability"

API_URL="${API_URL:-http://localhost:4000}"
HEALTH_PATH="${HEALTH_PATH:-/api/v1/health}"
TARGET="$API_URL$HEALTH_PATH"

log_info "probing $TARGET"

if ! command -v curl >/dev/null 2>&1; then
  log_skip "curl not available"
  scenario_end
  exit 0
fi

# 2-second connect timeout, 5-second total
HTTP_CODE=$(curl -s -o "$_scenario_log.body" -w "%{http_code}" \
  --connect-timeout 2 --max-time 5 "$TARGET" 2>>"$_scenario_log") || HTTP_CODE="000"

case "$HTTP_CODE" in
  200)
    log_pass "backend healthy: HTTP 200"
    if [ -f "$_scenario_log.body" ] && command -v python3 >/dev/null 2>&1; then
      if python3 -c "import json,sys; d=json.load(open('$_scenario_log.body')); sys.exit(0 if d.get('status')=='ok' else 1)" 2>>"$_scenario_log"; then
        log_pass "health payload status=ok"
      else
        log_fail "health payload status != ok"
      fi
    fi
    ;;
  000)
    log_skip "backend unreachable (start it via 'cd VNB4-Toeic-backend/api && pnpm start:dev')"
    ;;
  *)
    log_fail "backend returned HTTP $HTTP_CODE"
    ;;
esac

rm -f "$_scenario_log.body"
scenario_end
