---
name: agents-root-entrypoint
description: Entry point for LLM assistants into the project. Points to the source of truth, non-negotiable rules and the installed configuration. This file does NOT duplicate content.
document_type: agents_manifest
applies_when:
  - an agent opens the repository for the first time
  - an agent needs to know where the official rules live
max_lines: 150
---

# AGENTS.md — Entry Point for LLM Assistants

> **The source of truth LIVES in `.agents/*`.**
> Here there are ONLY pointers in the right order and the executive summary of
> what MUST NOT be broken. Any conflict between this file and `.agents/` is
> resolved by `.agents/`.

## Installed configuration

<!-- ai-guardrails:config:begin -->
| Option | Value |
|---|---|
| Prompts | `initial-setup` |
| Optional prompts | `none` |
| Stack packs | `none` |
| Git | versioned |
<!-- ai-guardrails:config:end -->

---

## 1. Mandatory reading — before any action

| File | What you learn there |
|---|---|
| [`.agents/prompts/initial-setup/PROMPT.md`](.agents/prompts/initial-setup/PROMPT.md) | Project bootstrap, workflow and language conventions | <!-- @if prompts -->
| [`.agents/rules/README.md`](.agents/rules/README.md) | Index of non-negotiable rules (blocking invariants) |
| [`.agents/skills/README.md`](.agents/skills/README.md) | Index of skills / roles and their triggers |
| [`.agents/prompts/README.md`](.agents/prompts/README.md) | Index of reusable prompts | <!-- @if prompts -->

> **Optional prompts installed in this project:** <!-- @if any-optional -->
> - [`.agents/prompts/tooling/PROMPT.md`](.agents/prompts/tooling/PROMPT.md) — use the repository's own scripts as the single source of truth for commands, tests and checks. <!-- @if tooling -->
> - [`.agents/prompts/ralph-loop/PROMPT.md`](.agents/prompts/ralph-loop/PROMPT.md) — run the Perceive → Orient → Decide → Act → Record cycle per story. <!-- @if ralph -->

---

## 2. Non-negotiable rules — DO NOT BREAK THEM

1.  **Test-first.** When behavior is testable, a failing test precedes the
    implementation. Refactor only after the functional tests are green.
2.  **Evidence over claims.** No story goes to `Done` without validation
    evidence. Tests must prove the business rule, not just the pipeline.
3.  **No silent refactors.** Only modify what was requested. No unrequested
    reformatting or "improvements".
4.  **No hallucination.** Never invent libraries, APIs, endpoints or
    versions. Verify when unsure.
5.  **Secrets never.** No keys, tokens, credentials or sensitive data in
    commits, logs or debug output.
6.  **Semantic commits + selective staging.** One concern per commit. See
    `.agents/rules/commit-conventions/RULE.md`.
7.  **Push, tag and release ONLY with explicit human authorization.** None of
    them automatic.
8.  **Artifact structure is 1 folder = 1 artifact:**
    ```
    Skills  →  .agents/skills/<name>/SKILL.md
    Rules   →  .agents/rules/<name>/RULE.md
    Prompts →  .agents/prompts/<name>/PROMPT.md
    ```

---

<!-- ai-guardrails:if prompts -->
## 3. Quick recipe for working here

| Situation | What to do |
|---|---|
| First time in the repo | Read section 1 in order, then the official kanban / backlog |
| Start a story | Move the kanban item to *In progress* **before** coding |
| Implement a story | Apply the rules; write the test first when behavior is testable |
| Close a story | Run the applicable gates → review → commit + tag (only with human OK) |
| New skill / rule / prompt | 1 folder per artifact + fixed name. Create `assets/` only with real content |
| Doubt about why a decision | Look for the ADR. No ADR = create one |

---
<!-- ai-guardrails:endif -->

<!-- ai-guardrails:if prompts -->
*Conflict between instructions? Always apply in this order:*
`.agents/prompts/initial-setup/PROMPT.md` → blocking `RULE`s → official kanban → this `AGENTS.md`.
<!-- ai-guardrails:endif -->
<!-- ai-guardrails:if no-prompts -->
*Conflict between instructions? Always apply in this order:*
blocking `RULE`s → this `AGENTS.md`.
<!-- ai-guardrails:endif -->

<!-- generated-by: ai-guardrails -->
