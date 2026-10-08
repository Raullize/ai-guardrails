# AI Guardrails

A portable, stack-agnostic `.agents` template that configures an AI-assisted
development environment in any project. It ships generic rules, skills and
prompts that adapt to the project's niche and stack — you fill in the
placeholders.

## What you get

- `.agents/AGENTS.md` — entry point for LLM assistants (Trae, OpenCode, Cursor,
  Claude Code, Copilot, AntiGravity).
- `.agents/rules/` — non-negotiable constraints, stack-independent (test-first,
  evidence quality, no silent refactors, no hallucination, secrets, semantic
  commits).
- `.agents/skills/` — generic roles (council, grill-me, docs, security audit,
  performance audit).
- `.agents/prompts/` — reusable procedure prompts, including
  `initial-setup/PROMPT.md` with `[brackets]` placeholders to adapt the
  project's niche and stack.
- `optional/packs/` — stack-specific skills (Docker, React, frontend
  humanization, SEO, UI-to-code, legacy modernization) installed only when
  relevant.

## Repository structure

```
ai-guardrails/
├── .agents/                  ← the template source of truth (what gets copied)
│   ├── AGENTS.md             ← entry point
│   ├── prompts/
│   ├── rules/
│   ├── skills/
│   └── template/             ← templates for new SKILL/RULE/PROMPT
├── optional/
│   ├── packs/                ← stack-specific skills (optional)
│   └── prompts/              ← tooling + ralph-loop (optional)
├── scripts/
│   └── init.sh               ← interactive installer
└── README.md
```

## How to use

From the root of your target project, run:

```bash
~/Projects/ai-guardrails/scripts/init.sh
```

The script is interactive, driven by the arrow keys:

1. **Optional prompts** — choose what the base `.agents` should include, beyond
   the always-installed rules, skills and initial-setup:
   - *tooling* — the repository's own scripts as the single source of truth
     for commands, tests and checks (never invent a command).
   - *ralph-loop* — the Perceive → Orient → Decide → Act → Record execution
     cycle per story.
2. **Optional packs** — navigate with ↑/↓, toggle with **Space**, confirm with
   **Enter**.
3. **Versioning** — ↑/↓ and Enter: `.agents` **versioned in git** (shared with
   the team) or **local-only** (hidden via `.git/info/exclude`, without
   touching `.gitignore`).

The result is a real `.agents/` folder inside your project. If you chose
versioned, it is committed like any other file. If local-only, it stays on your
machine and is never committed.

### Next step: adapt the initial-setup

The template is stack-agnostic by design. Open
`.agents/prompts/initial-setup/PROMPT.md` after installation and fill in every
`[brackets]` field — project name, objective, audience, domain rules, stack,
open decisions and language conventions. Then paste it into a new AI
conversation to bootstrap the project's workflow.

### Removing

```bash
~/Projects/ai-guardrails/scripts/init.sh --remove
```

- A **local-only** `.agents` is deleted. This is safe: the template is fully
  regenerable by running `init.sh` again.
- A **versioned** `.agents` is left untouched (it belongs to the repository).
  Remove it manually with `git rm -r .agents` if you no longer need it.
- The `.git/info/exclude` entry is always cleaned.
- The script **never touches `docs/` or any other project file** — it only
  manipulates `.agents` and `.git/info/exclude`.

### Switching between versioned and local-only

```bash
~/Projects/ai-guardrails/scripts/init.sh --set-versioning yes
~/Projects/ai-guardrails/scripts/init.sh --set-versioning no
```

This updates the install metadata and the `.git/info/exclude` entry in place,
without reinstalling or touching any content.

## Ecosystem note (mid-2026)

The AI coding assistant ecosystem is evolving rapidly and there is still no
universal standard for system prompt file names (`AGENTS.md`, `CLAUDE.md`,
`.cursorrules`, etc.). If a specific assistant stops reading the rules or
loading skills, open an Issue so we can update the entry point mapping.

## Roadmap

- [ ] **Interactive stack selection:** evolve `init.sh` to detect the project's
      stack and suggest the relevant packs automatically.
- [ ] **PowerShell equivalent** of `init.sh` for pure Windows users.
- [ ] **Agent harness:** introduce the "harness" concept as the umbrella
      document for the full agent wrapper (guardrails + skills + MCP servers +
      tool definitions + permissions), once the template supports MCP or
      external-tool configuration. Until then, `tooling` covers the only
      concrete piece that exists.