# AI Guardrails

A portable, stack-agnostic `.agents` template that configures an AI-assisted
development environment in any project. It ships generic rules, skills and
prompts that adapt to the project's niche and stack — you fill in the
placeholders.

Installation adds a **single `AGENTS.md` entry point at the project root** plus
the `.agents/` folder with the reusable artifacts.

## What you get

- `AGENTS.md` at the project root — the single entry point for LLM assistants
  (Trae, OpenCode, Cursor, Claude Code, Copilot, AntiGravity). It is rendered
  from the installer choices: an `Installed configuration` table plus
  references only to the prompts and packs that were actually installed.
- `.agents/rules/` — non-negotiable constraints, stack-independent (test-first,
  evidence quality, no silent refactors, no hallucination, secrets, semantic
  commits).
- `.agents/skills/` — generic roles (council, grill-me, docs, security audit,
  performance audit).
- `.agents/prompts/` — reusable procedure prompts, including
  `initial-setup/PROMPT.md` with `[brackets]` placeholders to adapt the
  project's niche and stack.
- `optional/packs/` — stack-specific skills (Docker, React, frontend
  humanization, SEO, UI-to-code, unslop, legacy modernization) installed only
  when relevant.

## Repository structure

```
ai-guardrails/
├── AGENTS.md                 ← single entry point, installed at the project root
├── .agents/                  ← template source of truth (rules, skills, prompts)
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

`init.sh` copies `.agents/` into the target project and installs a single
`AGENTS.md` at its root. The entry point does not live inside `.agents/`.

## How to use

From the root of your target project, run:

```bash
~/Projects/ai-guardrails/scripts/init.sh
```

### Windows (Git Bash or PowerShell)

`init.sh` is a Bash script. On Windows, run it through Git Bash from the root
of the target project:

**Git Bash**

```bash
cd "C:/Users/<you>/Documents/Projects/<project>"
bash "C:/Users/<you>/Documents/Projects/ai-guardrails/scripts/init.sh"
```

**PowerShell**

```powershell
cd "C:\Users\<you>\Documents\Projects\<project>"
& "C:\Program Files\Git\bin\bash.exe" "C:\Users\<you>\Documents\Projects\ai-guardrails\scripts\init.sh"
```

The other modes use the same pattern:

```bash
bash "C:/Users/<you>/Documents/Projects/ai-guardrails/scripts/init.sh" --remove
bash "C:/Users/<you>/Documents/Projects/ai-guardrails/scripts/init.sh" --set-versioning no
```

> Run the script from the target project root, never inside the
> `ai-guardrails` repository itself. The remaining examples in this README use
> the Unix path; on Windows use the `bash "C:/..."` form shown above.

The script is interactive, driven by the arrow keys:

1. **Prompts** — choose whether `.agents` includes prompts (`initial-setup`) or
   ships **rules and skills only**.
2. **Optional prompts** — when prompts are included, choose what the base
   `.agents` should add beyond the always-installed `initial-setup`:
   - *tooling* — the repository's own scripts as the single source of truth
     for commands, tests and checks (never invent a command).
   - *ralph-loop* — the Perceive → Orient → Decide → Act → Record execution
     cycle per story.
3. **Optional packs** — navigate with ↑/↓, toggle with **Space**, confirm with
   **Enter**.
4. **Versioning** — ↑/↓ and Enter: `.agents` and the generated `AGENTS.md`
   **versioned in git** (shared with the team) or **local-only** (hidden via
   `.git/info/exclude`, without touching `.gitignore`).

The result is a real `.agents/` folder plus a single `AGENTS.md` at the project
root. The entry point reflects the chosen configuration — prompts, optional
prompts, stack packs and git mode — and does not reference artifacts that were
not installed. Without prompts, the workflow sections (quick recipe and the
kanban/story/ADR ordering) are omitted. If you chose versioned, both are
committed like any other file.
If local-only, both stay on your machine and are never committed. If the
project already has an `AGENTS.md`, it is preserved and an ai-guardrails section
is appended to it instead of overwriting it.

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
- A root `AGENTS.md` generated by the installer is deleted. If it already
  existed, only the ai-guardrails section is removed and the rest is kept.
- A **versioned** `.agents` is left untouched (it belongs to the repository).
  Remove it manually with `git rm -r .agents` if you no longer need it.
- The `.git/info/exclude` entry is always cleaned.
- The script **never touches `docs/` or any other project file** — it only
  manipulates `.agents`, `AGENTS.md` and `.git/info/exclude`.

### Switching between versioned and local-only

```bash
~/Projects/ai-guardrails/scripts/init.sh --set-versioning yes
~/Projects/ai-guardrails/scripts/init.sh --set-versioning no
```

This updates the install metadata and the `.git/info/exclude` entries in place,
without reinstalling or touching any content. A generated `AGENTS.md` follows
the same versioning choice; a pre-existing `AGENTS.md` is left tracked.

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