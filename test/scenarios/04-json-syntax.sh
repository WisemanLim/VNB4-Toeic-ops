#!/usr/bin/env bash
# Scenario 04 — every JSON file in the app parses
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "04-json-syntax"

count=0
fails=0
while IFS= read -r f; do
  count=$((count+1))
  if python3 -c "import json; json.load(open('$f'))" 2>>"$_scenario_log"; then
    log_pass "$(realpath --relative-to="$APP_ROOT" "$f" 2>/dev/null || echo "$f")"
  else
    log_fail "invalid JSON: $f"
    fails=$((fails+1))
  fi
done < <(find "$APP_ROOT" -name "*.json" -not -path "*/node_modules*" -not -path "*/test/logs/*")

log_info "checked $count JSON files, $fails failed"

scenario_end
