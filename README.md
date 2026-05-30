# Vocabulary-NB4-TOEIC (Ops 메타 repo)

> 🌐 **언어 / Language**: **한국어** · [English](README.en.md)

TOEIC 파트별 단어암기 학습 플랫폼. **5개 컴포넌트 polyrepo** 구조이며 본 `VNB4-Toeic-ops` 가 워크스페이스 메타 관리 + 운영 인프라(Docker Compose / Caddy / CI / 환경설정 / 시스템시험)를 담당.

---

## 0. 워크스페이스 구성

### 0.1 컴포넌트 (디스크 레이아웃)

| Component | Path | Role |
|---|---|---|
| `VNB4-Toeic-app`      | `/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app` | 모바일 학습 앱 (iOS/Android/Web) |
| `VNB4-Toeic-frontend` | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-frontend` | 관리자 Web + Desktop |
| `VNB4-Toeic-backend`  | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-backend`  | HTTP API + Worker (큐) |
| `VNB4-Toeic-database` | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-database` | Prisma 스키마 + 마이그레이션 + 시드 |
| `VNB4-Toeic-ops`      | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-ops`      | Compose / Caddy / Env / CI / 시험 |

App 외 4 컴포넌트는 동일 부모(`Web(Node,Script)/`)에 위치. Compose bind mount + 상대경로 심볼릭 의존을 위해 형제 디렉토리 구조 유지 필수.

### 0.2 컴포넌트별 소프트웨어 스택

| Component | 주요 스택 | Lang | 패키지매니저 |
|---|---|---|---|
| `app`      | React Native 0.74, Expo SDK 51, Expo Router 3, TanStack Query 5, Zustand, NativeWind, expo-av, expo-secure-store | TypeScript | pnpm |
| `frontend/web`     | Next.js 14 (App Router), shadcn/ui (Radix + Tailwind), TanStack Query, Zustand | TypeScript | pnpm |
| `frontend/desktop` | Tauri 2 (Rust shell + Web view) — `web/out` 래핑 | TypeScript + Rust | pnpm |
| `backend/api`      | NestJS 10, Prisma 5, Swagger(OpenAPI), Passport(JWT/OAuth), Argon2 | TypeScript | pnpm |
| `backend/worker`   | BullMQ, Azure Speech SDK / AWS Polly / Piper TTS | TypeScript | pnpm |
| `database`         | PostgreSQL 16 + pgvector / SQLite (local), Prisma 5 | TypeScript | pnpm |
| `ops`              | Docker Compose v2, Caddy 2 (Apache-2.0), Valkey 8 (BSD-3, Redis 호환), MinIO, GitHub Actions | YAML + shell | — |

### 0.3 언어 통일 정책

PRD 권장 FastAPI(Python) 대신 **app 외 전 컴포넌트 TypeScript** 단일화 (NestJS + Prisma + BullMQ). 근거: 유지보수성 + 풀스택 인력 공유.

상세 라이선스 검토: [LICENSES.md](./LICENSES.md). 사용된 모든 AGPL/BSL 컴포넌트는 *unmodified container* → 재배포 트리거 없음.

---

## 1. 필수 사전 요구사항

### 1.1 공통

| 요구 | 버전 | 확인 |
|---|---|---|
| Node.js | 20.x LTS 이상 | `node -v` |
| pnpm | 10.x 이상 (workspace 전 컴포넌트) | `pnpm -v` |
| Git | 최신 | `git --version` |

### 1.2 Docker 사용 시 (mode B/C)

| 요구 | 버전 | 확인 |
|---|---|---|
| Docker Engine | 24+ | `docker -v` |
| Docker Compose | v2 (`docker compose`) | `docker compose version` |

### 1.3 모바일 (mode 별 추가)

| 대상 | 필요 |
|---|---|
| Expo Go (실기기) | Expo Go 앱 설치된 폰 + 같은 Wi-Fi |
| iOS 시뮬레이터 | Xcode **풀 설치** (CLT 만으론 불가) |
| Android 에뮬레이터 | Android Studio + AVD + JDK 17 |
| EAS Build (cloud) | Expo 계정 + `npx eas-cli login` |

상세: [VNB4-Toeic-app/README.md](../../Apps(Android,iOS,...)/VNB4-Toeic-app/README.md).

### 1.4 Desktop (Tauri)

Rust toolchain (`rustup default stable`) + 플랫폼 빌드 종속성 (macOS: Xcode CLT, Linux: webkit2gtk, Windows: WebView2).

### 1.5 pnpm 빌드 스크립트 정책

4 컴포넌트의 `pnpm-workspace.yaml` 에 `dangerouslyAllowAllBuilds: true` 설정 (pnpm 11 strict 차단 우회).
- 허용 근거: 사용 패키지 OSS, 빌드 스크립트 검증 완료.
- **금지**: `pnpm approve-builds` 인터랙티브 명령. yaml 에 잘못된 `allowBuilds:` placeholder 작성하여 install 깨짐.
- 새로 깨졌으면 `allowBuilds:` 블록 수동 제거 → `rm -rf node_modules && pnpm install` 재실행.

---

## 2. 전체 흐름 (요청 → 처리)

```
[모바일 앱 / Admin Web]
         │  HTTPS
         ▼
       Caddy (80/443, auto-HTTPS in prod)
         │
   ┌─────┴─────┐
   ▼           ▼
 NestJS API   Next.js Web
  (:4000)     (:3000)
   │  │
   │  └────► BullMQ ────► Worker (TTS / 시드 임포트)
   │                        │
   │                        ▼
   │                     Azure / AWS / Piper TTS
   ▼
 PostgreSQL 16 + pgvector   Valkey 8 (queue/cache)   MinIO / S3 / R2 (오디오·이미지)
```

- API 는 Prisma client 로 DB 접근. 비동기 작업(TTS 합성, 시드 대량 임포트)은 BullMQ 로 Worker에 위임.
- 정적 오디오/이미지는 S3 호환 스토리지(MinIO/AWS S3/Cloudflare R2)에 저장 → CDN/Caddy `/media/*` 로 서빙.

---

## 3. 실행 모드 — 3 종

| Mode | DB | 인프라 | 사용 시점 |
|---|---|---|---|
| **A. Local SQLite (no Docker)** | SQLite `prisma/dev.db` | 없음 | DB 스키마/시드 빠른 검증, 오프라인 |
| **B. Local Docker Compose** | PostgreSQL 16 + pgvector | Valkey + MinIO + Caddy | 전체 스택 로컬 테스트 |
| **C. Prod Docker Compose** | self-hosted Postgres (기본) 또는 외부 관리형 (옵션) | api/worker/web 빌드 이미지 + Valkey + Caddy | 운영 배포 |

> **DB 위치 기본값**
> - mode A: 로컬 파일 (SQLite, Docker 불필요)
> - mode B: docker-compose 내부 postgres 컨테이너
> - mode C: 기본은 docker-compose 내부 postgres (self-hosted). 외부 관리형(RDS/Supabase/Neon)은 환경설정값(`DATABASE_URL`) 만 교체하면 동일 compose 재사용.

---

## 4. Mode A — Local SQLite (개별 실행)

Docker 불필요. database 컴포넌트만 SQLite 로 띄움. 다른 컴포넌트는 각자 dev 서버 직접 기동.

### 4.1 DB (SQLite)

```bash
cd VNB4-Toeic-database
pnpm install
pnpm migrate:local    # .env.local 자동생성 + prisma db push (SQLite)
pnpm seed             # seeds/parts/*.json → SQLite upsert (≈96 단어)
pnpm studio           # Prisma Studio (SQLite)
```

스크립트는 `prisma/schema.local.prisma` 사용. SQLite 제약상 배열 필드는 JSON 문자열, enum 은 String 저장.

### 4.2 Backend (NestJS API + Worker)

```bash
cd VNB4-Toeic-backend
pnpm install
# API
cd api && pnpm start:dev          # http://localhost:4000  (Swagger /docs)
# Worker (별도 터미널)
cd ../worker && pnpm start:dev
```

API `DATABASE_URL` 은 database `.env.local` 의 SQLite 경로를 그대로 가리키도록 설정(또는 `file:../../VNB4-Toeic-database/prisma/dev.db`).

> 큐(BullMQ)는 Valkey/Redis 필요. mode A 에서 Worker 까지 띄우려면 로컬 brew/Docker 로 Redis 또는 Valkey 1개 실행 (`brew install valkey && valkey-server` 또는 `docker run -p 6379:6379 valkey/valkey:8-alpine`).
> Worker 가 필요없으면 API 만으로도 단어/학습 CRUD 기본 동작.

### 4.3 Frontend (Next.js)

```bash
cd VNB4-Toeic-frontend
pnpm install
pnpm web:dev          # http://localhost:3000
# Desktop (Tauri, Rust toolchain 필요)
pnpm desktop:dev
```

`web/.env.local` 또는 환경변수: `NEXT_PUBLIC_API_URL=http://localhost:4000`.

### 4.4 모바일 앱

```bash
cd /Users/wise/Developer/Apps\(Android,iOS,...\)/VNB4-Toeic-app
pnpm install
pnpm start            # QR → Expo Go (실기기 권장)
pnpm ios              # iOS 시뮬레이터 (Xcode 풀 설치 필요)
pnpm android          # Android 에뮬레이터 (AVD 실행 중)
pnpm web              # http://localhost:8081 (브라우저)
```

`app.json` → `expo.extra.apiUrl` 또는 `EXPO_PUBLIC_API_URL` 환경변수로 백엔드 URL 지정.

---

## 5. Mode B — Local Docker Compose (전체 스택)

`compose/docker-compose.local.yml` 는 **인프라(postgres + valkey + minio + caddy)** 만 컨테이너로 실행하고, app/api/worker/web 은 호스트에서 dev 서버로 띄우는 하이브리드 구성. 핫리로드 + 디버깅 친화.

### 5.1 인프라 기동

```bash
cd VNB4-Toeic-ops/compose
docker compose -f docker-compose.local.yml up -d
docker compose -f docker-compose.local.yml ps
```

기동되는 서비스:

| 서비스 | 이미지 | 포트 | 비고 |
|---|---|---|---|
| postgres | `pgvector/pgvector:pg16` | 5432 | `toeic`/`toeic`, db `toeic_local`, 초기화 SQL `VNB4-Toeic-database/local/init.sql` |
| valkey | `valkey/valkey:8-alpine` | 6379 | BSD-3 Redis 호환 fork |
| minio | `quay.io/minio/minio` | 9000 (S3), 9001 (콘솔) | `minioadmin`/`minioadmin`, 버킷 `toeic-media` 자동 생성 |
| caddy | `caddy:2-alpine` | 80 | `Caddyfile.local` 사용 |

### 5.2 DB 마이그레이션 + 시드 (PostgreSQL)

```bash
cd ../../VNB4-Toeic-database
pnpm install
pnpm env:init:prod          # .env 생성 (PostgreSQL용)
pnpm migrate:dev            # prisma migrate dev — TTY 필요 (마이그레이션 이름 입력)
pnpm seed:prod              # seeds/parts/*.json → PostgreSQL upsert
```

`.env` 의 `DATABASE_URL` 은 `postgres://toeic:toeic@localhost:5432/toeic_local`.

### 5.3 앱 서비스 기동 (별도 터미널)

```bash
# API (NestJS)
cd VNB4-Toeic-backend && pnpm install
cd api && pnpm start:dev                          # :4000

# Worker (BullMQ)
cd VNB4-Toeic-backend/worker && pnpm start:dev

# Admin Web (Next.js)
cd VNB4-Toeic-frontend && pnpm install && pnpm web:dev   # :3000

# Mobile App (Expo)
cd /Users/wise/Developer/Apps\(Android,iOS,...\)/VNB4-Toeic-app && pnpm install && pnpm start
```

호스트의 API/Web 은 Caddy 가 `host.docker.internal` 로 reverse-proxy 함 (Caddyfile.local 참조).

### 5.4 엔드포인트

| URL | 대상 |
|---|---|
| `http://localhost/` | Caddy → Next.js (:3000) |
| `http://localhost/api/*` | Caddy → NestJS API (:4000) |
| `http://localhost/api/docs` | Swagger UI |
| `http://localhost/media/*` | Caddy → MinIO (`toeic-media`) |
| `http://localhost:9001` | MinIO 콘솔 (`minioadmin`/`minioadmin`) |
| `localhost:5432` | PostgreSQL (`toeic`/`toeic`/`toeic_local`) |
| `localhost:6379` | Valkey |

### 5.5 정지

```bash
docker compose -f docker-compose.local.yml down       # 컨테이너만
docker compose -f docker-compose.local.yml down -v    # 볼륨까지 (DB 영구 삭제)
```

---

## 6. Mode C — Prod Docker Compose

`compose/docker-compose.prod.yml` 은 **api / worker / web 컨테이너 이미지 + postgres(self-hosted) + valkey + caddy(auto-HTTPS)** 풀스택 구성.

이미지는 CI에서 `${REGISTRY}/vnb4-{api,worker,web}:${TAG}` 로 빌드/푸시.

### 6.1 Self-hosted Postgres (기본)

`docker-compose.prod.yml` 의 `postgres` 서비스 활성. persistent volume `postgres_data` 사용. pgvector 동봉.

```bash
# 1) 환경설정 작성
cd VNB4-Toeic-ops/env
cp .env.prod.example .env.prod

# 2) 시크릿 교체 — 다음 모두 본인 값으로
#    __STRONG_DB_PASSWORD__    (POSTGRES_PASSWORD 와 DATABASE_URL 동일 값)
#    __STRONG_JWT_SECRET_64CHARS__
#    __SECRET__                (OAuth, S3, TTS, Sentry 등)
#
#    강한 시크릿 생성:
openssl rand -hex 32                                # JWT
openssl rand -base64 24 | tr -d '+/='               # DB password

# 3) (선택) 이미지 태그 고정
# REGISTRY=ghcr.io/your-org TAG=v1.0.0

# 4) 스택 기동
cd ../compose
docker compose -f docker-compose.prod.yml --env-file ../env/.env.prod up -d
docker compose -f docker-compose.prod.yml ps        # postgres healthy 확인

# 5) 최초 마이그레이션 (컨테이너 내부 실행)
docker compose -f docker-compose.prod.yml exec api \
  sh -c "cd /app && pnpm prisma migrate deploy --schema /app/prisma/schema.prisma"

# 6) (선택) 시드 임포트
docker compose -f docker-compose.prod.yml exec api \
  sh -c "cd /app && pnpm tsx /app/seeds/run.ts"
```

엔드포인트는 Caddyfile.prod 기준 (`api.example.com`, `admin.example.com`, `media.example.com`). 도메인 + DNS A 레코드 사전 설정 필요. Caddy 가 Let's Encrypt 자동 발급.

### 6.2 외부 관리형 Postgres (옵션)

RDS / Supabase / Neon / Cloud SQL / Aiven 등. compose 의 `postgres` 서비스를 비활성화하고 `DATABASE_URL` 만 외부로 가리키게 함.

```bash
# 1) 관리형 콘솔에서 1회 — 확장 설치
#    Supabase/Neon = vector 기본 지원. RDS = parameter group 에서 enable.
psql "<관리형 URL>" <<'SQL'
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
SQL

# 2) 환경설정 — managed 템플릿
cd VNB4-Toeic-ops/env
cp .env.prod.managed.example .env.prod
# DATABASE_URL 만 관리형 호스트로 교체 (sslmode=require 권장)
# 예: postgres://USER:PASS@db.xxx.rds.amazonaws.com:5432/toeic_prod?sslmode=require

# 3) compose 에서 postgres 서비스 비활성화 — override 파일 사용
cat > ../compose/docker-compose.prod.override.yml <<'EOF'
services:
  postgres: !reset null
  api:     {depends_on: [valkey]}
  worker:  {depends_on: [valkey]}
EOF

# 4) 기동
cd ../compose
docker compose -f docker-compose.prod.yml -f docker-compose.prod.override.yml \
  --env-file ../env/.env.prod up -d

# 5) 마이그레이션 — 호스트에서 직접 (관리형 호스트로 향함)
cd ../../VNB4-Toeic-database
DATABASE_URL='postgres://USER:PASS@<관리형호스트>:5432/toeic_prod?sslmode=require' \
  pnpm prisma migrate deploy --schema prisma/schema.prisma
```

### 6.3 정지

```bash
docker compose -f docker-compose.prod.yml down         # 컨테이너만
docker compose -f docker-compose.prod.yml down -v      # 볼륨까지 (DB 영구 삭제 — 주의)
```

### 6.4 백업 (self-hosted Postgres)

```bash
# cron 예시
docker compose -f docker-compose.prod.yml exec -T postgres \
  pg_dump -U toeic -d toeic_prod | gzip > backup-$(date +%F).sql.gz
```

---

## 7. 환경설정 파일 정리

| 파일 | 위치 | 용도 |
|---|---|---|
| `env/.env.local`              | ops | 로컬 docker-compose 인프라 기본값 (체크인) |
| `env/.env.prod.example`       | ops | prod self-hosted 템플릿 (시크릿 교체 후 `.env.prod`) |
| `env/.env.prod.managed.example` | ops | prod 외부 관리형 DB 템플릿 |
| `.env.local`                  | database | SQLite 경로 (mode A) — `pnpm migrate:local` 시 자동 생성 |
| `.env`                        | database | PostgreSQL 경로 (mode B/C) — `pnpm env:init:prod` 로 복사 |

주요 환경변수 키 요약:

| Key | 의미 |
|---|---|
| `ENV` | `local`/`prod` |
| `DATABASE_URL` | Prisma 연결 문자열 |
| `POSTGRES_DB/USER/PASSWORD` | self-hosted postgres 초기화 변수 (mode C 최초 부팅만) |
| `REDIS_HOST/PORT` | Valkey (BullMQ + 캐시) |
| `S3_ENDPOINT/REGION/BUCKET/ACCESS_KEY/SECRET_KEY/PUBLIC_BASE` | 오브젝트 스토리지 |
| `TTS_PROVIDER` | `piper`(OSS, dev) / `azure` / `polly` |
| `AZURE_SPEECH_KEY/REGION`, `AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY` | TTS 자격증명 |
| `JWT_SECRET`, `JWT_EXPIRES_IN`, `JWT_REFRESH_EXPIRES_IN` | 인증 토큰 |
| `GOOGLE_CLIENT_ID/SECRET/CALLBACK_URL`, `APPLE_CLIENT_ID`, `KAKAO_CLIENT_ID` | OAuth |
| `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `SEED_ADMIN_NAME` | **기본 관리자** — backend 부팅 시 보장(create-if-absent, role=admin). 관리 콘솔 최초 로그인용. prod 는 강력 비번 필수, 비우면 비활성 |
| `NEXT_PUBLIC_API_URL` | 프론트가 호출할 API base |
| `SENTRY_DSN` | 오류 추적 |
| `REGISTRY`, `TAG` | prod 이미지 핀 |

---

## 8. Makefile 명령

`VNB4-Toeic-ops/Makefile` 가 워크스페이스 전체 명령을 모아둔 단일 진입점. 모든 명령은 **ops 디렉토리에서** 실행. 4 컴포넌트(database/backend/frontend/desktop) + 모바일 앱(`/Apps(Android,iOS,...)/VNB4-Toeic-app`)을 한 곳에서 조작.

### 8.1 자주 쓰는 명령

```bash
make help              # 명령 목록
make bootstrap         # pnpm 의존성 설치 (4 컴포넌트 + 앱)
make ci                # lint + typecheck + test
make test              # pnpm -r test (백엔드 + 컴포넌트별)
make build             # Docker 이미지 빌드 (api + worker + web)
make docker-dev        # 로컬 인프라 스택 기동 (백그라운드)
make docker-logs       # 전체 로그 추적
make docker-down       # 정지 (볼륨 유지)
```

### 8.2 전체 타겟

| 분류 | 타겟 | 설명 |
|---|---|---|
| **Bootstrap** | `bootstrap` | 4 컴포넌트 + 앱 `pnpm install` |
| **Quality** | `lint`, `typecheck`, `test`, `ci` | 단일 또는 일괄 (`-backend`/`-frontend`/`-app` 서픽스 가능) |
| **DB / Seed** | `migrate-local` | SQLite `db push` + client gen |
| | `migrate-dev` | PostgreSQL `migrate dev` (TTY 필요) |
| | `migrate-prod` | PostgreSQL `migrate deploy` |
| | `seed`, `seed-prod` | 시드 데이터(~1,900단어) 임포트 |
| | `studio` | Prisma Studio (SQLite) |
| **Build** | `build` | api + worker + web 이미지 빌드 |
| | `build-api`, `build-worker`, `build-web` | 개별 빌드. `REGISTRY=ghcr.io/foo TAG=v1.2.3` 오버라이드 가능 |
| **Docker dev** | `docker-dev` | `docker-compose.local.yml up -d` |
| | `docker-logs`, `docker-ps` | 로그 / 상태 |
| | `docker-down` | 정지 (볼륨 유지) |
| | `docker-clean` | 정지 + 볼륨 삭제 |
| **Docker prod** | `docker-prod-up` | `docker-compose.prod.yml --env-file env/.env.prod up -d` |
| | `docker-prod-down`, `docker-prod-logs` | 정지 / 로그 |
| | `docker-prod-migrate` | 컨테이너 내부 prisma migrate deploy |
| **Dev servers** | `dev-api`, `dev-worker`, `dev-web`, `dev-app` | 호스트 dev 서버 기동 (별도 터미널 권장) |
| **Misc** | `smoke` | Caddy/API/MinIO health 확인 |
| | `license-report` | THIRD_PARTY_NOTICES 생성 |
| | `clean` | 전 컴포넌트 `node_modules`/`dist`/`.next` 삭제 |

### 8.3 변수 오버라이드

```bash
# 다른 레지스트리/태그로 빌드
REGISTRY=ghcr.io/your-org TAG=v1.0.0 make build

# 다른 env 파일로 prod 기동 (수정은 Makefile 의 ENV_PROD 변수 변경)
```

### 8.4 컴포넌트 경로 변수

| 변수 | 기본값 |
|---|---|
| `DB` | `../VNB4-Toeic-database` |
| `BACKEND` | `../VNB4-Toeic-backend` |
| `FRONTEND` | `../VNB4-Toeic-frontend` |
| `APP` | `/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app` (절대경로, 괄호 포함) |
| `COMPOSE_LOCAL` | `compose/docker-compose.local.yml` |
| `COMPOSE_PROD` | `compose/docker-compose.prod.yml` |
| `ENV_PROD` | `env/.env.prod` |

`APP` 경로의 괄호 문자 때문에 Makefile 내부에서 `"$(APP)"` 처럼 따옴표로 감싸 처리됨.

---

## 9. Ops 디렉토리 구조

```
VNB4-Toeic-ops/
├── README.md                       # 본 문서
├── Makefile                        # 워크스페이스 진입점 (make help)
├── LICENSES.md                     # 전체 라이선스 검토
├── .gitignore                      # 공통 ignore (per-project 추가 ignore 별도)
├── .doc/                           # PRD / ARCHITECTURE / ROADMAP_STATUS
├── .github/workflows/              # GH Actions (현재 ⚠️ disabled — ci/ 정본 sync 대상)
├── ci/github-actions-ci.yml        # CI 정본 (⚠️ 임시 주석처리됨, noop 잡만 active)
├── compose/
│   ├── docker-compose.local.yml    # mode B
│   └── docker-compose.prod.yml     # mode C
├── docker/
│   ├── Dockerfile.api
│   ├── Dockerfile.worker
│   └── Dockerfile.web
├── caddy/
│   ├── Caddyfile.local
│   └── Caddyfile.prod
├── env/
│   ├── .env.local                      # local infra 기본값 (체크인)
│   ├── .env.prod.example               # prod self-hosted 템플릿
│   └── .env.prod.managed.example       # prod 외부 관리형 템플릿
├── scripts/
│   ├── migrate.sh                  # 환경별 마이그레이션 헬퍼
│   ├── seed.sh                     # 시드 헬퍼
│   └── license-report.sh           # THIRD_PARTY_NOTICES 생성
├── test/                           # 시스템 시험 (20 시나리오)
└── k8s/                            # 향후 k3s/k8s 매니페스트
```

---

## 10. 빌드/배포 (CI)

> ⚠️ **임시 주석처리 (2026-05-21~)** — `ci/github-actions-ci.yml` 전체 비활성화 상태.
> 현재 활성 잡은 `workflow_dispatch` 트리거 `noop` 더미 1개뿐 (echo 메시지만 출력).
> 원본 워크플로우는 동일 파일 하단 `ORIGINAL CONTENT BELOW` 블록에 `# ` 프리픽스로 보존됨.
> 비활성화 이유: 외부 CI 사용 보류, 컴포넌트별 로컬 검증 스크립트로 대체.
> `.github/workflows/ci.yml` 도 동일하게 비활성화.

`ci/github-actions-ci.yml` 가 정본 워크플로우 (복원 시):

1. PR/Push → 각 컴포넌트 `pnpm install` + typecheck + build
2. main 머지 → `docker/Dockerfile.{api,worker,web}` 로 이미지 빌드 → GHCR push (`ghcr.io/<org>/vnb4-{api,worker,web}:<sha>`)
3. tag 푸시 → 이미지 `:vX.Y.Z` 부여 + release notes

**재활성화 절차** (`ci/github-actions-ci.yml` 헤더 주석 참조):
```bash
cd VNB4-Toeic-ops/ci
sed -n '/ORIGINAL CONTENT BELOW/,$p' github-actions-ci.yml \
  | sed '1,2d' | sed 's/^# //' > github-actions-ci.yml.new
mv github-actions-ci.yml.new github-actions-ci.yml
# 후 .github/workflows/ci.yml 에도 동일 내용 sync
```

EAS(모바일)는 별도 워크플로우 예정. `app/eas.json` 의 `production` 채널 사용.

---

## 11. 시스템 시험

```bash
cd VNB4-Toeic-ops/test
./run-tests.sh                  # 전체 20 시나리오
./run-tests.sh 15 16 17 18      # README 4 모드 검증
./run-tests.sh 20               # pnpm 정책 가드
```

상세: [test/README.md](./test/README.md), [test/QUICKSTART_VERIFY.md](./test/QUICKSTART_VERIFY.md).

---

## 12. Monitoring (M6 — TODO)

`compose/docker-compose.observability.yml` 추가 예정:

- Prometheus (Apache-2.0) — API/Worker `/metrics` scrape
- Grafana (AGPL-3.0) — unmodified image
- Loki (AGPL-3.0) — 로그 집계
- OpenTelemetry SDK — API/Worker 계측
- Sentry self-host (BSL 1.1) — 오류 추적

---

## 13. Open source / 라이선스 요약

| 원본 | 용도 | License | 채택 형태 |
|---|---|---|---|
| nestjs/nest | API 프레임워크 | MIT | dep |
| vercel/next.js | Admin Web | MIT | dep |
| shadcn-ui/ui | UI 컴포넌트 | MIT | source-copy |
| expo/expo | 모바일 런타임 | MIT | dep |
| prisma/prisma | ORM | Apache-2.0 | dep |
| tauri-apps/tauri | Desktop shell | MIT/Apache-2.0 | dep |
| taskforcesh/bullmq | Worker queue | MIT | dep |
| valkey-io/valkey | Cache/queue | BSD-3 | self-host container |
| caddyserver/caddy | Reverse proxy | Apache-2.0 | self-host container |
| pgvector/pgvector | Vector ext | PostgreSQL | self-host container |
| rhasspy/piper | OSS TTS (dev) | MIT | self-host container |

전부 dependency 또는 *unmodified container*. AGPL/BSL 트리거 없음.
전체 보고서: [LICENSES.md](./LICENSES.md), 자동 생성: `scripts/license-report.sh`.

---

## 14. Deploy targets

- 초기: 단일 VM (4 vCPU / 8GB) + `docker-compose.prod.yml` + self-hosted Postgres + persistent volume
- DB 백업: `pg_dump` cron (§6.4)
- 트래픽 증가 시: 외부 관리형 Postgres 전환 (§6.2) 또는 k3s 전환 (`k8s/` 자리 마련됨)

---

## 15. PRD 매핑

| PRD 영역 | 위치 |
|---|---|
| §3 디렉토리 | 본 구조 (§0, §8) |
| §4.3 환경 분리 (local/prod) | `compose/` × 2 + `env/` × 3 |
| §5.5.1 Docker + Compose | `compose/docker-compose.{local,prod}.yml` |
| §5.5.2 GitHub Actions + EAS | `ci/github-actions-ci.yml` + 별도 EAS 워크플로우 |
| §5.5.3 Caddy 자동 HTTPS | `caddy/Caddyfile.prod` |
| §5.5.4 모니터링 | M6 TODO (§11) |
| §7 라이선스 NOTICE 생성 | `scripts/license-report.sh` |

---

## 16. Roadmap

PRD §9 + [.doc/ROADMAP_STATUS.md](./.doc/ROADMAP_STATUS.md). M0 셋업 완료. M1~M6 진행 중.
