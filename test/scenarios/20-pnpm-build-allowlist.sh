#!/usr/bin/env bash
# Scenario 20 — pnpm 11+ install-script 정책 확인
# pnpm 11 가 기본적으로 모든 native postinstall 을 차단 → ERR_PNPM_IGNORED_BUILDS.
# 각 컴포넌트의 pnpm-workspace.yaml 에 dangerouslyAllowAllBuilds: true 가 설정되어 install
# 깨끗하게 끝나는지 확인. (onlyBuiltDependencies 화이트리스트 방식은 pnpm 11.1.3 에서 placeholder
# 충돌 문제로 미사용. 알려진 OSS dep 만 사용하므로 dev 환경 안전.)
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "20-pnpm-build-allowlist"

check_workspace_yaml() {
  local label="$1" yaml="$2"
  if [ ! -f "$yaml" ]; then
    log_fail "$label: pnpm-workspace.yaml missing ($yaml)"
    return
  fi
  if grep -qE '^dangerouslyAllowAllBuilds:[[:space:]]*true' "$yaml"; then
    log_pass "$label: dangerouslyAllowAllBuilds: true (모든 install/postinstall 허용)"
  else
    log_fail "$label: dangerouslyAllowAllBuilds: true 미설정 → pnpm 11 install 시 ERR_PNPM_IGNORED_BUILDS 위험"
  fi
  # 무효 'allowBuilds:' 키 (pnpm approve-builds placeholder) 잔존 검사
  if grep -q '^allowBuilds:' "$yaml" 2>/dev/null; then
    log_fail "$label: 무효 'allowBuilds:' 블록 잔존 — pnpm approve-builds placeholder. 제거 필요"
  else
    log_pass "$label: 무효 'allowBuilds:' 블록 없음"
  fi
}

check_workspace_yaml "backend"  "$BACKEND_ROOT/pnpm-workspace.yaml"
check_workspace_yaml "database" "$DB_ROOT/pnpm-workspace.yaml"
check_workspace_yaml "frontend" "$FRONTEND_ROOT/pnpm-workspace.yaml"
check_workspace_yaml "app"      "$APP_ROOT/pnpm-workspace.yaml"

# pnpm 11 deprecated 필드: 최상위 "pnpm": { ... } 형태 남아있으면 [WARN]
for pkg in "$BACKEND_ROOT/package.json" "$DB_ROOT/package.json" "$FRONTEND_ROOT/package.json" "$APP_ROOT/package.json"; do
  comp=$(basename "$(dirname "$pkg")")
  if grep -qE '"pnpm"[[:space:]]*:[[:space:]]*\{' "$pkg"; then
    log_fail "$comp: package.json 에 deprecated 'pnpm: { ... }' 필드 잔존 (pnpm 11 [WARN]) — pnpm-workspace.yaml 로 이전"
  else
    log_pass "$comp: deprecated 'pnpm: { ... }' 필드 없음 (pnpm 11 silent)"
  fi
done

# engines.pnpm 권장 버전 명시 확인
for pkg in "$BACKEND_ROOT/package.json" "$DB_ROOT/package.json" "$FRONTEND_ROOT/package.json" "$APP_ROOT/package.json"; do
  comp=$(basename "$(dirname "$pkg")")
  if grep -A3 '"engines"' "$pkg" | grep -qE '"pnpm"[[:space:]]*:[[:space:]]*">='; then
    log_pass "$comp: engines.pnpm >=N 명시"
  else
    log_info "$comp: engines.pnpm 권장 (선택)"
  fi
done

log_info "신규 native 패키지 추가 시 dangerouslyAllowAllBuilds: true 가 자동 허용. pnpm-lock.yaml diff 리뷰로 supply-chain 안전 검증."

scenario_end
