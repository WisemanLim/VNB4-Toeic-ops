# Roadmap Status — PRD §9 대비

_Generated 2026-05-21. PRD §9 단계별 로드맵에 대한 현재 구현 상태 매핑._

## 요약

| 단계 | 상태 | 비고 |
|---|:---:|---|
| M0 셋업 | ✅ Done | Alembic → Prisma, FastAPI → NestJS 치환 |
| M1 데이터 | ⚠️ Partial | 15-20/part starter (목표 200/part), image_prompt/audio 시드 미생성 |
| M2 TTS | ✅ Done | Azure SDK + Piper OSS 폴백 + S3 업로드 동작 |
| M3 사용자 앱 MVP | ⚠️ Partial | 로그인/카드/TTS/진도 ✅, 레슨 커버·OAuth 콜백 미구현 |
| M4 관리자 | ⚠️ Partial | 단어 CRUD API ✅, edit UI/레슨 편집기/Directus 미연결 |
| M5 학습설계 | ⚠️ Partial | Curriculum 모델 + SM-2 SRS ✅, 시험일 일정 생성기 없음 |
| M6 운영화 | ⚠️ Partial | Tauri config ✅, 통계 stub, 모니터링/OTA 미배포 |

범례: ✅ 완료 · ⚠️ 부분구현 · ❌ 미착수

---

## M0 — 셋업

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 디렉토리 5종 골격 | ✅ | [VNB4-Toeic-app/](../VNB4-Toeic-app/), [VNB4-Toeic-frontend/](../VNB4-Toeic-frontend/), [VNB4-Toeic-backend/](../VNB4-Toeic-backend/), [VNB4-Toeic-database/](../VNB4-Toeic-database/), [VNB4-Toeic-ops/](../VNB4-Toeic-ops/) |
| docker-compose.local | ✅ | [VNB4-Toeic-ops/compose/docker-compose.local.yml](../VNB4-Toeic-ops/compose/docker-compose.local.yml) — Postgres+pgvector / Valkey / MinIO / Caddy |
| Alembic init | 🔁 대체 | **Prisma 5** 사용 ([schema.prisma](../VNB4-Toeic-database/prisma/schema.prisma)). 사유: TS 통일 (PRD §10 결정사항) |
| Next.js admin 골격 | ✅ | [VNB4-Toeic-frontend/web/app/](../VNB4-Toeic-frontend/web/app/) — layout / dashboard / words / login |
| Expo 골격 | ✅ | [VNB4-Toeic-app/app/](../VNB4-Toeic-app/app/) — _layout / index / login / learn/[lessonId] |

**판정: ✅ Done**

---

## M1 — 데이터

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 파트별 200단어 시드 × 7 | ⚠️ | [seeds/parts/part{1..7}.json](../VNB4-Toeic-database/seeds/parts/) — 현재 part당 12-15개 (총 ~100개) |
| IPA | ✅ | 모든 시드 항목 `ipa` 필드 작성 |
| 한글발음 | ✅ | 모든 시드 항목 `pron_ko` 필드 작성 |
| 예문 (en + ko) | ✅ | 대부분 작성 (Part 1-3 위주) |
| 그림 prompt | ❌ | `image_prompt` 필드 시드 데이터에 미작성 (스키마는 존재) |
| 시드 임포터 | ✅ | [seeds/run.ts](../VNB4-Toeic-database/seeds/run.ts) — upsert by id, audio asset 동시 import |

**갭**:
1. part당 200까지 약 185개 추가 큐레이션 필요
2. `image_prompt` 작성 (이미지 자동생성 파이프라인 연계 전제)

**판정: ⚠️ Partial** — 시드 파이프라인은 production-ready, 데이터 양만 부족

---

## M2 — TTS

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| en-US 배치 | ✅ | [worker/src/providers/azure.ts](../VNB4-Toeic-backend/worker/src/providers/azure.ts) — `en-US-EmmaNeural` default |
| en-GB 배치 | ✅ | `en-GB-LibbyNeural` |
| en-AU 배치 | ✅ | `en-AU-NatashaNeural` |
| OSS 폴백 | ✅ | [worker/src/providers/piper.ts](../VNB4-Toeic-backend/worker/src/providers/piper.ts) |
| CDN 업로드 | ✅ | [worker/src/providers/storage.ts](../VNB4-Toeic-backend/worker/src/providers/storage.ts) — S3/R2/MinIO 호환 |
| 큐 인입 API | ✅ | [api/src/modules/tts/tts.module.ts](../VNB4-Toeic-backend/api/src/modules/tts/tts.module.ts) `POST /tts/batch` |
| Worker 처리 | ✅ | [worker/src/jobs/tts.job.ts](../VNB4-Toeic-backend/worker/src/jobs/tts.job.ts) + BullMQ 재시도(3회/expo backoff) |
| AudioAsset upsert | ✅ | DB `unique(wordId, locale, provider)` |

**갭**:
- AWS Polly / Google TTS 어댑터 stub만 (`throw not implemented`)
- 멀티벤더 페일오버 로직 (PRD: Azure 메인 + Polly 백업) 미구현

**판정: ✅ Done** (메인 경로 완성. 백업 벤더는 운영 확장 시점)

---

## M3 — 사용자 앱 MVP

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 로그인 (Email) | ✅ | [app/login.tsx](../VNB4-Toeic-app/app/login.tsx) → `/auth/login/email` → SecureStore |
| 로그인 (OAuth) | ⚠️ | API 측 Google strategy ✅, 모바일 OAuth redirect handler 미구현 |
| 레슨 커버 화면 | ❌ | 홈 → 파트 → 레슨목록 화면 없음. 현재 `/learn/part-N` 라우트만 존재, 파트 내 레슨 선택 UI 없음 |
| 단어 카드 | ✅ | [app/learn/[lessonId].tsx](../VNB4-Toeic-app/app/learn/[lessonId].tsx) — word/IPA/pronKo/example |
| TTS 재생 | ✅ | `expo-av` Sound.createAsync, locale별 버튼 |
| 진도 저장 | ✅ | `POST /progress/grade` + SM-2 알고리즘 |
| 오프라인 24h 캐시 | ❌ | TanStack Query staleTime 30s만 설정. AsyncStorage persist 미설정 |
| 푸시 알림 | ❌ | expo-notifications 미통합 |

**갭**:
1. 레슨 목록/커버 페이지 — `app/learn/part-[part].tsx` 신규
2. OAuth 리다이렉트 (`expo-auth-session` 통합)
3. Query persist (`@tanstack/query-async-storage-persister`) for 오프라인

**판정: ⚠️ Partial** — 핵심 학습 루프 ✅, 진입/오프라인은 미흡

---

## M4 — 관리자

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 단어 CRUD API | ✅ | [api/src/modules/words/](../VNB4-Toeic-backend/api/src/modules/words/) — GET/POST/PATCH/DELETE + Roles 가드 |
| 단어 리스트 UI | ✅ | [web/app/words/page.tsx](../VNB4-Toeic-frontend/web/app/words/page.tsx) — 파트 필터 + 검색 |
| 단어 편집 UI | ❌ | 리스트만, 생성/편집/삭제 폼 없음 |
| 레슨 API | ✅ | [api/src/modules/lessons/lessons.module.ts](../VNB4-Toeic-backend/api/src/modules/lessons/lessons.module.ts) — list/get/create |
| 레슨 편집기 UI | ❌ | 페이지 자체 없음 |
| Directus 연결 | ❌ | docker compose에 directus service 없음. PRD §5.2.3 결정 보류 |
| 사용자 관리 UI | ❌ | API stub만 (`/users/me`), 어드민 사용자 리스트 없음 |
| TTS 배치 UI | ❌ | API endpoint ✅, 어드민 트리거 페이지 없음 |
| 통계 UI | ⚠️ | dashboard 카드 3개 (status/db/version)만 |

**갭**:
1. 단어 create/edit modal (`react-hook-form` + `zod` 이미 설치됨)
2. 레슨 편집기 (drag-reorder LessonWord 매핑)
3. TTS 배치 트리거 페이지
4. Directus 도입 여부 의사결정 → 도입 시 docker-compose에 추가 + 인증 sync

**판정: ⚠️ Partial** — API 70%, UI 20%

---

## M5 — 학습설계

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 커리큘럼 모델 | ✅ | Prisma `Curriculum` model (name/examDate/dailyTarget) |
| 커리큘럼 API | ❌ | Curriculum 모듈 미구현 (모델만 존재) |
| SRS 큐 | ✅ | `Progress` + SM-2 알고리즘 ([progress.module.ts](../VNB4-Toeic-backend/api/src/modules/progress/progress.module.ts)) |
| `GET /progress/due` | ✅ | dueAt ≤ now 정렬, limit 지원 |
| 시험일 기반 일정 | ❌ | 시험일 기준 역산해서 daily target 자동 분배 로직 없음 |
| 통계 endpoint | ⚠️ | `/progress/stats` 단순 state groupBy. retention curve 등 없음 |

**갭**:
1. `CurriculumModule` 신규 (CRUD + 시험일 D-day 계산)
2. 일별 학습 계획 생성기 (totalWords / daysUntilExam / dailyTarget)
3. 통계 — 정답률 추이, 학습 시간 누적

**판정: ⚠️ Partial** — SRS 코어 ✅, 일정 자동화 미착수

---

## M6 — 운영화

| 산출물 | 상태 | 위치 / 근거 |
|---|:---:|---|
| 통계 (집계/대시) | ⚠️ | dashboard 카드 3개 (health). 학습 KPI 집계 없음 |
| 모니터링 (Prometheus/Grafana/Loki) | ❌ | compose stack 미작성. README에 TBD 명시 |
| Sentry 통합 | ❌ | DSN 환경변수 자리 있음, SDK 미설치 |
| OTA (EAS Update) | ❌ | Expo 프로젝트 설정만, EAS workflow 없음 |
| 데스크탑 Tauri 빌드 | ✅ | [VNB4-Toeic-frontend/desktop/](../VNB4-Toeic-frontend/desktop/) — Cargo.toml + tauri.conf + main.rs |
| 데스크탑 릴리스 자동화 | ❌ | GH release workflow 없음 |

**갭**:
1. `ops/compose/docker-compose.observability.yml` (Prometheus + Grafana + Loki)
2. API/Worker `@nestjs/terminus` + `prom-client` metrics endpoint
3. `@sentry/node` (api/worker) + `@sentry/react-native` (app)
4. `eas.json` + `expo-updates` 채널 설정
5. Tauri release workflow (.github/workflows/desktop-release.yml)

**판정: ⚠️ Partial** — Tauri만 ✅

---

## 우선순위 추천 (next sprint)

| 우선순위 | 항목 | 단계 | 가치 |
|:---:|---|:---:|---|
| 🔴 P0 | part1~7 시드 200개 채우기 | M1 | 데이터 부족하면 다른 기능 검증 불가 |
| 🔴 P0 | 레슨 커버/리스트 화면 (app) | M3 | 사용자 진입 동선 단절 |
| 🟡 P1 | 단어 edit/create form (web) | M4 | 어드민이 데이터 큐레이션 가능해짐 |
| 🟡 P1 | 오프라인 캐시 (TanStack persist) | M3 | PRD §7 비기능요건 |
| 🟢 P2 | CurriculumModule + 시험일 D-day | M5 | 차별화 기능 |
| 🟢 P2 | observability stack | M6 | 운영 시작 전 필수 |

---

## 미결 의사결정 (PRD §10) 매핑

| 항목 | PRD 후보 | 본 구현 채택 | 사유 |
|---|---|---|---|
| 모바일 프레임워크 | RN+Expo vs Flutter | **RN+Expo** | TS 통일 (사용자 요구) |
| 백엔드 언어 | FastAPI vs NestJS | **NestJS** | TS 통일 (사용자 요구) |
| 인증 | Supabase vs Authentik | **자체 (Passport+JWT)** | OAuth provider lazy-init, vendor lock-in 회피 |
| TTS 운영 | Azure / Polly / 듀얼 | **Azure 메인 + Piper OSS 폴백** | Polly 어댑터는 stub, 운영 확장 시 추가 |
| CMS 도입 | Directus / Next 단일 | **미결 (Next 단일 진행 중)** | Directus는 BSL 우려 + 자체 폼으로 충분히 커버 가능성 |
| 데스크탑 | Tauri vs Electron | **Tauri** | PRD 1순위 일치 (경량/보안) |
