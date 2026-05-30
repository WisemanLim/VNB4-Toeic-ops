#!/usr/bin/env bash
# Scenario 16 — README Mode B: docker-compose.local.yml 인프라 + 수동 컴포넌트
# 전체 스택 통합: postgres+valkey+minio+caddy 컨테이너 + backend/frontend/app dev server probe.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "16-mode-b-compose"

if ! command -v docker >/dev/null; then log_skip "docker not installed"; scenario_end; exit 0; fi
if ! docker info >/dev/null 2>&1; then log_skip "docker daemon not running"; scenario_end; exit 0; fi
if ! command -v pnpm >/dev/null; then log_skip "pnpm not installed"; scenario_end; exit 0; fi

COMPOSE_DIR="$OPS_ROOT/compose"
COMPOSE_LOCAL="docker-compose.local.yml"

# ---- B-1: Infra ----
log_info "B-1: docker-compose.local.yml infra 기동"
cd "$COMPOSE_DIR" || { log_fail "cannot cd compose dir"; scenario_end; exit 1; }
if docker compose -f "$COMPOSE_LOCAL" up -d >>"$_scenario_log" 2>&1; then
  log_pass "compose up -d"
else
  log_fail "compose up -d failed"
  scenario_end; exit 1
fi

# Wait for postgres healthy
for i in 1 2 3 4 5 6 7 8 9 10; do
  if docker exec vnb4_postgres pg_isready -U toeic -q 2>/dev/null; then break; fi
  sleep 1
done
if docker exec vnb4_postgres pg_isready -U toeic -q 2>/dev/null; then
  log_pass "postgres ready"
else
  log_fail "postgres not ready after 10s"
fi

# Service inventory
SVC=$(docker compose -f "$COMPOSE_LOCAL" ps --services --status running 2>>"$_scenario_log" | tr '\n' ' ')
echo "running services: $SVC" >> "$_scenario_log"
for s in postgres valkey minio caddy; do
  if echo "$SVC" | grep -qw "$s"; then
    log_pass "service running: $s"
  else
    log_fail "service NOT running: $s"
  fi
done

# ---- B-2: DB migrate + seed:prod ----
log_info "B-2: DB push (PG prod schema) + seed:prod"
cd "$DB_ROOT" || { log_fail "cannot cd DB_ROOT"; scenario_end; exit 1; }
pnpm env:init:prod >>"$_scenario_log" 2>&1 || true
# Use db push (non-interactive) instead of migrate:dev (TTY required) for automation
if pnpm exec dotenv -e .env -- prisma db push --schema prisma/schema.prisma >>"$_scenario_log" 2>&1; then
  log_pass "db push (PG prod schema)"
else
  log_fail "db push failed"
fi
if pnpm seed:prod >>"$_scenario_log" 2>&1; then
  log_pass "seed:prod"
else
  log_fail "seed:prod failed"
fi

if command -v psql >/dev/null || docker exec vnb4_postgres true 2>/dev/null; then
  PG_COUNT=$(docker exec vnb4_postgres psql -U toeic -d toeic_local -tAc 'SELECT COUNT(*) FROM "Word";' 2>>"$_scenario_log" | tr -d ' ')
  EXPECTED=$(node -e "const fs=require('fs');const d='$DB_ROOT/seeds/parts';const u=new Set();for(const f of fs.readdirSync(d).filter(x=>x.endsWith('.json'))){for(const r of JSON.parse(fs.readFileSync(d+'/'+f,'utf8')))u.add(r.part+'|'+String(r.word).toLowerCase())}console.log(u.size)" 2>/dev/null)
  if [ "$PG_COUNT" = "$EXPECTED" ]; then
    log_pass "PG Word count = $PG_COUNT (unique seed total)"
  else
    log_fail "PG Word count = $PG_COUNT (expected $EXPECTED unique seed words)"
  fi
fi

# ---- B-3a: Backend ----
log_info "B-3a: backend api install + start:dev + probe + stop"
cd "$BACKEND_ROOT" || { log_fail "cannot cd BACKEND_ROOT"; scenario_end; exit 1; }
if [ ! -d "$BACKEND_ROOT/node_modules" ] || [ ! -d "$BACKEND_ROOT/api/node_modules" ]; then
  log_info "installing backend deps (may take 1-2min)"
  if pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_pass "backend: pnpm install"
  else
    log_fail "backend: pnpm install failed"
    scenario_end; exit 1
  fi
else
  log_pass "backend: node_modules present"
fi

cd "$BACKEND_ROOT/api" || { log_fail "cannot cd backend/api"; scenario_end; exit 1; }
API_LOG="$TEST_LOG_DIR/${TEST_RUN_ID}_16_api.log"
pnpm start:dev >"$API_LOG" 2>&1 &
API_PID=$!
log_info "backend pid: $API_PID, log: $API_LOG"

# Wait for /api/v1/health (max 90s — nest watch + prisma generate first-run is slow)
HEALTH_OK=0
for i in $(seq 1 90); do
  if curl -sf -m 2 http://localhost:4000/api/v1/health >/dev/null 2>&1; then
    HEALTH_OK=1
    log_info "backend ready after ${i}s"
    break
  fi
  sleep 1
done
if [ "$HEALTH_OK" = "1" ]; then
  log_pass "backend /api/v1/health responsive"
else
  log_fail "backend /api/v1/health did NOT respond in 90s"
  log_info "last 30 lines of backend log:"
  tail -30 "$API_LOG" >> "$_scenario_log" 2>/dev/null
fi

# Stop backend — kill parent + children + sweep orphans (macOS lacks setsid)
pkill -TERM -P $API_PID 2>/dev/null || true
kill -TERM $API_PID 2>/dev/null || true
sleep 2
pkill -KILL -P $API_PID 2>/dev/null || true
kill -KILL $API_PID 2>/dev/null || true
pkill -9 -f "nest start" 2>/dev/null || true
pkill -9 -f "pnpm.*start:dev" 2>/dev/null || true
# Also clear port 4000
PORT_PIDS=$(lsof -ti :4000 2>/dev/null)
[ -n "$PORT_PIDS" ] && kill -9 $PORT_PIDS 2>/dev/null || true
sleep 1
log_info "backend stopped"

# ---- B-3b: Frontend ----
log_info "B-3b: frontend web install (check) + dev probe"
cd "$FRONTEND_ROOT/web" || { log_fail "cannot cd frontend/web"; scenario_end; exit 1; }
if [ ! -d "$FRONTEND_ROOT/web/node_modules" ]; then
  if pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_pass "frontend: pnpm install"
  else
    log_fail "frontend: pnpm install failed"
  fi
else
  log_pass "frontend: node_modules present"
fi

if pnpm typecheck >>"$_scenario_log" 2>&1; then
  log_pass "frontend: pnpm typecheck"
else
  log_fail "frontend: pnpm typecheck failed"
fi

# Start Next.js dev server
WEB_LOG="$TEST_LOG_DIR/${TEST_RUN_ID}_16_web.log"
pnpm dev >"$WEB_LOG" 2>&1 &
WEB_PID=$!
log_info "frontend pid: $WEB_PID, log: $WEB_LOG"
WEB_OK=0
for i in $(seq 1 45); do
  if curl -sf -m 2 http://localhost:3000/ >/dev/null 2>&1; then
    WEB_OK=1
    log_info "frontend ready after ${i}s"
    break
  fi
  sleep 1
done
if [ "$WEB_OK" = "1" ]; then
  log_pass "frontend dev server responsive on :3000"
else
  log_fail "frontend dev server did NOT respond in 45s"
  tail -30 "$WEB_LOG" >> "$_scenario_log" 2>/dev/null
fi
pkill -TERM -P $WEB_PID 2>/dev/null || true
kill -TERM $WEB_PID 2>/dev/null || true
sleep 2
pkill -KILL -P $WEB_PID 2>/dev/null || true
kill -KILL $WEB_PID 2>/dev/null || true
pkill -9 -f "next dev" 2>/dev/null || true
PORT_PIDS=$(lsof -ti :3000 2>/dev/null)
[ -n "$PORT_PIDS" ] && kill -9 $PORT_PIDS 2>/dev/null || true
sleep 1
log_info "frontend stopped"

# ---- B-3c: App (Expo) ----
log_info "B-3c: app install + typecheck (Metro 직접 띄움은 device 필요해 typecheck 로 대체)"
cd "$APP_ROOT" || { log_fail "cannot cd APP_ROOT"; scenario_end; exit 1; }
if [ ! -d "$APP_ROOT/node_modules" ]; then
  if pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_pass "app: pnpm install"
  else
    log_fail "app: pnpm install failed"
  fi
else
  log_pass "app: node_modules present"
fi
if pnpm typecheck >>"$_scenario_log" 2>&1; then
  log_pass "app: pnpm typecheck"
else
  log_fail "app: pnpm typecheck failed"
fi

# ---- E2E reachability check via Caddy ----
log_info "Caddy reverse-proxy 검증 (backend down 상태에선 502 예상)"
CADDY_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 3 http://localhost/ 2>>"$_scenario_log")
log_info "caddy http://localhost/ → HTTP $CADDY_CODE (502 expected when backend stopped)"

scenario_end
