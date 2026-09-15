---
name: initial-setup
description: Foundation prompt to bootstrap any project with the ai-guardrails agentic workflow. Fill the fields in brackets to adapt it to the project's niche and stack.
document_type: reusable_prompt
applies_when:
  - starting a new project
  - standardizing the agentic workflow
  - configuring AI-assisted development governance
max_lines: 200
---

# Initial Agentic Project Setup Prompt

Use this prompt to start a new project with the same agentic execution standard
for AI-assisted development, regardless of the chosen technology.

Copy the block below, fill in every field between brackets, and paste it into a
new conversation.

```text
You are a software engineering agent responsible for structuring a new project
called [PROJECT_NAME].

1. Product context (replace everything between brackets):
   - Objective: [describe in one paragraph what the product does and for whom]
   - Target audience / users: [describe primary users]
   - Domain rules that constrain behavior: [e.g. regulatory, security,
     cost, platform, business constraints]
   - Expected initial stack: [languages, frameworks, tools, versions]
   - Open decisions: [what must still be decided, with explicit trade-offs]

2. Deliver the following agentic foundation (stack-independent):
   - docs/spec-driven-development/ — initial understanding of the domain
   - docs/backlog/ — a single official kanban, source of truth of the next demand
   - docs/requirements/ — functional and non-functional requirements
   - docs/tasks/ — per-story execution plans
   - docs/deliveries/ — chronological documentation of each delivery
   - .agents/rules/ — non-negotiable constraints
   - .agents/skills/ — roles with their own procedures
   - .agents/prompts/ — reusable procedure prompts
   - scripts/ — reproducible local commands (the harness)

3. Workflow rules:
   - The official kanban is the only source of the next demand.
   - Each story must have verifiable acceptance criteria and cite related
     requirements.
   - Business stories exist when there is behavior perceived by a user;
     technical stories exist for infrastructure, quality, security, CI/CD,
     publishing, observability or governance.
   - Every completed delivery generates a document in docs/deliveries/.
   - No story goes to Done without validation evidence.
   - No delivery commit mixes files from another story.
   - No semantic tag points to a commit different from the closing commit.

4. Apply the rules and skills already present in .agents/:
   - Read .agents/rules/ and .agents/skills/ and apply them to every step.
   - Respect test-first ordering (tdd-bdd-before-implementation) when behavior
     is testable, and refactor only after the functional tests are green.
   - No silent refactors, no hallucinated libraries, no committed secrets.

5. Optional prompts (read them IF the file exists in .agents/prompts/):
   - .agents/prompts/harness/PROMPT.md — if present, ALWAYS run commands
     through the repository's own scripts (never invent commands) and document
     the real ones.
   - .agents/prompts/ralph-loop/PROMPT.md — if present, run the
     Perceive → Orient → Decide → Act → Record cycle for each story.

6. Language convention (adjust to the project's need):
   - [CODE_AND_DOCS_LANGUAGE]: code, docs, .agents, tests, commits, CI
   - [USER_FACING_LANGUAGE]: UI strings, README for end users
   - [CHAT_LANGUAGE]: language spoken with the user in the conversation

Expected first delivery:
1. Business epic (vision, personas, flows, requirements).
2. Technical epic (non-functional requirements, architecture, security,
   observability, tests, CI/CD).
3. Initial official kanban.
4. Templates for story, task, implementation plan, progress and delivery.
5. Do not implement the product yet, unless I explicitly ask.
```

## How to Use

1. Paste the prompt into a new conversation or project.
2. Fill in every field between brackets.
3. Ask first for the creation of the governance artifacts.
4. Only then ask for the execution of the first story.

## Adaptation By Technology

The workflow does not assume a stack. When choosing technology, create specific
technical stories for: local environment, build, tests, lint, static analysis,
security, CI/CD, publishing, observability, costs and operations.

## Golden Rule

The product changes according to the domain. The workflow does not change:
official kanban, small story, test first, refactoring, gates, documented
delivery, semantic commit and tag on the same hash.