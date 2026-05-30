#!/usr/bin/env bash
# Scenario 02 — Expo app.json manifest schema check
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "02-manifest"

MANIFEST="$APP_ROOT/app.json"
assert_file_exists "$MANIFEST"
assert_json_valid  "$MANIFEST"

assert_json_has "$MANIFEST" "expo.name"
assert_json_has "$MANIFEST" "expo.slug"
assert_json_has "$MANIFEST" "expo.scheme"
assert_json_has "$MANIFEST" "expo.ios.bundleIdentifier"
assert_json_has "$MANIFEST" "expo.android.package"
assert_json_has "$MANIFEST" "expo.extra.apiUrl"

# plugins array must include expo-router + expo-secure-store
if python3 -c "
import json,sys
m=json.load(open('$MANIFEST'))
plugins=m.get('expo',{}).get('plugins',[])
need={'expo-router','expo-secure-store'}
have={p if isinstance(p,str) else p[0] for p in plugins}
missing=need-have
sys.exit(0 if not missing else 1)
"; then
  log_pass "plugins include expo-router + expo-secure-store"
else
  log_fail "plugins missing expo-router or expo-secure-store"
fi

# typedRoutes flag (required for Expo Router type generation)
assert_json_has "$MANIFEST" "expo.experiments.typedRoutes"

scenario_end
