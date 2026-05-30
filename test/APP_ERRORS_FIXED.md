# VNB4-Toeic-app — 보고된 에러 분석 및 조치

_2026-05-21 사용자 보고 5개 에러 → 코드 수정 + 가이드 보강_

## 사용자가 만난 에러 ↔ 조치

| # | 명령 | 에러 | 원인 | 조치 |
|---|------|------|------|------|
| 1 | `pnpm start` → iOS sim | `xcrun simctl help exited with non-zero code: 72` → `Xcode must be fully installed` | macOS 에 Xcode CLT 만 설치됨 | README §2 단계별 가이드 + 트러블슈팅 매트릭스 |
| 2 | `pnpm web` | `It looks like you're trying to use web support but don't have the required dependencies installed. Please install react-native-web@~0.19.10, react-dom@18.2.0` | `package.json` 에 web 타겟 deps 미포함 | **코드 수정**: `react-native-web`, `react-dom`, `@babel/runtime` 추가 |
| 3 | `pnpm android` | `No Android connected device found, and no emulators could be started automatically` + `Install expo-system-ui in your project to enable this feature` | AVD 미실행 + `expo-system-ui` 미설치 | **코드 수정**: `expo-system-ui` 추가 / README §3 + 트러블슈팅 매트릭스 |
| 4 | `npx eas-cli build --plaform android` | `Nonexistent flag: --plaform` | 오타 (`--plaform` → `--platform`) | README §5 + 매트릭스에 명시 |
| 5 | `npx eas-cli build --plaform ios` | 동일 | 동일 | 동일 |

## 코드 변경

### `VNB4-Toeic-app/package.json` — 누락 dep 추가
```diff
   "dependencies": {
     "expo-av": "~14.0.7",
+    "expo-system-ui": "~3.0.7",
     "react": "18.2.0",
+    "react-dom": "18.2.0",
     "react-native": "0.74.5",
+    "react-native-web": "~0.19.10",
     ...
     "nativewind": "^4.1.20",
+    "@babel/runtime": "^7.25.0"
   }
```

`@babel/runtime` 은 web bundling 시 `interopRequireDefault` 헬퍼 해석에 필요. expo-system-ui 는 `app.json` 의 `userInterfaceStyle: "automatic"` 가 native 측에서 동작하려 요구.

### `VNB4-Toeic-app/README.md` — 풀 재작성
- §0 **Prerequisites** 표 (플랫폼별 필요 환경 + 빠른 진단 스크립트)
- §1~§5 **플랫폼별 단계별 가이드** (Expo Go / iOS sim / Android emul / Web / EAS)
- §7 **흔한 에러 → 조치 매트릭스** (8 종 에러 → 정확한 조치 명령)
- §8 commands 요약 (`--clear`, `--tunnel` 등 빈번 사용 옵션 포함)

## 검증 결과

### Mode A (SQLite + app typecheck)
```
✔ db: pnpm migrate:local (SQLite)
✔ db: SQLite Word count = 96
✔ app: pnpm typecheck
✔ app: expo CLI available
```

### Scenario 19 — 플랫폼 readiness (현재 호스트 기준)
```
✔ react-native-web (web target 필수)
✔ react-dom (web target 필수)
✔ expo-system-ui (userInterfaceStyle automatic 필수)
✔ node_modules/{react-native-web,react-dom,expo-system-ui,expo-av,...} installed
- iOS simulator NOT ready — Xcode 풀 설치 필요 (App Store ...)
- adb 미설치 — Android Studio 설치 + ANDROID_HOME export 필요
✔ web target ready (deps present)
✔ expo CLI available (pnpm start 가능, 폰의 Expo Go 로 QR 스캔)
✔ eas-cli installed (eas-cli/19.0.5 darwin-arm64 node-v22.22.1)
· 주의: 'eas-cli build --plaform' 은 오타. 정확한 옵션은 '--platform'
```

iOS sim / Android emul SKIP 은 현재 호스트의 환경 부재 (정상). 폰만 있으면 `pnpm start` → QR 스캔으로 Expo Go 에서 즉시 동작 가능 (README §1).

### 웹 번들 직접 검증
`pnpm web` 실행 결과:
```
Web Bundled 754ms node_modules/.../expo-router/entry.js (1060 modules)
LOG  [web] Logs will appear in the browser console
```
1060 모듈 번들 성공. 이전 에러 (`react-native-web missing`) 재현 안 됨.

## 사용자에게 보일 트러블슈팅 흐름

명령 실행 → 에러 발생 → 사용자는 [VNB4-Toeic-app/README.md §7 매트릭스](../../VNB4-Toeic-app/README.md#7-흔한-에러--조치-매트릭스) 에서 정확한 메시지로 lookup → 해당 행의 "조치" 칼럼에 명시된 명령/단계 실행.

추가로 [scenarios/19-app-platform-readiness.sh](scenarios/19-app-platform-readiness.sh) 는 호스트별 가능 플랫폼을 자동 점검:
```bash
cd VNB4-Toeic-ops/test && ./run-tests.sh 19
```
출력의 SKIP 메시지가 해당 플랫폼의 prereq 가이드를 그대로 알려줌.

## 재현

```bash
cd VNB4-Toeic-ops/test
./run-tests.sh 15            # Mode A (SQLite + app typecheck + expo CLI)
./run-tests.sh 19            # 플랫폼별 readiness 진단
./run-tests.sh               # 전체 19 시나리오
```
