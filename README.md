# AI Guardrails

Centralized repository for governance, rules, and capabilities to optimize AI assistants (Trae, OpenCode, Cursor, AntiGravity, Claude Code). Focused on reducing token costs, ensuring architectural consistency, and eliminating generic AI visual patterns.

## Repository Structure

- `rules/`: Style guidelines and safety constraints (the "how" to write).
- `skills/`: Specialized instruction blocks for specific tasks (e.g., frontend humanization, refactoring).
- `scripts/`: Automation scripts to inject rules into projects without polluting the Git tree.
- `template/`: Base templates for creating new AI components.

## Local Setup and Usage

To use these settings in any local repository without duplicating files, **without polluting the repository, and without changing `.gitignore`**, use the automation scripts.

They use a feature called `.git/info/exclude`, which ignores the rule files only on your local machine.

### To enable rules in a project:
**On Linux / Mac (or Git Bash on Windows):**
Go to the project folder you want to configure and run the script using the absolute path to where you cloned this repository. For example, if you cloned it in your `~/Projects` folder:
```bash
~/Projects/ai-guardrails/scripts/apply.sh
```
*(Note: The script automatically discovers where `ai-guardrails` is installed based on the path you typed to execute it, so it will always create the correct shortcuts regardless of where the repository was saved).*

**On Windows (PowerShell/CMD):**
For pure Windows users (who do not use Git Bash or WSL), the `.sh` script will not run natively. In this case, we recommend using Git Bash or WSL to run the script. If you want to run it natively, an equivalent `.ps1` script needs to be created (coming soon).

### To disable rules:
If you want to remove the AI settings from the project:
```bash
~/Projects/ai-guardrails/scripts/remove.sh
```

## Roadmap and Future

- [ ] **Dynamic Injection by Stack:** Evolve the `apply.sh` script to ask not only for the IDE but also for the project's Stack (e.g., Spring Boot, .NET, NestJS, React). This way, the script will inject only the *skills* and rules relevant to that language, saving tokens and avoiding context conflicts in the AI.

## Important Notice: Ecosystem Volatility (Mid-2026)

> **Note:** As of June 17, 2026, the AI coding assistant ecosystem (Trae, AntiGravity, OpenCode, Claude Code, etc.) is evolving rapidly. **There is still no universal standard** for naming system prompt files (e.g., `.cursorrules`, `AGENTS.md`, `GEMINI.md`) or skill directories. 
> 
> Because of this, the mapping created by the `apply.sh` script might become outdated if a specific IDE releases an update that changes its required folder structure or file name.
> 
> If you notice that an assistant is no longer reading the rules or loading the skills, please **open an Issue** in this repository so we can update the automation script with the new standard!