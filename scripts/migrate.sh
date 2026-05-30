#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-${ENV:-local}}"
case "$ENV" in
  local)
    set -a; source "$(dirname "$0")/../env/.env.local"; set +a
    cd "$(dirname "$0")/../../VNB4-Toeic-database"
    pnpm prisma migrate dev --name "$(date +%Y%m%d_%H%M%S)_local"
    ;;
  prod)
    set -a; source "$(dirname "$0")/../env/.env.prod"; set +a
    cd "$(dirname "$0")/../../VNB4-Toeic-database"
    pnpm prisma migrate deploy
    ;;
  *) echo "usage: migrate.sh [local|prod]"; exit 1;;
esac
