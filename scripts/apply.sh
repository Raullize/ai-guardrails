#!/bin/bash

GUARDRAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

options=("Trae" "Cursor" "Windsurf" "OpenCode" "Claude Code" "AntiGravity" "Other / Default (.cursorrules)")
selected=0

tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null; echo; exit' INT TERM EXIT

print_menu() {
    if [ "$1" != "first" ]; then
        tput cuu $((${#options[@]} + 1)) 2>/dev/null
    fi
    
    echo -e "$(tput el 2>/dev/null)Which AI Assistant or IDE are you using in this project? (Use Up/Down arrows and press Enter)"
    
    for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
            echo -e "$(tput el 2>/dev/null) > \033[1;32m${options[$i]}\033[0m"
        else
            echo -e "$(tput el 2>/dev/null)   ${options[$i]}"
        fi
    done
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

"$GUARDRAILS_DIR/scripts/remove.sh" > /dev/null 2>&1
echo "Cleaning previous configurations (if any)..."

case $IDE_CHOICE in
    "Trae")
        FOLDER_NAME=".trae"
        RULE_NAME=".traerules"
        ;;
    "Cursor")
        FOLDER_NAME=".cursor"
        RULE_NAME=".cursorrules"
        ;;
    "Windsurf")
        FOLDER_NAME=".windsurf"
        RULE_NAME=".windsurfrules"
        ;;
    "OpenCode")
        FOLDER_NAME=".opencode"
        RULE_NAME=".opencoderules"
        ;;
    "Claude Code")
        FOLDER_NAME=".claude"
        RULE_NAME="claudecode.md"
        ;;
    "AntiGravity")
        FOLDER_NAME=".antigravity"
        RULE_NAME=".antigravityrules"
        ;;
    "Other / Default (.cursorrules)")
        FOLDER_NAME=".cursor"
        RULE_NAME=".cursorrules"
        ;;
esac

ln -sf "$GUARDRAILS_DIR/rules/global.md" "$RULE_NAME"
echo "Rules symlink created: $RULE_NAME"

mkdir -p "$FOLDER_NAME"
ln -sfn "$GUARDRAILS_DIR/skills" "$FOLDER_NAME/skills"
echo "Skills symlink created at: $FOLDER_NAME/skills"

if [ -d ".git" ]; then
    for item in "$RULE_NAME" "$FOLDER_NAME/"; do
        if ! grep -q "^${item}$" .git/info/exclude 2>/dev/null; then
            echo "$item" >> .git/info/exclude
        fi
    done
    echo "Files hidden from Git locally (.git/info/exclude)."
else
    echo "Warning: This directory is not a Git repository."
fi

echo "Done! Project configured for $IDE_CHOICE."