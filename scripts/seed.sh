#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-${ENV:-local}}"
set -a; source "$(dirname "$0")/../env/.env.${ENV}"; set +a
cd "$(dirname "$0")/../../VNB4-Toeic-database"
pnpm seed
