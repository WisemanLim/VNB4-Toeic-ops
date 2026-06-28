# Vocabulary-NB4-TOEIC (Ops meta repo)

> 🌐 **Language / 언어**: **English** · [한국어](README.md)

A TOEIC vocabulary-memorization learning platform, organized by TOEIC part. It uses a **5-component polyrepo** structure, where this `VNB4-Toeic-ops` repo handles workspace meta management plus operational infrastructure (Docker Compose / Caddy / CI / environment config / system tests).

---

## 0. Workspace layout

### 0.1 Components (disk layout)

| Component | Path | Role |
|---|---|---|
| `VNB4-Toeic-app`      | `/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app` | Mobile learning app (iOS/Android/Web) |
| `VNB4-Toeic-frontend` | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-frontend` | Admin Web + Desktop |
| `VNB4-Toeic-backend`  | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-backend`  | HTTP API + Worker (queue) |
| `VNB4-Toeic-database` | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-database` | Prisma schema + migrations + seed |
| `VNB4-Toeic-ops`      | `/Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-ops`      | Compose / Caddy / Env / CI / tests |

All four components other than App live under the same parent (`Web(Node,Script)/`). The sibling directory structure must be preserved for Compose bind mounts and relative-path symbolic dependencies.

### 0.2 Software stack per component

| Component | Main stack | Lang | Package manager |
|---|---|---|---|
| `app`      | React Native 0.74, Expo SDK 51, Expo Router 3, TanStack Query 5, Zustand, NativeWind, expo-av, expo-secure-store | TypeScript | pnpm |
| `frontend/web`     | Next.js 14 (App Router), shadcn/ui (Radix + Tailwind), TanStack Query, Zustand | TypeScript | pnpm |
| `frontend/desktop` | Tauri 2 (Rust shell + Web view) — wraps `web/out` | TypeScript + Rust | pnpm |
| `backend/api`      | NestJS 10, Prisma 5, Swagger(OpenAPI), Passport(JWT/OAuth), Argon2 | TypeScript | pnpm |
| `backend/worker`   | BullMQ, Azure Speech SDK / AWS Polly / Piper TTS | TypeScript | pnpm |
| `database`         | PostgreSQL 16 + pgvector / SQLite (local), Prisma 5 | TypeScript | pnpm |
| `ops`              | Docker Compose v2, Caddy 2 (Apache-2.0), Valkey 8 (BSD-3, Redis-compatible), MinIO, GitHub Actions | YAML + shell | — |

### 0.3 Language unification policy

Instead of the PRD-recommended FastAPI (Python), **every component except app is unified on TypeScript** (NestJS + Prisma + BullMQ). Rationale: maintainability + shared full-stack staffing.

Detailed license review: [LICENSES.md](./LICENSES.md). All AGPL/BSL components used are *unmodified containers* → no redistribution trigger.

---

## 1. Required prerequisites

### 1.1 Common

| Requirement | Version | Check |
|---|---|---|
| Node.js | 20.x LTS or later | `node -v` |
| pnpm | 10.x or later (across all workspace components) | `pnpm -v` |
| Git | latest | `git --version` |

### 1.2 When using Docker (mode B/C)

| Requirement | Version | Check |
|---|---|---|
| Docker Engine | 24+ | `docker -v` |
| Docker Compose | v2 (`docker compose`) | `docker compose version` |

### 1.3 Mobile (additional, per mode)

| Target | Required |
|---|---|
| Expo Go (physical device) | Phone with the Expo Go app installed + same Wi-Fi |
| iOS simulator | **Full Xcode install** (CLT alone is insufficient) |
| Android emulator | Android Studio + AVD + JDK 17 |
| EAS Build (cloud) | Expo account + `npx eas-cli login` |

Details: [VNB4-Toeic-app/README.md](../../Apps(Android,iOS,...)/VNB4-Toeic-app/README.md).

### 1.4 Desktop (Tauri)

Rust toolchain (`rustup default stable`) + platform build dependencies (macOS: Xcode CLT, Linux: webkit2gtk, Windows: WebView2).

### 1.5 pnpm build-script policy

The four components set `dangerouslyAllowAllBuilds: true` in their `pnpm-workspace.yaml` (to bypass the pnpm 11 strict block).
- Justification for allowing it: the packages in use are OSS, and their build scripts have been verified.
- **Forbidden**: the interactive `pnpm approve-builds` command. It writes an invalid `allowBuilds:` placeholder into the yaml and breaks install.
- If newly broken, manually remove the `allowBuilds:` block → re-run `rm -rf node_modules && pnpm install`.

---

## 2. End-to-end flow (request → processing)

```
[Mobile app / Admin Web]
         │  HTTPS
         ▼
       Caddy (80/443, auto-HTTPS in prod)
         │
   ┌─────┴─────┐
   ▼           ▼
 NestJS API   Next.js Web
  (:4000)     (:3000)
   │  │
   │  └────► BullMQ ────► Worker (TTS / seed import)
   │                        │
   │                        ▼
   │                     Azure / AWS / Piper TTS
   ▼
 PostgreSQL 16 + pgvector   Valkey 8 (queue/cache)   MinIO / S3 / R2 (audio·images)
```

- The API accesses the DB via the Prisma client. Async work (TTS synthesis, bulk seed imports) is delegated to the Worker through BullMQ.
- Static audio/images are stored in S3-compatible storage (MinIO/AWS S3/Cloudflare R2) → served via CDN/Caddy at `/media/*`.

---

## 3. Run modes — 3 of them

| Mode | DB | Infra | When to use |
|---|---|---|---|
| **A. Local SQLite (no Docker)** | SQLite `prisma/dev.db` | none | Fast DB schema/seed validation, offline |
| **B. Local Docker Compose** | PostgreSQL 16 + pgvector | Valkey + MinIO + Caddy | Full stack local testing |
| **C. Prod Docker Compose** | self-hosted Postgres (default) or external managed (optional) | api/worker/web build images + Valkey + Caddy | Production deployment |

> **DB location defaults**
> - mode A: local file (SQLite, no Docker needed)
> - mode B: postgres container inside docker-compose
> - mode C: default is the postgres container inside docker-compose (self-hosted). For external managed (RDS/Supabase/Neon), just swap the config value (`DATABASE_URL`) and reuse the same compose.

---

## 4. Mode A — Local SQLite (run individually)

No Docker needed. Only the database component runs on SQLite. The other components start their own dev servers directly.

### 4.1 DB (SQLite)

```bash
cd VNB4-Toeic-database
pnpm install
pnpm migrate:local    # auto-generates .env.local + prisma db push (SQLite)
pnpm seed             # seeds/parts/*.json → SQLite upsert (≈3,700 words)
pnpm studio           # Prisma Studio (SQLite)
```

The scripts use `prisma/schema.local.prisma`. Due to SQLite constraints, array fields are stored as JSON strings and enums as String.

### 4.2 Backend (NestJS API + Worker)

```bash
cd VNB4-Toeic-backend
pnpm install
# API
cd api && pnpm start:dev          # http://localhost:4000  (Swagger /docs)
# Worker (separate terminal)
cd ../worker && pnpm start:dev
```

The API's `DATABASE_URL` should point directly at the SQLite path in the database `.env.local` (or `file:../../VNB4-Toeic-database/prisma/dev.db`).

> The queue (BullMQ) requires Valkey/Redis. To run the Worker as well in mode A, run one local Redis or Valkey via brew/Docker (`brew install valkey && valkey-server` or `docker run -p 6379:6379 valkey/valkey:8-alpine`).
> If you don't need the Worker, basic word/learning CRUD works with the API alone.

### 4.3 Frontend (Next.js)

```bash
cd VNB4-Toeic-frontend
pnpm install
pnpm web:dev          # http://localhost:3000
# Desktop (Tauri, requires Rust toolchain)
pnpm desktop:dev
```

In `web/.env.local` or as an environment variable: `NEXT_PUBLIC_API_URL=http://localhost:4000`.

### 4.4 Mobile app

```bash
cd /Users/wise/Developer/Apps\(Android,iOS,...\)/VNB4-Toeic-app
pnpm install
pnpm start            # QR → Expo Go (physical device recommended)
pnpm ios              # iOS simulator (requires full Xcode install)
pnpm android          # Android emulator (AVD running)
pnpm web              # http://localhost:8081 (browser)
```

Set the backend URL via `app.json` → `expo.extra.apiUrl` or the `EXPO_PUBLIC_API_URL` environment variable.

---

## 5. Mode B — Local Docker Compose (full stack)

`compose/docker-compose.local.yml` is a hybrid setup that runs only the **infrastructure (postgres + valkey + minio + caddy)** in containers, while app/api/worker/web run as dev servers on the host. Hot-reload + debugging friendly.

### 5.1 Start the infrastructure

```bash
cd VNB4-Toeic-ops/compose
docker compose -f docker-compose.local.yml up -d
docker compose -f docker-compose.local.yml ps
```

Services started:

| Service | Image | Port | Notes |
|---|---|---|---|
| postgres | `pgvector/pgvector:pg16` | 5432 | `toeic`/`toeic`, db `toeic_local`, init SQL `VNB4-Toeic-database/local/init.sql` |
| valkey | `valkey/valkey:8-alpine` | 6379 | BSD-3 Redis-compatible fork |
| minio | `quay.io/minio/minio` | 9000 (S3), 9001 (console) | `minioadmin`/`minioadmin`, bucket `toeic-media` auto-created |
| caddy | `caddy:2-alpine` | 80 | uses `Caddyfile.local` |

### 5.2 DB migration + seed (PostgreSQL)

```bash
cd ../../VNB4-Toeic-database
pnpm install
pnpm env:init:prod          # generate .env (for PostgreSQL)
pnpm migrate:dev            # prisma migrate dev — needs TTY (prompts for migration name)
pnpm seed:prod              # seeds/parts/*.json → PostgreSQL upsert
```

The `DATABASE_URL` in `.env` is `postgres://toeic:toeic@localhost:5432/toeic_local`.

### 5.3 Start app services (separate terminals)

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

The host's API/Web are reverse-proxied by Caddy via `host.docker.internal` (see Caddyfile.local).

### 5.4 Endpoints

| URL | Target |
|---|---|
| `http://localhost/` | Caddy → Next.js (:3000) |
| `http://localhost/api/*` | Caddy → NestJS API (:4000) |
| `http://localhost/api/docs` | Swagger UI |
| `http://localhost/media/*` | Caddy → MinIO (`toeic-media`) |
| `http://localhost:9001` | MinIO console (`minioadmin`/`minioadmin`) |
| `localhost:5432` | PostgreSQL (`toeic`/`toeic`/`toeic_local`) |
| `localhost:6379` | Valkey |

### 5.5 Stop

```bash
docker compose -f docker-compose.local.yml down       # containers only
docker compose -f docker-compose.local.yml down -v    # including volumes (permanently deletes DB)
```

---

## 6. Mode C — Prod Docker Compose

`compose/docker-compose.prod.yml` is a full-stack setup of **api / worker / web container images + postgres (self-hosted) + valkey + caddy (auto-HTTPS)**.

Images are built/pushed in CI as `${REGISTRY}/vnb4-{api,worker,web}:${TAG}`.

### 6.1 Self-hosted Postgres (default)

The `postgres` service in `docker-compose.prod.yml` is enabled. It uses the persistent volume `postgres_data`. pgvector is bundled.

```bash
# 1) Write the environment config
cd VNB4-Toeic-ops/env
cp .env.prod.example .env.prod

# 2) Replace secrets — all of the following with your own values
#    __STRONG_DB_PASSWORD__    (same value for POSTGRES_PASSWORD and DATABASE_URL)
#    __STRONG_JWT_SECRET_64CHARS__
#    __SECRET__                (OAuth, S3, TTS, Sentry, etc.)
#
#    Generate strong secrets:
openssl rand -hex 32                                # JWT
openssl rand -base64 24 | tr -d '+/='               # DB password

# 3) (optional) Pin image tags
# REGISTRY=ghcr.io/your-org TAG=v1.0.0

# 4) Start the stack
cd ../compose
docker compose -f docker-compose.prod.yml --env-file ../env/.env.prod up -d
docker compose -f docker-compose.prod.yml ps        # confirm postgres healthy

# 5) Initial migration (run inside the container)
docker compose -f docker-compose.prod.yml exec api \
  sh -c "cd /app && pnpm prisma migrate deploy --schema /app/prisma/schema.prisma"

# 6) (optional) Seed import
docker compose -f docker-compose.prod.yml exec api \
  sh -c "cd /app && pnpm tsx /app/seeds/run.ts"
```

Endpoints follow Caddyfile.prod (`api.example.com`, `admin.example.com`, `media.example.com`). The domain + DNS A records must be set up in advance. Caddy auto-issues via Let's Encrypt.

### 6.2 External managed Postgres (optional)

RDS / Supabase / Neon / Cloud SQL / Aiven, etc. Disable the `postgres` service in compose and point `DATABASE_URL` to the external one.

```bash
# 1) One-time in the managed console — install extensions
#    Supabase/Neon = vector supported by default. RDS = enable via parameter group.
psql "<managed URL>" <<'SQL'
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
SQL

# 2) Environment config — managed template
cd VNB4-Toeic-ops/env
cp .env.prod.managed.example .env.prod
# Replace only DATABASE_URL with the managed host (sslmode=require recommended)
# e.g.: postgres://USER:PASS@db.xxx.rds.amazonaws.com:5432/toeic_prod?sslmode=require

# 3) Disable the postgres service in compose — use an override file
cat > ../compose/docker-compose.prod.override.yml <<'EOF'
services:
  postgres: !reset null
  api:     {depends_on: [valkey]}
  worker:  {depends_on: [valkey]}
EOF

# 4) Start
cd ../compose
docker compose -f docker-compose.prod.yml -f docker-compose.prod.override.yml \
  --env-file ../env/.env.prod up -d

# 5) Migration — directly from the host (targeting the managed host)
cd ../../VNB4-Toeic-database
DATABASE_URL='postgres://USER:PASS@<managed-host>:5432/toeic_prod?sslmode=require' \
  pnpm prisma migrate deploy --schema prisma/schema.prisma
```

### 6.3 Stop

```bash
docker compose -f docker-compose.prod.yml down         # containers only
docker compose -f docker-compose.prod.yml down -v      # including volumes (permanently deletes DB — caution)
```

### 6.4 Backup (self-hosted Postgres)

```bash
# cron example
docker compose -f docker-compose.prod.yml exec -T postgres \
  pg_dump -U toeic -d toeic_prod | gzip > backup-$(date +%F).sql.gz
```

---

## 7. Environment config files

| File | Location | Purpose |
|---|---|---|
| `env/.env.local`              | ops | Defaults for local docker-compose infra (checked in) |
| `env/.env.prod.example`       | ops | prod self-hosted template (`.env.prod` after replacing secrets) |
| `env/.env.prod.managed.example` | ops | prod external managed DB template |
| `.env.local`                  | database | SQLite path (mode A) — auto-generated by `pnpm migrate:local` |
| `.env`                        | database | PostgreSQL path (mode B/C) — copied by `pnpm env:init:prod` |

Summary of key environment variables:

| Key | Meaning |
|---|---|
| `ENV` | `local`/`prod` |
| `DATABASE_URL` | Prisma connection string |
| `POSTGRES_DB/USER/PASSWORD` | self-hosted postgres init variables (mode C first boot only) |
| `REDIS_HOST/PORT` | Valkey (BullMQ + cache) |
| `S3_ENDPOINT/REGION/BUCKET/ACCESS_KEY/SECRET_KEY/PUBLIC_BASE` | object storage |
| `TTS_PROVIDER` | `piper`(OSS, dev) / `azure` / `polly` |
| `AZURE_SPEECH_KEY/REGION`, `AWS_ACCESS_KEY_ID/SECRET_ACCESS_KEY` | TTS credentials |
| `JWT_SECRET`, `JWT_EXPIRES_IN`, `JWT_REFRESH_EXPIRES_IN` | auth tokens |
| `GOOGLE_CLIENT_ID/SECRET/CALLBACK_URL`, `APPLE_CLIENT_ID`, `KAKAO_CLIENT_ID` | OAuth |
| `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `SEED_ADMIN_NAME` | **default admin** — ensured at backend boot (create-if-absent, role=admin). For first login to the admin console. In prod a strong password is required; leaving it empty disables it |
| `NEXT_PUBLIC_API_URL` | API base the frontend calls |
| `SENTRY_DSN` | error tracking |
| `REGISTRY`, `TAG` | prod image pins |

---

## 8. Makefile commands

`VNB4-Toeic-ops/Makefile` is the single entry point that collects all workspace-wide commands. Run every command **from the ops directory**. It lets you operate the four components (database/backend/frontend/desktop) plus the mobile app (`/Apps(Android,iOS,...)/VNB4-Toeic-app`) from one place.

### 8.1 Frequently used commands

```bash
make help              # list commands
make bootstrap         # install pnpm dependencies (4 components + app)
make ci                # lint + typecheck + test
make test              # pnpm -r test (backend + per-component)
make build             # build Docker images (api + worker + web)
make docker-dev        # start the local infra stack (background)
make docker-logs       # follow all logs
make docker-down       # stop (keep volumes)
```

### 8.2 All targets

| Category | Target | Description |
|---|---|---|
| **Bootstrap** | `bootstrap` | `pnpm install` for 4 components + app |
| **Quality** | `lint`, `typecheck`, `test`, `ci` | single or batch (`-backend`/`-frontend`/`-app` suffixes available) |
| **DB / Seed** | `migrate-local` | SQLite `db push` + client gen |
| | `migrate-dev` | PostgreSQL `migrate dev` (needs TTY) |
| | `migrate-prod` | PostgreSQL `migrate deploy` |
| | `seed`, `seed-prod` | import seed data (≈3,700 words) |
| | `studio` | Prisma Studio (SQLite) |
| **Build** | `build` | build api + worker + web images |
| | `build-api`, `build-worker`, `build-web` | individual builds. Can override `REGISTRY=ghcr.io/foo TAG=v1.2.3` |
| **Docker dev** | `docker-dev` | `docker-compose.local.yml up -d` |
| | `docker-logs`, `docker-ps` | logs / status |
| | `docker-down` | stop (keep volumes) |
| | `docker-clean` | stop + delete volumes |
| **Docker prod** | `docker-prod-up` | `docker-compose.prod.yml --env-file env/.env.prod up -d` |
| | `docker-prod-down`, `docker-prod-logs` | stop / logs |
| | `docker-prod-migrate` | prisma migrate deploy inside the container |
| **Dev servers** | `dev-api`, `dev-worker`, `dev-web`, `dev-app` | start host dev servers (separate terminals recommended) |
| **Misc** | `smoke` | check Caddy/API/MinIO health |
| | `license-report` | generate THIRD_PARTY_NOTICES |
| | `clean` | delete `node_modules`/`dist`/`.next` for all components |

### 8.3 Variable overrides

```bash
# Build with a different registry/tag
REGISTRY=ghcr.io/your-org TAG=v1.0.0 make build

# Start prod with a different env file (to change it, edit the Makefile's ENV_PROD variable)
```

### 8.4 Component path variables

| Variable | Default (resolution) | env override |
|---|---|---|
| `DB_DIR` | `$(REPO_ROOT)/VNB4-Toeic-database` (if present) | `VNB4_DB_DIR` |
| `BACKEND_DIR` | `$(REPO_ROOT)/VNB4-Toeic-backend` (if present) | `VNB4_BACKEND_DIR` |
| `FRONTEND_DIR` | `$(REPO_ROOT)/VNB4-Toeic-frontend` (if present) | `VNB4_FRONTEND_DIR` |
| `APP_DIR` | first existing dir among candidates (`$(REPO_ROOT)/VNB4-Toeic-app`, `/opt/vnb4-app`, `$(HOME)/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app`, etc.) — graceful skip if absent | `VNB4_APP_DIR` |
| `COMPOSE_LOCAL` | `compose/docker-compose.local.yml` | — |
| `COMPOSE_PROD` | `compose/docker-compose.prod.yml` | — |
| `ENV_PROD` | `env/.env.prod` | — |
| `REGISTRY` / `TAG` | `ghcr.io/vnb4` / `latest` | cli override |

`REPO_ROOT` is the parent of the Makefile's location (the ops directory). Component paths are resolved automatically from sibling directories with no hardcoded absolute paths, and can be overridden via the `VNB4_*_DIR` environment variables. `APP_DIR` is optional — related targets are skipped if it is absent (mobile is operated only on dev machines). Run `make info` to see the resolved paths.

---

## 9. Ops directory structure

```
VNB4-Toeic-ops/
├── README.md                       # this document
├── Makefile                        # workspace entry point (make help)
├── LICENSES.md                     # full license review
├── .gitignore                      # common ignore (per-project additional ignores are separate)
├── .doc/                           # PRD / ARCHITECTURE / ROADMAP_STATUS
├── .github/workflows/              # GH Actions (currently ⚠️ disabled — sync target for the ci/ canonical version)
├── ci/github-actions-ci.yml        # CI canonical (⚠️ temporarily commented out, only the noop job is active)
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
│   ├── .env.local                      # local infra defaults (checked in)
│   ├── .env.prod.example               # prod self-hosted template
│   └── .env.prod.managed.example       # prod external managed template
├── scripts/
│   ├── migrate.sh                  # per-environment migration helper
│   ├── seed.sh                     # seed helper
│   └── license-report.sh           # generate THIRD_PARTY_NOTICES
├── test/                           # system tests (20 scenarios)
└── k8s/                            # future k3s/k8s manifests
```

---

## 10. Build/deploy (CI)

> ⚠️ **Temporarily commented out (since 2026-05-21)** — `ci/github-actions-ci.yml` is entirely disabled.
> The only active job currently is a single `noop` dummy triggered by `workflow_dispatch` (it only echoes a message).
> The original workflow is preserved in the same file under the `ORIGINAL CONTENT BELOW` block with a `# ` prefix.
> Reason for disabling: external CI usage is on hold, replaced by per-component local verification scripts.
> `.github/workflows/ci.yml` is disabled the same way.

`ci/github-actions-ci.yml` is the canonical workflow (when restored):

1. PR/Push → `pnpm install` + typecheck + build for each component
2. main merge → build images via `docker/Dockerfile.{api,worker,web}` → GHCR push (`ghcr.io/<org>/vnb4-{api,worker,web}:<sha>`)
3. tag push → assign `:vX.Y.Z` to images + release notes

**Re-enable procedure** (see the header comment of `ci/github-actions-ci.yml`):
```bash
cd VNB4-Toeic-ops/ci
sed -n '/ORIGINAL CONTENT BELOW/,$p' github-actions-ci.yml \
  | sed '1,2d' | sed 's/^# //' > github-actions-ci.yml.new
mv github-actions-ci.yml.new github-actions-ci.yml
# then sync the same content into .github/workflows/ci.yml as well
```

EAS (mobile) is planned as a separate workflow. It uses the `production` channel in `app/eas.json`.

---

## 11. System tests

```bash
cd VNB4-Toeic-ops/test
./run-tests.sh                  # all 20 scenarios
./run-tests.sh 15 16 17 18      # verify the 4 README modes
./run-tests.sh 20               # pnpm policy guard
```

Details: [test/README.md](./test/README.md), [test/QUICKSTART_VERIFY.md](./test/QUICKSTART_VERIFY.md).

---

## 12. Monitoring (M6 — TODO)

`compose/docker-compose.observability.yml` is planned to be added:

- Prometheus (Apache-2.0) — scrapes API/Worker `/metrics`
- Grafana (AGPL-3.0) — unmodified image
- Loki (AGPL-3.0) — log aggregation
- OpenTelemetry SDK — API/Worker instrumentation
- Sentry self-host (BSL 1.1) — error tracking

---

## 13. Open source / license summary

| Source | Use | License | Adoption form |
|---|---|---|---|
| nestjs/nest | API framework | MIT | dep |
| vercel/next.js | Admin Web | MIT | dep |
| shadcn-ui/ui | UI components | MIT | source-copy |
| expo/expo | mobile runtime | MIT | dep |
| prisma/prisma | ORM | Apache-2.0 | dep |
| tauri-apps/tauri | Desktop shell | MIT/Apache-2.0 | dep |
| taskforcesh/bullmq | Worker queue | MIT | dep |
| valkey-io/valkey | Cache/queue | BSD-3 | self-host container |
| caddyserver/caddy | Reverse proxy | Apache-2.0 | self-host container |
| pgvector/pgvector | Vector ext | PostgreSQL | self-host container |
| rhasspy/piper | OSS TTS (dev) | MIT | self-host container |

All are either dependencies or *unmodified containers*. No AGPL/BSL trigger.
Full report: [LICENSES.md](./LICENSES.md), auto-generated: `scripts/license-report.sh`.

---

## 14. Deploy targets

- Initial: single VM (4 vCPU / 8GB) + `docker-compose.prod.yml` + self-hosted Postgres + persistent volume
- DB backup: `pg_dump` cron (§6.4)
- As traffic grows: switch to external managed Postgres (§6.2) or to k3s (placeholder set up in `k8s/`)

---

## 15. PRD mapping

| PRD area | Location |
|---|---|
| §3 directory | this structure (§0, §8) |
| §4.3 environment separation (local/prod) | `compose/` × 2 + `env/` × 3 |
| §5.5.1 Docker + Compose | `compose/docker-compose.{local,prod}.yml` |
| §5.5.2 GitHub Actions + EAS | `ci/github-actions-ci.yml` + separate EAS workflow |
| §5.5.3 Caddy auto HTTPS | `caddy/Caddyfile.prod` |
| §5.5.4 monitoring | M6 TODO (§11) |
| §7 license NOTICE generation | `scripts/license-report.sh` |

---

## 16. Roadmap

PRD §9 + [.doc/ROADMAP_STATUS.md](./.doc/ROADMAP_STATUS.md). M0 setup complete. M1–M6 in progress.
