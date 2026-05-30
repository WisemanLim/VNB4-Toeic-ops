#!/usr/bin/env bash
# Scenario 05 — TypeScript typecheck (tsc --noEmit). Skipped if deps not installed.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "05-typecheck"

if [ ! -d "$APP_ROOT/node_modules" ]; then
  log_skip "node_modules missing — run 'pnpm install' under VNB4-Toeic-app first"
  scenario_end
  exit 0
fi

cd "$APP_ROOT" || { log_fail "cannot cd to $APP_ROOT"; scenario_end; exit 1; }

if ! [ -x "node_modules/.bin/tsc" ]; then
  log_skip "typescript not installed locally"
  scenario_end
  exit 0
fi

if node_modules/.bin/tsc --noEmit > "$TEST_LOG_DIR/${TEST_RUN_ID}_tsc.out" 2>&1; then
  log_pass "tsc --noEmit clean"
else
  log_fail "tsc errors (see ${TEST_RUN_ID}_tsc.out)"
  tail -30 "$TEST_LOG_DIR/${TEST_RUN_ID}_tsc.out" >> "$_scenario_log"
fi

scenario_end
