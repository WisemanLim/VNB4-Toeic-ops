#!/usr/bin/env bash
# Scenario 19 — VNB4-Toeic-app 플랫폼별 실행 준비 상태 점검
# 각 타겟(iOS sim / Android emul / web / Expo Go / EAS) 의 prereq 점검.
# 누락된 경우 FAIL 이 아니라 INFO 로 안내 — README 트러블슈팅과 1:1 매칭.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "19-app-platform-readiness"

# ---- App deps 가 README §4 (web) 와 expo-system-ui 요구사항 충족 ----
PKG="$APP_ROOT/package.json"
assert_grep '"react-native-web"'  "$PKG" "react-native-web (web target 필수)"
assert_grep '"react-dom"'         "$PKG" "react-dom (web target 필수)"
assert_grep '"expo-system-ui"'    "$PKG" "expo-system-ui (userInterfaceStyle automatic 필수)"

# node_modules 실제 존재 여부
for m in react-native-web react-dom expo-system-ui expo-av expo-secure-store expo-router; do
  if [ -d "$APP_ROOT/node_modules/$m" ]; then
    log_pass "node_modules/$m installed"
  else
    log_fail "node_modules/$m missing — run: cd VNB4-Toeic-app && pnpm install"
  fi
done

# ---- iOS sim readiness ----
if xcrun simctl help >/dev/null 2>&1; then
  log_pass "iOS simulator ready (xcrun simctl OK)"
else
  log_skip "iOS simulator NOT ready — Xcode 풀 설치 필요 (App Store 에서 Xcode 다운로드 + 'sudo xcode-select -s /Applications/Xcode.app/Contents/Developer')"
fi

# ---- Android readiness ----
if command -v adb >/dev/null 2>&1; then
  log_pass "adb installed"
  DEVS=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -c "device$" || true)
  if [ "$DEVS" -gt 0 ]; then
    log_pass "Android device/emulator connected ($DEVS device(s))"
  else
    log_skip "Android emulator/device 없음 — 'emulator -list-avds' 후 'emulator -avd <name>' 실행, 또는 USB 디버깅 기기 연결"
  fi
else
  log_skip "adb 미설치 — Android Studio 설치 + ANDROID_HOME export 필요 (README §3 참조)"
fi

# ---- Web readiness (deps 만 있으면 됨, 위에서 확인) ----
if [ -d "$APP_ROOT/node_modules/react-native-web" ] && [ -d "$APP_ROOT/node_modules/react-dom" ]; then
  log_pass "web target ready (deps present)"
else
  log_fail "web target deps missing — 'npx expo install react-native-web react-dom'"
fi

# ---- Expo Go readiness ----
# Expo Go 는 폰의 앱이므로 호스트에서 검증 불가. 핵심은 pnpm start 가 동작하는지.
if [ -f "$APP_ROOT/node_modules/.bin/expo" ]; then
  log_pass "expo CLI available (pnpm start 가능, 폰의 Expo Go 로 QR 스캔)"
else
  log_fail "expo CLI 미설치 — 'cd VNB4-Toeic-app && pnpm install'"
fi

# ---- EAS CLI ----
if npx --no-install eas-cli --version >/dev/null 2>&1; then
  EAS_VER=$(npx --no-install eas-cli --version 2>/dev/null | tail -1)
  log_pass "eas-cli installed ($EAS_VER)"
else
  log_info "eas-cli not installed (실제 빌드 시 'npx eas-cli build --platform ios|android' 가 첫 실행에서 자동 설치)"
fi

# ---- 알려진 명령 오타 알림 (사용자 빈번 실수) ----
log_info "주의: 'eas-cli build --plaform' 은 오타. 정확한 옵션은 '--platform' (l 빠짐 X)"

# ---- 결론 ----
log_info "플랫폼별 실행 가능 여부는 README §0 Prerequisites + §7 트러블슈팅 매트릭스 참고"

scenario_end
