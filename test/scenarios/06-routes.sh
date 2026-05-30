#!/usr/bin/env bash
# Scenario 06 — Expo Router route file surface check
# Each .tsx under app/ must have `export default` and reasonable React Native imports.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "06-routes"

ROUTES=(
  "app/_layout.tsx"
  "app/index.tsx"
  "app/login.tsx"
  "app/learn/[lessonId].tsx"
)

for r in "${ROUTES[@]}"; do
  file="$APP_ROOT/$r"
  if [ ! -f "$file" ]; then
    log_fail "missing route file: $r"
    continue
  fi
  assert_grep '^export default' "$file" "$r has default export"
  assert_grep 'react-native|expo-router|expo-' "$file" "$r imports RN/expo lib"
done

# Layout-specific: must wrap with QueryClientProvider and SafeAreaProvider
assert_grep 'QueryClientProvider' "$APP_ROOT/app/_layout.tsx" "_layout wraps QueryClientProvider"
assert_grep 'SafeAreaProvider'   "$APP_ROOT/app/_layout.tsx" "_layout wraps SafeAreaProvider"
assert_grep 'Stack'              "$APP_ROOT/app/_layout.tsx" "_layout declares <Stack>"

# Home: must have part navigation Links
assert_grep 'expo-router'        "$APP_ROOT/app/index.tsx"   "index imports expo-router"
assert_grep 'PARTS|Part'         "$APP_ROOT/app/index.tsx"   "index references parts"

# Learn: grade + audio playback (refactored into hooks)
assert_grep 'useTts'             "$APP_ROOT/app/learn/[lessonId].tsx" "learn uses TTS hook"
assert_grep 'expo-av'            "$APP_ROOT/src/features/learn/useTts.ts" "useTts wraps expo-av"
assert_grep 'grade'              "$APP_ROOT/app/learn/[lessonId].tsx" "learn implements grading"
assert_grep '/progress/grade'    "$APP_ROOT/src/core/queries.ts" "useGradeWord calls /progress/grade"

scenario_end
