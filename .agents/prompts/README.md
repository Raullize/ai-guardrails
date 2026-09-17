---
name: prompts-indice
description: Index of the prompts shipped with the ai-guardrails template.
document_type: index
applies_when:
  - locating the prompt of a process stage
max_lines: 80
---

# Prompts

| Prompt | Use |
| --- | --- |
| [initial-setup](./initial-setup/PROMPT.md) | Foundation prompt to bootstrap a project with the agentic workflow. **Always included.** |
| [tooling](./tooling/PROMPT.md) | Optional. Instructs the agent to use the repository's own scripts as the single source of truth for commands, tests and checks. Included when the init script enables tooling. |
| [ralph-loop](./ralph-loop/PROMPT.md) | Optional. Perceive → Orient → Decide → Act → Record execution cycle per story. Included when the init script enables the Ralph Loop. |

> **Note on `harness`:** the term "agent harness" (the full wrapper around an LLM
> — guardrails, MCP servers, tool definitions, permissions) is a **future
> concept** for this template. It is not implemented yet because there is no MCP
> or external-tool configuration to describe. When that support lands, the
> harness concept will be introduced here as the umbrella document; until then,
> `tooling` covers the only concrete part that exists.

## Source of truth

- `.agents/prompts/*` is the official source of truth, versioned in git.
- Convenience copies for specific IDEs are the LOCAL responsibility of each
  person's installation; they are never versioned and never a shared reference.
  In any conflict, `.agents/*` wins.

## Mandatory structure of a prompt

Each prompt is **its own folder** (not a loose `.md` file):

```
.agents/prompts/<prompt-name-kebab-case>/
└── PROMPT.md                  ← main file, ALWAYS with this name
```

When (and only when) complementary content emerges, create an `assets/`
subfolder at the same level.

## Convention

- Mandatory frontmatter, single responsibility.
- A prompt describes a **procedure**; a rule describes a **constraint**; a
  skill describes a **role**. When a prompt starts imposing a constraint,
  extract a rule.