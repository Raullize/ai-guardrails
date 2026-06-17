#!/bin/bash

GUARDRAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR="$(pwd)"

if [ "$CURRENT_DIR" == "$GUARDRAILS_DIR" ]; then
    # We do not print an error here because apply.sh calls remove.sh silently
    exit 0
fi

echo "Removing AI Guardrails from this project..."

for file in ".cursorrules" ".traerules" "AGENTS.md" "GEMINI.md" "CLAUDE.md"; do
    if [ -L "$file" ] || [ -f "$file" ]; then
        rm -f "$file"
        echo "File/Symlink $file removed."
    fi
done

for dir in ".cursor" ".trae" ".opencode" ".claude" ".antigravity"; do
    if [ -L "$dir/skills" ] || [ -d "$dir/skills" ]; then
        rm -rf "$dir/skills"
        echo "Folder/Symlink $dir/skills removed."
    fi
    rmdir "$dir" 2>/dev/null
done

if [ -d ".git" ] && [ -f ".git/info/exclude" ]; then
    sed '/^\.cursorrules$/d' .git/info/exclude | \
    sed '/^\.traerules$/d' | \
    sed '/^AGENTS\.md$/d' | \
    sed '/^GEMINI\.md$/d' | \
    sed '/^CLAUDE\.md$/d' | \
    sed '/^\.cursor\/$/d' | \
    sed '/^\.trae\/$/d' | \
    sed '/^\.opencode\/$/d' | \
    sed '/^\.antigravity\/$/d' | \
    sed '/^\.claude\/$/d' > .git/info/exclude.tmp
    
    mv .git/info/exclude.tmp .git/info/exclude
    echo "Exclusion rules removed from .git/info/exclude."
fi

echo "Project cleaned. Repository is back to its original state."