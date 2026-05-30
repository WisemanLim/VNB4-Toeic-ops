# VNB4 TOEIC — System Test Results

_Generated 2026-05-30T07:54:59Z by `test/run-tests.sh`_

**Run ID:** `20260530_165451`

## Summary

| Total | Pass | Fail | Skip |
|------:|-----:|-----:|-----:|
| 1 | 1 | 0 | 0 |

> **Overall: PASS**

## Scenarios

| # | Scenario | Status | Time (s) | Log |
|--:|----------|:------:|---------:|-----|
| 1 | `10-database-local-mode` | ✅ PASS | 8 | [`logs/20260530_165451_10-database-local-mode.log`](logs/20260530_165451_10-database-local-mode.log) |

## Scenario details

### `10-database-local-mode` — PASS

Duration: 8s · Log: `logs/20260530_165451_10-database-local-mode.log`

<details><summary>Checks</summary>

```
  · ===== scenario: 10-database-local-mode =====
  · started at 2026-05-30T07:54:51Z
  ✔ node_modules present
  · cleared prisma/dev.db and .env.local
wrote .env.local (SQLite, no Docker needed)
  ✔ pnpm migrate:local succeeded
  ✔ .env.local auto-created exists
  ✔ .env.local has SQLite URL
  ✔ SQLite db file created exists
tables: AudioAsset    Curriculum    LessonWord    SentenceItem  Word        
  ✔ table exists: User
  ✔ table exists: Word
  ✔ table exists: Lesson
  ✔ table exists: Progress
  ✔ table exists: AudioAsset
  ✔ table exists: Note
  ✔ table exists: Bookmark
  ✔ table exists: Curriculum
  ✔ table exists: Job
  ✔ table exists: AuthIdentity
  ✔ table exists: Session
  ✔ table exists: LessonWord
  ✔ table exists: SentenceItem
✔ Generated Prisma Client (v5.22.0) to ./node_modules/.pnpm/@prisma+client@5.22.0_prisma@5.22.0/node_modules/@prisma/client in 45ms
  ✔ pnpm seed succeeded
  ✔ Word rowcount > 0 (actual: 3686)
  ✔ Word rowcount matches unique seed total (3686)
  ✔ topic field is JSON-encoded array (got: ["place","action"])
  ✔ synonyms field is JSON-encoded array (got: ["sidewalk"])
  ✔ SentenceItem rowcount > 0 (actual: 198)
  ✔ SentenceItem rowcount matches unique seed ids (198)
  ✔ part P1: 337 words
  ✔ part P2: 527 words
  ✔ part P3: 549 words
  ✔ part P4: 551 words
  ✔ part P5: 677 words
  ✔ part P6: 411 words
  ✔ part P7: 634 words
✔ Generated Prisma Client (v5.22.0) to ./node_modules/.pnpm/@prisma+client@5.22.0_prisma@5.22.0/node_modules/@prisma/client in 51ms
  ✔ seed idempotent (3686 before, 3686 after re-run)
  · ===== finished 10-database-local-mode (PASS, 8s) =====
```

</details>

## Environment

| Key | Value |
|-----|-------|
| OS | Darwin 25.4.0 |
| Shell | 3.2.57(1)-release |
| Node | v26.0.0 |
| pnpm | 10.33.0 |
| App root | `/Users/wise/Developer/Apps(Android,iOS,...)/VNB4-Toeic-app` |
| Backend probe | `http://localhost:4000` |

## Re-run

```bash
cd /Users/wise/Developer/Web(Node,Script)/VNB4-Toeic-ops/test
./run-tests.sh                # all scenarios
./run-tests.sh 05 10          # subset (typecheck + local DB integration)
./run-tests.sh 09 10          # database-only (file checks + SQLite integration)
API_URL=https://api.dev ./run-tests.sh 08   # override backend probe URL
```
