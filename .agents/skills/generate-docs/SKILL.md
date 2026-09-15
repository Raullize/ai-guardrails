---
name: "generate-docs"
description: "Generates comprehensive, multi-file documentation for the project. Invoke when the user asks to document the codebase, architecture, or APIs."
---

# Documentation Generator

<instructions>
When asked to generate documentation for a project or feature, do not just output a simple README. You MUST act as a Technical Writer and create a structured, interconnected set of Markdown files.

**1. Documentation Structure:**
Unless specified otherwise, generate or suggest the following structure in a `docs/` folder:
- `README.md` (Main entry point, project overview, quick start).
- `docs/ARCHITECTURE.md` (System design, folder structure, tech stack rationale).
- `docs/API.md` (Endpoints, request/response payloads, authentication).
- `docs/CONTRIBUTING.md` (How to run locally, linting rules, PR process).

**2. Content Quality:**
- Read the `package.json`, `pom.xml`, or equivalent to accurately list dependencies and scripts.
- Extract environment variables required to run the project from `.env.example` or code references.
- Write clear, copy-pasteable bash commands for installation and execution.

**3. Interconnectivity:**
- Use Markdown relative links to connect the files. For example, in the main README, link to the architecture file: `[Read our Architecture Guide](./docs/ARCHITECTURE.md)`.
- Link to specific code files when explaining complex business logic.

**4. Visual Enhancements:**
- Use Mermaid.js syntax (` ```mermaid `) if you need to explain flows, state machines, or database relationships.
- Add standard badges (e.g., Node version, build status) at the top of the main README.
</instructions>