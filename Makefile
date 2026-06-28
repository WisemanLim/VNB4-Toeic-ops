SHELL := /bin/bash

# ─────────────────────────────────────────────────────────────────────
# VNB4-Toeic ops Makefile
# ─────────────────────────────────────────────────────────────────────
# Server-deploy 친화. 절대경로 하드코딩 제거 — Makefile 위치 기준으로
# 자동 해결 + 환경변수 오버라이드. 부재 컴포넌트는 graceful skip.
# ─────────────────────────────────────────────────────────────────────

# Ops dir = this Makefile's dir (absolute, trailing-slash stripped)
OPS_DIR   := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
REPO_ROOT := $(abspath $(OPS_DIR)/..)

# ─────────────────────────────────────────────────────────────────────
# Component path resolution
# ─────────────────────────────────────────────────────────────────────
# 우선순위:
#   1) 환경변수 (VNB4_*_DIR)
#   2) REPO_ROOT 의 sibling (서버 + 개발 공통 기본값)
#   3) 개발 머신 대안 경로 (mac 디스크 분리 사례)
#
# 부재 시 빈 문자열 → 관련 타겟이 graceful skip.

DB_DIR       ?= $(VNB4_DB_DIR)
BACKEND_DIR  ?= $(VNB4_BACKEND_DIR)
FRONTEND_DIR ?= $(VNB4_FRONTEND_DIR)
APP_DIR      ?= $(VNB4_APP_DIR)

# 후보 경로 — 첫 번째 existing dir 채택. 부재면 빈 값.
define RESOLVE
$(strip $(firstword $(foreach p,$(1),$(if $(wildcard $(p)/.),$(p),))))
endef

DB_DIR       := $(or $(DB_DIR),$(call RESOLVE,$(REPO_ROOT)/VNB4-Toeic-database))
BACKEND_DIR  := $(or $(BACKEND_DIR),$(call RESOLVE,$(REPO_ROOT)/VNB4-Toeic-backend))
FRONTEND_DIR := $(or $(FRONTEND_DIR),$(call RESOLVE,$(REPO_ROOT)/VNB4-Toeic-frontend))

# App candidates (모바일은 dev 머신에서만 운영; 서버는 보통 부재 — graceful)
APP_CANDIDATES := \
  $(REPO_ROOT)/VNB4-Toeic-app \
  $(REPO_ROOT)/../Apps(Android,iOS,...)/VNB4-Toeic-app \
  $(REPO_ROOT)/../app/VNB4-Toeic-app \
  /opt/vnb4-app \
  $(HOME)/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app
APP_DIR := $(or $(APP_DIR),$(call RESOLVE,$(APP_CANDIDATES)))

# Compose / env (ops 디렉토리 기준 상대경로 — server safe)
COMPOSE_LOCAL := $(OPS_DIR)/compose/docker-compose.local.yml
COMPOSE_PROD  := $(OPS_DIR)/compose/docker-compose.prod.yml
ENV_PROD      := $(OPS_DIR)/env/.env.prod

# Docker image registry/tag (override on cli)
REGISTRY ?= ghcr.io/vnb4
TAG      ?= latest

# ─────────────────────────────────────────────────────────────────────
# Guard macros
# ─────────────────────────────────────────────────────────────────────
# REQUIRE_DIR — 부재면 즉시 fail (의무 컴포넌트용)
# OPTIONAL_DIR — 부재면 skip 메시지 출력하고 성공 종료 (앱 등)

REQUIRE_DIR = @if [ -z "$($(1))" ] || [ ! -d "$($(1))" ]; then \
  echo "ERROR: $(1) not resolved (looked for VNB4-Toeic-$$(echo $(1) | tr '[:upper:]' '[:lower:]' | sed 's/_dir//') under $(REPO_ROOT))"; \
  echo "  hint: export VNB4_$(1)=/path/to/dir 로 오버라이드 또는 sibling 디렉토리 배치."; \
  exit 1; fi
# (Optional-skip pattern is inlined per-recipe with `if/then/else/fi` because
#  each make recipe line is its own subshell — a macro-level `exit 0` would
#  only terminate the first line, not the whole recipe.)

# ─────────────────────────────────────────────────────────────────────
# Help / Info
# ─────────────────────────────────────────────────────────────────────
.PHONY: help info check-paths
help:
	@echo "── VNB4-TOEIC ops Makefile ─────────────────────────────────"
	@echo ""
	@echo "  make help              명령 목록"
	@echo "  make info              해석된 경로/환경 확인"
	@echo "  make check-paths       필수 컴포넌트 경로 검증"
	@echo "  make bootstrap         pnpm 의존성 설치 (있는 컴포넌트만)"
	@echo ""
	@echo "── Lint / Typecheck / Test ─────────────────────────────────"
	@echo "  make lint              ESLint 전체"
	@echo "  make typecheck         tsc --noEmit 전체"
	@echo "  make test              pnpm -r test (백엔드 + 컴포넌트별)"
	@echo "  make ci                lint + typecheck + test"
	@echo ""
	@echo "── DB / Seed ───────────────────────────────────────────────"
	@echo "  make migrate-local     SQLite db push + client gen"
	@echo "  make migrate-dev       PostgreSQL migrate dev (TTY 필요)"
	@echo "  make migrate-prod      PostgreSQL migrate deploy"
	@echo "  make seed              SQLite 시드 (≈3,700 단어)"
	@echo "  make seed-prod         PostgreSQL 시드"
	@echo "  make studio            Prisma Studio (SQLite)"
	@echo ""
	@echo "── Build (Docker images) ───────────────────────────────────"
	@echo "  make build             api + worker + web 이미지 빌드"
	@echo "  make build-api / build-worker / build-web"
	@echo ""
	@echo "── Docker dev stack (local compose) ────────────────────────"
	@echo "  make docker-dev        local 스택 기동 (postgres/valkey/minio/caddy)"
	@echo "  make docker-logs       전체 로그 추적"
	@echo "  make docker-ps         상태 확인"
	@echo "  make docker-down       정지 (볼륨 유지)"
	@echo "  make docker-clean      정지 + 볼륨 삭제"
	@echo ""
	@echo "── Docker prod stack ───────────────────────────────────────"
	@echo "  make docker-prod-up    prod 스택 기동 (.env.prod 필요)"
	@echo "  make docker-prod-down"
	@echo "  make docker-prod-logs"
	@echo "  make docker-prod-migrate   컨테이너 내부 prisma migrate deploy"
	@echo ""
	@echo "── Dev servers (host) ──────────────────────────────────────"
	@echo "  make dev-api / dev-worker / dev-web"
	@echo "  make dev-app           Expo dev (APP_DIR 필요)"
	@echo ""
	@echo "── Misc ────────────────────────────────────────────────────"
	@echo "  make license-report    THIRD_PARTY_NOTICES 생성"
	@echo "  make smoke             health 엔드포인트 확인"
	@echo "  make clean             node_modules + dist 삭제 (있는 것만)"
	@echo ""
	@echo "── Path overrides (env) ────────────────────────────────────"
	@echo "  VNB4_DB_DIR        VNB4_BACKEND_DIR"
	@echo "  VNB4_FRONTEND_DIR  VNB4_APP_DIR"

info:
	@echo "OPS_DIR       = $(OPS_DIR)"
	@echo "REPO_ROOT     = $(REPO_ROOT)"
	@echo "DB_DIR        = $(or $(DB_DIR),«not found»)"
	@echo "BACKEND_DIR   = $(or $(BACKEND_DIR),«not found»)"
	@echo "FRONTEND_DIR  = $(or $(FRONTEND_DIR),«not found»)"
	@echo "APP_DIR       = $(or $(APP_DIR),«not found — optional»)"
	@echo "COMPOSE_LOCAL = $(COMPOSE_LOCAL)"
	@echo "COMPOSE_PROD  = $(COMPOSE_PROD)"
	@echo "ENV_PROD      = $(ENV_PROD)"
	@echo "REGISTRY      = $(REGISTRY)"
	@echo "TAG           = $(TAG)"

check-paths:
	$(call REQUIRE_DIR,DB_DIR)
	$(call REQUIRE_DIR,BACKEND_DIR)
	$(call REQUIRE_DIR,FRONTEND_DIR)
	@echo "✓ required component paths resolved"
	@if [ -z "$(APP_DIR)" ]; then echo "ℹ APP_DIR not resolved (optional — mobile builds skipped)"; \
	 else echo "✓ APP_DIR = $(APP_DIR)"; fi

# ─────────────────────────────────────────────────────────────────────
# Bootstrap
# ─────────────────────────────────────────────────────────────────────
.PHONY: bootstrap bootstrap-db bootstrap-backend bootstrap-frontend bootstrap-app
bootstrap: bootstrap-db bootstrap-backend bootstrap-frontend bootstrap-app
	@echo "✓ bootstrap complete"

bootstrap-db:
	$(call REQUIRE_DIR,DB_DIR)
	@echo "▶ pnpm install — database"
	cd "$(DB_DIR)" && pnpm install

bootstrap-backend:
	$(call REQUIRE_DIR,BACKEND_DIR)
	@echo "▶ pnpm install — backend"
	cd "$(BACKEND_DIR)" && pnpm install

bootstrap-frontend:
	$(call REQUIRE_DIR,FRONTEND_DIR)
	@echo "▶ pnpm install — frontend"
	cd "$(FRONTEND_DIR)" && pnpm install

bootstrap-app:
	@if [ -n "$(APP_DIR)" ] && [ -d "$(APP_DIR)" ]; then \
	  echo "▶ pnpm install — app"; \
	  cd "$(APP_DIR)" && pnpm install; \
	else \
	  echo "⊘ APP_DIR not found — skipping (set VNB4_APP_DIR to enable)"; \
	fi

# ─────────────────────────────────────────────────────────────────────
# Lint / Typecheck / Test / CI
# ─────────────────────────────────────────────────────────────────────
.PHONY: lint lint-backend lint-frontend lint-app
lint: lint-backend lint-frontend lint-app

lint-backend:
	$(call REQUIRE_DIR,BACKEND_DIR)
	cd "$(BACKEND_DIR)" && pnpm -r lint || true

lint-frontend:
	$(call REQUIRE_DIR,FRONTEND_DIR)
	cd "$(FRONTEND_DIR)/web" && pnpm lint || true

lint-app:
	@if [ -n "$(APP_DIR)" ] && [ -d "$(APP_DIR)" ]; then \
	  cd "$(APP_DIR)" && pnpm lint || true; \
	else \
	  echo "⊘ APP_DIR not found — skipping lint-app"; \
	fi

.PHONY: typecheck typecheck-backend typecheck-frontend typecheck-app
typecheck: typecheck-backend typecheck-frontend typecheck-app

typecheck-backend:
	$(call REQUIRE_DIR,BACKEND_DIR)
	cd "$(BACKEND_DIR)/api"    && pnpm exec tsc --noEmit
	cd "$(BACKEND_DIR)/worker" && pnpm exec tsc --noEmit

typecheck-frontend:
	$(call REQUIRE_DIR,FRONTEND_DIR)
	cd "$(FRONTEND_DIR)/web" && pnpm typecheck

typecheck-app:
	@if [ -n "$(APP_DIR)" ] && [ -d "$(APP_DIR)" ]; then \
	  cd "$(APP_DIR)" && pnpm typecheck; \
	else \
	  echo "⊘ APP_DIR not found — skipping typecheck-app"; \
	fi

.PHONY: test test-backend
test: test-backend

test-backend:
	$(call REQUIRE_DIR,BACKEND_DIR)
	cd "$(BACKEND_DIR)" && pnpm -r test

.PHONY: ci
ci: check-paths lint typecheck test
	@echo "✓ ci pipeline complete"

# ─────────────────────────────────────────────────────────────────────
# DB / Seed
# ─────────────────────────────────────────────────────────────────────
.PHONY: migrate-local migrate-dev migrate-prod seed seed-prod studio
migrate-local:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm migrate:local

migrate-dev:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm migrate:dev

migrate-prod:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm migrate:prod

seed:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm seed

seed-prod:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm seed:prod

studio:
	$(call REQUIRE_DIR,DB_DIR)
	cd "$(DB_DIR)" && pnpm studio

# ─────────────────────────────────────────────────────────────────────
# Build Docker images
# ─────────────────────────────────────────────────────────────────────
# Build context = REPO_ROOT (모든 컴포넌트 접근 가능). Dockerfile은 ops/docker/.
.PHONY: build build-api build-worker build-web
build: build-api build-worker build-web

build-api:
	docker build -f "$(OPS_DIR)/docker/Dockerfile.api" \
	  -t $(REGISTRY)/vnb4-api:$(TAG) "$(REPO_ROOT)"

build-worker:
	docker build -f "$(OPS_DIR)/docker/Dockerfile.worker" \
	  -t $(REGISTRY)/vnb4-worker:$(TAG) "$(REPO_ROOT)"

build-web:
	docker build -f "$(OPS_DIR)/docker/Dockerfile.web" \
	  -t $(REGISTRY)/vnb4-web:$(TAG) "$(REPO_ROOT)"

# ─────────────────────────────────────────────────────────────────────
# Local docker compose (mode B — infra only)
# ─────────────────────────────────────────────────────────────────────
.PHONY: docker-dev docker-logs docker-ps docker-down docker-clean
docker-dev:
	docker compose -f "$(COMPOSE_LOCAL)" up -d
	docker compose -f "$(COMPOSE_LOCAL)" ps

docker-logs:
	docker compose -f "$(COMPOSE_LOCAL)" logs -f --tail=200

docker-ps:
	docker compose -f "$(COMPOSE_LOCAL)" ps

docker-down:
	docker compose -f "$(COMPOSE_LOCAL)" down

docker-clean:
	docker compose -f "$(COMPOSE_LOCAL)" down -v --remove-orphans

# ─────────────────────────────────────────────────────────────────────
# Prod docker compose (mode C — self-hosted)
# ─────────────────────────────────────────────────────────────────────
.PHONY: docker-prod-up docker-prod-down docker-prod-logs docker-prod-migrate
docker-prod-up:
	@test -f "$(ENV_PROD)" || { \
	  echo "ERROR: $(ENV_PROD) missing."; \
	  echo "  cp $(OPS_DIR)/env/.env.prod.example $(ENV_PROD) 후 시크릿 교체."; \
	  exit 1; }
	docker compose -f "$(COMPOSE_PROD)" --env-file "$(ENV_PROD)" up -d
	docker compose -f "$(COMPOSE_PROD)" ps

docker-prod-down:
	docker compose -f "$(COMPOSE_PROD)" down

docker-prod-logs:
	docker compose -f "$(COMPOSE_PROD)" logs -f --tail=200

docker-prod-migrate:
	docker compose -f "$(COMPOSE_PROD)" exec api \
	  sh -c "cd /app && pnpm prisma migrate deploy --schema /app/prisma/schema.prisma"

# ─────────────────────────────────────────────────────────────────────
# Dev servers (host-side, 별도 터미널 권장)
# ─────────────────────────────────────────────────────────────────────
.PHONY: dev-api dev-worker dev-web dev-app
dev-api:
	$(call REQUIRE_DIR,BACKEND_DIR)
	cd "$(BACKEND_DIR)/api" && pnpm start:dev

dev-worker:
	$(call REQUIRE_DIR,BACKEND_DIR)
	cd "$(BACKEND_DIR)/worker" && pnpm start:dev

dev-web:
	$(call REQUIRE_DIR,FRONTEND_DIR)
	cd "$(FRONTEND_DIR)" && pnpm web:dev

dev-app:
	$(call REQUIRE_DIR,APP_DIR)
	cd "$(APP_DIR)" && pnpm start

# ─────────────────────────────────────────────────────────────────────
# Misc
# ─────────────────────────────────────────────────────────────────────
.PHONY: smoke license-report clean
smoke:
	@echo "▶ caddy /"
	@curl -fsS -o /dev/null -w "  HTTP %{http_code}\n" http://localhost/ 2>/dev/null || echo "  caddy not reachable"
	@echo "▶ api /health"
	@curl -fsS http://localhost:4000/health 2>/dev/null || echo "  api not reachable"
	@echo "▶ minio live"
	@curl -fsS -o /dev/null -w "  HTTP %{http_code}\n" http://localhost:9000/minio/health/live 2>/dev/null || echo "  minio not reachable"

license-report:
	bash "$(OPS_DIR)/scripts/license-report.sh"

clean:
	@echo "▶ cleaning node_modules + dist (existing dirs only)"
	@for d in "$(DB_DIR)" "$(BACKEND_DIR)" "$(BACKEND_DIR)/api" "$(BACKEND_DIR)/worker" \
	          "$(FRONTEND_DIR)" "$(FRONTEND_DIR)/web" "$(FRONTEND_DIR)/desktop" "$(APP_DIR)"; do \
	  [ -n "$$d" ] && [ -d "$$d/node_modules" ] && { echo "  rm $$d/node_modules"; rm -rf "$$d/node_modules"; } || true; \
	done
	@for d in "$(BACKEND_DIR)/api/dist" "$(BACKEND_DIR)/worker/dist" "$(FRONTEND_DIR)/web/.next"; do \
	  [ -d "$$d" ] && { echo "  rm $$d"; rm -rf "$$d"; } || true; \
	done
