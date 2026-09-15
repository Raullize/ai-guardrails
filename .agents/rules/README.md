---
name: rules-indice
description: Index of the generic rules shipped with the ai-guardrails template, with severity and complement relationships.
document_type: index
applies_when:
  - discovering which rule applies to a stage of the work
  - creating a new rule
max_lines: 120
---

# Rules

A rule is a non-negotiable constraint of the process. It states what must
**not** happen and how to prove it did not happen. A skill executes; a rule
limits.

| Rule | Severity | Applies to |
| --- | --- | --- |
| [tdd-bdd-before-implementation](./tdd-bdd-before-implementation/RULE.md) | Blocking | Order between test and code |
| [test-evidence-quality](./test-evidence-quality/RULE.md) | Blocking | Quality of proof and evidence |
| [refactor-after-functional-green](./refactor-after-functional-green/RULE.md) | Blocking | Post-green cleanup stage |
| [clean-code-readable-names](./clean-code-readable-names/RULE.md) | Strongly recommended | Names and readability |
| [architecture-boundaries-and-solid](./architecture-boundaries-and-solid/RULE.md) | Blocking | Boundaries, SOLID, dependency direction |
| [main-push-quality-and-versioning](./main-push-quality-and-versioning/RULE.md) | Blocking | Closing, commit, tag and push |
| [commit-conventions](./commit-conventions/RULE.md) | Blocking | Commit message format |
| [no-silent-refactors](./no-silent-refactors/RULE.md) | Blocking | Scope of changes |
| [no-hallucination](./no-hallucination/RULE.md) | Blocking | Verification of library/API facts |
| [security-and-secrets](./security-and-secrets/RULE.md) | Blocking | Secrets, credentials and data handling |

## Complement map

```
tdd-bdd-before-implementation
  └─ test-evidence-quality
       └─ refactor-after-functional-green
            ├─ clean-code-readable-names
            └─ architecture-boundaries-and-solid
                 └─ main-push-quality-and-versioning
                      └─ commit-conventions
no-silent-refactors ── guards the scope of every rule above
no-hallucination   ── guards every code-generating skill
security-and-secrets ── applies before any commit
```

A rule may complement other rules and skills; it never contradicts them.
Conflict between rules is resolved by the most restrictive one and recorded as a
decision.

## Mandatory structure of a rule

Each rule is **its own folder** (not a loose `.md` file):

```
.agents/rules/<rule-name-kebab-case>/
└── RULE.md                    ← main file, ALWAYS with this name
```

When (and only when) complementary content arises, create an `assets/`
subfolder at the same level (checklists, examples, references).

## How to create a rule

1. Mandatory frontmatter: `name`, `description`, `document_type`, `severity`,
   `applies_when`.
2. Single responsibility: one rule, one constraint.
3. Must contain: intent, obligations, how to verify and signs of violation.
4. A rule that cannot be verified is not a rule — it is advice, and goes to a
   skill.