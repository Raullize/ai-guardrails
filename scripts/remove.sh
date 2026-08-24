#!/bin/bash

GUARDRAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR="$(pwd)"

RULE_LINKS=(
    "AGENTS.md"
    "CLAUDE.md"
    ".cursor/rules/ai-guardrails.md"
    ".trae/rules/ai-guardrails.md"
    ".agents/rules/ai-guardrails.md"
)

SKILL_LINKS=(
    ".agents/skills"
    ".claude/skills"
    ".cursor/skills"
    ".opencode/skills"
    ".trae/skills"
)

EXCLUDE_ENTRIES=(
    "AGENTS.md"
    "CLAUDE.md"
    ".agents/rules/ai-guardrails.md"
    ".agents/skills"
    ".claude/skills"
    ".cursor/rules/ai-guardrails.md"
    ".cursor/skills"
    ".opencode/skills"
    ".trae/rules/ai-guardrails.md"
    ".trae/skills"
)

PARENT_DIRS=(
    ".agents/rules"
    ".agents"
    ".claude"
    ".cursor/rules"
    ".cursor"
    ".opencode"
    ".trae/rules"
    ".trae"
)

remove_link() {
    local path="$1"
    local label="$2"

    if [ -L "$path" ]; then
        rm -f "$path"
        echo "$label $path removed."
    fi
}

if [ "$CURRENT_DIR" == "$GUARDRAILS_DIR" ]; then
    exit 0
fi

echo "Removing AI Guardrails from this project..."

for path in "${RULE_LINKS[@]}"; do
    remove_link "$path" "Link"
done

for path in "${SKILL_LINKS[@]}"; do
    remove_link "$path" "Link"
done

for path in "${PARENT_DIRS[@]}"; do
    rmdir "$path" 2>/dev/null
done

if [ -d ".git" ] && [ -f ".git/info/exclude" ]; then
    cp .git/info/exclude .git/info/exclude.tmp

    for item in "${EXCLUDE_ENTRIES[@]}"; do
        grep -Fvx "$item" .git/info/exclude.tmp > .git/info/exclude.next || true
        mv .git/info/exclude.next .git/info/exclude.tmp
    done

    mv .git/info/exclude.tmp .git/info/exclude
    echo "Exclusion rules removed from .git/info/exclude."
fi

echo "Project cleaned. Repository is back to its original state."
