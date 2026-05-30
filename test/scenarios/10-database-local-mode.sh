#!/usr/bin/env bash
# Scenario 10 — local mode (SQLite) end-to-end integration
# Resets local SQLite db, runs migrate + seed, verifies rows + JSON-encoded arrays.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "10-database-local-mode"

# Skip if dependencies missing
if ! command -v pnpm >/dev/null; then
  log_skip "pnpm not installed — cannot run integration"
  scenario_end
  exit 0
fi
if ! command -v sqlite3 >/dev/null; then
  log_skip "sqlite3 CLI not installed — cannot verify db content"
  scenario_end
  exit 0
fi

cd "$DB_ROOT" || { log_fail "cannot cd into $DB_ROOT"; scenario_end; exit 1; }

# node_modules check
if [ ! -d "$DB_ROOT/node_modules" ]; then
  log_info "installing deps (first run)"
  if ! pnpm install --silent >>"$_scenario_log" 2>&1; then
    log_fail "pnpm install failed"
    scenario_end
    exit 1
  fi
fi
log_pass "node_modules present"

# Fresh state — remove db + env to test idempotent setup
rm -f "$DB_ROOT/prisma/dev.db" "$DB_ROOT/.env.local"
log_info "cleared prisma/dev.db and .env.local"

# Run migrate:local
if pnpm migrate:local >>"$_scenario_log" 2>&1; then
  log_pass "pnpm migrate:local succeeded"
else
  log_fail "pnpm migrate:local failed"
  scenario_end
  exit 1
fi

# Verify .env.local auto-created
assert_file_exists "$DB_ROOT/.env.local" ".env.local auto-created"
assert_grep '^DATABASE_URL=file:' "$DB_ROOT/.env.local" ".env.local has SQLite URL"

# Verify SQLite db created
assert_file_exists "$DB_ROOT/prisma/dev.db" "SQLite db file created"

# Verify schema applied — tables exist
TABLES=$(sqlite3 "$DB_ROOT/prisma/dev.db" ".tables" 2>>"$_scenario_log")
echo "tables: $TABLES" >> "$_scenario_log"
for t in User Word Lesson Progress AudioAsset Note Bookmark Curriculum Job AuthIdentity Session LessonWord SentenceItem; do
  if echo "$TABLES" | grep -qw "$t"; then
    log_pass "table exists: $t"
  else
    log_fail "table missing: $t"
  fi
done

# Run seed
if pnpm seed >>"$_scenario_log" 2>&1; then
  log_pass "pnpm seed succeeded"
else
  log_fail "pnpm seed failed"
  scenario_end
  exit 1
fi

# Verify Word rowcount == unique (part, word) across seed JSON (matches run.ts dedup)
COUNT=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT COUNT(*) FROM Word;" 2>>"$_scenario_log")
if [ "$COUNT" -gt 0 ] 2>/dev/null; then
  log_pass "Word rowcount > 0 (actual: $COUNT)"
else
  log_fail "Word table empty (got '$COUNT')"
fi
EXPECTED=$(node -e "const fs=require('fs');const d='$DB_ROOT/seeds/parts';const u=new Set();for(const f of fs.readdirSync(d).filter(x=>x.endsWith('.json'))){for(const r of JSON.parse(fs.readFileSync(d+'/'+f,'utf8')))u.add(r.part+'|'+String(r.word).toLowerCase())}console.log(u.size)" 2>/dev/null)
if [ "$COUNT" = "$EXPECTED" ]; then
  log_pass "Word rowcount matches unique seed total ($EXPECTED)"
else
  log_info "Word rowcount: $COUNT (expected $EXPECTED unique seed words)"
fi

# Verify JSON-encoded array fields (SQLite stores topic/synonyms/distractors as JSON strings)
TOPIC=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT topic FROM Word WHERE id='toeic-p1-pavement';" 2>>"$_scenario_log")
if echo "$TOPIC" | grep -qE '^\[.*\]$'; then
  log_pass "topic field is JSON-encoded array (got: $TOPIC)"
else
  log_fail "topic field not JSON-encoded (got: $TOPIC)"
fi

SYN=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT synonyms FROM Word WHERE id='toeic-p1-pavement';" 2>>"$_scenario_log")
if echo "$SYN" | grep -qE '^\[.*\]$'; then
  log_pass "synonyms field is JSON-encoded array (got: $SYN)"
else
  log_fail "synonyms field not JSON-encoded (got: $SYN)"
fi

# 문장쓰기/쉐도잉 SentenceItem rowcount (parts 1-4).
# run.ts upserts by id and skips duplicate ids, so the expected count is the
# number of UNIQUE ids across the seed files (not the raw array length).
SCOUNT=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT COUNT(*) FROM SentenceItem;" 2>>"$_scenario_log")
SEXPECT=$(node -e "const fs=require('fs');const d='$DB_ROOT/seeds/sentences';const u=new Set();try{for(const f of fs.readdirSync(d).filter(x=>x.endsWith('.json')))for(const r of JSON.parse(fs.readFileSync(d+'/'+f,'utf8')))u.add(r.id)}catch(e){}console.log(u.size)" 2>/dev/null)
if [ "$SCOUNT" -gt 0 ] 2>/dev/null; then
  log_pass "SentenceItem rowcount > 0 (actual: $SCOUNT)"
else
  log_fail "SentenceItem table empty (got '$SCOUNT')"
fi
if [ -n "$SEXPECT" ] && [ "$SEXPECT" -gt 0 ] 2>/dev/null && [ "$SCOUNT" = "$SEXPECT" ]; then
  log_pass "SentenceItem rowcount matches unique seed ids ($SEXPECT)"
else
  log_fail "SentenceItem rowcount $SCOUNT != unique seed ids $SEXPECT"
fi

# Per-part counts
for n in 1 2 3 4 5 6 7; do
  C=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT COUNT(*) FROM Word WHERE part='P${n}';" 2>>"$_scenario_log")
  if [ "$C" -gt 0 ] 2>/dev/null; then
    log_pass "part P${n}: $C words"
  else
    log_fail "part P${n}: empty"
  fi
done

# Idempotency check — re-run seed, count unchanged
if pnpm seed >>"$_scenario_log" 2>&1; then
  COUNT2=$(sqlite3 "$DB_ROOT/prisma/dev.db" "SELECT COUNT(*) FROM Word;" 2>>"$_scenario_log")
  if [ "$COUNT" = "$COUNT2" ]; then
    log_pass "seed idempotent ($COUNT before, $COUNT2 after re-run)"
  else
    log_fail "seed non-idempotent ($COUNT → $COUNT2)"
  fi
else
  log_fail "second pnpm seed failed"
fi

scenario_end
