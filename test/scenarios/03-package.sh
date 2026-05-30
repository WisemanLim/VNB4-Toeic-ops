#!/usr/bin/env bash
# Scenario 03 — package.json: required deps + scripts
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "03-package"

PKG="$APP_ROOT/package.json"
assert_file_exists "$PKG"
assert_json_valid  "$PKG"

# Required runtime deps for current implementation
REQUIRED_DEPS=(
  "expo"
  "expo-router"
  "expo-secure-store"
  "expo-av"
  "expo-constants"
  "react"
  "react-native"
  "@tanstack/react-query"
  "react-native-safe-area-context"
  "react-native-gesture-handler"
  "react-native-reanimated"
  "zustand"
  "zod"
)

for dep in "${REQUIRED_DEPS[@]}"; do
  if python3 -c "
import json,sys
p=json.load(open('$PKG'))
deps={**p.get('dependencies',{}),**p.get('devDependencies',{})}
sys.exit(0 if '$dep' in deps else 1)
"; then
    log_pass "dep present: $dep"
  else
    log_fail "dep missing: $dep"
  fi
done

# Required scripts
for s in start ios android web typecheck; do
  if python3 -c "
import json,sys
p=json.load(open('$PKG'))
sys.exit(0 if '$s' in p.get('scripts',{}) else 1)
"; then
    log_pass "script present: $s"
  else
    log_fail "script missing: $s"
  fi
done

# main entry must be expo-router/entry
MAIN=$(python3 -c "import json; print(json.load(open('$PKG')).get('main',''))")
if [ "$MAIN" = "expo-router/entry" ]; then
  log_pass "main = expo-router/entry"
else
  log_fail "main is '$MAIN' (expected expo-router/entry)"
fi

scenario_end
