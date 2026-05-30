# VNB4 TOEIC · system test harness

전 컴포넌트(app/backend/frontend/database/ops) 정적/구조/통합 검증 스위트.
순수 셸 기반. emulator/시뮬레이터/CI 불필요. 로컬모드(SQLite)에서 통합 시드까지 검증.

## Component roots (run-tests.sh가 export)

| Var | Path |
|-----|------|
| `REPO_ROOT` | `Vocabulary-NB4-TOEIC/` |
| `APP_ROOT` | `$REPO_ROOT/VNB4-Toeic-app` |
| `BACKEND_ROOT` | `$REPO_ROOT/VNB4-Toeic-backend` |
| `FRONTEND_ROOT` | `$REPO_ROOT/VNB4-Toeic-frontend` |
| `DB_ROOT` | `$REPO_ROOT/VNB4-Toeic-database` |
| `OPS_ROOT` | `$REPO_ROOT/VNB4-Toeic-ops` |
| `TEST_ROOT` | `$OPS_ROOT/test` |

## What it tests

| # | Scenario | Scope | What |
|--:|---|---|---|
| 01 | `01-structure`              | app      | Expo Router 라우트 + src/api + assets + configs |
| 02 | `02-manifest`               | app      | `app.json` (slug/bundleId/plugins/extra.apiUrl) |
| 03 | `03-package`                | app      | `package.json` 필수 deps + scripts + main |
| 04 | `04-json-syntax`            | app      | 앱 디렉토리 내 *.json 구문 |
| 05 | `05-typecheck`              | app      | `tsc --noEmit` (deps 없으면 SKIP) |
| 06 | `06-routes`                 | app      | 라우트별 `export default` + import + 기능 키워드 |
| 07 | `07-api-client`             | app      | `client.ts` export surface + 보안 패턴 |
| 08 | `08-backend-reachability`   | backend  | `/api/v1/health` 200 (없으면 SKIP) |
| 09 | `09-database-files`         | database | 듀얼 schema (PostgreSQL prod + SQLite local) + env + scripts |
| 10 | `10-database-local-mode`    | database | **로컬 통합**: SQLite 리셋 → migrate → seed → 데이터 검증 |
| 11 | `11-backend-files`          | backend  | NestJS api + worker(BullMQ) + shared 골격 |
| 12 | `12-frontend-files`         | frontend | Next.js 14 + Tailwind + shadcn + desktop(Tauri) |
| 13 | `13-ops-files`              | ops      | compose + caddy + dockerfiles + scripts + CI disabled |

## Run

```bash
cd VNB4-Toeic-ops/test
./run-tests.sh                       # 전체
./run-tests.sh 09 10                 # database (정적 + SQLite 통합)
./run-tests.sh 01 03 06              # app subset
API_URL=http://localhost:4000 ./run-tests.sh 08
```

## Output

- 콘솔: 실시간 컬러 + 시나리오별 PASS/FAIL/SKIP 요약
- `logs/{run_id}_{scenario}.log` — 시나리오별 상세 로그
- `logs/{run_id}_run.log` — 전체 실행 로그
- `logs/{run_id}_summary.tsv` — `name|status|seconds|details|logfile`
- `TEST_RESULTS.md` — Markdown 리포트 (PR 첨부용)

Exit 0 = all PASS, 1 = 하나라도 FAIL. SKIP은 PASS로 카운트.

## Local mode 통합 시나리오 (10)

`10-database-local-mode` 흐름:
1. `prisma/dev.db` + `.env.local` 삭제
2. `pnpm migrate:local` (env:init + SQLite db push + client generate)
3. `.env.local` 자동생성 검증
4. SQLite 12 테이블 존재 검증
5. `pnpm seed` 실행
6. Word rowcount = 시드 JSON의 고유 (part, word) 수(현재 1,908), JSON-encoded array 필드 검증
7. 파트별 (P1~P7) 카운트 검증
8. seed idempotency (재실행해도 카운트 동일)

`pnpm` 없으면 SKIP, `sqlite3` CLI 없으면 SKIP.

> 카운트는 하드코딩이 아니라 `seeds/parts/*.json` 의 고유 (part,word) 수를 런타임에 계산해 비교(10/15/16). 시드가 늘면 자동 반영.

## 기능 시험 (시뮬레이터/브라우저)

정적 하니스 외에 **실제 구동** 기능 시험은 [FUNCTIONAL_TEST_RESULTS.md](FUNCTIONAL_TEST_RESULTS.md) 참고:
app(iOS 시뮬레이터 / Android 에뮬레이터 / Web) + admin(backend API + frontend) end-to-end,
발견 오류 수정·재시험 기록 포함. 시나리오는 01~20 (14~20: compose/mode/플랫폼/pnpm allowlist).

## Adding a scenario

```bash
cat > scenarios/14-my-thing.sh <<'EOF'
#!/usr/bin/env bash
source "$(dirname "$0")/../lib/log.sh"
scenario_begin "14-my-thing"
assert_file_exists "$BACKEND_ROOT/some/file"
assert_grep "pattern" "$DB_ROOT/some/file" "found pattern"
scenario_end
EOF
chmod +x scenarios/14-my-thing.sh
```

`lib/log.sh` 헬퍼:
- `scenario_begin <name>` / `scenario_end`
- `assert_file_exists <path> [desc]`
- `assert_dir_exists <path> [desc]`
- `assert_json_valid <file>` / `assert_json_has <file> <dotted.path>`
- `assert_grep <pattern> <file> [desc]`
- `assert_cmd <desc> <cmd> [args...]`
- `log_pass / log_fail / log_skip / log_info <msg>`
