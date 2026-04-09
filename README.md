# personal-claw

> OpenClaw plugin — your AI learns how you like to talk.

No configuration. No training. Just chat, and it adapts.

**personal-claw** observes your conversation patterns and automatically adjusts response style across 12 dimensions — length, tone, format, depth, and more. It uses a Thompson Sampling bandit to find the optimal balance between exploiting known preferences and exploring new ones.

**[한국어](./README.ko.md)**

---

## How It Works

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Phase 1    │────▶│  Phase 2    │────▶│  Phase 3    │
│  Pattern    │     │  A/B Test   │     │  Bandit     │
│  Analysis   │     │  Collection │     │  Optimization│
└─────────────┘     └─────────────┘     └─────────────┘
   ~20 msgs           ~10 choices         Continuous
   Passive observe     Natural prompts     Auto-adaptive
```

**Phase 1 — Pattern Analysis** (first ~20 messages)
Passively observes your language, sentence length, tone, and format preferences. No interaction required.

**Phase 2 — A/B Collection** (next ~10 choices)
Occasionally offers natural-sounding choices: "Want me to keep it concise, or go deeper?" Your selections train the model.

**Phase 3 — Bandit Optimization** (ongoing)
Thompson Sampling algorithm automatically selects the best response style per dimension. No user intervention needed.

Explicit directives (e.g. "be concise", "explain in Korean") are applied immediately at any phase.

---

## Personalization Dimensions

| Dimension | What it controls | Example values |
|-----------|-----------------|----------------|
| `response_length` | How verbose | concise, balanced, detailed |
| `tone` | Formality level | casual, semi-formal, formal |
| `output_format` | Primary format | text, markdown, code |
| `topic_depth` | Explanation depth | surface, practical, deep |
| `language` | Response language | ko, en, auto |
| `code_examples` | Code preference | none, inline, full |
| `explanation_style` | How to explain | analogy, direct, step-by-step |
| `emoji_usage` | Emoji frequency | none, minimal, moderate |
| `meta_explanation` | Explain the approach | off, brief, detailed |
| `reference_style` | Citation style | none, inline, footnotes |
| `question_handling` | Clarification style | assume, ask, both |
| `error_detail` | Error verbosity | brief, moderate, full-stack |

---

## Topic-Aware Profiles

personal-claw detects conversation topics and maintains separate preference profiles:

- **coding** — code, debug, API, programming
- **analysis** — data, statistics, comparison
- **writing** — essays, design, creative
- **learning** — study, explanation, tutorials
- **planning** — strategy, architecture, design
- **general** — everything else

Example: you might prefer detailed code explanations but concise general answers. The plugin handles this automatically.

---

## Installation

### Prerequisites

- [OpenClaw](https://docs.openclaw.ai) >= 2026.3.0
- Node.js >= 22.0.0

### Quick Install (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/Jinbro98/personal-claw/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/Jinbro98/personal-claw.git
cd openclaw-personal-claw
npm install
npm run build
openclaw plugins install .
openclaw gateway restart
```

### Verify installation

```bash
openclaw plugins list | grep personal-claw
openclaw skills list | grep personal-claw
```

Expected output: `loaded` (plugin) and `ready` (skill).

> **Note:** OpenClaw does not support `plugins install <github-user>/<repo>` directly. You must clone and install from a local path.

---

## Usage

Once installed, personal-claw activates automatically on all conversations. No configuration needed.

### Commands

| Command | Description |
|---------|-------------|
| `personal-claw-status` | Show current learning state and profile |
| `personal-claw-reset` | Reset all learned preferences (starts over) |
| `personal-claw-export` | Export profile as JSON for backup |

### Status output example

```
Phase: ab (collecting preferences)

Learning progress:
  Total messages: 42
  Positive signals: 15
  Negative signals: 3

Dimensions:
  response_length  [████████░░] concise  (confidence 78%)
  tone             [██████░░░░] casual   (confidence 62%)
  output_format    [█████████░] markdown (confidence 89%)
  ...
```

Higher confidence = more accurate personalization.

---

## Architecture

```
openclaw-personal-claw/
├── src/
│   ├── index.ts              # Plugin entry point (hooks + tools)
│   ├── types.ts              # Core type definitions
│   ├── core/
│   │   ├── bandit.ts         # Thompson Sampling engine
│   │   ├── profile.ts        # Profile load/save/update
│   │   ├── phase.ts          # Phase transition logic
│   │   ├── signals.ts        # Signal detection (regex-based)
│   │   ├── session-state.ts  # Per-session message tracking
│   │   ├── ab-suggester.ts   # A/B suggestion generator
│   │   └── topic-detector.ts # Topic classification
│   ├── analyzer/
│   │   ├── conversation.ts   # Conversation length analysis
│   │   ├── language.ts       # Language detection (ko/en)
│   │   └── sentiment.ts      # Sentiment analysis
│   ├── injector/
│   │   ├── prompt-builder.ts # System prompt generation
│   │   └── agents-md.ts      # AGENTS.md section updater
│   ├── tools/
│   │   ├── status-tool.ts    # personal-claw-status
│   │   ├── reset-tool.ts     # personal-claw-reset
│   │   └── export-tool.ts    # personal-claw-export
│   └── utils/
│       ├── constants.ts      # Dimension definitions, defaults
│       └── file-io.ts        # JSON file I/O with corruption handling
├── skills/personal-claw/
│   └── SKILL.md              # OpenClaw skill definition
├── tests/                    # Vitest unit tests (50 tests)
└── docs/solutions/           # Bug fixes and best practices
```

### Plugin Hooks

personal-claw implements three OpenClaw plugin hooks:

| Hook | When | What |
|------|------|------|
| `onMessage` | Every user message | Detects signals, updates profile, saves |
| `getSystemPromptAddition` | Every turn | Injects learned preferences into system prompt |
| `onSessionEnd` | Session close | Updates stats, refreshes AGENTS.md |

The `getSystemPromptAddition` hook is the primary control mechanism — it injects personalization instructions into the system prompt so the LLM naturally follows learned preferences.

---

## Development

```bash
# Install dependencies
npm install

# Run tests
npm test

# Watch mode
npm run test:watch

# Type check
npm run typecheck

# Build
npm run build

# Lint
npm run lint
```

### Project conventions

- All profile update functions use immutable patterns (return new objects)
- Signals are detected via regex patterns (no LLM calls for detection)
- Profile data is stored as JSON in `~/.openclaw/data/personal-claw/`
- AGENTS.md is updated on session end for long-term context

---

## Multi-Agent Support

Each agent learns independently. Profile data is stored under each agent's workspace:

```
~/.openclaw/workspace/.personal-claw/         ← main agent
~/.openclaw/workspace-kiwi/.personal-claw/    ← kiwi agent
~/.openclaw/workspace-strawberry/.personal-claw/  ← strawberry agent
```

No shared state between agents. Each develops its own user profile based on its conversations.

## Privacy

- **100% local** — no data leaves your machine
- Conversation content is never stored — only extracted signals and profile values
- No external API calls for learning or personalization
- Reset anytime with `personal-claw-reset`
- Export anytime with `personal-claw-export` to inspect stored data
- Per-agent data isolation — each agent's profile is independent

---

## FAQ

**How long until it adapts?**
~20 messages to enter Phase 2, ~10 more choices to build a reliable profile. Typically 1-3 days of normal use.

**What if it learns wrong?**
Say "be concise" or "explain more" — explicit directives override immediately. Or use `personal-claw-reset` to start fresh.

**Does it work across channels?**
Currently a shared profile across all channels. Per-channel profiles planned.

**Performance impact?**
Signal detection is regex-based, completes in <50ms. Memory usage is a few KB per profile. Negligible overhead.

**What OpenClaw version is required?**
>= 2026.3.0 (plugin hook system required)

---

## License

MIT
