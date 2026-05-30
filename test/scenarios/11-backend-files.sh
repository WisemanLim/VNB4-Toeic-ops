#!/usr/bin/env bash
# Scenario 11 — VNB4-Toeic-backend (NestJS + BullMQ) file structure
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "11-backend-files"

# Monorepo layout
assert_file_exists "$BACKEND_ROOT/package.json"          "root package.json"
assert_file_exists "$BACKEND_ROOT/pnpm-workspace.yaml"   "pnpm workspace manifest"
assert_dir_exists  "$BACKEND_ROOT/api"                   "api workspace"
assert_dir_exists  "$BACKEND_ROOT/worker"                "worker workspace"
assert_dir_exists  "$BACKEND_ROOT/shared"                "shared workspace"

# API (NestJS)
assert_file_exists "$BACKEND_ROOT/api/package.json"      "api/package.json"
assert_file_exists "$BACKEND_ROOT/api/nest-cli.json"     "nest-cli.json"
assert_file_exists "$BACKEND_ROOT/api/tsconfig.json"     "api/tsconfig.json"
assert_dir_exists  "$BACKEND_ROOT/api/src"               "api/src"
assert_file_exists "$BACKEND_ROOT/api/src/main.ts"       "api entrypoint main.ts"

# Worker (BullMQ)
assert_file_exists "$BACKEND_ROOT/worker/package.json"   "worker/package.json"
assert_dir_exists  "$BACKEND_ROOT/worker/src"            "worker/src"

# Manifest content — NestJS deps
assert_grep '"@nestjs/core"'      "$BACKEND_ROOT/api/package.json" "api uses @nestjs/core"
assert_grep '"@nestjs/common"'    "$BACKEND_ROOT/api/package.json" "api uses @nestjs/common"
assert_grep '"@prisma/client"'    "$BACKEND_ROOT/api/package.json" "api uses @prisma/client"

# Worker uses bullmq
assert_grep '"bullmq"'            "$BACKEND_ROOT/worker/package.json" "worker uses bullmq"

# main.ts content — bootstrap pattern
assert_grep 'NestFactory'         "$BACKEND_ROOT/api/src/main.ts"  "main.ts uses NestFactory"
assert_grep 'listen'              "$BACKEND_ROOT/api/src/main.ts"  "main.ts calls listen()"

scenario_end
