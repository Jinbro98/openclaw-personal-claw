# personal-claw

> OpenClaw 플러그인 — 당신의 AI가 당신을 알아갑니다.

매번 "짧게 해줘", "자세히 설명해줘"라고 말하고 싶지 않으셨나요?

**personal-claw**는 대화 패턴을 관찰하고 12개 차원에 걸쳐 응답 스타일을 자동 조정합니다 — 길이, 말투, 형식, 깊이 등. Thompson Sampling 밴딧으로 기존 선호 활용과 새로운 탐색 사이의 최적 균형을 찾아냅니다.

**[English](./README.md)**

---

## 작동 방식

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Phase 1    │────▶│  Phase 2    │────▶│  Phase 3    │
│  패턴 분석   │     │  A/B 수집    │     │  밴딧 최적화  │
└─────────────┘     └─────────────┘     └─────────────┘
   ~20메시지           ~10선택지           지속적
   수동 관찰           자연스러운 질문      자동 적응
```

**Phase 1 — 패턴 분석** (처음 ~20메시지)
언어, 문장 길이, 말투, 형식을 조용히 관찰합니다. 사용자 개입 불필요.

**Phase 2 — A/B 수집** (이후 ~10선택지)
가끔 자연스럽게 선택지를 제안합니다: "간결하게 할까요, 자세하게 할까요?" 선택 결과가 학습에 반영됩니다.

**Phase 3 — 밴딧 최적화** (지속)
Thompson Sampling 알고리즘이 차원별 최적 응답 스타일을 자동 선택합니다. 사용자 개입 불필요.

명시적 지시(예: "짧게 해줘", "한국어로 설명해")는 어느 단계에서든 즉시 반영됩니다.

---

## 개인화 차원

| 차원 | 조정 대상 | 예시 값 |
|------|----------|---------|
| `response_length` | 응답 길이 | concise, balanced, detailed |
| `tone` | 격식체 정도 | casual, semi-formal, formal |
| `output_format` | 출력 형식 | text, markdown, code |
| `topic_depth` | 설명 깊이 | surface, practical, deep |
| `language` | 응답 언어 | ko, en, auto |
| `code_examples` | 코드 예시 | none, inline, full |
| `explanation_style` | 설명 스타일 | analogy, direct, step-by-step |
| `emoji_usage` | 이모지 빈도 | none, minimal, moderate |
| `meta_explanation` | 접근법 설명 | off, brief, detailed |
| `reference_style` | 인용 스타일 | none, inline, footnotes |
| `question_handling` | 질문 처리 | assume, ask, both |
| `error_detail` | 에러 상세도 | brief, moderate, full-stack |

---

## 주제별 프로필

personal-claw는 대화 주제를 감지하고 별도의 선호 프로필을 유지합니다:

- **코딩** — 코드, 디버그, API, 프로그래밍
- **분석** — 데이터, 통계, 비교
- **창작** — 글쓰기, 디자인, 창의적 작업
- **학습** — 공부, 설명, 튜토리얼
- **기획** — 전략, 아키텍처, 설계
- **일반** — 나머지 전체

예시: 코딩할 때는 코드를 자세히 보여주고, 일반 질문에는 간결하게 답합니다. 플러그인이 자동으로 처리합니다.

---

## 설치

### 사전 요구사항

- [OpenClaw](https://docs.openclaw.ai) >= 2026.3.0
- Node.js >= 22.0.0

### 원라인 설치

```bash
curl -fsSL https://raw.githubusercontent.com/Jinbro98/openclaw-personal-claw/main/install.sh | bash
```

### 수동 설치

```bash
git clone https://github.com/Jinbro98/openclaw-personal-claw.git
cd openclaw-personal-claw
npm install
npm run build
openclaw plugins install .
openclaw gateway restart
```

### 설치 확인

```bash
openclaw plugins list | grep personal-claw
openclaw skills list | grep personal-claw
```

예상 출력: `loaded` (플러그인) 및 `ready` (스킬).

> **참고:** OpenClaw는 `plugins install <github-user>/<repo>` 형식을 지원하지 않습니다. 반드시 clone 후 로컬 경로에서 설치해야 합니다.

---

## 사용법

설치 후 모든 대화에서 자동 활성화됩니다. 별도 설정 불필요.

### 명령어

| 명령어 | 설명 |
|--------|------|
| `personal-claw-status` | 현재 학습 상태와 프로필 확인 |
| `personal-claw-reset` | 학습된 선호도 초기화 (처음부터 다시) |
| `personal-claw-export` | 프로필을 JSON으로 백업 |

### 상태 출력 예시

```
Phase: ab (선호 수집 중)

학습 현황:
  총 대화: 42회
  긍정 신호: 15개
  부정 신호: 3개

차원별 학습:
  응답 길이  [████████░░] 간결하게 (확신도 78%)
  말투       [██████░░░░] 편하게   (확신도 62%)
  출력 형식  [█████████░] 마크다운 (확신도 89%)
  ...
```

확신도가 높을수록 더 정확하게 맞춥니다.

---

## 아키텍처

```
openclaw-personal-claw/
├── src/
│   ├── index.ts              # 플러그인 진입점 (훅 + 도구)
│   ├── types.ts              # 핵심 타입 정의
│   ├── core/
│   │   ├── bandit.ts         # Thompson Sampling 엔진
│   │   ├── profile.ts        # 프로필 로드/저장/업데이트
│   │   ├── phase.ts          # Phase 전환 로직
│   │   ├── signals.ts        # 신호 감지 (정규식 기반)
│   │   ├── session-state.ts  # 세션별 메시지 추적
│   │   ├── ab-suggester.ts   # A/B 제안 생성기
│   │   └── topic-detector.ts # 주제 분류
│   ├── analyzer/
│   │   ├── conversation.ts   # 대화 길이 분석
│   │   ├── language.ts       # 언어 감지 (ko/en)
│   │   └── sentiment.ts      # 감정 분석
│   ├── injector/
│   │   ├── prompt-builder.ts # 시스템 프롬프트 생성
│   │   └── agents-md.ts      # AGENTS.md 섹션 업데이트
│   ├── tools/
│   │   ├── status-tool.ts    # personal-claw-status
│   │   ├── reset-tool.ts     # personal-claw-reset
│   │   └── export-tool.ts    # personal-claw-export
│   └── utils/
│       ├── constants.ts      # 차원 정의, 기본값
│       └── file-io.ts        # JSON 파일 I/O (손상 처리 포함)
├── skills/personal-claw/
│   └── SKILL.md              # OpenClaw 스킬 정의
├── tests/                    # Vitest 유닛 테스트 (50개)
└── docs/solutions/           # 버그 수정 및 모범 사례
```

### 플러그인 훅

personal-claw는 3가지 OpenClaw 플러그인 훅을 구현합니다:

| 훅 | 실행 시점 | 동작 |
|----|----------|------|
| `onMessage` | 매 사용자 메시지 | 신호 감지, 프로필 업데이트, 저장 |
| `getSystemPromptAddition` | 매 턴 | 학습된 선호도를 시스템 프롬프트에 주입 |
| `onSessionEnd` | 세션 종료 | 통계 업데이트, AGENTS.md 갱신 |

`getSystemPromptAddition` 훅이 핵심 제어 메커니즘입니다 — 학습된 선호 지침을 시스템 프롬프트에 주입하여 LLM이 자연스럽게 따르도록 합니다.

---

## 개발

```bash
# 의존성 설치
npm install

# 테스트 실행
npm test

# 감시 모드
npm run test:watch

# 타입 체크
npm run typecheck

# 빌드
npm run build

# 린트
npm run lint
```

### 프로젝트 규칙

- 모든 프로필 업데이트 함수는 불변 패턴 사용 (새 객체 반환)
- 신호 감지는 정규식 기반 (학습에 LLM 호출 없음)
- 프로필 데이터는 `~/.openclaw/data/personal-claw/`에 JSON으로 저장
- 세션 종료 시 AGENTS.md 업데이트 (장기 맥락 유지)

---

## 프라이버시

- **100% 로컬** — 외부로 데이터 전송 없음
- 대화 원문 저장 안 함 — 추출된 신호와 프로필 값만 저장
- 학습/개인화에 외부 API 호출 없음
- `personal-claw-reset`으로 언제든지 초기화 가능
- `personal-claw-export`로 저장된 데이터 직접 확인 가능

---

## 자주 묻는 질문

**얼마나 빨리 적응하나요?**
약 20메시지 후 Phase 2 진입, ~10개 선택지 후 신뢰할만한 프로필 형성. 보통 1~3일 정상 사용이면 수렴합니다.

**잘못 학습하면 어떻게 하나요?**
"짧게 해줘", "자세히 설명해줘"라고 직접 말하면 즉시 반영됩니다. 또는 `personal-claw-reset`으로 초기화할 수 있습니다.

**여러 채널에서 사용하면?**
현재는 모든 채널에서 공유 프로필. 채널별 프로필은 향후 지원 예정.

**성능 영향은?**
신호 감지는 정규식 기반으로 50ms 이내 완료. 메모리 사용량은 프로필당 수 KB. 무시할 수준의 오버헤드.

**필요한 OpenClaw 버전은?**
>= 2026.3.0 (플러그인 훅 시스템 필요)

---

## 라이선스

MIT
