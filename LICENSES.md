# Third-Party Licenses & Compliance

본 프로젝트가 임베드/의존하는 오픈소스 라이선스 전수 검토. 최종 법무 검토 필요.

## License classification

| License | 상업 배포 | 수정 시 소스공개 | 비고 |
|---|---|---|---|
| MIT | ✅ | ✗ | NOTICE 포함 권장 |
| Apache-2.0 | ✅ | ✗ | NOTICE/특허조항 |
| BSD-2/3 | ✅ | ✗ | NOTICE |
| PostgreSQL License | ✅ | ✗ | BSD 유사 |
| Public Domain | ✅ | ✗ | - |
| MPL-2.0 | ✅ | ⚠ 파일 단위 | 수정파일만 공개 |
| LGPL-3.0 | ✅ | ⚠ 동적링크 OK | 정적링크 시 공개 |
| AGPL-3.0 | ⚠ | ⚠ 네트워크 사용도 트리거 | self-host 사용은 OK, 수정/SaaS 배포 시 소스공개 |
| BSL 1.1 | ⚠ 매출 한도 | - | 한도 초과 시 상용 |
| SSPL | ⚠ | - | 경쟁 서비스 금지 |

## Per-component audit

### VNB4-Toeic-app (RN + Expo)
| Package | License | OK |
|---|---|---|
| react-native | MIT | ✅ |
| expo | MIT | ✅ |
| expo-router | MIT | ✅ |
| zustand | MIT | ✅ |
| @tanstack/react-query | MIT | ✅ |
| react-hook-form | MIT | ✅ |
| zod | MIT | ✅ |
| nativewind | MIT | ✅ |
| react-native-track-player | Apache-2.0 | ✅ |
| react-native-mmkv | MIT | ✅ |
| @sentry/react-native | MIT | ✅ |

### VNB4-Toeic-frontend
| Package | License | OK |
|---|---|---|
| next | MIT | ✅ |
| react / react-dom | MIT | ✅ |
| @radix-ui/* (shadcn 기반) | MIT | ✅ |
| tailwindcss | MIT | ✅ |
| @tauri-apps/cli | MIT/Apache-2.0 | ✅ |
| @tanstack/react-query | MIT | ✅ |
| refine (선택) | MIT | ✅ |

### VNB4-Toeic-backend
| Package | License | OK |
|---|---|---|
| @nestjs/* | MIT | ✅ |
| @nestjs/jwt | MIT | ✅ |
| @nestjs/passport | MIT | ✅ |
| passport / passport-jwt | MIT | ✅ |
| bullmq | MIT | ✅ |
| ioredis | MIT | ✅ |
| @aws-sdk/client-s3 | Apache-2.0 | ✅ |
| microsoft-cognitiveservices-speech-sdk | MIT | ✅ |
| class-validator / class-transformer | MIT | ✅ |
| @prisma/client | Apache-2.0 | ✅ |

### VNB4-Toeic-database
| Component | License | OK |
|---|---|---|
| PostgreSQL 16 | PostgreSQL License | ✅ |
| pgvector | PostgreSQL License | ✅ |
| Prisma CLI/Client | Apache-2.0 | ✅ |

### VNB4-Toeic-ops
| Component | License | OK | 사용 형태 |
|---|---|---|---|
| Docker Engine | Apache-2.0 | ✅ | runtime |
| docker-compose | Apache-2.0 | ✅ | runtime |
| Caddy | Apache-2.0 | ✅ | 컨테이너 (수정X) |
| Prometheus | Apache-2.0 | ✅ | 컨테이너 |
| Grafana OSS | AGPL-3.0 | ⚠ | **컨테이너 그대로 사용, 수정X → AGPL 트리거 없음** |
| Loki | AGPL-3.0 | ⚠ | 동일 |
| MinIO | AGPL-3.0 | ⚠ | self-host dev only, 수정 없음 |
| Redis OSS ≤7.2 | BSD-3 | ✅ | Redis 7.4+은 RSAL → **Valkey로 대체** |
| Valkey | BSD-3 | ✅ | Redis fork, Linux Foundation |
| Sentry self-host | BSL 1.1 | ⚠ | 비경쟁 사용 OK |

## Risk flags

1. **AGPL-3.0 (Grafana/Loki/MinIO)**:
   - 수정 없이 official image 사용 시 트리거 없음.
   - 만약 fork/수정하여 외부 서비스 제공 시 → 소스공개 의무.
   - **결정: 공식 컨테이너 unmodified 사용**.

2. **BSL 1.1 (Directus, Sentry)**:
   - Directus: 매출 $5M 이하 무료. 초과 시 상용 라이선스.
   - Sentry self-host: 비경쟁 용도(=동일 서비스 SaaS 판매 금지). 내부 모니터링은 OK.
   - **결정: 매출 추적 + 분기마다 재검토**.

3. **Redis 라이선스 변경 (2024-)**: Redis 7.4+ RSALv2/SSPL.
   - **결정: Valkey 사용** (`ops/compose/docker-compose.local.yml`).

4. **TTS Provider SDK**:
   - Azure Speech SDK: MIT. ✅
   - AWS Polly via aws-sdk: Apache-2.0. ✅
   - Piper (선택): MIT. ✅ self-host OSS 옵션.

## NOTICE generation

```bash
cd VNB4-Toeic-ops/scripts && ./license-report.sh
# → 각 컴포넌트의 node_modules/.../LICENSE 수집 → THIRD_PARTY_NOTICES.md 생성
```

Apache-2.0 컴포넌트는 NOTICE 파일 동봉 의무.
배포 아티팩트 (모바일 앱 빌드, 데스크탑 .dmg/.exe)에 `/legal` 화면 또는 동봉 텍스트로 표시 필요.

## Final clearance

본 구성 채택 시 **AGPL/BSL/SSPL 트리거 조건 없음** (수정 없이 컨테이너 사용 + 매출 한도 내).
상업 배포 가능 판정. 단 출시 직전 법무 최종 검토 권장.
