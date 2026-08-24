#!/bin/bash

GUARDRAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR="$(pwd)"

options=("Trae" "Cursor" "OpenCode" "Claude Code" "AntiGravity" "Other / Generic")
selected=0

tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null; echo; exit' INT TERM EXIT

print_menu() {
    if [ "$1" != "first" ]; then
        tput cuu $((${#options[@]} + 1)) 2>/dev/null
    fi

    echo -e "$(tput el 2>/dev/null)Which AI assistant or IDE are you using in this project? (Use Up/Down arrows and press Enter)"

    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "$(tput el 2>/dev/null) > \033[1;32m${options[$i]}\033[0m"
        else
            echo -e "$(tput el 2>/dev/null)   ${options[$i]}"
        fi
    done
}

assert_safe_target() {
    local path="$1"

    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo -e "\033[1;31mError: $path already exists as a real file or directory.\033[0m"
        echo "Refusing to overwrite existing project files."
        exit 1
    fi
}

add_git_exclude() {
    local item="$1"

    if [ ! -d ".git" ]; then
        return
    fi

    if ! grep -Fxq "$item" .git/info/exclude 2>/dev/null; then
        echo "$item" >> .git/info/exclude
    fi
}

print_menu "first"

while true; do
    read -rsn1 key
    if [[ $key == $'\e' ]]; then
        read -rsn2 key2
        if [[ $key2 == "[A" ]]; then
            ((selected--))
            if [ $selected -lt 0 ]; then selected=$((${#options[@]} - 1)); fi
            print_menu
        elif [[ $key2 == "[B" ]]; then
            ((selected++))
            if [ $selected -ge ${#options[@]} ]; then selected=0; fi
            print_menu
        fi
    elif [[ -z "$key" ]]; then
        break
    fi
done

trap - INT TERM EXIT
tput cnorm 2>/dev/null
echo ""

IDE_CHOICE="${options[$selected]}"
echo "Applying AI Guardrails for: $IDE_CHOICE..."

if [ "$CURRENT_DIR" == "$GUARDRAILS_DIR" ]; then
    echo -e "\033[1;31mError: You cannot apply guardrails inside the ai-guardrails repository itself.\033[0m"
    echo "Please run this script from the root of your target project."
    exit 1
fi

"$GUARDRAILS_DIR/scripts/remove.sh" > /dev/null 2>&1
echo "Cleaning previous configurations (if any)..."

case $IDE_CHOICE in
    "Trae")
        RULE_PATH=".trae/rules/ai-guardrails.md"
        SKILLS_PATH=".trae/skills"
        ;;
    "Cursor")
        RULE_PATH=".cursor/rules/ai-guardrails.md"
        SKILLS_PATH=".cursor/skills"
        ;;
    "OpenCode")
        RULE_PATH="AGENTS.md"
        SKILLS_PATH=".opencode/skills"
        ;;
    "Claude Code")
        RULE_PATH="CLAUDE.md"
        SKILLS_PATH=".claude/skills"
        ;;
    "AntiGravity")
        RULE_PATH=".agents/rules/ai-guardrails.md"
        SKILLS_PATH=".agents/skills"
        ;;
    "Other / Generic")
        RULE_PATH="AGENTS.md"
        SKILLS_PATH=".agents/skills"
        ;;
esac

assert_safe_target "$RULE_PATH"
assert_safe_target "$SKILLS_PATH"

mkdir -p "$(dirname "$RULE_PATH")"
ln -sfn "$GUARDRAILS_DIR/rules/global.md" "$RULE_PATH"
echo "Rules symlink created: $RULE_PATH"

mkdir -p "$(dirname "$SKILLS_PATH")"
ln -sfn "$GUARDRAILS_DIR/skills" "$SKILLS_PATH"
echo "Skills symlink created at: $SKILLS_PATH"

if [ -d ".git" ]; then
    add_git_exclude "$RULE_PATH"
    add_git_exclude "$SKILLS_PATH"
    echo "Files hidden from Git locally (.git/info/exclude)."
else
    echo "Warning: This directory is not a Git repository."
fi

echo "Done! Project configured for $IDE_CHOICE."
