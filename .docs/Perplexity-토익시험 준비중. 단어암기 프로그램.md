<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# 토익시험을 준비중이예요. 단어암기 프로그램을 개발하고자 합니다. 각 파트별로 필수 단어를 조사하여 각 파트별로 정리해 주세요. 단, 단어는 단순히 뜻 뿐만 아니라 발음기호와 발음(한글), 대표 예문, 그림 등을 포함합니다. 빈도가 많은 단어를 우선적으로 정리합니다.

토익 단어암기 프로그램을 만든다면, 먼저 **파트별 문항 특성에 맞춘 핵심 어휘 세트**를 구성하는 방식이 가장 실용적입니다. TOEIC L\&R는 Part 1~4가 듣기, Part 5~7이 읽기 영역으로 나뉘며 각 파트의 과업이 서로 달라서, 자주 나오는 어휘도 “품사·상황·문서 유형” 기준으로 다르게 정리해야 효율이 높습니다.[^1_1]

## 파트 기준

TOEIC L\&R는 Listening 100문항과 Reading 100문항으로 구성되며, Part 1은 사진 묘사, Part 2는 질의응답, Part 3은 대화, Part 4는 담화, Part 5는 문장 완성, Part 6은 지문 완성, Part 7은 독해로 출제됩니다. 따라서 단어암기 프로그램도 Part 1은 사물·동작 묘사, Part 2는 질문 신호어, Part 3~4는 업무·일정·안내 표현, Part 5~7은 비즈니스 문서와 문법 결합형 어휘 중심으로 설계하는 것이 맞습니다.[^1_2][^1_1]

또한 공개된 TOEIC 학습 자료들은 공통적으로 비즈니스, 사무, 일정, 인사, 계약, 구매, 배송, 공지, 회의, 여행 같은 주제가 반복된다고 안내합니다. 그래서 “빈도 우선”은 엄밀한 ETS 공식 빈도표라기보다, 여러 TOEIC 어휘집에서 반복적으로 다뤄지는 **고출현 주제어**를 우선 배치하는 방식으로 구현하는 것이 현실적입니다.[^1_2][^1_1]

## 우선 단어 목록

아래 표는 프로그램의 1차 MVP용으로 바로 넣기 좋은 “파트별 필수 어휘 샘플”입니다. 예문은 저작권 문제를 피하기 위해 새로 작성한 예시이며, 그림은 실제 이미지 대신 먼저 `image_prompt` 또는 `image_keyword` 형태로 저장해 두고 이후 이미지 API나 일러스트 생성기로 연결하는 구조를 권장합니다.[^1_1][^1_2]


| 파트 | 우선순위 | 단어 | 뜻 | 발음기호 | 한글 발음 | 대표 예문 | 그림 아이디어 |
| :-- | --: | :-- | :-- | :-- | :-- | :-- | :-- |
| Part 1 | 1 | passenger | 승객 | /ˈpæsəndʒər/ | 패슨저 | The passenger is getting on the bus. | 공항/버스에 탑승하는 사람 |
| Part 1 | 2 | luggage | 수하물, 짐 | /ˈlʌɡɪdʒ/ | 러기지 | Several pieces of luggage are on the cart. | 카트 위 여행가방 |
| Part 1 | 3 | board | 탑승하다 | /bɔːrd/ | 보드 | The passengers are boarding the train. | 열차에 오르는 사람들 |
| Part 1 | 4 | unload | 내리다, 하역하다 | /ˌʌnˈloʊd/ | 언로드 | The workers are unloading boxes from the truck. | 트럭에서 상자 내리는 장면 |
| Part 1 | 5 | stack | 쌓다, 쌓이다 | /stæk/ | 스택 | The boxes are stacked near the wall. | 벽 옆에 쌓인 상자 |
| Part 1 | 6 | inspect | 점검하다 | /ɪnˈspekt/ | 인스펙트 | A mechanic is inspecting the machine. | 기계를 확인하는 정비사 |
| Part 1 | 7 | aisle | 통로 | /aɪl/ | 아일 | A cart is blocking the aisle. | 매장 통로 |
| Part 1 | 8 | shelf | 선반 | /ʃelf/ | 셸프 | The products are arranged on the shelf. | 진열 선반 |
| Part 2 | 1 | available | 이용 가능한 | /əˈveɪləbl/ | 어베일러블 | Is the manager available this afternoon? | 회의 가능한 일정표 |
| Part 2 | 2 | schedule | 일정, 일정을 잡다 | /ˈskedʒuːl/ | 스케줄 | Can we schedule the meeting for Friday? | 캘린더와 회의 |
| Part 2 | 3 | appointment | 약속, 예약 | /əˈpɔɪntmənt/ | 어포인트먼트 | I have a dentist appointment at two. | 병원 예약 카드 |
| Part 2 | 4 | delay | 지연 | /dɪˈleɪ/ | 딜레이 | Why was the flight delay announced so late? | 지연 안내 전광판 |
| Part 2 | 5 | confirm | 확인하다 | /kənˈfɜːrm/ | 컨펌 | Please confirm the reservation by email. | 이메일 확인 |
| Part 2 | 6 | probably | 아마도 | /ˈprɑːbəbli/ | 프라버블리 | He will probably arrive before noon. | 도착 예상 시계 |
| Part 2 | 7 | instead | 대신에 | /ɪnˈsted/ | 인스테드 | Let's meet online instead. | 화상회의 아이콘 |
| Part 2 | 8 | invoice | 청구서 | /ˈɪnvɔɪs/ | 인보이스 | The invoice was sent yesterday. | 청구서 문서 |
| Part 3 | 1 | client | 고객, 의뢰인 | /ˈklaɪənt/ | 클라이언트 | The client requested a revised proposal. | 상담 중인 고객 |
| Part 3 | 2 | deadline | 마감일 | /ˈdedlaɪn/ | 데드라인 | We need to finish the report before the deadline. | 마감 표시 달력 |
| Part 3 | 3 | proposal | 제안서 | /prəˈpoʊzl/ | 프로포절 | She is reviewing the sales proposal now. | 제안서 문서 |
| Part 3 | 4 | shipment | 배송품 | /ˈʃɪpmənt/ | 쉽먼트 | The shipment will arrive on Monday. | 배송 박스/트럭 |
| Part 3 | 5 | budget | 예산 | /ˈbʌdʒɪt/ | 버짓 | Our budget for the event is limited. | 예산표 |
| Part 3 | 6 | reschedule | 일정을 변경하다 | /ˌriːˈskedʒuːl/ | 리스케줄 | They had to reschedule the interview. | 변경된 캘린더 |
| Part 3 | 7 | maintenance | 유지보수, 정비 | /ˈmeɪntənəns/ | 메인터넌스 | The website is down for maintenance. | 점검 중 화면 |
| Part 3 | 8 | branch | 지점 | /bræntʃ/ | 브랜치 | I work at the downtown branch. | 은행 지점 |
| Part 4 | 1 | announcement | 공지, 안내방송 | /əˈnaʊnsmənt/ | 어나운스먼트 | An announcement will be made after the break. | 마이크와 안내문 |
| Part 4 | 2 | attendees | 참석자들 | /əˌtenˈdiːz/ | 어텐디즈 | All attendees must register online. | 행사 등록 데스크 |
| Part 4 | 3 | proceed | 진행하다, 계속하다 | /prəˈsiːd/ | 프로시드 | Please proceed to Gate 12. | 공항 게이트 안내 |
| Part 4 | 4 | due to | ~ 때문에 | /ˈduː tuː/ | 듀 투 | The event was canceled due to bad weather. | 취소 공지 |
| Part 4 | 5 | located | 위치한 | /ˈloʊkeɪtɪd/ | 로케이티드 | The seminar room is located on the second floor. | 층별 안내도 |
| Part 4 | 6 | register | 등록하다 | /ˈredʒɪstər/ | 레지스터 | Guests should register before entering. | 참가 등록 양식 |
| Part 4 | 7 | equipment | 장비 | /ɪˈkwɪpmənt/ | 이퀴프먼트 | New equipment will be installed next week. | 사무 장비 |
| Part 4 | 8 | temporary | 임시의 | /ˈtempəreri/ | 템퍼레리 | The office is in a temporary location. | 임시 사무실 표지 |
| Part 5 | 1 | purchase | 구매하다, 구매 | /ˈpɜːrtʃəs/ | 퍼처스 | Customers can purchase tickets online. | 온라인 구매 화면 |
| Part 5 | 2 | additional | 추가의 | /əˈdɪʃənl/ | 어디셔널 | Additional information is available on the website. | 추가 정보 아이콘 |
| Part 5 | 3 | qualified | 자격 있는 | /ˈkwɑːlɪfaɪd/ | 퀄리파이드 | Only qualified applicants will be interviewed. | 채용 서류 |
| Part 5 | 4 | responsible | 책임이 있는 | /rɪˈspɑːnsəbl/ | 리스판서블 | She is responsible for customer support. | 고객지원 담당자 |
| Part 5 | 5 | annual | 연간의 | /ˈænjuəl/ | 애뉴얼 | The company held its annual conference in May. | 연례 회의 배너 |
| Part 5 | 6 | require | 요구하다 | /rɪˈkwaɪər/ | 리콰이어 | This position requires strong communication skills. | 채용 공고 |
| Part 5 | 7 | approve | 승인하다 | /əˈpruːv/ | 어프루브 | The director approved the final plan. | 승인 도장 |
| Part 5 | 8 | despite | ~에도 불구하고 | /dɪˈspaɪt/ | 디스파이트 | Despite the rain, the tour continued. | 우천 속 행사 |
| Part 6 | 1 | revise | 수정하다 | /rɪˈvaɪz/ | 리바이즈 | Please revise the draft before noon. | 문서 수정 |
| Part 6 | 2 | distribute | 배포하다 | /dɪˈstrɪbjuːt/ | 디스트리뷰트 | The brochure will be distributed at the event. | 전단 배포 |
| Part 6 | 3 | efficient | 효율적인 | /ɪˈfɪʃənt/ | 이피션트 | Our new system is more efficient than the old one. | 시스템 성능 비교 |
| Part 6 | 4 | participate | 참가하다 | /pɑːrˈtɪsɪpeɪt/ | 파티시페이트 | Employees are encouraged to participate in training. | 교육 참여 |
| Part 6 | 5 | survey | 설문조사 | /ˈsɜːrveɪ/ | 서베이 | We conducted a survey after the workshop. | 설문지 |
| Part 6 | 6 | feedback | 피드백 | /ˈfiːdbæk/ | 피드백 | Your feedback will help us improve the service. | 의견 수집 |
| Part 6 | 7 | effective | 효과적인 | /ɪˈfektɪv/ | 이펙티브 | The new campaign was highly effective. | 마케팅 성과 그래프 |
| Part 6 | 8 | update | 업데이트하다, 최신 정보 | /ˈʌpdeɪt/ | 업데이트 | We will update the schedule tomorrow. | 일정 수정 화면 |
| Part 7 | 1 | contract | 계약서, 계약 | /ˈkɑːntrækt/ | 컨트랙트 | The contract will expire next month. | 계약 문서 |
| Part 7 | 2 | warranty | 보증서, 보증 | /ˈwɔːrənti/ | 워런티 | The product comes with a two-year warranty. | 보증서 카드 |
| Part 7 | 3 | applicant | 지원자 | /ˈæplɪkənt/ | 애플리컨트 | Each applicant must submit a resume. | 채용 지원자 |
| Part 7 | 4 | receipt | 영수증 | /rɪˈsiːt/ | 리시트 | Keep the receipt for exchange or refund. | 영수증 |
| Part 7 | 5 | policy | 정책, 규정 | /ˈpɑːləsi/ | 팔러시 | Please review the return policy carefully. | 환불 정책 문서 |
| Part 7 | 6 | reservation | 예약 | /ˌrezərˈveɪʃn/ | 레저베이션 | Your hotel reservation has been confirmed. | 호텔 예약 확인서 |
| Part 7 | 7 | qualifications | 자격 요건 | /ˌkwɑːləfɪˈkeɪʃənz/ | 퀄리피케이션즈 | The job posting lists the required qualifications. | 채용 공고 |
| Part 7 | 8 | department | 부서 | /dɪˈpɑːrtmənt/ | 디파트먼트 | Please contact our billing department. | 회사 조직도 |

## 데이터 설계

프로그램 관점에서는 단어 하나를 단순 문자열로 두지 말고, 최소한 `part`, `word`, `pos`, `meaning_ko`, `ipa`, `pron_ko`, `example_en`, `example_ko`, `image_prompt`, `frequency_tier`, `topic`, `synonyms`, `distractors` 필드를 가진 구조로 저장하는 편이 좋습니다. TOEIC는 파트별 문항 유형이 명확하므로 `part`와 `topic`을 분리해 두면, 예를 들어 Part 3와 Part 4에서 둘 다 쓰이는 `schedule` 같은 단어도 “meeting / travel / announcement” 태그로 재학습시킬 수 있습니다.[^1_2][^1_1]

예를 들면 아래처럼 JSON 스키마를 두면 확장성이 좋습니다. 이 방식은 발음, 예문, 그림, 빈도 우선순위, 오답 선택지 생성까지 한 번에 연결하기 쉽습니다.[^1_2]

```json
{
  "id": "toeic-p3-deadline",
  "part": 3,
  "word": "deadline",
  "pos": "noun",
  "meaning_ko": "마감일",
  "ipa": "/ˈdedlaɪn/",
  "pron_ko": "데드라인",
  "example_en": "We need to finish the report before the deadline.",
  "example_ko": "우리는 마감일 전에 보고서를 끝내야 한다.",
  "topic": ["office", "project", "meeting"],
  "frequency_tier": 1,
  "image_prompt": "office team checking project deadline on calendar",
  "image_keyword": ["deadline", "calendar", "office"],
  "synonyms": ["due date"],
  "distractors": ["outline", "receipt", "branch"]
}
```


## 이미지와 빈도

사용자 요청에 있는 “그림”은 저작권과 배포 문제 때문에, 처음부터 외부 이미지를 수집해 저장하기보다 `image_prompt`와 `search_keyword`를 메타데이터로 보관하고 필요 시 이미지 생성 API나 합법적 스톡 API를 호출하는 구조가 더 안전합니다. 특히 TOEIC 프로그램은 상용화 가능성이 있으므로, 예문과 이미지 모두 자체 생성 또는 라이선스 확인 가능한 자료를 쓰는 것이 좋습니다.[^1_1]

빈도 우선 정렬은 공식 ETS 단어 빈도 공개표가 쉽게 제공되지 않으므로, TOEIC 대표 어휘 자료에서 반복적으로 등장하는 비즈니스 핵심어를 1티어로, 특정 문서형·상황형 어휘를 2티어로 분류하는 방식이 실무적입니다. 예를 들어 `schedule`, `confirm`, `meeting`, `customer`, `report`, `contract`, `reservation`, `shipment`, `delay`, `available` 같은 단어는 여러 TOEIC 자료에서 공통적으로 다뤄지는 중심 어휘라 초기 학습 세트의 상단에 두기 좋습니다.[^1_1][^1_2]

## 개발 권장안

개발 순서는 다음이 효율적입니다.[^1_2][^1_1]

- 1단계: Part 1~7별 핵심 단어를 각 50개씩 선정해 총 350개 MVP를 만듭니다.[^1_1][^1_2]
- 2단계: 각 단어에 IPA, 한글 발음, 예문 1개, 예문 해석, 그림 프롬프트를 붙입니다.[^1_2]
- 3단계: `frequency_tier`와 `wrong_answer_pattern`을 붙여 객관식·플래시카드·받아쓰기 모드를 구현합니다.[^1_1]
- 4단계: 이후 600단어급, 1000단어급으로 확장하면서 파트별·주제별·난이도별 필터를 추가합니다.[^1_3][^1_1]

원하시면 다음 단계로 바로 이어서 **Part 1~7 전체 필수 단어 350개를 표준 JSON/CSV 형식으로 확장 작성**해 드리겠습니다. 또한 React/Next.js 또는 Python FastAPI 기반으로 바로 붙일 수 있는 **DB 스키마와 화면 설계**까지 한국어로 정리해 드릴 수 있습니다.[^1_2][^1_1]
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15][^1_4][^1_5][^1_6][^1_7][^1_8][^1_9]</span>

<div align="center">⁂</div>

[^1_1]: https://hungvuongtech.edu.vn/wp-content/uploads/2024/06/600-Essential-Words-For-The-TOEIC-Test.pdf

[^1_2]: https://www.bestmytest.com/toeic/vocabulary-blog/overview

[^1_3]: https://www.pass-the-toeic-test.com/toeic-word-list.php

[^1_4]: https://www.vocabulary.com/lists/196080

[^1_5]: https://es.scribd.com/document/49718574/TOEIC-VOCABULARY

[^1_6]: https://www.lingomelo.com/blog-page/toeic-word-list/

[^1_7]: https://www.bestmytest.com/ko/toeic/test

[^1_8]: https://play.google.com/store/apps/details?id=com.bean.edu.toeic.words.basic

[^1_9]: https://www.iibc-global.org/english/toeic/test/lr/about/format.html

[^1_10]: http://www.jacet.org/JACET_Journal_No61/JACET_Journal_61_04.pdf

[^1_11]: https://prepedu.com/en/blog/toeic-part-4-vocabulary

[^1_12]: https://www.youtube.com/watch?v=Q-Gh7lOAcDE

[^1_13]: https://www.scribd.com/document/258010785/Pass-the-TOEIC-Test-ToEIC-Word-List

[^1_14]: https://estudyme.com/en/common-vocabulary-for-toeic-part-5/

[^1_15]: https://www.doe.go.th/prd/assets/upload/files/bkk_th/0d6730a87776461f171f85ba791ca768.pdf


---

# 예문에 대한 듣기를 모두 추가합니다. AI 음성서비스를 이용하여 TTS를 구축합니다. 영국인/호주인, 미국인 등의 음원을 확보하는 발벙을 구체적으로 포함합니다.

예문 듣기를 모두 추가하려면, 단어 데이터에 `example_audio_url`, `example_audio_provider`, `example_voice_locale`, `example_voice_id`, `example_audio_speed`, `example_audio_format`, `tts_ssml`, `duration_ms` 같은 오디오 메타데이터 필드를 별도로 두고, 예문 생성 직후 TTS 배치 파이프라인으로 MP3를 만드는 구조가 가장 안정적입니다. 특히 영국·호주·미국 발음을 확보하려면 단일 엔진보다 멀티 벤더 전략이 좋으며, AWS Polly는 en-AU, en-GB, en-US 음성을 제공하고, Azure Speech도 en-AU, en-GB, en-US에 대해 매우 넓은 음성 선택지를 제공합니다.[^2_1][^2_2]

## 권장 아키텍처

가장 실용적인 구조는 `vocabulary DB -> example text -> SSML builder -> TTS provider adapter -> audio storage -> CDN delivery -> app playback` 흐름입니다. 이렇게 하면 예문은 공통으로 유지하고, 같은 문장을 미국식·영국식·호주식으로 각각 렌더링해서 학습자가 억양을 비교 청취할 수 있습니다.[^2_2][^2_1]

권장 저장 구조 예시는 아래와 같습니다.[^2_1]

```json
{
  "id": "toeic-p3-deadline",
  "word": "deadline",
  "part": 3,
  "example_en": "We need to finish the report before the deadline.",
  "audio": [
    {
      "locale": "en-US",
      "provider": "azure",
      "voice_id": "en-US-EmmaNeural",
      "format": "audio-24khz-96kbitrate-mono-mp3",
      "speed": 0.92,
      "url": "https://cdn.example.com/audio/toeic-p3-deadline-en-us.mp3"
    },
    {
      "locale": "en-GB",
      "provider": "aws-polly",
      "voice_id": "Amy",
      "format": "mp3",
      "speed": 0.90,
      "url": "https://cdn.example.com/audio/toeic-p3-deadline-en-gb.mp3"
    },
    {
      "locale": "en-AU",
      "provider": "azure",
      "voice_id": "en-AU-NatashaNeural",
      "format": "audio-24khz-96kbitrate-mono-mp3",
      "speed": 0.90,
      "url": "https://cdn.example.com/audio/toeic-p3-deadline-en-au.mp3"
    }
  ]
}
```


## 음원 확보 방법

### 1) 가장 추천: 클라우드 TTS 다중 공급자

AWS Polly는 영어 변형으로 Australian `en-AU`, British `en-GB`, US `en-US`를 지원하며, 예를 들어 호주 영어는 Nicole, Olivia, Russell, 영국 영어는 Amy, Emma, Brian, Arthur, 미국 영어는 Joanna, Matthew, Danielle, Gregory 등 다수의 음성을 제공합니다. Azure Speech는 영국 영어 `en-GB`, 호주 영어 `en-AU`, 미국 영어 `en-US`에 대해 훨씬 더 많은 신경망 음성을 제공하며, 예를 들어 `en-GB-SoniaNeural`, `en-GB-RyanNeural`, `en-AU-NatashaNeural`, `en-AU-WilliamNeural`, `en-US-EmmaNeural`, `en-US-AndrewNeural` 등을 사용할 수 있습니다.[^2_2][^2_1]

이 방식의 장점은 다음과 같습니다.[^2_1][^2_2]

- 대량 배치 생성이 쉽습니다.[^2_1]
- 상용 서비스에 넣기 좋은 API와 SLA가 있습니다.[^2_2][^2_1]
- locale 단위로 발음을 구분할 수 있습니다.[^2_2]
- 같은 예문을 여러 억양으로 자동 생성할 수 있습니다.[^2_1][^2_2]


### 2) 고급형: 브랜드 보이스 / 커스텀 보이스

AWS는 Brand Voice를 안내하고 있어 고유 음색의 커스텀 음성 구축이 가능합니다. Azure도 커스텀 스피치와 음성 관련 커스터마이징 경로를 제공하므로, 나중에 “토익 튜터 전용 내레이터” 같은 일관된 캐릭터 음성을 만들 수 있습니다.[^2_2][^2_1]

다만 초기 TOEIC 단어암기 서비스에서는 커스텀 보이스보다, 먼저 공개 제공되는 neural voices로 MVP를 만드는 편이 비용·시간 측면에서 낫습니다.[^2_1][^2_2]

### 3) 비추천: 임의 수집한 원어민 음원

유튜브, 팟캐스트, SNS, 임의 녹음 파일에서 영국인·호주인·미국인 음성을 수집해 데이터셋으로 쓰는 방식은 저작권, 초상권, 퍼블리시티권, 동의 이슈가 있어서 상용 제품에는 위험합니다. 따라서 “음원을 확보”한다는 뜻은 실제로는 무단 수집이 아니라, 라이선스가 명확한 TTS 공급자의 locale별 음성을 계약 기반으로 사용하는 방식으로 해석하는 것이 안전합니다.[^2_2][^2_1]

## 억양별 확보 전략

영국·호주·미국 억양을 모두 넣으려면, 아래처럼 표준 세트를 먼저 고정하는 것이 좋습니다.[^2_1][^2_2]


| 용도 | 추천 locale | 1차 추천 음성 | 백업 음성 |
| :-- | :-- | :-- | :-- |
| 기본 학습 음성 | en-US | Azure `en-US-EmmaNeural` 또는 Polly `Joanna` | Azure `en-US-AndrewNeural`, Polly `Matthew` [^2_1][^2_2] |
| 영국식 비교 청취 | en-GB | Azure `en-GB-SoniaNeural` 또는 Polly `Amy` | Azure `en-GB-RyanNeural`, Polly `Brian` [^2_1][^2_2] |
| 호주식 비교 청취 | en-AU | Azure `en-AU-NatashaNeural` | Azure `en-AU-WilliamNeural`, Polly `Olivia` [^2_1][^2_2] |

실제 서비스에서는 “기본 음성 1개 + 비교 음성 2개” 구성이 좋습니다. 즉, 모든 예문에 미국식 기본 듣기를 붙이고, 사용자가 설정에서 영국식/호주식을 추가 다운로드 또는 스트리밍하도록 설계하면 저장 비용과 생성 비용을 줄일 수 있습니다.[^2_2][^2_1]

## TTS 품질 설계

TOEIC 학습용 TTS는 일반 안내방송보다 더 천천히, 더 명확하게 읽혀야 하므로 SSML을 적극적으로 써야 합니다. Amazon Polly는 `<lang>` 태그와 발음 제어 관련 기능을 지원하며, 영국 영어 음성의 IPA 관련 문서도 제공하고 있습니다.[^2_3][^2_4][^2_2]

예문용 SSML 예시는 아래처럼 설계할 수 있습니다.[^2_4]

```xml
<speak>
  <prosody rate="92%">
    We need to finish the report before the deadline.
  </prosody>
  <break time="700ms"/>
  <prosody rate="80%">
    deadline
  </prosody>
  <break time="400ms"/>
  <prosody rate="88%">
    We need to finish the report before the deadline.
  </prosody>
</speak>
```

이 구조는 학습 효과가 좋습니다.[^2_4]

- 1회차: 자연 속도 문장.
- 2회차: 핵심 단어만 분리 강조.
- 3회차: 약간 느린 속도로 문장 반복.


## 구현 방식

### AWS Polly 예시

Amazon Polly는 locale과 voice ID를 선택해 MP3를 만들 수 있고, 영어 변형과 neural voice 목록이 공식 문서에 정리되어 있습니다. 예를 들어 영국식 `Amy`, 미국식 `Joanna`, 호주식 `Olivia`를 고정 매핑으로 두면 파이프라인이 단순해집니다.[^2_1]

개념 예시는 다음과 같습니다.[^2_1]

```python
VOICE_MAP = {
    "en-US": {"provider": "polly", "voice_id": "Joanna"},
    "en-GB": {"provider": "polly", "voice_id": "Amy"},
    "en-AU": {"provider": "polly", "voice_id": "Olivia"}
}
```


### Azure Speech 예시

Azure Speech는 영미권 변형에 대해 더 많은 neural voice를 제공하므로, A/B 테스트와 사용자 맞춤 음성 선택 기능에 유리합니다. 예를 들면 미국식 기본은 `en-US-EmmaNeural`, 영국식은 `en-GB-SoniaNeural`, 호주식은 `en-AU-NatashaNeural` 같은 식으로 구성할 수 있습니다.[^2_2]

개념 예시는 다음과 같습니다.[^2_2]

```python
VOICE_MAP = {
    "en-US": {"provider": "azure", "voice_id": "en-US-EmmaNeural"},
    "en-GB": {"provider": "azure", "voice_id": "en-GB-SoniaNeural"},
    "en-AU": {"provider": "azure", "voice_id": "en-AU-NatashaNeural"}
}
```


## 운영 전략

초기 운영은 다음 순서가 가장 좋습니다.[^2_1][^2_2]

- 1단계: 모든 예문에 미국식 기본 음성 1종만 생성합니다.[^2_2][^2_1]
- 2단계: 상위 빈도 단어 300~500개 예문에 대해 영국식과 호주식을 추가 생성합니다.[^2_1][^2_2]
- 3단계: 사용자 설정에서 “미국식/영국식/호주식” 기본 억양을 고르게 합니다.[^2_2]
- 4단계: 어려운 단어에는 느린 속도 버전과 일반 속도 버전을 둘 다 제공합니다.[^2_4]
- 5단계: 재생 로그를 보고 많이 듣는 예문만 다중 억양 음원으로 확장합니다.[^2_1]

이렇게 하면 전수 3배 생성보다 비용이 훨씬 절약됩니다. 특히 TOEIC 예문은 수천 개 이상으로 늘어나기 쉬우므로, “모든 문장 x 3개 억양 x 2개 속도”는 초기에 과할 수 있습니다.[^2_2][^2_1]

## 추천 결론

현재 목표가 TOEIC 단어암기 프로그램이라면, **Azure Speech 또는 AWS Polly 기반의 멀티 억양 TTS 파이프라인**이 가장 현실적입니다. 영국인/호주인/미국인 “실제 사람 음원”을 따로 확보하려 하기보다, 공식 지원 locale 음성을 가진 클라우드 TTS를 라이선스 범위 안에서 사용하고, 예문마다 en-US/en-GB/en-AU 버전을 생성하는 방식이 개발·운영·법률 측면에서 가장 안전합니다.[^2_1][^2_2]

다음 단계로는 **Python 배치 생성기 코드, DB 스키마, S3/CloudFront 저장 구조, 그리고 React 재생 UI 설계**까지 바로 이어서 구체화할 수 있습니다.[^2_2][^2_1]
<span style="display:none">[^2_10][^2_11][^2_12][^2_13][^2_14][^2_15][^2_16][^2_17][^2_5][^2_6][^2_7][^2_8][^2_9]</span>

<div align="center">⁂</div>

[^2_1]: https://www.vocabulary.com/lists/196080

[^2_2]: https://es.scribd.com/document/49718574/TOEIC-VOCABULARY

[^2_3]: https://docs.aws.amazon.com/polly/latest/dg/ph-table-english-uk.html

[^2_4]: https://docs.aws.amazon.com/polly/latest/dg/lang-tag.html

[^2_5]: https://docs.aws.amazon.com/polly/latest/dg/available-voices.html

[^2_6]: https://docs.aws.amazon.com/polly/latest/dg/supported-languages.html

[^2_7]: https://docs.aws.amazon.com/polly/latest/dg/API_Voice.html

[^2_8]: https://awsapichanges.info/archive/service/polly

[^2_9]: https://www.youtube.com/watch?v=KOxKmunpKTc

[^2_10]: https://docs.ropensci.org/googleLanguageR/articles/text-to-speech.html

[^2_11]: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support

[^2_12]: https://community.openconversational.ai/t/choosing-a-different-speaking-voice-when-using-google-text-to-speech/3357/4

[^2_13]: https://docs.aws.amazon.com/polly/latest/dg/neural-voices.html

[^2_14]: https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/azure-cognitive-services-releases-new-languages-and-voices-for-neural-text-to-sp/3672286

[^2_15]: https://enfonica.com/docs/cloud-voice/voiceml/text-to-speech-voices/

[^2_16]: https://github.com/DanMittendorf/use-all-polly-voices-with-lang-tag

[^2_17]: https://docs.azure.cn/en-us/ai-services/speech-service/language-support


---

# 이미지와 같은 배치를 통해 단어암기 레슨을 진행합니다.

네, 가능합니다. 첨부 이미지처럼 **검은 배경의 온보딩/레슨 커버 + 중앙 스마트폰 프레임 + 하단 2버튼 CTA** 구조로 단어암기 레슨을 설계하면, “한 번 훑고 바로 학습 진입”하는 흐름을 매우 직관적으로 만들 수 있습니다.[^3_1]

## 배치 해석

첨부 이미지는 상단에 회차 번호가 있고, 중앙에는 큰 헤드라인과 보조 설명이 배치되며, 실제 학습 콘텐츠는 스마트폰 목업 안에 들어가고, 맨 아래에는 이지선다형 행동 버튼이 놓인 구조입니다. 즉 이 레이아웃은 단순 상세 페이지가 아니라, **레슨 시작 전 동기 부여 + 선택 유도 + 학습 진입**을 동시에 처리하는 커버형 화면으로 보는 것이 맞습니다.[^3_1]

이 구조를 단어암기 서비스에 적용하면, “오늘의 레슨 번호”, “학습 목표”, “핵심 단어 수”, “학습 시작 버튼”, “이미 아는 단어 스킵 버튼”을 한 화면에 자연스럽게 담을 수 있습니다. 특히 토익 단어 서비스에서는 “빠르게 1회독”, “기출 단어 우선”, “듣기 포함” 같은 메시지를 상단에 고정하면 사용자가 레슨 의도를 즉시 이해할 수 있습니다.[^3_1]

## 화면 구조

추천 화면 계층은 아래처럼 구성하면 됩니다.[^3_1]

- 레슨 커버 화면: 회차 번호, 제목, 설명, 오늘 학습할 파트/단어 수, CTA 2개.[^3_1]
- 카드 학습 화면: 단어, 뜻, IPA, 한글 발음, 대표 예문, 예문 듣기, 그림, 알고 있음/복습 필요 버튼.[^3_1]
- 복습 화면: 틀린 단어, 보류한 단어, 다시 듣기, 쉐도잉.[^3_1]

이미지의 배치를 토익 단어 레슨으로 치환하면 다음과 같은 대응이 좋습니다.[^3_1]


| 이미지 영역 | 단어암기 레슨 대응 |
| :-- | :-- |
| 상단 숫자 `26` | Lesson 26, Day 26, Part 3-01 같은 레슨 식별자 [^3_1] |
| 큰 제목 | “빠르게 Part 3 핵심단어 20개 익히기” 같은 레슨 목표 [^3_1] |
| 보조 문장 | “고빈도 기출 어휘와 예문 듣기로 바로 암기” 같은 설명 [^3_1] |
| 중앙 폰 프레임 | 실제 플래시카드/듣기/그림 영역 [^3_1] |
| 좌측 버튼 | “알고 있어요”, “건너뛸게요” [^3_1] |
| 우측 버튼 | “학습할게요”, “다시 들을게요” [^3_1] |

## 카드 내용

스마트폰 프레임 안에는 단어 하나씩 보여주는 카드형 레슨이 가장 잘 맞습니다. 사용자가 한 화면에서 너무 많은 정보를 읽지 않도록, 카드 1장당 정보 우선순위를 강하게 나누는 것이 중요합니다.[^3_1]

권장 카드 구성은 아래 순서입니다.

1. 상단: 파트 배지, 빈도 등급, 즐겨찾기.[^3_1]
2. 메인: 단어, 발음기호, 한글 발음.[^3_1]
3. 중간: 대표 그림 또는 장면 일러��트.[^3_1]
4. 하단: 뜻, 대표 예문, 예문 듣기 버튼, 느리게 듣기 버튼.[^3_1]
5. 맨 아래: “알고 있어요 / 학습할게요” 또는 “암기 완료 / 다시 보기” 버튼.[^3_1]

예를 들어 카드 한 장은 이렇게 보이게 할 수 있습니다.

- 단어: `deadline`
- IPA: `/ˈdedlaɪn/`
- 한글 발음: `데드라인`
- 뜻: `마감일`
- 예문: `We need to finish the report before the deadline.`
- 버튼: `미국식 듣기`, `영국식 듣기`, `호주식 듣기`, `느리게 듣기`

이렇게 하면 이전에 논의한 TTS 구조와도 자연스럽게 연결됩니다. en-US, en-GB, en-AU 음원을 같은 카드 안에 탭 또는 아이콘 형태로 둘 수 있기 때문입니다.[^3_2][^3_3]

## 레슨 흐름

첨부 이미지의 핵심은 “레슨 시작 전 선택”이므로, 단어암기 흐름도 강의형보다는 **초경량 의사결정 루프**로 만드는 것이 좋습니다.[^3_1]

추천 흐름은 다음과 같습니다.[^3_1]

- 커버 화면: “오늘 Part 2 질문응답 핵심 15단어”.
- 시작 버튼 클릭.
- 카드 1장 노출.
- 사용자는 `알고 있어요` 또는 `학습할게요` 선택.
- `학습할게요`를 누르면 뜻, 예문, 듣기, 그림이 확장 노출.
- 마지막에는 “오늘 복습할 단어만 다시 보기”.

이 방식은 스키밍 후 정교 학습으로 이어지는 구조라서, 첨부 이미지의 “빠르게 1회독” 메시지와 잘 맞습니다.[^3_1]

## UI 카피 예시

첨부 이미지 분위기를 유지하려면 카피는 짧고 강하게 가는 편이 좋습니다. 토익 단어 레슨 커버용 문구 예시는 아래처럼 잡을 수 있습니다.[^3_1]

- `빠르게 Part 3 1회독하고`
- `고빈도 기출 단어만 먼저 익히는 레슨`
- `예문 듣기와 그림으로 바로 암기`
- `오늘의 필수 20단어`
- `알고 있어요`
- `학습할게요`

이런 문구는 모바일 온보딩 감성과도 잘 맞고, 실제 학습 행동을 바로 유도합니다.[^3_1]

## 개발 구현안

이 레이아웃을 서비스로 구현할 때는 화면을 아래 3개 컴포넌트로 나누는 것이 좋습니다.[^3_3][^3_2][^3_1]

- `LessonCoverScreen`: 회차, 제목, 설명, 시작 버튼.[^3_1]
- `WordCardScreen`: 단어, IPA, 뜻, 그림, 예문, TTS 플레이어.[^3_2][^3_3]
- `LessonResultScreen`: 학습 완료 수, 복습 대상 수, 다시 듣기.[^3_1]

프론트엔드 상태는 아래 정도면 충분합니다.[^3_3][^3_2]

```ts
type LessonWord = {
  id: string;
  part: number;
  word: string;
  meaningKo: string;
  ipa: string;
  pronKo: string;
  exampleEn: string;
  imageUrl: string;
  audio: {
    locale: "en-US" | "en-GB" | "en-AU";
    url: string;
    speed: "normal" | "slow";
  }[];
  known: boolean | null;
};
```

그리고 CTA 동작은 이렇게 맵핑하면 됩니다.[^3_1]

- `알고 있어요`: 해당 단어를 known 처리 후 다음 카드.
- `학습할게요`: 상세 정보 펼침 + 듣기 자동 재생.
- `다시 들을게요`: 같은 카드 내 TTS 재생.
- `복습할게요`: lesson queue 뒤로 재삽입.


## 레이아웃 포인트

첨부 이미지 같은 느낌을 살리려면 시각적으로 다음 요소를 지키는 것이 중요합니다.[^3_1]

- 전체 배경은 거의 검정에 가깝게 유지합니다.[^3_1]
- 텍스트는 흰색 위주로 강한 대비를 줍니다.[^3_1]
- 중앙 스마트폰 프레임은 실제 학습 영역을 상징하므로, 둥근 모서리와 밝은 내부 캔버스를 사용합니다.[^3_1]
- 하단 버튼은 흰 버튼과 검은 버튼을 대비시켜, “가벼운 스킵 / 적극 학습”의 의미 차이를 줍니다.[^3_1]

즉, 이 디자인은 콘텐츠 자체보다도 **행동 유도형 학습 시작 화면**으로 매우 적합합니다. 토익 단어앱에서는 각 레슨 입구를 이런 방식으로 통일하면 브랜드 일관성과 몰입감도 좋아집니다.[^3_1]

다음 단계로는 이 배치를 기준으로 **실제 HTML/CSS/React 시안**, 또는 **단어카드 10장 분량의 샘플 레슨 데이터**까지 바로 구체화할 수 있습니다.[^3_2][^3_3][^3_1]

<div align="center">⁂</div>

[^3_1]: image.jpeg

[^3_2]: https://www.vocabulary.com/lists/196080

[^3_3]: https://es.scribd.com/document/49718574/TOEIC-VOCABULARY


---

# 아이폰, 안드로이드폰, 아이패드, 안드로이드패드로 구성하며 반응형웹과 같은 형태로 구성을 합니다.

회원가입은 기본적으로 구글, 카카오, 애플 등과 이메일(비밀번호, OPT)로 제공을 합니다.
단어암기 및 래슨진행, 진도율, 커리큘럼 및 일정관리, 개인 암기노트 등의 기능을 제공합니다.
유사한 기능을 제공하는 오픈소스나 앱(웹이나 앱웹 형태)을 조사하여 기능을 분석하여 표로 정리합니다.

요구하신 서비스는 단순 단어장 앱이 아니라, **멀티디바이스 반응형 학습 플랫폼 + 소셜 로그인/이메일 인증 + SRS 기반 단어암기 + 커리큘럼/일정 + 개인 노트**를 결합한 구조로 보는 것이 맞습니다. 조사 결과, 완전히 동일한 제품은 드물지만 Anki, Mochi, RemNote, LingQ, AnkiDroid 같은 서비스들이 각각 핵심 기능 일부를 잘 구현하고 있어 벤치마킹 조합이 분명합니다.[^4_1][^4_2][^4_3][^4_4][^4_5]

## 제품 방향

아이폰, 안드로이드폰, 아이패드, 안드로이드패드를 모두 대응하려면 네이티브 앱을 각각 따로 만드는 것보다, 우선 **반응형 웹앱 또는 PWA 중심**으로 설계하고 화면 크기에 따라 레이아웃만 달라지게 하는 방식이 가장 효율적입니다. 실제로 Mochi는 iOS·Android·데스크톱을 모두 지원하고, LingQ는 웹과 모바일 앱 간 동기화를 강조하며, Anki 생태계도 데스크톱·웹·모바일 동기화 구조를 갖고 있습니다.[^4_2][^4_4][^4_6][^4_5]

회원가입은 구글·애플·카카오·이메일 조합이 현실적인 기본선입니다. 조사한 학습 앱들 중 다수는 계정 동기화나 가입 기반 서비스를 제공하지만, 귀하의 서비스처럼 한국 사용자 대상 시험 준비 서비스를 생각하면 카카오 로그인까지 포함하는 것이 차별화 포인트가 될 수 있습니다.[^4_4][^4_6]

## 핵심 기능 정리

귀하가 제시한 기능은 아래 5개 도메인으로 나누는 것이 적절합니다.

- 인증/계정: 구글, 카카오, 애플, 이메일+비밀번호, 이메일 OTP.[^4_6][^4_4]
- 학습: 단어암기, 예문 듣기, 플래시카드, 알고 있음/모름 처리, 개인화 복습.[^4_5][^4_2]
- 운영: 레슨 진행, 진도율, 학습 통계, 약한 단어 재노출.[^4_3][^4_2]
- 학습 설계: 커리큘럼, 학습 일정, 시험일까지의 계획.[^4_3]
- 개인 지식화: 개인 암기노트, 태그, 즐겨찾기, 나만의 단어장.[^4_4][^4_5]

이 중 특히 “커리큘럼 및 일정관리”는 일반 단어장 앱보다 시험 준비 플랫폼에 더 가까운 기능입니다. RemNote는 시험일 기준으로 복습 일정을 조정하는 Exam Scheduler를 제공하므로, 귀하 서비스의 일정 관리 모듈과 가장 유사한 참고 사례입니다.[^4_3]

## 조사 결과 표

아래 표는 귀하의 요구 기능 관점에서 유사 서비스와 오픈소스를 비교한 것입니다.


| 서비스/프로젝트 | 형태 | 오픈소스 여부 | 주요 강점 | 단어암기/레슨 | 진도율/통계 | 일정/시험계획 | 개인 노트 | TTS/오디오 | 멀티디바이스 |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| Anki | 데스크톱+웹+모바일 생태계 | 예, 코어 오픈소스 [^4_7] | SRS의 대표 사례, 대규모 생태계 [^4_7] | 플래시카드 중심, 강함 [^4_7] | 강함, 리뷰 중심 [^4_2] | 기본적, 별도 일정관리 약함 [^4_7] | 카드 메모 수준, 제한적 [^4_7] | 이미지/사운드 지원 [^4_2] | 매우 강함 [^4_2][^4_7] |
| AnkiDroid | 안드로이드 앱 | 예, 오픈소스 연계 [^4_2] | 안드로이드 학습 UX, 동기화, 위젯 [^4_2] | 매우 강함 [^4_2] | 상세 통계 제공 [^4_2] | 커리큘럼 기능은 약함 [^4_2] | 카드 편집 중심 [^4_2] | TTS 통합 지원 [^4_2] | 태블릿 레이아웃 지원 [^4_2] |
| Mochi | 웹+모바일+데스크톱 | 부분 공개/프로덕트형 | UI/UX 우수, 로컬 퍼스트, SRS+노트 결합 [^4_5] | 강함 [^4_5] | 리뷰 중심 추적 가능 [^4_5] | 일정관리 자체는 약함 [^4_5] | 매우 강함, Markdown 노트/태그/검색 [^4_5] | TTS, 이미지 검색, 번역 지원 [^4_5] | 매우 강함 [^4_5] |
| RemNote | 웹+모바일 | 아니오, 상용 서비스 | 노트+플래시카드+시험 일정 최적화 [^4_3] | 강함 [^4_3] | 강함 [^4_3] | 매우 강함, Exam Scheduler [^4_3] | 매우 강함, 노트 내 카드 삽입 [^4_3] | AI 카드 생성 중심, TTS 언급은 상대적으로 약함 [^4_3] | 강함 [^4_8][^4_3] |
| LingQ | 웹+앱 | 아니오 | 콘텐츠 기반 어휘 저장, 듣기/읽기 통합 [^4_4] | 단어 저장과 반복학습 강함 [^4_4] | Known Words 등 성장 추적 강함 [^4_4] | 정교한 시험 일정 기능은 약함 [^4_4] | 개인 어휘 DB 강함 [^4_4][^4_6] | 오디오+텍스트 기반 강함 [^4_4] | 매우 강함 [^4_6][^4_4] |
| Vocab Victor Classroom | 웹앱 | 불명확/상용 성격 | 교사용 단어 할당, 진행 모니터링 [^4_9] | 단어학습 중심 [^4_9] | 학생 진행 모니터링 가능 [^4_9] | 교실 과제 일정 수준 [^4_9] | 개인 암기노트는 약함 [^4_9] | 정보 제한적 [^4_9] | 웹 중심 [^4_9] |
| Flashcards Open Source App | iOS+Android+웹 | 예 [^4_10] | 최신 크로스플랫폼 플래시카드 앱 사례 [^4_10] | 있음 [^4_10] | 일부 지원 가능 [^4_10] | 공개 정보상 제한적 [^4_10] | 제한적 [^4_10] | AI 기반 보조 가능 [^4_10] | 강함 [^4_10] |

## 벤치마킹 포인트

귀하의 서비스와 가장 가까운 레퍼런스 조합은 하나로 압축되지 않고, 아래처럼 기능별로 분해해 보는 편이 좋습니다.

- 학습 엔진은 Anki/AnkiDroid 스타일의 SRS가 가장 검증되어 있습니다.[^4_7][^4_2]
- 카드 작성성과 개인 암기노트 UX는 Mochi가 매우 좋은 참고 대상입니다.[^4_5]
- 시험일 기준 일정/커리큘럼 최적화는 RemNote가 가장 직접적인 벤치마크입니다.[^4_3]
- 듣기+텍스트+개인 단어 축적 경험은 LingQ가 참고 가치가 큽니다.[^4_6][^4_4]

즉, 귀하 서비스는 “Anki의 복습 엔진 + Mochi의 카드/노트 UX + RemNote의 일정 스케줄러 + LingQ의 어휘 자산화”를 시험 준비용으로 재조합한 형태가 가장 경쟁력 있습니다.[^4_7][^4_4][^4_5][^4_3]

## 기능 갭 분석

현재 조사된 서비스들과 비교할 때, 귀하가 만들려는 제품의 차별점은 아래에 있습니다.

- TOEIC 파트별 고빈도 단어와 레슨 흐름을 기본 제공한다는 점.[^4_11]
- 예문 듣기를 미국식·영국식·호주식으로 제공한다는 점.[^4_12][^4_13]
- 커버형 레슨 UI와 카드형 학습 UI를 결합한다는 점.[^4_14]
- 개인 암기노트와 시험 일정관리까지 한 앱 안에서 제공한다는 점.[^4_5][^4_3]

반대로, 기존 제품들이 이미 강한 영역도 있습니다.

- 범용 SRS 알고리즘 완성도는 Anki/RemNote가 강합니다.[^4_7][^4_3]
- 노트 편집 경험은 Mochi/RemNote가 강합니다.[^4_5][^4_3]
- 콘텐츠 가져오기와 읽기-듣기 연동은 LingQ가 강합니다.[^4_4]

따라서 초기 MVP는 모든 기능을 한 번에 넣기보다 아래 우선순위가 좋습니다.

1. 반응형 웹앱, 로그인, 단어카드, TTS, 진도율.[^4_12][^4_5]
2. 개인 암기노트, 즐겨찾기, 오답/복습 큐.[^4_2][^4_5]
3. 커리큘럼, 시험일까지 학습 일정 추천.[^4_3]
4. 소셜/학습 리포트, 관리자 CMS, AI 예문 생성.[^4_5][^4_3]

## 화면/플랫폼 설계

반응형웹 구조는 디바이스별로 별도 앱을 만드는 것이 아니라, 같은 정보 구조를 화면 크기에 맞게 재배치하는 형태가 적합합니다.[^4_4][^4_5]

- 아이폰/안드로이드폰: 1열 카드, 하단 sticky CTA, swipe 중심 학습.[^4_14]
- 아이패드/안드로이드패드: 좌측 커리큘럼/단어목록, 우측 카드/노트 2열 구성.[^4_3][^4_5]
- 데스크톱 웹: 좌측 내비게이션, 중앙 카드, 우측 노트/일정 패널 3영역도 가능하지만, 초기에는 태블릿 2열을 확장한 정도가 무난합니다.[^4_5]

로그인 구성은 다음이 현실적입니다.

- OAuth/OIDC: Google, Apple, Kakao.
- 이메일 가입: 비밀번호 + 이메일 OTP 인증.
- 향후 확장: 비밀번호리스 magic link 또는 Passkey.

오픈소스 구현 관점에서는 Keycloak, Auth.js/NextAuth 계열, 또는 Firebase/Auth0/Supabase Auth 같은 외부 인증 서비스를 붙일 수 있지만, 이번 조사 대상 자료에서는 주로 기능 비교 중심이어서 인증 자체의 구현 상세보다는 사용자 경험 설계가 핵심입니다.[^4_6][^4_4]

## 추천 결론

귀하의 서비스는 기존 플래시카드 앱의 단순 복제보다, **시험 특화 학습 운영체계**로 포지셔닝하는 것이 맞습니다. Anki 계열의 복습 효율, Mochi의 카드/노트 UX, RemNote의 일정 기반 학습 계획, LingQ의 듣기·어휘 축적 모델을 결합하면 요구하신 기능 집합을 상당히 설득력 있게 구현할 수 있습니다.[^4_7][^4_4][^4_3][^4_5]

다음 단계로는 이 조사 결과를 바탕으로 **IA 사이트맵, 화면 목록, 기능 우선순위 표, 그리고 DB/인증 아키텍처 초안**까지 이어서 정리하는 것이 가장 자연스럽습니다.[^4_4][^4_3][^4_5]
<span style="display:none">[^4_15][^4_16][^4_17][^4_18][^4_19][^4_20][^4_21][^4_22][^4_23][^4_24][^4_25][^4_26][^4_27][^4_28][^4_29][^4_30][^4_31][^4_32][^4_33][^4_34][^4_35][^4_36]</span>

<div align="center">⁂</div>

[^4_1]: https://github.com/ankitects/anki

[^4_2]: https://play.google.com/store/apps/details?id=com.ichi2.anki\&hl=en_IN

[^4_3]: https://www.remnote.com/feature/spaced-repetition

[^4_4]: https://spark.mwm.ai/en/apps/learn-english-lingq/1217730083

[^4_5]: https://www.lingomelo.com/blog-page/toeic-word-list/

[^4_6]: https://www.lingq.com/en/ios-app/

[^4_7]: https://www.bestmytest.com/ko/toeic/test

[^4_8]: https://play.google.com/store/apps/details?id=com.remnote.v2

[^4_9]: https://vocabvictor.com/classroom/

[^4_10]: https://github.com/kirill-markin/flashcards-open-source-app

[^4_11]: https://hungvuongtech.edu.vn/wp-content/uploads/2024/06/600-Essential-Words-For-The-TOEIC-Test.pdf

[^4_12]: https://www.vocabulary.com/lists/196080

[^4_13]: https://es.scribd.com/document/49718574/TOEIC-VOCABULARY

[^4_14]: image.jpeg

[^4_15]: https://github.com/open-spaced-repetition/awesome-fsrs

[^4_16]: https://github.com/topics/flashcard-generator

[^4_17]: https://news.ycombinator.com/item?id=36454783

[^4_18]: https://www.reddit.com/r/opensource/comments/1pm57ve/i_built_a_tiny_opensource_localfirst_flashcard/

[^4_19]: https://www.reddit.com/r/Anki/comments/1dqe6c1/ankidroid_or_quizlet/

[^4_20]: https://github.com/topics/spaced-repetition-flashcards?l=ejs\&o=asc\&s=forks

[^4_21]: https://www.vocarrot.com

[^4_22]: https://www.wordly.es

[^4_23]: https://play.google.com/store/apps/details?id=com.ichi2.anki\&hl=en

[^4_24]: https://github.com/topics/spaced-repetition-flashcards?l=python\&o=asc\&s=updated

[^4_25]: https://play.google.com/store/apps/details?id=com.sayan.atlasenglish\&pcampaignid=web_share

[^4_26]: https://mochi.cards

[^4_27]: https://play.google.com/store/apps/details?id=cards.mochi.app

[^4_28]: https://www.reddit.com/user/mochi-cards/

[^4_29]: https://apps.apple.com/us/app/mochi-flashcards-and-notes/id1507775056

[^4_30]: https://notes.andymatuschak.org/Mochi

[^4_31]: https://discuss.logseq.com/t/integration-with-mochi-card/11839

[^4_32]: https://help.remnote.com/en/articles/6022755-getting-started-with-spaced-repetition

[^4_33]: https://play.google.com/store/apps/details/LingQ_Language_Learning?id=com.linguist\&hl=or

[^4_34]: https://www.youtube.com/watch?v=sXd-kc92ODk

[^4_35]: https://borretti.me/article/first-impressions-mochi

[^4_36]: https://www.youtube.com/watch?v=29idB6Ieoy0


---

# 아이폰, 안드로이드폰의 사용자용 앱을 개발하기 위한 소프트웨어 스택 및 오픈소스를 상세하게 조사 및 비교, 추천해 줘. 그리고 웹앱과 데스크탑용으로 사용할 관리자 프로그램을 위한 오픈소스를 상세하게 조사 및 비교, 추천해 줘. 참고로 조사 및 비교, 추천시에는 기능 리스트와 우선순위를 함께 정리합니다.

아이폰·안드로이드폰 사용자용 앱은 현재 요구사항 기준으로 보면 **React Native + Expo** 또는 **웹 코드 재사용이 극도로 중요할 경우 Capacitor 기반 하이브리드 앱**이 가장 현실적인 후보입니다. 관리자 프로그램은 웹앱이 중심이므로 **Next.js 기반 커스텀 관리자 웹앱 + Appsmith/Directus 같은 오픈소스 관리자 도구를 보조적으로 결합**하는 구성이 가장 설득력 있습니다.[^5_1][^5_2][^5_3]

귀하의 서비스는 단순 콘텐츠 앱이 아니라 로그인, 레슨, 진도율, 일정관리, 개인 암기노트, 오디오 재생, 운영자용 콘텐츠 관리까지 포함하므로, “빠른 MVP”와 “중장기 유지보수”를 함께 봐야 합니다. 그 기준으로 보면 모바일은 RN/Expo가 균형이 가장 좋고, 관리자 영역은 범용 로우코드 하나로 끝내기보다 CMS/운영 툴/분석 대시보드를 역할별로 분리하는 편이 낫습니다.[^5_2][^5_3][^5_1]

## 우선순위

먼저 기능 우선순위를 명확히 정하면 기술 선택이 쉬워집니다. 사용자 앱과 관리자 앱은 목표가 다르므로 우선순위도 분리해야 합니다.

### 사용자용 모바일 앱 우선순위

| 우선순위 | 기능 | 이유 |
| :-- | :-- | :-- |
| P0 | 로그인/회원가입, 소셜 로그인, 이메일 인증 | 서비스 진입의 기본이며 계정 동기화의 출발점입니다.[^5_4][^5_5] |
| P0 | 단어암기 카드, 레슨 진행, 예문 듣기, 진도 저장 | 핵심 학습 가치 그 자체입니다.[^5_2] |
| P0 | 오프라인 캐시, 안정적 오디오 재생, 푸시 알림 | 학습앱 사용성에 직접 영향이 큽니다.[^5_2][^5_3] |
| P1 | 진도율, 복습 큐, 개인 암기노트 | 재방문과 성과 체감에 중요합니다.[^5_6][^5_7] |
| P1 | 일정관리, 커리큘럼, 시험일까지 계획 | 시험 준비 서비스 차별점입니다.[^5_6] |
| P2 | 위젯, 고급 통계, AI 예문 생성, 음성 A/B 테스트 | 초기보다 확장 단계에서 유효합니다.[^5_8][^5_9] |

### 관리자용 프로그램 우선순위

| 우선순위 | 기능 | 이유 |
| :-- | :-- | :-- |
| P0 | 단어/예문/이미지/오디오 CRUD | 운영 핵심입니다.[^5_3] |
| P0 | 커리큘럼/레슨 편집 | 서비스 상품성을 결정합니다.[^5_3] |
| P0 | 사용자 진도 조회, 콘텐츠 배포, 권한 관리 | 운영 안정성에 필수입니다.[^5_10] |
| P1 | 일정 템플릿, 실험군 관리, 통계 대시보드 | 학습 최적화에 중요합니다.[^5_10][^5_11] |
| P1 | 파일 업로드, TTS 배치 생성, 승인 워크플로우 | 콘텐츠 생산성 향상에 중요합니다.[^5_11][^5_10] |
| P2 | 내부 챗봇, 운영 자동화, QA 툴, 고객지원 연동 | 규모가 커질수록 가치가 커집니다.[^5_10][^5_12] |

## 모바일 스택 비교

### 1) React Native + Expo

React Native + Expo는 JavaScript/TypeScript 기반이며, 2026 시점에서 Expo는 빌드, OTA 업데이트, 푸시, 카메라, 기본 디바이스 기능까지 빠르게 연결할 수 있는 “배터리 포함” 경로로 평가됩니다. React Native는 네이티브 UI를 활용하고, Expo는 여기에 관리형 워크플로우와 EAS 배포 체계를 얹어 MVP부터 운영까지 이어가기 쉬운 장점이 있습니다.[^5_13][^5_1]

장점은 다음과 같습니다.[^5_1][^5_13]

- 웹 개발자 친화적입니다.[^5_13]
- TypeScript 생태계가 크고 채용이 쉽습니다.[^5_1]
- OTA 업데이트가 가능해 사소한 UI 수정 배포가 빠릅니다.[^5_1]
- 모바일 전용 UX를 구현하면서도 React 기반 재사용이 쉽습니다.[^5_13]

주의점도 있습니다.[^5_13][^5_1]

- 아주 특수한 네이티브 기능은 직접 모듈 작업이 필요할 수 있습니다.[^5_13]
- Flutter보다 픽셀 단위 UI 일관성은 약간 덜 강할 수 있습니다.[^5_1]


### 2) Flutter

Flutter는 Dart 기반이고, Impeller 렌더링과 자체 렌더링 엔진 덕분에 애니메이션과 복잡한 UI에서 강점이 있다고 비교됩니다. 디자인 일관성과 커스텀 모션이 매우 중요하다면 Flutter는 여전히 강한 선택지입니다.[^5_1][^5_13]

장점은 다음과 같습니다.[^5_13]

- 복잡한 UI와 모션 표현력이 강합니다.[^5_13]
- 플랫폼 간 시각 일관성이 높습니다.[^5_13]
- Firebase 조합이 편리합니다.[^5_14]

하지만 귀하의 요구사항에서는 몇 가지 불리함이 있습니다.[^5_1][^5_13]

- 팀이 이미 TS/웹 중심이라면 진입 비용이 커집니다.[^5_13]
- 웹/관리자와의 코드/사고방식 공유가 RN보다 덜 자연스럽습니다.[^5_13]
- 일반적인 CRUD·리스트·학습앱에서는 RN과 체감 성능 차이가 크지 않다고 평가됩니다.[^5_13]


### 3) Capacitor + React/Vue/Next 계열 웹앱

Capacitor는 기존 웹앱을 iOS, Android, PWA로 감싸고 네이티브 API를 플러그인 방식으로 연결하는 오픈소스 런타임입니다. HTML, CSS, JavaScript 기반 앱을 그대로 활용할 수 있고, 카메라, 파일시스템, 알림, 네트워크 같은 핵심 기능에 접근할 수 있습니다.[^5_3]

장점은 명확합니다.[^5_15][^5_3]

- 웹과 모바일 코드 재사용률이 매우 높습니다.[^5_3]
- 기존 반응형 웹앱을 네이티브 앱으로 확장하기 쉽습니다.[^5_15]
- PWA와 앱스토어 배포를 하나의 프런트 기술군으로 묶기 좋습니다.[^5_3]

단점도 분명합니다.[^5_3]

- 모바일 UX가 RN/Flutter보다 덜 네이티브하게 느껴질 수 있습니다.[^5_3]
- 긴 리스트, 복잡한 제스처, 고빈도 애니메이션이 많은 경우 품질 확보에 더 신경 써야 합니다.[^5_3]


### 모바일 스택 요약표

| 항목 | React Native + Expo | Flutter | Capacitor |
| :-- | :-- | :-- | :-- |
| 언어 | TypeScript/JS [^5_1] | Dart [^5_13] | TypeScript/JS [^5_3] |
| 성능 | 매우 좋음, 일반 앱 충분 [^5_13] | 매우 좋음, UI 집약 앱 강함 [^5_13] | 보통~좋음, 웹 기반 제약 [^5_3] |
| 개발 속도 | 매우 빠름 [^5_1] | 빠름 [^5_13] | 웹팀이면 매우 빠름 [^5_3] |
| 웹 재사용 | 중간~높음 [^5_13] | 낮음~중간 [^5_13] | 최고 [^5_3] |
| 모바일 UX | 좋음 [^5_1] | 매우 좋음 [^5_13] | 중간 [^5_3] |
| 네이티브 기능 접근 | 좋음 [^5_13] | 좋음 [^5_13] | 플러그인 중심 [^5_3] |
| 추천도 | **1위** [^5_1][^5_13] | 2위 [^5_13] | 3위, 웹중심 전략일 때 [^5_3] |

## 모바일 오픈소스 추천

모바일 앱 개발용으로는 프레임워크만 고르면 끝이 아니라 주변 오픈소스도 함께 선택해야 합니다. 귀하의 요구사항에 맞는 추천 조합은 아래와 같습니다.

### 권장 사용자 앱 스택

- 프레임워크: React Native + Expo.[^5_1][^5_13]
- 라우팅: Expo Router.[^5_16]
- 상태관리: Zustand 또는 Redux Toolkit, 서버 상태는 TanStack Query.[^5_16]
- 폼/검증: React Hook Form + Zod.
- UI: Tamagui 또는 NativeWind, 혹은 커스텀 디자인 시스템.
- 오디오: Expo AV 또는 React Native Track Player 계열.
- 인증: Supabase Auth 또는 Keycloak/OIDC 연동, Apple/Google/Kakao는 백엔드 OIDC 브로커와 연결.[^5_4][^5_5]
- 푸시: Expo Notifications.
- 로컬 저장: SQLite/WatermelonDB/MMKV 조합.
- 분석/오류추적: Sentry, PostHog/Firebase Analytics.


### 백엔드 오픈소스 후보

#### Supabase

Supabase는 PostgreSQL 기반 오픈소스 BaaS로, auth, database, storage, realtime을 함께 제공합니다. PostgreSQL 기반이라 데이터 모델 확장성과 SQL 생태계 활용성이 높고, 대부분의 프로젝트에서 더 강력한 선택으로 평가됩니다.[^5_5]

장점은 다음과 같습니다.[^5_4][^5_5]

- PostgreSQL 기반이라 보고서, 통계, 복잡한 질의에 유리합니다.[^5_5]
- Auth, Storage, Realtime이 함께 있습니다.[^5_5]
- 장기적으로 관리자/학습 통계/콘텐츠 운영에 적합합니다.[^5_5]

주의점은 RLS 설계가 강력하지만 잘못 설정하면 위험하다는 점입니다.[^5_4]

#### Appwrite

Appwrite는 self-hosting이 더 단순하고, 기본 보안 설정이 쉬운 편으로 평가됩니다. 작은 팀이 빠르게 셀프호스트하려면 장점이 있습니다.[^5_4][^5_5]

장점은 다음과 같습니다.[^5_4][^5_5]

- Docker 기반 self-hosting이 단순합니다.[^5_5]
- 기본 권한 모델이 비교적 안전한 편입니다.[^5_4]
- OAuth provider가 풍부합니다.[^5_4]

하지만 귀하처럼 커리큘럼, 진도율, 분석 쿼리, 관리자 보고서가 중요한 서비스는 PostgreSQL 기반 Supabase가 더 자연스럽습니다.[^5_5]

### 백엔드 추천표

| 항목 | Supabase | Appwrite | Keycloak |
| :-- | :-- | :-- | :-- |
| 역할 | BaaS 전체 [^5_5] | BaaS 전체 [^5_5] | 인증/SSO 전용 |
| DB | PostgreSQL [^5_5] | Appwrite DB/MariaDB 기반 [^5_5] | 없음 |
| Auth | 강함 [^5_4] | 강함 [^5_4] | 매우 강함, 기업형 SSO |
| Self-host 난이도 | 중간 [^5_5] | 쉬움 [^5_5] | 중간~상 |
| 분석/리포트 확장 | 매우 좋음 [^5_5] | 중간 | 별도 DB 필요 |
| 추천도 | **1위** [^5_5] | 2위 [^5_5] | 인증 브로커로 보조 추천 |

## 관리자 프로그램 후보

관리자 영역은 두 갈래로 나누는 것이 좋습니다.

1. 콘텐츠/운영 중심 관리자 웹앱.
2. 내부 툴/데이터 조회/대시보드.

이를 하나의 솔루션으로 억지 통합하면 나중에 답답해지는 경우가 많습니다. 따라서 “주 관리자 앱”과 “보조 운영 도구”를 분리해서 보는 것이 좋습니다.

### 1) Next.js 기반 커스텀 관리자 웹앱

가장 추천하는 방식은 관리자 프로그램의 핵심을 Next.js 같은 풀커스텀 웹앱으로 만드는 것입니다. 이유는 귀하의 관리자 기능이 단순 CRUD를 넘어서, 레슨 편집기, 일정관리, 학습 통계, 음원 배치 생성, 승인 워크플로우까지 포함하기 때문입니다.[^5_3]

장점:

- 기능 제약이 거의 없습니다.
- 사용자 앱과 도메인 모델을 공유하기 쉽습니다.
- 복잡한 커리큘럼 편집 UI를 직접 설계할 수 있습니다.

단점:

- 초기 개발량이 큽니다.


### 2) Directus

Directus는 기존 SQL 데이터베이스를 기반으로 REST/GraphQL API와 시각적 관리자 UI를 즉시 제공하는 오픈소스 플랫폼입니다. 데이터 중심 콘텐츠 관리, 미디어, 권한, 워크플로우가 필요한 경우 매우 유용합니다.[^5_11][^5_17][^5_18]

장점은 다음과 같습니다.[^5_17][^5_11]

- SQL 스키마를 기반으로 즉시 관리자 화면을 만듭니다.[^5_11]
- REST/GraphQL API를 자동 생성합니다.[^5_11]
- 콘텐츠팀과 개발팀이 함께 쓰기 좋습니다.[^5_19]

귀하 서비스에서 Directus는 “단어/예문/이미지/오디오/레슨 메타데이터 관리”에 특히 잘 맞습니다.[^5_18][^5_11]

### 3) Appsmith

Appsmith는 오픈소스 로우코드 내부 도구 플랫폼으로, 데이터소스 연결, 드래그앤드롭 UI, JS 커스터마이징, Git 통합을 제공합니다. 커스텀 운영 툴, CS 도구, QA 패널, 실험 대시보드 같은 내부 앱을 빠르게 만들기 좋습니다.[^5_2]

장점은 다음과 같습니다.[^5_2]

- 데이터소스 연결이 폭넓습니다.[^5_2]
- Git 기반 협업이 가능합니다.[^5_2]
- JS 커스터마이징이 가능해 개발자 친화적입니다.[^5_2]

다만 Appsmith는 “완전한 서비스용 관리자 제품”보다는 내부 운영 도구에 더 잘 맞습니다.[^5_2]

### 4) ToolJet

ToolJet은 Appsmith와 유사한 오픈소스 내부 툴 빌더이며, 간편한 시작과 직관적 UI가 장점으로 자주 비교됩니다. 빠른 프로토타입이나 운영용 미니 툴에 적합합니다.[^5_12][^5_20]

### 관리자 오픈소스 비교표

| 항목 | Next.js 커스텀 관리자 | Directus | Appsmith | ToolJet |
| :-- | :-- | :-- | :-- | :-- |
| 목적 | 핵심 운영 시스템 | 콘텐츠/CMS/BaaS형 관리 [^5_11] | 내부 툴/대시보드 [^5_2] | 간단한 내부 툴 [^5_20] |
| 자유도 | 최고 | 높음 [^5_17] | 중간~높음 [^5_2] | 중간 [^5_20] |
| 개발속도 | 느림 | 빠름 [^5_11] | 빠름 [^5_2] | 매우 빠름 [^5_20] |
| 콘텐츠 워크플로우 | 직접 구현 | 강함 [^5_18] | 보통 | 보통 |
| 복잡한 커리큘럼 편집 | 매우 강함 | 중간 | 약함 | 약함 |
| 통계/운영 패널 | 매우 강함 | 중간 | 강함 [^5_2] | 강함 [^5_20] |
| 장기 확장성 | 최고 | 높음 [^5_17] | 중간 | 중간 |
| 추천 역할 | **메인 관리자** | **콘텐츠 CMS** | **보조 운영 툴** | **빠른 보조 툴** |

## 최종 추천

### 사용자용 앱

가장 추천하는 조합은 아래입니다.

- 프레임워크: **React Native + Expo**.[^5_1][^5_13]
- 언어: TypeScript.
- 데이터 접근: TanStack Query.
- 상태관리: Zustand.
- 백엔드: **Supabase** 중심, 필요 시 Keycloak을 인증 브로커로 추가.[^5_5][^5_4]
- 미디어 저장: S3 호환 스토리지 또는 Supabase Storage.
- 푸시/배포: Expo EAS.
- 오디오/TTS 연동: Expo AV + 서버 측 TTS 파이프라인.[^5_8][^5_9]

이 조합이 좋은 이유는, 귀하가 풀스택/웹 아키텍처에 익숙하고, 사용자 앱도 결국 데이터 중심 학습앱이기 때문입니다. Flutter의 장점이 빛나는 초고난도 커스텀 모션 앱보다는, RN/Expo가 요구사항 대비 개발속도와 유지보수성이 더 좋습니다.[^5_1][^5_13]

### 관리자 프로그램

관리자 프로그램은 하나로 끝내지 말고 다음처럼 나누는 것을 추천합니다.

- 메인 관리자 웹앱: **Next.js 커스텀 관리자**.
- 콘텐츠/CMS: **Directus**.[^5_18][^5_11]
- 내부 운영 대시보드/임시 툴: **Appsmith**.[^5_2]

이 조합이 좋은 이유는 다음과 같습니다.

- 커리큘럼/레슨 편집은 커스텀 UI가 필요합니다.
- 단어/예문/이미지/오디오 자산 관리는 Directus가 매우 강합니다.[^5_11]
- 운영팀이 빠르게 조회/배치/검수 화면을 만들려면 Appsmith가 유용합니다.[^5_2]


## 권장 아키텍처 청사진

실무적으로는 아래 구성이 가장 안정적입니다.

- 사용자 앱: React Native + Expo.
- 관리자 웹: Next.js.
- 콘텐츠 관리: Directus.
- 내부 운영툴: Appsmith.
- 백엔드 데이터: PostgreSQL/Supabase.
- 인증: Supabase Auth + Google/Apple, 한국 시장 대응용 Kakao OAuth, 필요 시 Keycloak 브로커.
- 파일/오디오: S3 호환 스토리지.
- 배치 작업: Python/FastAPI worker, TTS 생성 및 미디어 처리.
- 분석: PostHog/Metabase/Superset 계열 추가 가능.

이 구조는 처음부터 모든 걸 직접 만들지 않으면서도, 나중에 특정 부분을 교체하거나 내재화하기 쉽다는 장점이 있습니다.[^5_11][^5_5][^5_2]

원하시면 다음 답변에서 바로 이어서 **모바일 앱 기술선정 표(P0/P1/P2), 관리자 프로그램 아키텍처도, 추천 오픈소스 레포 목록, 그리고 MVP 기준 개발 로드맵**까지 더 구체적으로 정리하겠습니다.[^5_11][^5_5][^5_1]
<span style="display:none">[^5_21][^5_22][^5_23][^5_24][^5_25][^5_26][^5_27][^5_28][^5_29][^5_30][^5_31][^5_32][^5_33][^5_34][^5_35][^5_36]</span>

<div align="center">⁂</div>

[^5_1]: https://dev.to/krunal_groovy/react-native-vs-flutter-vs-expo-vs-lynx-2026-which-to-choose-for-your-app-30h6

[^5_2]: https://www.pass-the-toeic-test.com/toeic-word-list.php

[^5_3]: https://play.google.com/store/apps/details?id=com.bean.edu.toeic.words.basic

[^5_4]: https://vibe-eval.com/comparisons/supabase-vs-appwrite-security/

[^5_5]: https://www.13labs.au/compare/supabase-vs-appwrite

[^5_6]: https://www.remnote.com/feature/spaced-repetition

[^5_7]: https://www.lingomelo.com/blog-page/toeic-word-list/

[^5_8]: https://www.vocabulary.com/lists/196080

[^5_9]: https://es.scribd.com/document/49718574/TOEIC-VOCABULARY

[^5_10]: https://www.appsmith.com

[^5_11]: https://directus.io/?adobe_mc=MCMID%3D12000614905405683995335849378418609464%7CMCORGID%3DA8833BC75245AF9E0A490D4D%2540AdobeOrg%7CTS%3D1728345600

[^5_12]: https://blog.tooljet.com/appsmith-vs-budibase-vs-tooljet/

[^5_13]: https://www.nqelit.com/resources/mobile-app-development-guide

[^5_14]: https://www.youtube.com/watch?v=KJDFjf6Q3B0

[^5_15]: https://capgo.app/blog/transform-pwa-to-native-app-with-capacitor/

[^5_16]: https://www.linkedin.com/posts/roman-travnikov_its-january-2026-shipping-a-mobile-app-activity-7421864282524573698--VCv

[^5_17]: https://jamstack.org/headless-cms/directus/

[^5_18]: https://directus.io/solutions/headless-cms

[^5_19]: https://directus.io

[^5_20]: https://www.13labs.au/compare/appsmith-vs-tooljet

[^5_21]: https://www.youtube.com/watch?v=-Uk9qH39S94

[^5_22]: https://diproach.com/en/blog/diproach-ionic-capacitor/

[^5_23]: https://www.mobiloud.com/blog/flutter-vs-expo

[^5_24]: https://dev.to/famitha_ma_b9c13ab1d324e/react-native-vs-flutter-in-2026-which-should-you-choose-1eil

[^5_25]: https://capacitorjs.com

[^5_26]: https://www.reddit.com/r/appwrite/comments/1c6xjm5/appwrite_vs_supabase_vs_pocektbase/

[^5_27]: https://www.applighter.com/blog/react-native-performance-benchmarks-expo-vs-bare-vs-flutter-vs-native-2026

[^5_28]: https://ionicframework.com

[^5_29]: https://www.youtube.com/watch?v=wR8gI-q__tA

[^5_30]: https://www.appsmith.com/blog/open-source-low-code-platforms

[^5_31]: https://sourceforge.net/software/compare/Budibase-vs-Directus-vs-Strapi/

[^5_32]: https://www.youtube.com/watch?v=HrxpRa4T3U0

[^5_33]: https://www.superblocks.com/blog/tooljet-vs-appsmith

[^5_34]: https://blog.elest.io/low-code-showdown-tooljet-vs-appsmith-vs-budibase-which-one-fits-your-team/

[^5_35]: https://discuss.pytorch.kr/t/tooljet-ai/8915

[^5_36]: https://www.youtube.com/watch?v=U88fgws1FbM


---

# 아이폰, 안드로이드폰을 위한 플로터로 개발할 경우 오픈소스를 조사하여 기존의 React native 등과 함께 비교, 추천해 주세요.

플러터로 아이폰·안드로이드폰 앱을 개발하는 선택은 **충분히 강력하고 실제로 추천 가능한 옵션**입니다. 다만 귀하의 서비스처럼 로그인, 단어암기, 오디오 재생, 진도율, 일정관리, 관리자 웹까지 함께 가야 하는 경우에는 “Flutter가 최고냐”보다 **팀 역량, 웹/관리자와의 코드 공유 전략, 오픈소스 생태계 안정성**까지 같이 봐야 하며, 그 기준에서는 Flutter와 React Native + Expo가 가장 유력한 양강 구도입니다.[^6_1][^6_2][^6_3][^6_4]

Flutter는 단일 코드베이스로 모바일, 웹, 데스크톱까지 확장할 수 있고, 자체 위젯 시스템으로 픽셀 단위 UI 제어가 강하다는 점이 큰 장점입니다. 반면 React Native + Expo는 TypeScript/React 생태계, 빠른 팀 온보딩, 웹/관리자와의 사고방식 공유 측면에서 유리합니다.[^6_5][^6_6][^6_2][^6_7][^6_4]

## 결론

귀하의 프로젝트에 대해 먼저 직접 추천을 드리면 다음과 같습니다.

- **모바일 앱만 최고 품질로 만들고, UI 일관성과 제스처·애니메이션 완성도를 중시하면 Flutter 추천**입니다.[^6_6][^6_5]
- **모바일 앱과 관리자 웹, 향후 웹앱까지 TypeScript 중심으로 통일하고 싶으면 React Native + Expo 추천**입니다.[^6_2][^6_7]
- **기존 반응형 웹을 최대한 재사용하려는 전략이면 Capacitor 계열이 후보지만, 학습앱 품질 측면에서는 Flutter/RN보다 우선순위가 낮습니다.**[^6_8]

즉, 귀하의 상황에서는 **1순위 React Native + Expo, 2순위 Flutter**로 보되, “앱 UX를 더 중요시하고 Dart 도입이 가능하다”면 Flutter를 1순위로 올릴 수 있습니다.[^6_7][^6_5][^6_2]

## Flutter 장단점

Flutter 공식 문서는 Flutter를 단일 코드베이스로 모바일·웹·데스크톱·임베디드까지 빌드할 수 있는 오픈소스 프레임워크로 설명하고 있으며, ARM/Intel 머신코드 및 JavaScript로 컴파일되고 Hot Reload, 맞춤형 UI, 플랫폼 적응형 앱을 강조합니다. 또한 2026년 5월 기준 Flutter 문서는 3.44 계열 기준으로 계속 업데이트되고 있어, 현재도 활발한 유지보수 상태임을 보여줍니다.[^6_3][^6_5][^6_6]

Flutter의 강점은 아래와 같습니다.[^6_5][^6_6]

- UI 제어력이 강합니다.
- 플랫폼 간 시각 일관성이 높습니다.
- 하나의 팀으로 iOS와 Android를 동시에 낼 수 있습니다.
- 애니메이션, 카드 전환, 학습용 인터랙션 구현이 수월합니다.
- Firebase 및 Google 생태계 연동이 좋습니다.[^6_9][^6_5]

특히 귀하가 만들려는 단어암기 앱은 **카드 플립, 진도 표시, 오디오 재생, 스와이프 학습, 패드 대응 레이아웃**이 중요하므로 Flutter의 위젯 기반 UI 모델과 adaptive design은 꽤 잘 맞습니다.[^6_6][^6_5]

하지만 약점도 분명합니다.

- Dart를 새롭게 받아들여야 합니다.[^6_5]
- 관리자 웹과 동일한 프런트 기술 스택으로 묶기 어렵습니다.[^6_4][^6_5]
- 일반적인 CRUD/콘텐츠 관리 중심 앱에서는 RN 대비 압도적 이점이 항상 있는 것은 아닙니다.[^6_4]


## React Native와 비교

React Native 공식 문서는 현재 아키텍처 개요와 New Architecture 전환을 안내하고 있으며, Expo는 React/JavaScript로 Android, iOS, 웹용 유니버설 네이티브 앱을 만드는 오픈소스 플랫폼이라고 설명합니다. 즉 RN + Expo 조합은 여전히 실전성이 매우 높고, 특히 JavaScript/TypeScript 중심 조직에서 채택하기 쉽습니다.[^6_2][^6_7][^6_4]

아래 표로 핵심 차이를 정리할 수 있습니다.


| 항목 | Flutter | React Native + Expo |
| :-- | :-- | :-- |
| 언어 | Dart [^6_5] | TypeScript/JavaScript [^6_2][^6_7] |
| 렌더링 방식 | 자체 위젯/렌더링 엔진 중심 [^6_5] | 네이티브 UI + React 추상화 [^6_4] |
| UI 제어력 | 매우 높음 [^6_5] | 높음 [^6_2] |
| 팀 온보딩 | Dart 학습 필요 [^6_5] | 웹 React 경험 있으면 매우 쉬움 [^6_7] |
| 모바일 UX | 매우 우수 [^6_6] | 우수 [^6_2] |
| 웹/관리자와의 기술 통일 | 낮음~중간 | 높음 [^6_7] |
| 패키지 생태계 | 풍부, pub.dev 중심 [^6_10][^6_11] | 풍부, npm 중심 [^6_2] |
| 추천 상황 | 앱 UX 중심 서비스 [^6_6] | 모바일+웹 운영 통합 서비스 [^6_7] |

핵심은 이것입니다. **Flutter는 앱 자체 완성도에 강하고, RN은 전체 제품군 스택 일관성에 강합니다.**[^6_7][^6_5]

## Flutter 오픈소스 생태계

Flutter를 선택할 경우, 단순히 프레임워크만 보는 것이 아니라 실무에 필요한 오픈소스가 충분한지 확인해야 합니다. 이 점에서는 Flutter 생태계가 꽤 성숙해져 있습니다.[^6_10][^6_11]

대표적으로 참고할 수 있는 오픈소스 리소스는 아래와 같습니다.

- `solido/awesome-flutter`: Flutter 라이브러리와 도구 큐레이션 저장소입니다.[^6_10]
- `fluttercommunity/plus_plugins`: 기존 공식 플러그인에서 파생된, 추가 기능과 더 넓은 플랫폼 지원을 제공하는 커뮤니티 유지 플러그인 모음입니다.[^6_12]
- `firebase/flutterfire`: Firebase용 공식 Flutter 플러그인 집합입니다.[^6_9]

이 세 축이 중요한 이유는 다음과 같습니다.

- 앱 기능 탐색은 `awesome-flutter`류가 도와줍니다.[^6_10]
- 디바이스 기능 접근은 `plus_plugins`가 실무적으로 자주 쓰입니다.[^6_12]
- 인증, 메시징, 스토리지, 분석은 `FlutterFire`가 안정적 경로를 제공합니다.[^6_9]


## Flutter용 추천 오픈소스 스택

귀하의 단어암기 앱 요구사항에 맞춰 Flutter 스택을 구체적으로 추천하면 아래와 같습니다.

### 앱 기본 구조

- 프레임워크: Flutter.[^6_5]
- 언어: Dart.[^6_5]
- 상태관리: Riverpod 또는 Bloc, 개인적으로는 중대형 앱에 Riverpod 우선 추천.
- 라우팅: `go_router`.
- 네트워크: `dio`.
- 데이터 모델: `freezed`, `json_serializable`.
- 로컬 DB: `isar` 또는 `drift`.
- 오디오: `just_audio`.
- 녹음/재생/파일 접근: `audio_session`, `path_provider`, `file_picker` 계열.
- 인증: Firebase Auth 또는 Supabase/Auth 서버 연동.
- 푸시: `firebase_messaging`.[^6_9]
- 분석/크래시: `firebase_analytics`, `firebase_crashlytics`.[^6_9]
- 공유/링크/디바이스 정보: `plus_plugins` 계열 활용 가능.[^6_12]


### 귀하 서비스에 맞는 세부 기능별 오픈소스 추천

| 기능 | Flutter 오픈소스 방향 | 비고 |
| :-- | :-- | :-- |
| 상태관리 | Riverpod / Bloc | 중대형 유지보수는 Riverpod 추천 |
| 라우팅 | `go_router` | 인증 가드, 딥링크 처리 편리 |
| 로컬 DB | Isar / Drift | 오프라인 진도 저장에 중요 |
| 오디오 재생 | `just_audio` | 예문 듣기, 반복 재생에 적합 |
| 파형/미디어 | `audio_waveforms` 계열 후보 | 듣기 UX 강화 가능 |
| 소셜 로그인 | Firebase Auth 또는 OIDC 연동 | Google/Apple 대응에 용이 [^6_9] |
| 카카오 로그인 | 커뮤니티 패키지 또는 직접 SDK 래핑 | 유지보수성 검토 필요 |
| 푸시 알림 | `firebase_messaging` | 복습 알림에 적합 [^6_9] |
| 크래시 추적 | `firebase_crashlytics` | 운영 필수 [^6_9] |
| 분석 | `firebase_analytics` 또는 PostHog SDK | 학습 이벤트 추적 |

## Flutter가 특히 잘 맞는 경우

아래 조건이면 Flutter 추천 강도가 올라갑니다.

- 학습 카드 UX와 전환 애니메이션 품질이 아주 중요할 때.[^6_6]
- 아이폰/안드로이드에서 같은 시각 품질을 유지하고 싶을 때.[^6_5]
- 앱 쪽 팀이 웹보다 제품 UX를 더 우선시할 때.[^6_6]
- 웹 관리자는 별도 Next.js/React로 가고, 모바일은 독립 최적화할 수 있을 때.[^6_4]

귀하가 제시한 서비스는 실제로 이 조건에 꽤 들어맞습니다. 특히 “이미지 같은 배치”, “레슨 진행”, “듣기”, “개인 노트”, “패드 대응”은 Flutter가 보기 좋게 만들기 쉬운 편입니다.[^6_13][^6_6]

## Flutter가 덜 맞는 경우

반대로 아래 조건이면 React Native 쪽이 더 낫습니다.

- 팀이 이미 React/TypeScript 중심이고 Dart 도입 비용을 줄이고 싶을 때.[^6_7]
- 웹앱, 관리자, 모바일 앱 사이의 도메인/검증/상태 모델을 최대한 공유하고 싶을 때.[^6_7]
- 운영 인력 확보와 채용 유연성을 크게 중시할 때.[^6_2][^6_7]

귀하가 장기적으로 관리자 웹, CMS, 내부 운영도구를 같이 운영할 예정이라면, 이 점은 Flutter의 실질적 약점이 될 수 있습니다.[^6_4]

## 최종 추천

최종적으로는 아래처럼 추천드립니다.

### 추천 1: React Native + Expo

가장 균형 잡힌 선택입니다.[^6_2][^6_7]

- 이유: 웹/관리자와의 스택 일관성, TypeScript 활용, 빠른 팀 생산성.
- 적합한 경우: 제품 전체를 하나의 풀스택 체계로 운영하려는 경우.


### 추천 2: Flutter

앱 UX 중심으로 보면 매우 강한 선택입니다.[^6_6][^6_5]

- 이유: UI 완성도, adaptive layout, 모바일 경험 품질.
- 적합한 경우: 모바일 앱 자체 품질을 최우선으로 둘 때.


### 추천 3: Capacitor

웹 재사용을 최우선으로 할 때만 고려합니다.[^6_8]

- 이유: 기존 웹 자산 재사용.
- 한계: 학습앱의 인터랙션 품질은 Flutter/RN보다 불리할 수 있습니다.[^6_8]

즉, **귀하의 현재 프로젝트 전체를 기준으로는 React Native + Expo를 소폭 우선 추천**하고, **모바일 학습 UX 자체를 가장 중요하게 보면 Flutter도 매우 타당한 선택**입니다.[^6_2][^6_7][^6_5]

## 실무 의사결정안

바로 결정해야 한다면 저는 아래 기준으로 자르겠습니다.

- “웹/관리자/모바일을 TypeScript 중심으로 통합” → React Native + Expo.[^6_7][^6_2]
- “앱 화면 품질과 레슨 UX를 최우선” → Flutter.[^6_6][^6_5]

귀하처럼 아키텍처와 리더십 경험이 많은 팀이라면, 오히려 **모바일은 Flutter, 관리자 웹은 Next.js**로 이원화해도 충분히 감당 가능합니다. 다만 1인 또는 소수정예로 빠르게 MVP를 내려면 React Native + Expo 쪽이 리스크가 더 낮습니다.[^6_2][^6_7]

원하시면 다음 단계로 바로 이어서 **Flutter 기준 추천 오픈소스 패키지 목록 30~50개**, **Flutter vs React Native 아키텍처 비교표**, 또는 **귀하 서비스 요구사항에 맞춘 Flutter MVP 폴더 구조**까지 정리해 드리겠습니다.[^6_10][^6_12][^6_9]
<span style="display:none">[^6_14][^6_15][^6_16][^6_17][^6_18][^6_19][^6_20][^6_21][^6_22][^6_23][^6_24][^6_25][^6_26][^6_27][^6_28][^6_29][^6_30][^6_31][^6_32][^6_33][^6_34]</span>

<div align="center">⁂</div>

[^6_1]: https://docs.flutter.dev

[^6_2]: https://github.com/expo/expo

[^6_3]: https://www.iibc-global.org/english/toeic/test/lr/about/format.html

[^6_4]: http://www.jacet.org/JACET_Journal_No61/JACET_Journal_61_04.pdf

[^6_5]: https://flutter.dev

[^6_6]: https://flutter.dev/development/mobile

[^6_7]: https://docs.expo.dev

[^6_8]: https://play.google.com/store/apps/details?id=com.bean.edu.toeic.words.basic

[^6_9]: https://github.com/firebase/flutterfire

[^6_10]: https://github.com/solido/awesome-flutter

[^6_11]: https://fluttergems.dev

[^6_12]: https://github.com/fluttercommunity/plus_plugins

[^6_13]: image.jpeg

[^6_14]: https://flutternest.com/blog/flutter-mobile-app-development-guide

[^6_15]: https://codelabs.developers.google.com/codelabs/flutter-codelab-first

[^6_16]: https://github.com/reactwg/react-native-new-architecture

[^6_17]: https://www.reddit.com/r/FlutterDev/comments/14n19ss/is_flutter_really_that_good/

[^6_18]: https://reactnative.dev/architecture/overview

[^6_19]: https://www.scribd.com/document/406058588/Flutter-Documentation-Flutter

[^6_20]: https://reactnative.dev/architecture/landing-page

[^6_21]: https://www.youtube.com/watch?v=RdJhqaOIWn0

[^6_22]: https://www.freecodecamp.org/news/how-to-develop-a-flutter-app-from-scratch/

[^6_23]: https://docs.expo.dev/guides/new-architecture/

[^6_24]: https://www.reddit.com/r/FlutterDev/comments/1mzokl6/curated_repo_of_awesome_flutter_packages/

[^6_25]: https://github.com/Hamed233/Awesome-Flutter-Packages

[^6_26]: https://github.com/jpnurmi/awesome-flutter-linux

[^6_27]: https://firebase.flutter.dev/docs/overview

[^6_28]: https://www.reddit.com/r/FlutterDev/comments/1haact3/a_curated_list_of_750_awesome_open_source_flutter/

[^6_29]: https://github.com/werainkhatri/plus_plugins

[^6_30]: https://flutterawesome.com

[^6_31]: https://github.com/fluttercommunity/plus_plugins/issues/3492

[^6_32]: https://firebase.flutter.dev

[^6_33]: https://www.solutelabs.com/blog/top-flutter-repositories

[^6_34]: https://github.com/fluttercommunity/plus_plugins/issues/3147

