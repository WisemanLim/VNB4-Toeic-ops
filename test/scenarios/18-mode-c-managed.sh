#!/usr/bin/env bash
# Scenario 18 — README Mode C-2: 외부 관리형 Postgres (RDS / Supabase / Neon)
# 본 시험에서는 사용자 지시에 따라 SKIP (외부 호스트 액세스 + 비밀번호 필요).
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "18-mode-c-managed"

log_info "외부 관리형 DB 시험은 사용자 요청에 의해 본 회차 제외."
log_info "수행하려면: cp .env.prod.managed.example .env.prod → DATABASE_URL 채우기 → override 파일 생성 → up"

# Static check: template + 권장 override 구조 확인 (실제 실행 X)
assert_file_exists "$OPS_ROOT/env/.env.prod.managed.example" "managed env 템플릿 존재"
assert_grep 'sslmode=require' "$OPS_ROOT/env/.env.prod.managed.example" "managed 템플릿 sslmode=require"
assert_grep 'Supabase'         "$OPS_ROOT/env/.env.prod.managed.example" "Supabase 예시 포함"
assert_grep 'Neon'             "$OPS_ROOT/env/.env.prod.managed.example" "Neon 예시 포함"

log_skip "관리형 DB 실제 연결 시험은 본 회차 제외"

scenario_end
