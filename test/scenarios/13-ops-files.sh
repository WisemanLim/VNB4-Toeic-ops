#!/usr/bin/env bash
# Scenario 13 — VNB4-Toeic-ops (Docker Compose + Caddy + CI) file structure
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "13-ops-files"

# Top-level
assert_file_exists "$OPS_ROOT/README.md"                       "ops README"

# Compose
assert_file_exists "$OPS_ROOT/compose/docker-compose.local.yml" "docker-compose.local.yml"
assert_file_exists "$OPS_ROOT/compose/docker-compose.prod.yml"  "docker-compose.prod.yml"

# Caddy
assert_file_exists "$OPS_ROOT/caddy/Caddyfile.local"           "Caddyfile.local"
assert_file_exists "$OPS_ROOT/caddy/Caddyfile.prod"            "Caddyfile.prod"

# Dockerfiles
assert_file_exists "$OPS_ROOT/docker/Dockerfile.api"           "Dockerfile.api"
assert_file_exists "$OPS_ROOT/docker/Dockerfile.web"           "Dockerfile.web"
assert_file_exists "$OPS_ROOT/docker/Dockerfile.worker"        "Dockerfile.worker"

# Env templates
assert_file_exists "$OPS_ROOT/env/.env.local"                  ".env.local (ops infra)"
assert_file_exists "$OPS_ROOT/env/.env.prod.example"           ".env.prod.example (self-hosted default)"
assert_file_exists "$OPS_ROOT/env/.env.prod.managed.example"   ".env.prod.managed.example (external DB)"

# Self-hosted vs managed env templates differ in DATABASE_URL host
assert_grep '@postgres:'    "$OPS_ROOT/env/.env.prod.example"           "self-hosted .env points DATABASE_URL to compose service 'postgres'"
assert_grep 'POSTGRES_DB='  "$OPS_ROOT/env/.env.prod.example"           "self-hosted .env defines POSTGRES_DB"
assert_grep 'POSTGRES_USER=' "$OPS_ROOT/env/.env.prod.example"           "self-hosted .env defines POSTGRES_USER"
assert_grep 'sslmode=require' "$OPS_ROOT/env/.env.prod.managed.example" "managed .env uses sslmode=require"

# Scripts
assert_file_exists "$OPS_ROOT/scripts/migrate.sh"              "migrate.sh"
assert_file_exists "$OPS_ROOT/scripts/seed.sh"                 "seed.sh"
assert_file_exists "$OPS_ROOT/scripts/license-report.sh"       "license-report.sh"

# CI — canonical (disabled state)
assert_file_exists "$OPS_ROOT/ci/github-actions-ci.yml"        "ops ci yaml (canonical)"
assert_file_exists "$OPS_ROOT/.github/workflows/ci.yml"        ".github/workflows/ci.yml (ops가 메타 repo)"

# CI disabled markers
assert_grep 'CI DISABLED'      "$OPS_ROOT/ci/github-actions-ci.yml"   "ops CI disabled marker"
assert_grep 'ci-disabled'      "$OPS_ROOT/ci/github-actions-ci.yml"   "ops CI workflow name = ci-disabled"
assert_grep 'CI DISABLED'      "$OPS_ROOT/.github/workflows/ci.yml"   "gh-actions CI disabled marker"

# Compose content — local infra services
assert_grep 'pgvector'         "$OPS_ROOT/compose/docker-compose.local.yml"  "local compose has pgvector image"
assert_grep 'valkey'           "$OPS_ROOT/compose/docker-compose.local.yml"  "local compose has valkey"
assert_grep 'minio'            "$OPS_ROOT/compose/docker-compose.local.yml"  "local compose has minio"
assert_grep 'caddy'            "$OPS_ROOT/compose/docker-compose.local.yml"  "local compose has caddy"

scenario_end
