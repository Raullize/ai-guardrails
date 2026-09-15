---
name: commit-conventions
description: Requires semantic commits and selective staging, following the repository convention.
document_type: rule
severity: blocking
applies_when:
  - creating any commit
max_lines: 55
---

# Commit Conventions

## Intent

A commit is a unit of history. Its message and content must allow a future
reader (human or model) to understand what happened and why.

## Obligations

1. Use the semantic commit format: `type(scope): description`, e.g.
   `feat(auth): add password reset`, `fix(cart): total without discount`.
2. `type` in: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`,
   `build`, `ci`, `style`.
3. One story/concern per commit. Selective staging only.
4. If the project mandates it, add the `Generated-by-AI: <model>` footer
   declaring AI authorship.
5. Do not amend commits that were already pushed.

## How to verify

- `git log --oneline` shows consistent semantic messages.
- Each commit changes files of a single concern.
- Footer convention (if any) is respected.

## Signs of violation

- Messages like `fix stuff`, `update`, `asdf`, `wip`.
- One commit mixing feature, refactor and config changes.
- Amended history that already reached the remote.