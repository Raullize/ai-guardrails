---
name: tooling
description: Instructs the agent to treat the repository's own scripts as the single source of truth for commands, tests and checks.
document_type: reusable_prompt
applies_when:
  - running commands, tests, linters or builds
  - creating documentation that references how to run the project
max_lines: 60
---

# Repository Tooling

The project's own scripts are the single source of truth for how to run, test,
lint and build the repository. Do not invent commands.

## Obligations

1. Read the package manifest (`package.json`, `pyproject.toml`, `Makefile`,
   `pom.xml`, or equivalent) and the `scripts/` folder to discover the real
   commands.
2. Run commands through the documented tooling (e.g. `npm run`, `pnpm`, `make`,
   `docker compose`, custom `scripts/*.sh`). Never invent a command name.
3. When documenting the project, list the real commands with copy-paste
   snippets and, when applicable, Docker compose setup.
4. If a command does not exist, do not fabricate it. Report the gap and propose
   adding it to the tooling.

## Output

- Any runnable instruction in docs must come from the actual tooling.
- Evidence of checks (tests, lint) must show the exact command used.