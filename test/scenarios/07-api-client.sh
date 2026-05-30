#!/usr/bin/env bash
# Scenario 07 — API client surface check
# Verifies src/core/client.ts + config.ts expose the symbols the app relies on.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "07-api-client"

CLIENT="$APP_ROOT/src/core/client.ts"
CONFIG="$APP_ROOT/src/core/config.ts"
assert_file_exists "$CLIENT"
assert_file_exists "$CONFIG"

EXPECTED_EXPORTS=("export async function api" "export async function saveToken" "export async function loadToken" "export class ApiError")
for sig in "${EXPECTED_EXPORTS[@]}"; do
  assert_grep "$sig" "$CLIENT" "exports: ${sig#export }"
done

# API base URL read from Expo config (not hardcoded) — now centralized in config.ts
assert_grep 'expoConfig.*extra'             "$CONFIG" "reads apiUrl from Expo extra (config.ts)"
assert_grep 'SecureStore'                   "$CLIENT" "uses SecureStore for token persistence"
assert_grep '/api/v1'                       "$CLIENT" "calls /api/v1 prefix"
assert_grep 'authorization'                 "$CLIENT" "sends Authorization header"

# Must not have a hardcoded production URL leaking
if grep -qE 'https://[a-zA-Z0-9.-]+\.(com|net|io|app)' "$CLIENT"; then
  log_fail "hardcoded prod URL detected in client.ts"
else
  log_pass "no hardcoded prod URL in client.ts"
fi

scenario_end
