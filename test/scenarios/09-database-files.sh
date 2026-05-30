#!/usr/bin/env bash
# Scenario 09 — VNB4-Toeic-database file structure
# Verifies dual-schema setup (SQLite local + PostgreSQL prod) is in place.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "09-database-files"

# Schemas
assert_file_exists "$DB_ROOT/prisma/schema.prisma"        "prod schema (PostgreSQL)"
assert_file_exists "$DB_ROOT/prisma/schema.local.prisma"  "local schema (SQLite)"

# Env templates
assert_file_exists "$DB_ROOT/.env.example"        ".env.example (prod)"
assert_file_exists "$DB_ROOT/.env.local.example"  ".env.local.example (local SQLite)"

# Manifest + seeds
assert_file_exists "$DB_ROOT/package.json"        "package.json"
assert_file_exists "$DB_ROOT/README.md"           "README.md"
assert_file_exists "$DB_ROOT/seeds/run.ts"        "seed runner"
assert_dir_exists  "$DB_ROOT/seeds/parts"         "seeds/parts dir"

# Per-part seed JSON
for n in 1 2 3 4 5 6 7; do
  assert_file_exists "$DB_ROOT/seeds/parts/part${n}.json" "seeds/parts/part${n}.json"
done

# Schema content checks
assert_grep 'provider[[:space:]]*=[[:space:]]*"postgresql"' "$DB_ROOT/prisma/schema.prisma"       "prod schema uses postgresql"
assert_grep 'pgvector'                                       "$DB_ROOT/prisma/schema.prisma"       "prod schema has pgvector extension"
assert_grep 'provider[[:space:]]*=[[:space:]]*"sqlite"'     "$DB_ROOT/prisma/schema.local.prisma" "local schema uses sqlite"

# Local schema must NOT have enum or Json (SQLite unsupported)
if grep -qE '^enum ' "$DB_ROOT/prisma/schema.local.prisma"; then
  log_fail "local schema contains enum (SQLite incompatible)"
else
  log_pass "local schema has no enum (SQLite compatible)"
fi
# Match field-declaration `Json` only (skip comments via leading //)
if grep -vE '^\s*//' "$DB_ROOT/prisma/schema.local.prisma" | grep -qE '^\s+\w+\s+Json(\?)?\b'; then
  log_fail "local schema uses Json field type (SQLite incompatible)"
else
  log_pass "local schema avoids Json field type (SQLite compatible)"
fi

# Package scripts
assert_grep '"migrate:local"' "$DB_ROOT/package.json" "package.json has migrate:local"
assert_grep '"migrate:prod"'  "$DB_ROOT/package.json" "package.json has migrate:prod"
assert_grep '"seed"'          "$DB_ROOT/package.json" "package.json has seed"
assert_grep '"seed:prod"'     "$DB_ROOT/package.json" "package.json has seed:prod"

# Env content
assert_grep '^DATABASE_URL=file:' "$DB_ROOT/.env.local.example" ".env.local.example points to SQLite file URL"
assert_grep '^DATABASE_URL=postgres' "$DB_ROOT/.env.example"    ".env.example points to PostgreSQL URL"

scenario_end
