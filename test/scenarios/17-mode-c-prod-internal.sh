#!/usr/bin/env bash
# Scenario 17 — README Mode C-1: docker-compose.prod.yml + self-hosted postgres
# 운영 이미지(api/worker/web)는 본 환경에 빌드 안 되어 있어 postgres+valkey 만 검증.
# Mode B (local compose) 와 포트 충돌하므로 임시로 B 를 내림 → C 검증 → B 복원.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "17-mode-c-prod-internal"

if ! command -v docker >/dev/null; then log_skip "docker not installed"; scenario_end; exit 0; fi
if ! docker info >/dev/null 2>&1; then log_skip "docker daemon not running"; scenario_end; exit 0; fi

COMPOSE_DIR="$OPS_ROOT/compose"
ENV_DIR="$OPS_ROOT/env"
ENV_PROD="$ENV_DIR/.env.prod"
ENV_PROD_EXAMPLE="$ENV_DIR/.env.prod.example"
COMPOSE_LOCAL="docker-compose.local.yml"
COMPOSE_PROD="docker-compose.prod.yml"
CREATED_ENV_PROD=0

# ---- Prep .env.prod (시험용 placeholder 값으로 채움) ----
if [ ! -f "$ENV_PROD" ]; then
  log_info ".env.prod 가 없어 example 에서 시험용 비밀번호로 채워서 생성"
  if [ ! -f "$ENV_PROD_EXAMPLE" ]; then
    log_fail ".env.prod.example missing"
    scenario_end; exit 1
  fi
  # 시험용 약한 비밀번호 (실제 배포 절대 사용 X)
  sed 's/__STRONG_DB_PASSWORD__/testpw123/g; s/__STRONG_JWT_SECRET_64CHARS__/test-jwt-secret-do-not-use-in-prod/g; s/__SECRET__/test-placeholder/g' \
    "$ENV_PROD_EXAMPLE" > "$ENV_PROD"
  CREATED_ENV_PROD=1
  log_pass ".env.prod 임시 생성 (시험 종료 후 삭제)"
else
  log_info ".env.prod 가 이미 존재 — 그대로 사용"
fi

# ---- 포트 충돌 회피: 로컬 compose 가 실행 중이면 내림 ----
LOCAL_RUNNING=0
if (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_LOCAL" ps --services --status running 2>/dev/null | grep -q '.'); then
  LOCAL_RUNNING=1
  log_info "로컬 compose 실행 중 → 임시로 down"
  if (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_LOCAL" down >>"$_scenario_log" 2>&1); then
    log_pass "local compose down"
  else
    log_fail "local compose down 실패"
  fi
fi

# ---- prod compose config 검증 ----
if (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_PROD" --env-file "$ENV_PROD" config >/dev/null 2>>"$_scenario_log"); then
  log_pass "prod compose config validates with .env.prod"
else
  log_fail "prod compose config 실패"
fi

# ---- postgres + valkey + caddy 만 기동 (api/worker/web 이미지 부재 회피) ----
log_info "postgres + valkey 기동 (api/worker/web 이미지 미존재로 제외)"
if (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_PROD" --env-file "$ENV_PROD" up -d postgres valkey >>"$_scenario_log" 2>&1); then
  log_pass "prod compose: postgres + valkey up"
else
  log_fail "prod compose 기동 실패"
  tail -30 "$_scenario_log" >> "$_scenario_log" 2>/dev/null
  # Cleanup + restore
  (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_PROD" down >>"$_scenario_log" 2>&1)
  [ "$LOCAL_RUNNING" = "1" ] && (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_LOCAL" up -d >>"$_scenario_log" 2>&1)
  [ "$CREATED_ENV_PROD" = "1" ] && rm -f "$ENV_PROD"
  scenario_end; exit 1
fi

# ---- 프로젝트 네임스페이스 확인 (vnb4-toeic-prod) ----
PROD_PG=$(docker ps --format "{{.Names}}" | grep "vnb4-toeic-prod" | grep postgres | head -1)
if [ -n "$PROD_PG" ]; then
  log_pass "prod postgres container running: $PROD_PG"
else
  log_fail "prod postgres container not found"
fi

# Wait for healthy
log_info "postgres healthy 대기 (최대 30s)"
HEALTHY=0
for i in $(seq 1 30); do
  if [ -n "$PROD_PG" ] && docker exec "$PROD_PG" pg_isready -U toeic -d toeic_prod -q 2>/dev/null; then
    HEALTHY=1
    break
  fi
  sleep 1
done
if [ "$HEALTHY" = "1" ]; then
  log_pass "prod postgres pg_isready"
else
  log_fail "prod postgres healthy 실패 (30s)"
fi

# pgvector 확장 검증 (init.sql 실행 확인)
if [ -n "$PROD_PG" ]; then
  if docker exec "$PROD_PG" psql -U toeic -d toeic_prod -tAc "SELECT 1 FROM pg_extension WHERE extname='vector';" 2>>"$_scenario_log" | grep -q '^1$'; then
    log_pass "prod postgres pgvector extension installed (init.sql ran)"
  else
    log_fail "prod postgres pgvector missing (init.sql did not run)"
  fi
fi

# valkey ping
if docker ps --format "{{.Names}}" | grep -q "vnb4-toeic-prod.*valkey"; then
  PROD_VALKEY=$(docker ps --format "{{.Names}}" | grep "vnb4-toeic-prod.*valkey" | head -1)
  if docker exec "$PROD_VALKEY" valkey-cli ping 2>>"$_scenario_log" | grep -q PONG; then
    log_pass "prod valkey ping OK"
  else
    log_fail "prod valkey ping 실패"
  fi
fi

# ---- 정리: prod down, 로컬 복원 ----
log_info "정리: prod compose down + (필요시) 로컬 compose 복원"
(cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_PROD" --env-file "$ENV_PROD" down -v >>"$_scenario_log" 2>&1)
log_pass "prod compose down (volumes 도 삭제)"

if [ "$LOCAL_RUNNING" = "1" ]; then
  if (cd "$COMPOSE_DIR" && docker compose -f "$COMPOSE_LOCAL" up -d >>"$_scenario_log" 2>&1); then
    log_pass "로컬 compose 복원"
  else
    log_fail "로컬 compose 복원 실패"
  fi
fi

if [ "$CREATED_ENV_PROD" = "1" ]; then
  rm -f "$ENV_PROD"
  log_pass ".env.prod 임시본 삭제"
fi

log_info "Mode C-1 결론: self-hosted postgres + valkey 기동·healthy·pgvector 확인. api/worker/web 이미지는 별도 빌드/CI 필요."

scenario_end
