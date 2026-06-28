# Vocabulary-NB4-TOEIC Architecture

상세 아키텍처 도면. 5개 컴포넌트 (app / frontend / backend / database / ops) + 외부 시스템 (OAuth, TTS, CDN, Monitoring).

---

## 1. 전체 시스템 개요 (Component Topology)

```mermaid
flowchart TB
    subgraph Clients["사용자 / 운영자 디바이스"]
        direction LR
        iPhone["iPhone / iPad<br/>(iOS 15+)"]
        Android["Android phone / tablet<br/>(API 26+)"]
        AdminWeb["Admin 브라우저<br/>(Chrome/Safari/Edge)"]
        AdminDesktop["Admin 데스크탑<br/>(Tauri: Win/macOS/Linux)"]
    end

    subgraph Edge["엣지 계층"]
        CDN["CDN<br/>(CloudFront / Cloudflare)"]
        Caddy["Reverse Proxy<br/>Caddy (auto-TLS)"]
    end

    subgraph App["app/ — 사용자 모바일"]
        RN["React Native + Expo<br/>TypeScript"]
        LocalCache["expo-sqlite + MMKV<br/>(오프라인 단어 캐시)"]
    end

    subgraph FE["frontend/ — 관리자"]
        NextAdmin["Next.js Admin (App Router)<br/>shadcn/ui + Refine"]
        Tauri["Tauri Shell<br/>(Rust + WebView)"]
        Directus["Directus CMS<br/>(콘텐츠 CRUD)"]
        Appsmith["Appsmith<br/>(운영 패널)"]
    end

    subgraph BE["backend/"]
        API["api/<br/>FastAPI + Pydantic v2<br/>+ SQLAlchemy 2"]
        Worker["worker/<br/>Celery + Redis/Valkey"]
        Auth["Auth Service<br/>Supabase Auth / Authentik"]
    end

    subgraph DB["database/"]
        PG["PostgreSQL 16<br/>+ pgvector"]
        Redis["Redis / Valkey<br/>(cache + queue)"]
    end

    subgraph Storage["오브젝트 스토리지"]
        S3["S3 / R2 (prod)<br/>MinIO (local)"]
    end

    subgraph External["외부 SaaS"]
        OAuth["OAuth Providers<br/>Google / Apple / Kakao"]
        AzureTTS["Azure Speech TTS"]
        PollyTTS["AWS Polly TTS"]
        SentryS["Sentry"]
        PostHog["PostHog Analytics"]
    end

    subgraph Ops["ops/"]
        Compose["docker-compose<br/>(local + prod)"]
        CI["GitHub Actions<br/>+ Expo EAS"]
        Monitor["Prometheus + Grafana<br/>+ Loki + OpenTelemetry"]
    end

    iPhone --> CDN
    Android --> CDN
    AdminWeb --> Caddy
    AdminDesktop --> Caddy

    CDN --> Caddy
    Caddy --> API
    Caddy --> NextAdmin
    Caddy --> Directus
    Caddy --> Appsmith

    RN -. dev .-> API
    iPhone -. runtime .-> RN
    Android -. runtime .-> RN
    RN <--> LocalCache

    NextAdmin --> API
    Tauri --> NextAdmin
    Directus --> PG
    Appsmith --> PG
    Appsmith --> API

    API --> PG
    API --> Redis
    API --> Auth
    API --> S3
    API -- enqueue --> Worker
    Worker --> PG
    Worker --> S3
    Worker --> AzureTTS
    Worker --> PollyTTS

    Auth --> OAuth
    Auth --> PG

    API -.-> SentryS
    RN -.-> SentryS
    RN -.-> PostHog
    NextAdmin -.-> SentryS

    Ops -. provisions .-> BE
    Ops -. provisions .-> DB
    Ops -. provisions .-> FE
    CI -. builds .-> RN
    CI -. builds .-> NextAdmin
    CI -. builds .-> Tauri
    Monitor -. scrapes .-> API
    Monitor -. scrapes .-> Worker
```

---

## 2. 인증 플로우 (OAuth + Email OTP)

```mermaid
sequenceDiagram
    autonumber
    participant U as User (Mobile App)
    participant App as app/ (RN+Expo)
    participant Auth as backend/auth<br/>(Supabase Auth)
    participant OAuth as Google / Apple / Kakao
    participant API as backend/api
    participant PG as database/postgres

    rect rgb(235,245,255)
    Note over U,OAuth: A) 소셜 로그인
    U->>App: 카카오로 로그인 탭
    App->>Auth: /auth/oauth/start?provider=kakao
    Auth->>OAuth: redirect (PKCE)
    OAuth-->>U: 동의 화면
    U->>OAuth: 승인
    OAuth-->>Auth: authorization code
    Auth->>OAuth: token exchange
    OAuth-->>Auth: id_token + access_token
    Auth->>PG: upsert users + identities
    Auth-->>App: app_jwt (access + refresh)
    end

    rect rgb(245,255,235)
    Note over U,API: B) 이메일 + OTP
    U->>App: email 입력
    App->>Auth: /auth/email/otp/send
    Auth->>Auth: code 발급 + 이메일 발송
    Auth-->>App: pending
    U->>App: 6자리 OTP 입력
    App->>Auth: /auth/email/otp/verify
    Auth->>PG: verify + upsert users
    Auth-->>App: app_jwt
    end

    App->>API: GET /me  (Authorization: Bearer)
    API->>Auth: verify jwt (JWKS)
    Auth-->>API: claims (sub, email, scope)
    API->>PG: select user_profile
    PG-->>API: profile
    API-->>App: 200 user
```

---

## 3. 학습 데이터 흐름 (단어 카드 학습 + 진도 저장)

```mermaid
sequenceDiagram
    autonumber
    participant App as app/ (RN)
    participant Cache as 로컬 SQLite + MMKV
    participant CDN as CDN
    participant API as backend/api
    participant PG as PostgreSQL
    participant S3 as Object Storage

    App->>API: GET /lessons/today?user=u123
    API->>PG: SELECT due cards (SRS) + lesson plan
    PG-->>API: 20 cards
    API-->>App: cards meta + audio urls

    loop 각 단어 카드
        App->>Cache: 캐시 hit?
        alt 캐시 miss
            App->>CDN: GET /audio/<id>-en-US.mp3
            CDN->>S3: origin pull (first time)
            S3-->>CDN: mp3
            CDN-->>App: mp3 (edge cached)
            App->>Cache: write blob + meta
        end
        App->>App: 재생 + 학습
        App->>Cache: 결과 기록 (known/unknown)
    end

    App->>API: POST /progress/batch<br/>[{card_id, result, latency_ms}, ...]
    API->>PG: INSERT progress + UPDATE SRS schedule
    PG-->>API: ok
    API->>PG: recompute mastery + next_review_at
    API-->>App: 200 + next lesson preview
```

---

## 4. TTS 배치 파이프라인 (예문 다국적 음원 생성)

```mermaid
flowchart LR
    subgraph AdminTrigger["관리자 트리거"]
        Admin["Admin Web<br/>(Next.js)"]
        Directus["Directus<br/>(콘텐츠 변경 hook)"]
    end

    subgraph APIQueue["enqueue"]
        API2["backend/api<br/>POST /jobs/tts"]
        Queue[("Redis / Valkey<br/>queue: tts.batch")]
    end

    subgraph Workers["backend/worker (Celery)"]
        W1["tts_render<br/>(per word x locale)"]
        W2["audio_normalize<br/>(loudness, trim)"]
        W3["storage_upload<br/>(S3 multipart)"]
        W4["db_update<br/>(audio_urls)"]
    end

    subgraph Providers["TTS Providers"]
        Az["Azure Speech<br/>en-US/en-GB/en-AU"]
        Pl["AWS Polly<br/>fallback"]
        Pi["Piper<br/>(self-host, dev/staging)"]
    end

    subgraph Store["스토리지"]
        S32["S3 / R2<br/>(prod)"]
        Min["MinIO<br/>(local)"]
        CDN2["CDN edge"]
    end

    Admin -- "단어/예문 publish" --> API2
    Directus -- webhook --> API2
    API2 --> Queue
    Queue --> W1
    W1 --> Az
    W1 -. fallback .-> Pl
    W1 -. dev .-> Pi
    Az --> W1
    Pl --> W1
    Pi --> W1
    W1 --> W2
    W2 --> W3
    W3 --> S32
    W3 --> Min
    S32 --> CDN2
    W3 --> W4
    W4 --> PG2[("PostgreSQL<br/>audio table")]
```

---

## 5. 환경 분리 (local vs prod) + 배포 토폴로지

```mermaid
flowchart TB
    subgraph LocalEnv["LOCAL (개발자 머신)"]
        direction TB
        LocalCompose["docker-compose.local.yml"]
        LocalPG["postgres:16 (volume)"]
        LocalRedis["valkey:8"]
        LocalMinIO["MinIO"]
        LocalAPI["api (uvicorn --reload)"]
        LocalNext["Next.js dev (pnpm dev)"]
        LocalExpo["Expo dev client"]
        LocalPiper["Piper TTS<br/>(자체호스팅)"]
        LocalCompose --> LocalPG
        LocalCompose --> LocalRedis
        LocalCompose --> LocalMinIO
        LocalCompose --> LocalAPI
        LocalCompose --> LocalPiper
    end

    subgraph ProdEnv["PROD (운영)"]
        direction TB
        ProdLB["Caddy + CDN"]
        ProdAPI["api (gunicorn x N)"]
        ProdWorker["celery worker (autoscale)"]
        ProdPG[("Postgres (RDS / Supabase)<br/>+ daily backup")]
        ProdRedis[("ElastiCache / Upstash")]
        ProdS3[("S3 / R2 + CloudFront")]
        ProdAzure["Azure Speech (live)"]
        ProdPolly["AWS Polly (live)"]
        ProdLB --> ProdAPI
        ProdAPI --> ProdPG
        ProdAPI --> ProdRedis
        ProdAPI --> ProdS3
        ProdAPI --> ProdWorker
        ProdWorker --> ProdAzure
        ProdWorker --> ProdPolly
    end

    subgraph CICD["CI / CD"]
        GA["GitHub Actions"]
        EAS["Expo EAS Build"]
        Tauri2["Tauri release"]
        Alembic["Alembic migrate<br/>(manual approval gate)"]
    end

    Dev["개발자 git push"] --> GA
    GA -- build & push --> Reg["GHCR / ECR images"]
    Reg --> ProdAPI
    Reg --> ProdWorker
    GA --> EAS
    EAS --> TestFlight["TestFlight"]
    EAS --> PlayInt["Play Internal"]
    GA --> Tauri2
    Tauri2 --> Releases["GitHub Releases"]
    GA --> Alembic
    Alembic --> ProdPG

    LocalEnv -. promote schema .-> Alembic
```

---

## 6. 컴포넌트 책임 매트릭스 (RACI 요약)

| 책임 | app | frontend | backend/api | backend/worker | database | ops |
|---|---|---|---|---|---|---|
| 사용자 인증 토큰 보관 | **R** | — | A | — | C | C |
| 학습 카드 렌더링/재생 | **R** | — | C | — | C | — |
| 콘텐츠 CRUD | — | **R** | A | — | C | — |
| TTS 음원 생성 | — | T (트리거) | A | **R** | C | I |
| 진도/SRS 계산 | C | C | **R** | C | C | — |
| 스키마 마이그레이션 | — | — | C | — | C | **R** |
| 빌드/배포 | — | C | C | C | C | **R** |
| 모니터링/알림 | I | I | I | I | I | **R** |

R = Responsible, A = Accountable, C = Consulted, I = Informed, T = Trigger.

---

## 7. 데이터 모델 핵심 엔터티 (논리)

```mermaid
erDiagram
    USER ||--o{ IDENTITY : has
    USER ||--o{ PROGRESS : tracks
    USER ||--o{ NOTE : writes
    USER ||--o{ ENROLLMENT : enrolls
    CURRICULUM ||--o{ LESSON : contains
    LESSON ||--o{ LESSON_WORD : includes
    WORD ||--o{ LESSON_WORD : appears_in
    WORD ||--o{ EXAMPLE : has
    EXAMPLE ||--o{ AUDIO : rendered_as
    WORD ||--o{ PROGRESS : reviewed_in
    ENROLLMENT }o--|| CURRICULUM : on

    USER {
      uuid id PK
      string email
      string display_name
      timestamp created_at
    }
    IDENTITY {
      uuid id PK
      uuid user_id FK
      string provider
      string provider_uid
    }
    WORD {
      string id PK
      int part
      string word
      string pos
      string ipa
      string pron_ko
      string meaning_ko
      int frequency_tier
      string[] topic
    }
    EXAMPLE {
      uuid id PK
      string word_id FK
      text example_en
      text example_ko
    }
    AUDIO {
      uuid id PK
      uuid example_id FK
      string locale
      string provider
      string voice_id
      string url
      int duration_ms
    }
    LESSON {
      uuid id PK
      uuid curriculum_id FK
      int seq
      string title
      jsonb objectives
    }
    LESSON_WORD {
      uuid lesson_id FK
      string word_id FK
      int seq
    }
    CURRICULUM {
      uuid id PK
      string name
      int target_score
      int duration_days
    }
    ENROLLMENT {
      uuid id PK
      uuid user_id FK
      uuid curriculum_id FK
      date exam_date
      date start_date
    }
    PROGRESS {
      uuid id PK
      uuid user_id FK
      string word_id FK
      int srs_state
      int interval_days
      timestamp next_review_at
      timestamp last_reviewed_at
      smallint result
    }
    NOTE {
      uuid id PK
      uuid user_id FK
      string word_id FK
      text body_md
      string[] tags
    }
```

---

## 8. 보안 경계 (Trust Boundaries)

```mermaid
flowchart LR
    subgraph Untrusted["Untrusted Zone"]
        Web["Public Internet"]
        Mob["Mobile devices"]
    end

    subgraph DMZ["DMZ"]
        CDN3["CDN edge"]
        CaddyB["Caddy reverse proxy<br/>(WAF rules, TLS 1.3)"]
    end

    subgraph AppZone["App Zone (private subnet)"]
        APIB["FastAPI (JWT verify)"]
        WorkerB["Celery worker"]
    end

    subgraph DataZone["Data Zone (private, no internet)"]
        PGB[("Postgres<br/>row-level-security")]
        RedisB[("Redis/Valkey<br/>AUTH + TLS")]
        S3B[("Object Storage<br/>presigned URLs only")]
    end

    Web --> CDN3
    Mob --> CDN3
    CDN3 --> CaddyB
    CaddyB -- mTLS optional --> APIB
    APIB --> PGB
    APIB --> RedisB
    APIB -- presign --> S3B
    WorkerB --> PGB
    WorkerB --> S3B

    classDef ut fill:#fde2e2,stroke:#b33;
    classDef dmz fill:#fff4d6,stroke:#aa7;
    classDef app fill:#dff0d8,stroke:#393;
    classDef data fill:#d6e6ff,stroke:#36c;
    class Untrusted ut
    class DMZ dmz
    class AppZone app
    class DataZone data
```

보안 원칙:
- JWT 검증 후에만 데이터존 접근.
- Object Storage 직접 URL 노출 금지 — presigned URL 5분 만료.
- Postgres RLS로 `user_id = auth.uid()` 강제.
- Secrets: ops/env (gitignore) + GitHub Actions Secret + AWS Secrets Manager (prod).
- 비밀번호: Argon2id, OTP: TOTP/HMAC + 1회용.

---

끝.
