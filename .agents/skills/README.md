---
name: skills-indice
description: Index of the generic skills shipped with the ai-guardrails template, with role and trigger moment.
document_type: index
applies_when:
  - choosing which skill triggers the next action
  - creating a new skill for a specific domain
max_lines: 120
---

# Skills

A skill is a role with its own procedure. It executes; the rule limits. A skill
can complement another, never replace the verdict of someone else's gate.

| Skill | Role | Triggers when |
| --- | --- | --- |
| [council](./council/SKILL.md) | Decision | A real decision with more than one path must be made |
| [generate-docs](./generate-docs/SKILL.md) | Execution | Documenting the codebase, architecture or APIs |
| [security-audit](./security-audit/SKILL.md) | Gate | Security review, before deploy, OWASP concerns |
| [performance-audit](./performance-audit/SKILL.md) | Gate | Improving performance or optimizing bottlenecks |

> Stack-specific skills (Docker, React, frontend humanization, SEO, UI-to-code,
> legacy modernization) are NOT in the core. They are shipped as optional packs
> under `optional/packs/` and installed by the init script when relevant to the
> project's stack.

## Mandatory structure of a skill

Each skill is **its own folder** (not a loose `.md` file):

```
.agents/skills/<skill-name-kebab-case>/
└── SKILL.md                  ← main file, ALWAYS with this name
```

When (and only when) complementary content arises — code snippets, checklists,
templates — create an `assets/` subfolder at the same level.

### Minimum requirements of a skill

1. Frontmatter with `name` and `description`.
2. Single responsibility declared in one sentence.
3. Verifiable checklist, verdict criteria and antipatterns.
4. Explicit boundary: what it does **not** decide.