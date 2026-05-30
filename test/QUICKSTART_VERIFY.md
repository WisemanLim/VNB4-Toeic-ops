# Quick Start 시험 보고서 (README.md 기준)

_생성 2026-05-21 · Run ID: `20260521_141539` · 자동 재현: `cd VNB4-Toeic-ops/test && ./run-tests.sh 15 16 17 18`_

## 요청 시험 매트릭스

| 시험 | 시나리오 | 결과 | 소요 |
|------|----------|------|------|
| **Local (1)** — 수동 컴포넌트 (SQLite, Docker 없음) + app 확인 | `15-mode-a-sqlite` | ✅ PASS | 2s |
| **Local (2)** — `docker-compose.local.yml` 전체 스택 + app 확인 | `16-mode-b-compose` | ✅ PASS | 16s |
| **Prod (internal)** — `docker-compose.prod.yml` self-hosted Postgres | `17-mode-c-prod-internal` | ✅ PASS | 3s |
| **Prod (external)** — managed Postgres | `18-mode-c-managed` | ➖ SKIP (요청대로) | 0s |

전체: **17 PASS / 0 FAIL / 1 SKIP** ([TEST_RESULTS.md](TEST_RESULTS.md))

---

## 시험 1 — Local 수동 (Mode A, SQLite 단독)

README §A 명령 그대로 실행.

### 실행 단계
```bash
cd VNB4-Toeic-database
pnpm install         # node_modules 존재 → 스킵
pnpm migrate:local   # .env.local 자동생성 + SQLite db push + client gen
pnpm seed            # SQLite upsert
```

### 검증 결과 (전부 ✔)
- `pnpm migrate:local` 성공 → `prisma/dev.db` 생성
- `pnpm seed` 성공 → Word 96 rows
- App `pnpm typecheck` 통과
- Expo CLI 정상 (`node_modules/.bin/expo`)

### 한계
백엔드·프론트는 PostgreSQL·Valkey·MinIO 의존 → Mode A 에선 DB+App 만 확인 가능.
전체 스택 수동 실행 = Mode B (compose infra + 수동 dev 서버).

---

## 시험 2 — Local compose (Mode B, 전체 스택)

README §B 단계 (B-1 infra + B-2 DB + B-3 backend/frontend/app) 실행.

### 실행 단계
```bash
# B-1
cd VNB4-Toeic-ops/compose
docker compose -f docker-compose.local.yml up -d

# B-2
cd ../../VNB4-Toeic-database
pnpm env:init:prod
pnpm exec dotenv -e .env -- prisma db push --schema prisma/schema.prisma
pnpm seed:prod

# B-3a backend
cd ../VNB4-Toeic-backend/api && pnpm start:dev      # 백그라운드

# B-3b frontend
cd ../../VNB4-Toeic-frontend/web && pnpm dev        # 백그라운드

# B-3c app
cd ../../VNB4-Toeic-app && pnpm typecheck
```

### 검증 결과
| 단계 | 결과 |
|------|------|
| compose `up -d` | ✔ |
| postgres (`pg_isready -U toeic`) | ✔ |
| 컨테이너: postgres / valkey / minio / caddy 모두 running | ✔✔✔✔ |
| prod schema db push | ✔ |
| `seed:prod` → PG Word count = 96 | ✔ |
| **backend** `pnpm start:dev` → `/api/v1/health` 응답 (**1s**) | ✔ |
| **frontend** `pnpm dev` → `http://localhost:3000/` 응답 (**2s**) | ✔ |
| **app** `pnpm typecheck` | ✔ |
| Caddy → HTTP 502 (backend down 상태, 예상치) | ✔ (정상) |

### 시험 중 발견하여 수정한 이슈
1. **Backend 의 Prisma client 미생성** — `VNB4-Toeic-backend/api/node_modules/.pnpm/.../@prisma/client` 가 비어 있어 NestJS import 실패. 수정:
   - `backend/api/prisma/` → `../VNB4-Toeic-database/prisma/` 심볼릭 링크
   - `backend/api/package.json` 에 `prisma:generate` 스크립트 + `start:dev`/`build` 가 사전 실행
   - `backend/package.json` 에 `prisma` devDep 추가
2. **`words.service.ts` TS2322** — `{ ...dto, ...(dto.part ? { part: PART_MAP[dto.part] } : {}) }` 가 `number` 스프레드를 enum 으로 덮어쓰지 못함. `part` 를 destructure 로 분리.
3. **OAuth Google strategy 부팅 실패** — 빈 문자열 `GOOGLE_CLIENT_ID=""` 에 `??` 가 폴백 안 함. `||` 로 변경 (`stub-client-id`).
4. **Backend `.env.local` 부재** — `VNB4-Toeic-backend/api/.env.local` → `../../VNB4-Toeic-ops/env/.env.local` 심볼릭 링크. `DATABASE_URL` + JWT/Redis/S3 모두 로드됨.

---

## 시험 3 — Prod compose, self-hosted Postgres (Mode C-1)

README §C-1 단계 검증. 운영 이미지(`ghcr.io/vnb4/vnb4-api` 등)는 본 환경에 빌드/풀 안 되어 있어 **postgres + valkey 만 기동**.

### 실행 단계
```bash
# 시험용 .env.prod 자동 생성 (placeholder 비밀번호로 채움)
sed 's/__STRONG_DB_PASSWORD__/testpw123/g; ...' .env.prod.example > .env.prod

# 로컬 compose 와 포트 충돌 → 임시 down
docker compose -f docker-compose.local.yml down

# prod compose 검증 + 기동
docker compose -f docker-compose.prod.yml --env-file .env.prod config   # syntax OK
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d postgres valkey
```

### 검증 결과 (전부 ✔)
- prod compose `config` syntax + interpolation 통과 (`.env.prod` 의 `__STRONG_DB_PASSWORD__:?required` 해소)
- 컨테이너 `vnb4-toeic-prod-postgres-1` 기동
- `pg_isready -U toeic -d toeic_prod` 통과
- **pgvector 확장 설치 확인** (`init.sql` 가 `docker-entrypoint-initdb.d` 에서 실행됨)
- valkey `PING` → `PONG`

### 정리
- `docker compose -f docker-compose.prod.yml down -v` 로 prod 컨테이너 + 볼륨 삭제
- 로컬 compose 복원 (`docker-compose.local.yml up -d`)
- 임시 `.env.prod` 삭제

### 미검증 항목 (이미지 부재)
- `api` / `worker` / `web` 서비스: 빌드된 이미지 (`ghcr.io/vnb4/...`) 가 없어 시작 안 함
- 호스트→컨테이너 마이그레이션 (`docker compose exec api ...`): 위와 동일 사유
- 실제 운영 배포에서는 CI 가 이미지를 푸시한 뒤 동일 compose 로 전체 기동 가능

---

## 시험 4 — Prod compose, 외부 관리형 (Mode C-2) — SKIP

사용자 요청에 따라 본 회차 제외. 정적 검증만 수행:
- `.env.prod.managed.example` 존재 ✔
- `sslmode=require` 강제 ✔
- Supabase / Neon URL 예시 포함 ✔

실제 수행하려면:
```bash
cp VNB4-Toeic-ops/env/.env.prod.managed.example VNB4-Toeic-ops/env/.env.prod
# DATABASE_URL 을 실제 관리형 호스트로 교체

cat > docker-compose.prod.override.yml <<'EOF'
services:
  postgres: !reset null
  api:     {depends_on: [valkey]}
  worker:  {depends_on: [valkey]}
EOF

docker compose -f docker-compose.prod.yml -f docker-compose.prod.override.yml up -d
```

---

## 부산물 / 영구화된 변경

본 시험을 통해 부주의로 보고만 했던 문제를 코드로 반영:

| 파일 | 변경 |
|------|------|
| `VNB4-Toeic-backend/package.json` | `prisma` devDep, `prisma:generate` 스크립트 |
| `VNB4-Toeic-backend/api/package.json` | `prisma:generate` + `start:dev` 사전실행 |
| `VNB4-Toeic-backend/api/prisma` | 심볼릭 링크 → `../../VNB4-Toeic-database/prisma` |
| `VNB4-Toeic-backend/api/.env.local` | 심볼릭 링크 → `../../VNB4-Toeic-ops/env/.env.local` |
| `VNB4-Toeic-backend/api/src/modules/words/words.service.ts` | `update()` `part` destructure 수정 |
| `VNB4-Toeic-backend/api/src/modules/auth/strategies/google.strategy.ts` | `??` → `\|\|` (빈 env 폴백) |
| `VNB4-Toeic-ops/test/scenarios/15..18-*.sh` | 신규 시나리오 |

## 재현

```bash
cd VNB4-Toeic-ops/test
./run-tests.sh                # 전체 18 시나리오
./run-tests.sh 15 16 17 18    # 본 보고서 4 시나리오만
./run-tests.sh 16             # Mode B 단독 (가장 무거움, ~15s)
```
