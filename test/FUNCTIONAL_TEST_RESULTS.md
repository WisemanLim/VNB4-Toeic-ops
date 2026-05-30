# VNB4 TOEIC · 기능 시험 결과 (시뮬레이터/브라우저)

_2026-05-30 · 실기기/시뮬레이터/브라우저 기반 end-to-end 기능 시험 + 발견 오류 수정 + 재시험._

정적 하니스(`run-tests.sh`)는 구조/통합 검증용. 이 문서는 **실제 구동 기능** 시험 기록.

> **2차 (2026-05-30)** — Hackers TOEIC 800 PDF 반영: 단어 1908→**3686**(중복 dedupe), 신규 **문장쓰기(단어 고르기)·쉐도잉** 기능(Part 1–4, **198문항**) 추가.
>
> **4차 (2026-05-30)** — **로그인/인증 + 게스트·로그인 데이터 동기화**: 프론트 admin 로그인 가드+회원가입, 앱 게스트(오프라인 mock)/로그인(서버 sync) 런타임 전환, 서버 `/me/analysis`(LC/RC 실분석).
>
> **5차 (2026-05-30)** — **홈 중복 제거 + 파트 카드 전체 단어**: 홈 레슨 리스트(LC/RC 카드와 중복) 제거, 파트 카드 진입 시 `lesson not found` 오류 수정 → `/words` 페이지네이션으로 **파트 전체 단어**(예: P1 337개) 로드. 오프라인(게스트)도 전체 단어 지원.
>
> **6차 (2026-05-30)** — **pos 파싱 크래시 수정 + 데이터 정규화**: 로그인(서버) 학습 시 `pos` 값이 enum 밖(`modal`/`prep`/`adj` 등)이라 `WordListSchema` 파싱 throw → iOS 학습 화면 오류(`invalid_enum_value`). 앱 `pos`를 자유 문자열로 관용화 + DB/번들 pos 정규화.
>
> **7차 (2026-05-30)** — **도넛 일관성 + 학습 이미지**: 게스트 도넛이 `tested:false`인데 가짜 4세그먼트 표시(모순) → 빈 회색 트랙으로 변경. 서버 분석은 오답만 → 한 영역만 학습 시 단색 풀링 → **LC/RC 정답·오답 4분할**. 로그인(서버) 단어 `imageUrl=null` → 학습 카드 이미지 미표시 → picsum 폴백 추가(android·ios 공통). 아래 표는 최신 결과.

## 요약

| 영역 | 타겟 | 결과 | 비고 |
|---|---|---|---|
| App | iOS 시뮬레이터 (Expo Go) | ✅ PASS | 게스트 도넛 **빈 회색**(가짜 세그먼트 제거) + 학습 P1 1/337, metro 에러 0 |
| App | Android 에뮬레이터 (네이티브 dev build) | ✅ PASS | 로그인 도넛 **4분할(LC/RC 정답·오답)** + 학습 카드 **이미지(picsum 폴백) 표시**, JS 에러 0 |
| App | Web (expo web, react-native-web) | ✅ PASS | 로그인 도넛 **4분할** + 학습 카드 **이미지 표시**, 게스트 도넛 빈 회색, 콘솔 에러 0 |
| Admin | backend API (NestJS, :4000) | ✅ PASS | auth(signup/login/me) + **/me/analysis(LC/RC 실분석)** + sentences/users/tts + cursor/part 검증, JWT 부트 버그 수정 |
| Admin | frontend (Next.js admin, :3000) | ✅ PASS | **로그인 가드(미인증→/login) + 회원가입** + 대시보드/단어/문장/레슨/사용자/TTS, 라우트 200 |

## 환경

- iOS: iPhone 17 Pro 시뮬레이터 + Expo Go (SDK 51). 경로 괄호로 로컬 네이티브 빌드 불가 → Expo Go 사용.
- Android: AVD `Medium_Phone`, `pnpm android` 자동 부팅 + 네이티브 dev build (react-native-svg 포함).
- Web: `expo start --web` :8082, gstack browse(headless Chromium).
- Admin: docker compose 로컬 스택(postgres/valkey/minio/caddy) + backend·frontend 로컬 dev. browse로 시험.
- 데이터: `EXPO_PUBLIC_USE_MOCK=1`(app 오프라인 시드 3686단어+198문장), postgres 시드 3686단어+198문장.

## 발견 오류 → 수정 → 재시험

### 1차 (초기 end-to-end)

| # | 영역 | 오류 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 1 | database | `pnpm seed` 실패 `Unique constraint (part,word)` P2002 | 시드 JSON에 중복 (part,word) 24건 + upsert가 id 기준 | `seeds/run.ts` 에 (part,word) dedupe (첫 항목 유지) | seed upsert / skip, exit 0 |
| 2 | app | 앱 오프라인 시드에도 동일 중복 | `gen-seed.mjs` dedupe 없음 | gen-seed.mjs (part,word) dedupe | `assets/seed/words.json` |
| 3 | ops/test | 정적 하니스 6 FAIL | 리팩토링(src/core, hooks) + 시드수 변경 미반영 | 01/07 `src/api`→`src/core`, 06 expo-av/grade→hooks, 10/15/16 카운트 동적계산 | 재실행 PASS |
| 4 | frontend | admin `/words` 호출 404 → 단어표 무한 Loading | `lib/api.ts` 가 `${BASE}/v1` (←`/api` 누락) | `${BASE}/api/v1` + BASE 기본값 origin (app client 규약과 일치) | `/api/v1/words` 200, 단어표 렌더 |
| 5 | backend | admin 대시보드 카운트 전부 0, `/words/stats` 404 | 백엔드에 `/words/stats` 라우트 부재 | `WordsService.stats()` + `@Get("stats")` (`:id` 앞 선언) 추가 | `{total, byPart{...}}`, 대시보드 카운트 표시 |

### 2차 (Hackers 800 PDF 반영 · 문장쓰기 추가)

| # | 영역 | 오류/이슈 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 6 | database | PDF 단어 병합 시 중복 222건 | part+lower(word) 키 기준 기존 시드와 겹침 | `merge-vocab.mjs` 에 part+lower(word) dedupe → +1778 신규만 추가 | parts JSON 3686, 중복 0 |
| 7 | database | seed P1001 (postgres 도달 불가) | docker compose 스택 중지됨 | `docker compose up -d` 재기동 + pg_isready 대기 | seed exit 0 (3686단어+198문장) |
| 8 | backend | EADDRINUSE :4000 | 이전 인스턴스/watcher 점유 | `lsof -ti :4000 \| xargs kill -9` | 신규 빌드 구동, sentences 라우트 200 |

### 3차 (코드리뷰 위험 수정 보완)

| # | 영역 | 위험 | 수정 | 재시험 |
|---|---|---|---|---|
| 9 | database | 문장 seeding id-upsert만, dedupe Set 없음 → 중복 id 조용히 덮어쓰기 | `run.ts` 문장 루프에 `sSeen` Set dedupe(단어 루프와 대칭) | seed `198 upserted, skipped dup id: 0` |
| 10 | app | TTS `play()` fire-and-forget → 오프라인 시 unhandled rejection | `write/[part].tsx` `speak()` async wrapper(try/catch) | tsc 0, 탭 시 throw 없음 |
| 11 | backend | sentences `cursor` 미검증 → 미존재 id 시 prisma 500; PART_MAP 1–7 vs DTO @Max(4) 데드코드 | service에 cursor 존재검증(`BadRequestException`) + PART_MAP 1–4로 축소 | `cursor=NOPE`→400 "invalid cursor", `part=5`→400, 유효 cursor 페이지네이션 정상 |
| 12 | ops | scenario 10 문장 rowcount `log_info`(soft) + raw length 기대 | 기대값=고유 id 수, `log_fail`로 승격 + `>0` 하한 | scenario 10 PASS(8 단언) |
| 13 | frontend | 문장 admin 페이지 부재 | `app/sentences/page.tsx` 신규(KPI+표+파트필터) + sidebar nav | `web:build` ✓ `/sentences` 1.54kB, 라우트 200, 렌더 확인 |

### 7차 (도넛 일관성 + 학습 이미지)

| # | 영역 | 오류/이슈 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 23 | app | 게스트 도넛이 android·ios 상이/오류처럼 보임 | 게스트 mock이 `tested:false`인데 가짜 4세그먼트 제공 → 컬러 도넛(모순). 로그인은 오답만 → 단색 풀링 | mock `segments:[]`(빈 회색 트랙) + 서버 분석을 **LC/RC 정답·오답 4분할**(`me.module.ts`) | 게스트=빈 회색, 로그인=4색 (web/android 확인) |
| 24 | app | 로그인 시 학습 카드 단어 **이미지 미표시**(android·ios) | 서버 단어 `imageUrl=null`(시드 이미지 없음), 카드가 `imageUrl` 있을 때만 렌더 | 학습 카드 `wordImage()` picsum 폴백(mock과 동일 스킴) | web/android 로그인 카드 이미지 표시 |

### 6차 (pos 파싱 크래시 + 데이터 정규화)

| # | 영역 | 오류/이슈 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 21 | app | 로그인 후 파트 학습 시 **`invalid_enum_value` 크래시**(iOS ErrorView) | 서버 단어 `pos`가 `PosSchema` enum 밖(`modal`,`prep`,`adj`,`adv`,`conj`,`det`,`place`,`time`,`abbr`,`wh-word`) → `WordListSchema.parse` throw | `WordSchema.pos`를 `z.string().nullish()`로 관용화 + 학습화면 라벨맵(축약/oddball→한글, 미매핑→원문) | iOS/web/android 파트학습 1/337 정상 |
| 22 | database | pos 값 비표준·불일치(`prep` vs `preposition` 등) | Hackers 추출 데이터 축약/오타 | `run.ts`·`gen-seed.mjs`에 `POS_CANON` 정규화(prep→preposition, adj→adjective, adv→adverb, conj→conjunction, det→determiner, wh-word→pronoun, place/time→noun, abbr→abbreviation) | PG/sqlite/번들 재시드, API pos 정규화 확인(축약 0) |

### 5차 (홈 중복 제거 + 파트 카드 전체 단어)

| # | 영역 | 오류/이슈 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 18 | app | 홈에 **레슨 리스트**(Part 1~7)와 LC/RC 카드 그리드가 **중복** | 4차에서 `useLessons` 레슨 섹션 추가 → 파트 카드와 의미 중복 | 홈 레슨 리스트 섹션 제거(LC/RC 카드 + 문장쓰기만 유지) | web/android/ios 홈에 레슨 섹션 없음 |
| 19 | app | 파트 카드 진입 시 **`문제가 발생했습니다 / lesson not found`** | `/learn/part-N` → 로그인 시 서버 `/lessons/part-N` 조회(서버 레슨 id는 `lesson-pN`) → 404 | `useLearnQueue` 의 `part-N` 분기를 `/words?part=N` **페이지네이션**(limit 100, cursor)으로 변경 — 게스트 mock + 로그인 서버 공통 | web/android/ios 파트 진입 = 정상 학습 |
| 20 | app | 오프라인/초기 배포 시 단어 **20개 제한** 인상 | 레슨(starter 20단어)만 노출 | 파트 카드 = 해당 파트 **전체 단어** 로드 + `mock /words` 가 번들 전체 제공 | guest/authed 모두 P1=337 (20 아님) |

### 4차 (로그인/인증 + 게스트·로그인 동기화)

| # | 영역 | 오류/이슈 | 원인 | 수정 | 재시험 |
|---|---|---|---|---|---|
| 14 | backend | 인증 라우트 전부 401 (토큰 정상인데) | `JwtModule.register` 가 import 시점에 `process.env.JWT_SECRET` 평가 → fallback 서명, strategy(DI 시점)는 실시크릿 검증 → 불일치 | `registerAsync({useFactory})` 로 전환(양쪽 DI 시점 동일 시크릿) | login→/me→/users→/tts 200, 무토큰 401 |
| 15 | app(web) | 웹에서 부팅 시 무한 로딩 | `expo-secure-store` 가 web 미지원 → `loadToken()` throw | `tokenStore` 플랫폼 분기(web=localStorage, native=SecureStore) | 웹 게스트/로그인 정상 |
| 16 | app | 로그인 직후 데이터가 mock(예: learn 1/337) | 비동기 auth 부팅 전에 쿼리가 먼저 발사돼 `authed=false`로 mock 사용 (race) | `AuthProvider` 가 `status="loading"` 동안 트리 게이트 | 로그인 후 learn 1/20·write 20 (서버) |
| 17 | app | 로그인 시 레슨/문장 미표시 | 서버 `part`="P1"(enum 문자열)·nullable 필드·`orderIndex` ↔ 앱 스키마(number·non-null·`order`) 불일치 → Zod parse 실패 | WordSchema/SentenceItemSchema 서버 관용화(part 코어션, `.nullish()`, order/orderIndex) | 로그인 홈 레슨 7·learn·write 정상 |

## 시험 상세

### 도넛 일관성 + 학습 이미지 (7차)
- **iOS**: 게스트 홈 도넛 = 빈 회색 트랙 + "분석결과는 테스트 완료 후 확인 가능" (이전 단색 풀링/가짜 세그먼트 해소).
- **Web**: 로그인(admin, LC/RC 정답·오답 grade 후) 홈 도넛 = 4색 세그먼트(LC 오답 red / LC 정답 green / RC 오답 orange / RC 정답 blue) + 범례 일치. `/learn/part-1` adjust 카드 = picsum 폴백 이미지 표시.
- **Android**: 로그인 홈 도넛 4분할(범례 LC/RC 정답·오답) + Part 1 학습 카드 이미지 표시.
- **백엔드**: `/me/analysis` 4분할 세그먼트 확인(`["LC 오답:1","LC 정답:1","RC 오답:1","RC 정답:1"]`).

### pos 크래시 + 정규화 (6차)
- **데이터**: API `/words` 전수 집계 — pos 19종(verb/noun/preposition/adjective/modal/adverb/phrase/abbreviation/determiner/conjunction/pronoun/null) **축약·오타 0** (이전 prep/adj/adv/conj/det/place/time/wh-word 제거). 번들 `words.json`도 동일.
- **iOS**: 로그인 상태 `/--/learn/part-1` → `1 / 337`(adjust 동사) 정상, `invalid_enum_value` 오류 화면 해소.
- **Web**: 게스트·로그인(admin) 모두 `/learn/part-1` = `1 / 337`, 콘솔 enum/zod 에러 0.
- **Android**: Part 1 카드 탭 → `1 / 337`(명사), logcat enum/zod 에러 0.
- **Admin/backend/ops**: 로그인 가드 통과 후 `/words` 20행 렌더, `/words/stats` total 3686, ops 하니스 scenario 10 PASS.

### 홈 중복 제거 + 파트 카드 전체 단어 (5차)
- **백엔드**: `/words?part=1&limit=100` cursor 페이지네이션 → 4페이지 누적 337개, `/words/stats` P1=337 일치.
- **Web**: 홈에 레슨 섹션 없음(LC/RC + 문장쓰기만). 게스트 `/learn/part-1` = `1 / 337`(mock), 로그인(admin) `/learn/part-1` = `1 / 337`(server, lesson-not-found 없음). 콘솔 에러 0(HMR ws 경고만).
- **Android**: 게스트 홈 레슨 섹션 없음 + Part 1 카드 탭 → `1 / 337`(mock, pavement). lesson-not-found 해소.
- **iOS**: 인증 홈 레슨 섹션 없음 + `/--/learn/part-1` 딥링크 → `1 / 337`(server, adjust). 정상.

### 로그인·인증 + 게스트/서버 동기화 (4차)
- **백엔드 계약 (curl)**: 신규 가입 → 토큰 → `/users/me`·`/me/analysis`(미학습 tested:false)·`/lessons`(7)·`/sentences?part=1`(20) 200; 단어 2개 grade 후 `/me/analysis` → tested:true, detail `lc:{correct,wrong}` 갱신; `/progress/stats` 반영. 무토큰 `/users` 401.
- **Web (전 흐름)**: 게스트 홈=mock(레슨 7·도넛 미테스트 안내) → `/login` admin 로그인 → 인증 홈(관리자/로그아웃, 서버 분석 LC) → `/learn/lesson-p1` 서버 20단어 → `/write/1` 서버 20문항 → 회원가입(신규 유저) → 인증 홈. 콘솔 에러 0.
- **Android (인터랙티브)**: 게스트 홈(mock) → 로그인 탭 → 이메일/비번 입력(adb) → 인증 홈(서버 분석 LC, 복습 0). 네이티브 SecureStore 토큰 영속. logcat JS 에러 0.
- **iOS**: 게스트 홈 + 로그인 화면 렌더(deep-link `/--/login`). metro 에러 0. (tap 자동화는 idb 미설치로 미수행 — 로그인 왕복은 Android·Web에서 검증.)
- **Admin (frontend)**: Shell 가드 — 미인증 접근 시 `/login` 리다이렉트, `/auth/me` 검증 후 진입. `/register` 신규.

### App — iOS (Expo Go)
- 홈: 취약유형결과 도넛(0점/목표 900점, LC·RC·프리미엄 범례), 복습 카드, LC·듣기/RC·독해 그리드, **문장쓰기·쉐도잉** 섹션(Part 1–4 카드) 렌더.
- 학습카드(`/learn/part-1`): 이미지/POS/단어/IPA·한글발음/로케일 칩/툴바. 실시드 데이터.
- **문장쓰기**(`/write/1`): `1 / 20 · Part 1`, 한글힌트("그녀는 식료품 제품을 살펴보고 있다."), prompt(`She's ____.`), 단어칩(a/item/grocery/vehicle/examining/construction/arm), 확인 버튼 렌더. 1423 모듈 번들, metro 에러 0.
- 로그인: 이메일/비밀번호/로그인 버튼 렌더.

### App — Android (네이티브)
- `pnpm android`: 에뮬레이터 자동 부팅 → BUILD SUCCESSFUL → 설치/구동.
- 홈 도넛(react-native-svg) 네이티브 렌더 확인.
- SRS 루프: 복습 시작 → 탭 reveal(뜻 + 예문 EN/KO) → 다음(grade) → 진행. 정상.
- **문장쓰기 풀 인터랙션**: 홈→문장쓰기 Part1→`1/20`→단어칩 순서대로 골라 "examining a grocery item" 완성→확인→`정답! ✓` + fullSentence + 🔊 + `🎧 듣고 따라 말하기(쉐도잉)`→다음→`2/20`. JS 에러 0.
- logcat FATAL/JS 에러 0.

### App — Web
- `expo start --web` → home 렌더(도넛 svg, LC/RC 컬러카드, 문장쓰기 섹션).
- Part 1 클릭 → 학습카드 reveal. **문장쓰기**: 단어 골라 완성→확인→`정답! ✓`. 콘솔 비-200 0 (RN-web `shadow*`/`pointerEvents` deprecation warning만).

### Admin — backend (NestJS :4000)
- `/api/v1/health` → `{status:ok, db:up}`. `/docs` 200 (Swagger).
- 라우트: auth/users/words/lessons/progress/tts/**sentences** (app 계약과 일치).
- `/api/v1/words` → 3686 시드 서빙. `/api/v1/words/stats` → `{total:3686, byPart}`.
- `/api/v1/sentences?part=1` → 문항 서빙. `/api/v1/sentences/stats` → `{total:198, byPart{P1:20,P2:36,P3:69,P4:73}}`.

### Admin — frontend (Next.js :3000)
- 대시보드: 총 단어 3686, API ok/DB up, 파트별 카운트, 최근 로그인 표.
- 단어 관리: 백엔드 데이터 표 렌더(ID/Part/Word/의미/IPA/한글발음), 파트 필터 동작.
- **문장쓰기·쉐도잉**(`/sentences`): KPI 카드(총 198 + Part1~4) + 표(ID/Part/Day/문제/정답/전체문장/번역) + 파트 필터. `/sentences/stats` + `/sentences?limit=200` 호출. 라우트 200, nav 활성.
- 비-200/콘솔 에러 0.

## 재현 방법

```bash
# 인프라 (postgres/valkey/minio/caddy)
cd VNB4-Toeic-ops/compose && docker compose -f docker-compose.local.yml up -d
# DB 시드
cd ../../VNB4-Toeic-database && pnpm seed:prod        # postgres (또는 pnpm seed = sqlite)
# backend
cd ../VNB4-Toeic-backend/api && pnpm build && node dist/main      # :4000
# frontend admin
cd ../../VNB4-Toeic-frontend && pnpm web:dev                       # :3000
# app
cd /path/to/VNB4-Toeic-app && EXPO_PUBLIC_USE_MOCK=1 pnpm android  # 또는 ios / ios:go / web
# 정적 하니스
cd VNB4-Toeic-ops/test && API_URL=http://localhost:4000 ./run-tests.sh
```
