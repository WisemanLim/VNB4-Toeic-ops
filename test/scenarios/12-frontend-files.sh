#!/usr/bin/env bash
# Scenario 12 — VNB4-Toeic-frontend (Next.js + Tauri) file structure
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "12-frontend-files"

# Monorepo layout
assert_file_exists "$FRONTEND_ROOT/package.json"            "root package.json"
assert_file_exists "$FRONTEND_ROOT/pnpm-workspace.yaml"     "pnpm workspace manifest"
assert_dir_exists  "$FRONTEND_ROOT/web"                     "web workspace"
assert_dir_exists  "$FRONTEND_ROOT/desktop"                 "desktop workspace"
assert_dir_exists  "$FRONTEND_ROOT/shared"                  "shared workspace"

# Web (Next.js 14 App Router + Tailwind + shadcn)
assert_file_exists "$FRONTEND_ROOT/web/package.json"        "web/package.json"
assert_file_exists "$FRONTEND_ROOT/web/next.config.mjs"     "next.config.mjs"
assert_file_exists "$FRONTEND_ROOT/web/tsconfig.json"       "web/tsconfig.json"
assert_file_exists "$FRONTEND_ROOT/web/tailwind.config.ts"  "tailwind.config.ts"
assert_file_exists "$FRONTEND_ROOT/web/postcss.config.mjs"  "postcss.config.mjs"
assert_dir_exists  "$FRONTEND_ROOT/web/app"                 "Next.js App Router dir"
assert_dir_exists  "$FRONTEND_ROOT/web/components"          "components dir"
assert_dir_exists  "$FRONTEND_ROOT/web/lib"                 "lib dir"

# Deps content
assert_grep '"next"'             "$FRONTEND_ROOT/web/package.json" "web uses next"
assert_grep '"react"'            "$FRONTEND_ROOT/web/package.json" "web uses react"
assert_grep '"tailwindcss"'      "$FRONTEND_ROOT/web/package.json" "web uses tailwindcss"

scenario_end
