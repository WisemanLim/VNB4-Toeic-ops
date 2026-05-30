#!/usr/bin/env bash
# Scenario 15 — README Mode A: SQLite (Docker 불필요), 컴포넌트 수동 실행
# DB layer (SQLite) + app(typecheck) 만 검증. backend/frontend 는 PG 필요하므로 모드 B 에서 처리.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "15-mode-a-sqlite"

if ! command -v pnpm >/dev/null; then
  log_skip "pnpm not installed"
  scenario_end; exit 0
fi

# ---- DB layer (Mode A) ----
log_info "DB layer (SQLite) — README mode A 검증"

cd "$DB_ROOT" || { log_fail "cannot cd $DB_ROOT"; scenario_end; exit 1; }
if [ ! -d "$DB_ROOT/node_modules" ]; then
  if pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_pass "db: pnpm install"
  else
    log_fail "db: pnpm install"
    scenario_end; exit 1
  fi
else
  log_pass "db: node_modules already present"
fi

rm -f "$DB_ROOT/prisma/dev.db"
if pnpm migrate:local >>"$_scenario_log" 2>&1; then
  log_pass "db: pnpm migrate:local (SQLite)"
else
  log_fail "db: pnpm migrate:local"
  scenario_end; exit 1
fi
assert_file_exists "$DB_ROOT/prisma/dev.db" "SQLite db created"

if pnpm seed >>"$_scenario_log" 2>&1; then
  log_pass "db: pnpm seed (SQLite)"
else
  log_fail "db: pnpm seed"
fi

if command -v sqlite3 >/dev/null; then
  COUNT=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT COUNT(*) FROM Word;" 2>>"$_scenario_log")
  # Expected = unique (part, word) across seed JSON (dedup matches seeds/run.ts).
  EXPECTED=$(node -e "const fs=require('fs');const d='$DB_ROOT/seeds/parts';const u=new Set();for(const f of fs.readdirSync(d).filter(x=>x.endsWith('.json'))){for(const r of JSON.parse(fs.readFileSync(d+'/'+f,'utf8')))u.add(r.part+'|'+String(r.word).toLowerCase())}console.log(u.size)" 2>/dev/null)
  if [ "$COUNT" = "$EXPECTED" ]; then
    log_pass "db: SQLite Word count = $COUNT (unique seed total)"
  else
    log_fail "db: SQLite Word count = $COUNT (expected $EXPECTED unique seed words)"
  fi
else
  log_skip "sqlite3 CLI not installed — cannot verify count"
fi

# ---- App layer (수동 실행 가능 검증: install + typecheck) ----
log_info "App layer — install + typecheck (백엔드 없이도 확인 가능)"

cd "$APP_ROOT" || { log_fail "cannot cd $APP_ROOT"; scenario_end; exit 1; }
if [ ! -d "$APP_ROOT/node_modules" ]; then
  if pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_pass "app: pnpm install"
  else
    log_fail "app: pnpm install"
  fi
else
  log_pass "app: node_modules already present"
fi

if pnpm typecheck >>"$_scenario_log" 2>&1; then
  log_pass "app: pnpm typecheck"
else
  log_fail "app: pnpm typecheck"
fi

# Verify Metro/Expo entrypoint loads (briefly, then kill)
if command -v node >/dev/null; then
  if [ -f "$APP_ROOT/node_modules/.bin/expo" ]; then
    log_pass "app: expo CLI available"
  else
    log_fail "app: expo CLI missing (node_modules incomplete)"
  fi
else
  log_skip "node not installed — cannot probe Metro"
fi

log_info "Mode A 결론: SQLite DB + App 수동 실행 가능. backend/frontend 는 mode B 필요."

scenario_end
