#!/usr/bin/env bash
# Scenario 01 — repository structure
# Verifies all expected files/directories of the mobile app are in place.
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "01-structure"

# Top-level manifests
assert_file_exists "$APP_ROOT/package.json"            "package.json"
assert_file_exists "$APP_ROOT/app.json"                "Expo manifest"
assert_file_exists "$APP_ROOT/tsconfig.json"           "tsconfig.json"
assert_file_exists "$APP_ROOT/babel.config.js"         "babel.config.js"
assert_file_exists "$APP_ROOT/README.md"               "README.md"

# Expo Router file-based routes
assert_dir_exists  "$APP_ROOT/app"                     "expo-router app dir"
assert_file_exists "$APP_ROOT/app/_layout.tsx"         "root layout"
assert_file_exists "$APP_ROOT/app/index.tsx"           "home screen"
assert_file_exists "$APP_ROOT/app/login.tsx"           "login screen"
assert_file_exists "$APP_ROOT/app/learn/[lessonId].tsx" "dynamic learn route"

# Source layout (refactored: core/ + features/ + ui.tsx)
assert_dir_exists  "$APP_ROOT/src/core"                "src/core"
assert_file_exists "$APP_ROOT/src/core/client.ts"      "API client (core/client.ts)"
assert_file_exists "$APP_ROOT/src/core/queries.ts"     "TanStack Query hooks (core/queries.ts)"
assert_file_exists "$APP_ROOT/src/core/schemas.ts"     "Zod schemas (core/schemas.ts)"
assert_dir_exists  "$APP_ROOT/src/features"            "src/features"
assert_file_exists "$APP_ROOT/src/ui.tsx"              "shared UI (ui.tsx)"
assert_dir_exists  "$APP_ROOT/assets"                  "assets dir"

scenario_end
