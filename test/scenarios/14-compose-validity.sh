#!/usr/bin/env bash
# Scenario 14 — Docker compose validity (local + prod)
# Lints both compose files, validates referenced bind mounts + caddyfiles exist.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "14-compose-validity"

if ! command -v docker >/dev/null; then
  log_skip "docker CLI not installed"
  scenario_end
  exit 0
fi
if ! docker info >/dev/null 2>&1; then
  log_skip "docker daemon not running"
  scenario_end
  exit 0
fi

LOCAL_YML="$OPS_ROOT/compose/docker-compose.local.yml"
PROD_YML="$OPS_ROOT/compose/docker-compose.prod.yml"

assert_file_exists "$LOCAL_YML" "local compose file"
assert_file_exists "$PROD_YML"  "prod compose file"

# Bind-mount targets referenced from local compose
assert_file_exists "$DB_ROOT/local/init.sql"            "postgres init.sql (mounted)"
assert_file_exists "$OPS_ROOT/caddy/Caddyfile.local"    "Caddyfile.local (mounted)"
assert_file_exists "$OPS_ROOT/caddy/Caddyfile.prod"     "Caddyfile.prod (mounted)"

# Syntax/schema validation via `docker compose config`
if (cd "$OPS_ROOT/compose" && docker compose -f docker-compose.local.yml config >/dev/null 2>>"$_scenario_log"); then
  log_pass "docker-compose.local.yml validates"
else
  log_fail "docker-compose.local.yml has invalid syntax/refs"
fi

# prod compose 는 .env.prod 의 POSTGRES_PASSWORD 등을 strict-require 하므로
# 검증 시점에는 example 파일을 env-file 로 주입.
if (cd "$OPS_ROOT/compose" && docker compose -f docker-compose.prod.yml --env-file "$OPS_ROOT/env/.env.prod.example" config >/dev/null 2>>"$_scenario_log"); then
  log_pass "docker-compose.prod.yml validates (with .env.prod.example)"
else
  log_fail "docker-compose.prod.yml has invalid syntax/refs"
fi

# Verify prod compose includes postgres service (self-hosted default)
PROD_SVC=$(cd "$OPS_ROOT/compose" && docker compose -f docker-compose.prod.yml --env-file "$OPS_ROOT/env/.env.prod.example" config --services 2>>"$_scenario_log" | sort | tr '\n' ' ')
echo "prod services: $PROD_SVC" >> "$_scenario_log"
for s in postgres api worker web valkey caddy; do
  if echo "$PROD_SVC" | grep -qw "$s"; then
    log_pass "prod compose defines service: $s"
  else
    log_fail "prod compose missing service: $s"
  fi
done

# Service inventory (local)
SVC=$(cd "$OPS_ROOT/compose" && docker compose -f docker-compose.local.yml config --services 2>>"$_scenario_log" | sort | tr '\n' ' ')
echo "local services: $SVC" >> "$_scenario_log"
for s in postgres valkey minio caddy; do
  if echo "$SVC" | grep -qw "$s"; then
    log_pass "local compose defines service: $s"
  else
    log_fail "local compose missing service: $s"
  fi
done

# Runtime probe (if local stack is already up — opportunistic, never required)
if docker ps --format '{{.Names}}' | grep -qw vnb4_postgres; then
  log_info "vnb4_postgres running — probing health"
  if docker exec vnb4_postgres pg_isready -U toeic -d toeic_local -q 2>>"$_scenario_log"; then
    log_pass "postgres pg_isready OK"
  else
    log_fail "postgres pg_isready failed"
  fi
  if docker exec vnb4_postgres psql -U toeic -d toeic_local -tAc "SELECT 1 FROM pg_extension WHERE extname='vector';" 2>>"$_scenario_log" | grep -q '^1$'; then
    log_pass "pgvector extension installed"
  else
    log_fail "pgvector extension missing (init.sql did not run)"
  fi
else
  log_info "local stack not running — skipping runtime probe (start via: docker compose -f docker-compose.local.yml up -d)"
fi

if docker ps --format '{{.Names}}' | grep -qw vnb4_valkey; then
  if docker exec vnb4_valkey valkey-cli ping 2>>"$_scenario_log" | grep -q PONG; then
    log_pass "valkey ping OK"
  else
    log_fail "valkey not responding"
  fi
fi

scenario_end
