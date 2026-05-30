#!/usr/bin/env bash
# Generate THIRD_PARTY_NOTICES.md from each component's node_modules.
# Uses license-checker-rseidelsohn (BSD-3) via npx (no install required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/THIRD_PARTY_NOTICES.md"

components=(
  "VNB4-Toeic-app"
  "VNB4-Toeic-frontend/web"
  "VNB4-Toeic-frontend/desktop"
  "VNB4-Toeic-backend/api"
  "VNB4-Toeic-backend/worker"
  "VNB4-Toeic-database"
)

echo "# Third-Party Notices" > "$OUT"
echo "" >> "$OUT"
echo "Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) by ops/scripts/license-report.sh" >> "$OUT"
echo "" >> "$OUT"

for c in "${components[@]}"; do
  if [ -d "$ROOT/$c/node_modules" ]; then
    echo "## $c" >> "$OUT"
    echo '```' >> "$OUT"
    (cd "$ROOT/$c" && npx -y license-checker-rseidelsohn --production --summary 2>/dev/null) >> "$OUT" || echo "(skipped: deps not installed)" >> "$OUT"
    echo '```' >> "$OUT"
    echo "" >> "$OUT"
  else
    echo "## $c (deps not installed — run pnpm install first)" >> "$OUT"
    echo "" >> "$OUT"
  fi
done

echo "Wrote $OUT"
