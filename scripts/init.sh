#!/bin/bash

GUARDRAILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_DIR="$(pwd)"

if [ "$CURRENT_DIR" == "$GUARDRAILS_DIR" ]; then
    echo -e "\033[1;31mError: You cannot initialize inside the ai-guardrails repository itself.\033[0m"
    echo "Please run this script from the root of your target project."
    exit 1
fi

if [ ! -d "$GUARDRAILS_DIR/.agents" ]; then
    echo -e "\033[1;31mError: .agents template not found in $GUARDRAILS_DIR\033[0m"
    exit 1
fi

add_git_exclude() {
    local item="$1"
    if [ -d ".git" ]; then
        if ! grep -Fxq "$item" .git/info/exclude 2>/dev/null; then
            echo "$item" >> .git/info/exclude
        fi
    fi
}

remove_git_exclude() {
    local item="$1"
    if [ -d ".git" ] && [ -f ".git/info/exclude" ]; then
        grep -Fvx "$item" .git/info/exclude > .git/info/exclude.tmp 2>/dev/null && mv .git/info/exclude.tmp .git/info/exclude
    fi
}

ROOT_AGENTS_TEMPLATE='---
name: agents-root-entrypoint
description: Entry point for LLM assistants. Points to the source of truth in .agents/. Does not duplicate content.
document_type: agents_manifest
max_lines: 60
---

# AGENTS.md — Entry Point for LLM Assistants

> **The source of truth lives in `.agents/*`, versioned in git.**
> Read [`.agents/AGENTS.md`](.agents/AGENTS.md) for the full instructions,
> rules and skills. This file only points; it does not duplicate content.

<!-- generated-by: ai-guardrails -->
'

usage() {
    cat <<'EOF'
Usage: init.sh [OPTION]

Initialize this project with the ai-guardrails .agents template.

The base .agents (rules + skills) is always installed.
You can include prompts (initial-setup) or install rules and skills only.
If prompts are included, you can also add:
  tooling     — use the repo's own scripts as the single source of truth
                for commands, tests and checks
  ralph-loop  — Perceive→Orient→Decide→Act→Record cycle per story
                (standard + ralph-loop == the previous "Full" mode)

Options:
  --remove               Remove a local-only .agents installation (real files are
                         deleted; the template is regenerable via init.sh) and
                         clean its .git/info/exclude entry. A versioned .agents
                         is left untouched.
  --set-versioning yes|no  Switch between versioned and local-only after install.
  --help                 Show this help
EOF
}

if [ "${1:-}" == "--help" ]; then
    usage
    exit 0
fi

if [ "${1:-}" == "--remove" ]; then
    MARKER="$CURRENT_DIR/.agents/.ai-guardrails-install"

    IS_TRACKED=0
    if [ -d "$CURRENT_DIR/.git" ] && [ -d "$CURRENT_DIR/.agents" ]; then
        if [ -n "$(git -C "$CURRENT_DIR" ls-files -- .agents 2>/dev/null)" ]; then
            IS_TRACKED=1
        fi
    fi

    if [ -L "$CURRENT_DIR/.agents" ]; then
        rm -f "$CURRENT_DIR/.agents"
        echo "Symlink .agents removed."
    elif [ -d "$CURRENT_DIR/.agents" ] && [ "$IS_TRACKED" == "0" ] && [ -f "$MARKER" ]; then
        rm -rf "$CURRENT_DIR/.agents"
        if [ -f "$CURRENT_DIR/AGENTS.md" ] && grep -q "generated-by: ai-guardrails" "$CURRENT_DIR/AGENTS.md" 2>/dev/null; then
            rm -f "$CURRENT_DIR/AGENTS.md"
            echo "Root AGENTS.md (generated entry point) removed."
        fi
        echo "Local-only .agents removed."
    elif [ -d "$CURRENT_DIR/.agents" ]; then
        if [ "$IS_TRACKED" == "1" ]; then
            echo -e "\033[1;31m$CURRENT_DIR/.agents is a real versioned directory.\033[0m"
            echo "It is tracked in git. Remove it manually (git rm -r .agents) if you no longer need it."
            echo "The generated AGENTS.md is also versioned; remove it with git rm AGENTS.md if desired."
        else
            echo -e "\033[1;31m$CURRENT_DIR/.agents was not installed by ai-guardrails.\033[0m"
            echo "Remove it manually if you no longer need it."
        fi
    else
        echo "No .agents installation found."
    fi

    remove_git_exclude ".agents"
    remove_git_exclude "/AGENTS.md"
    remove_git_exclude "AGENTS.md"
    echo "Entries removed from .git/info/exclude."
    exit 0
fi

if [ "${1:-}" == "--set-versioning" ]; then
    TARGET="${2:-}"
    if [ "$TARGET" != "yes" ] && [ "$TARGET" != "no" ]; then
        echo -e "\033[1;31mUsage: init.sh --set-versioning yes|no\033[0m"
        exit 1
    fi
    MARKER="$CURRENT_DIR/.agents/.ai-guardrails-install"
    if [ ! -f "$MARKER" ]; then
        echo -e "\033[1;31mNo .agents installation found here.\033[0m"
        exit 1
    fi
    if [ "$TARGET" == "no" ]; then
        add_git_exclude ".agents"
        add_git_exclude "/AGENTS.md"
        sed -i 's/"versioned": *"[a-z]*"/"versioned": "no"/' "$MARKER"
        echo "Switched to local-only. .agents is now hidden from git (.git/info/exclude)."
    else
        remove_git_exclude ".agents"
        remove_git_exclude "/AGENTS.md"
        remove_git_exclude "AGENTS.md"
        sed -i 's/"versioned": *"[a-z]*"/"versioned": "yes"/' "$MARKER"
        echo "Switched to versioned. Run 'git add .agents' to track it."
    fi
    exit 0
fi

if [ -e "$CURRENT_DIR/.agents" ]; then
    echo -e "\033[1;31mError: $CURRENT_DIR/.agents already exists.\033[0m"
    echo "Remove it first or run 'init.sh --remove' to clean an existing installation."
    exit 1
fi

# --- arrow-key selection helpers -------------------------------------------
# select_option TITLE OPTION... -> prints the chosen OPTION; index in $? (0-based)
select_option() {
    local title="$1"; shift
    local -a options=("$@")
    local selected=0
    local key key2

    tput civis 2>/dev/null
    trap 'tput cnorm 2>/dev/null; echo; exit' INT TERM EXIT

    render_menu() {
        local i
        if [ "$1" != "first" ]; then
            tput cuu "$(( ${#options[@]} + 1 ))" 2>/dev/null
        fi
        echo -e "$(tput el 2>/dev/null)$title"
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo -e "$(tput el 2>/dev/null) > \033[1;32m${options[$i]}\033[0m"
            else
                echo -e "$(tput el 2>/dev/null)   ${options[$i]}"
            fi
        done
    }

    render_menu "first"
    while true; do
        IFS= read -rsn1 key
        if [[ $key == $'\e' ]]; then
            read -rsn2 key2
            if [[ $key2 == "[A" ]]; then
                ((selected--))
                [ $selected -lt 0 ] && selected=$(( ${#options[@]} - 1 ))
                render_menu
            elif [[ $key2 == "[B" ]]; then
                ((selected++))
                [ $selected -ge ${#options[@]} ] && selected=0
                render_menu
            fi
        elif [[ -z "$key" ]]; then
            break
        fi
    done

    trap - INT TERM EXIT
    tput cnorm 2>/dev/null
    echo ""
    return "$selected"
}

# select_multi TITLE OPTION... -> toggles with Space, Enter confirms.
# Selected options (0-based indices) are returned in $MULTI_RESULT.
select_multi() {
    local title="$1"; shift
    local -a options=("$@")
    local -a flags=()
    local i cur=0
    for i in "${!options[@]}"; do flags[$i]=0; done
    local key key2

    tput civis 2>/dev/null
    trap 'tput cnorm 2>/dev/null; echo; exit' INT TERM EXIT

    render_multi() {
        local i mark
        if [ "$1" != "first" ]; then
            tput cuu "$(( ${#options[@]} + 2 ))" 2>/dev/null
        fi
        echo -e "$(tput el 2>/dev/null)$title"
        for i in "${!options[@]}"; do
            if [ "${flags[$i]}" == "1" ]; then
                mark="\033[1;32m*\033[0m"
            else
                mark=" "
            fi
            if [ "$i" -eq "$cur" ]; then
                echo -e "$(tput el 2>/dev/null) > [${mark}] \033[1;32m${options[$i]}\033[0m"
            else
                echo -e "$(tput el 2>/dev/null)   [${mark}] ${options[$i]}"
            fi
        done
        echo -e "$(tput el 2>/dev/null)   (\033[2m↑/↓\033[0m move · \033[2mSpace\033[0m toggle · \033[2mEnter\033[0m confirm)"
    }

    render_multi "first"
    while true; do
        IFS= read -rsn1 key
        if [[ $key == $'\e' ]]; then
            read -rsn2 key2
            if [[ $key2 == "[A" ]]; then
                ((cur--))
                [ $cur -lt 0 ] && cur=$(( ${#options[@]} - 1 ))
                render_multi
            elif [[ $key2 == "[B" ]]; then
                ((cur++))
                [ $cur -ge ${#options[@]} ] && cur=0
                render_multi
            fi
        elif [[ $key == " " ]]; then
            flags[$cur]=$(( 1 - ${flags[$cur]} ))
            render_multi
        elif [[ -z "$key" ]]; then
            break
        fi
    done

    trap - INT TERM EXIT
    tput cnorm 2>/dev/null
    echo ""
    MULTI_RESULT=""
    for i in "${!flags[@]}"; do
        [ "${flags[$i]}" == "1" ] && MULTI_RESULT="$MULTI_RESULT $i"
    done
}

echo "== ai-guardrails — .agents template initializer =="
echo "Project: $CURRENT_DIR"
echo ""

echo ""
select_option \
    "Include prompts? (↑/↓ + Enter)" \
    "Yes — initial-setup + optional prompts" \
    "No — rules and skills only"
INCLUDE_PROMPTS=$?

ENABLE_TOOLING=0
ENABLE_RALPH=0
if [ "$INCLUDE_PROMPTS" == "0" ]; then
    echo ""
    echo "Choose which optional prompts to add (Space to toggle, Enter to confirm):"
    select_multi \
        "Optional prompts:" \
        "tooling — use the repo's own scripts as the source of truth for commands" \
        "ralph-loop — Perceive → Orient → Decide → Act → Record per story"
    PROMPT_SEL=$MULTI_RESULT

    for sel in $PROMPT_SEL; do
        case "$sel" in
            0) ENABLE_TOOLING=1 ;;
            1) ENABLE_RALPH=1 ;;
        esac
    done
    if [ "$ENABLE_TOOLING" == "1" ] && [ "$ENABLE_RALPH" == "1" ]; then
        MODE=3
    elif [ "$ENABLE_TOOLING" == "1" ]; then
        MODE=2
    else
        MODE=1
    fi
else
    MODE=0
fi

echo ""
select_multi \
    "Optional stack-specific packs (Space to toggle, Enter to confirm):" \
    "docker-expert" "humanize-frontend" "modernize-legacy" \
    "refactor-react" "seo-optimizer" "ui-to-code"
PACKS=$(echo $MULTI_RESULT | sed 's/ /,/g')
if [ -z "$PACKS" ]; then
    PACKS="7"
fi

echo ""
select_option \
    "Should .agents be versioned in git? (↑/↓ + Enter)" \
    "Yes — .agents becomes part of the repository (shared with the team)" \
    "No — local only, hidden from git via .git/info/exclude"
VERSIONING=$?
VERSIONING=$((VERSIONING + 1))

echo ""
echo "Installing .agents template..."

cp -R "$GUARDRAILS_DIR/.agents" "$CURRENT_DIR/.agents"
echo "  .agents base copied."

if [ "$INCLUDE_PROMPTS" != "0" ]; then
    rm -rf "$CURRENT_DIR/.agents/prompts"
    echo "  prompts skipped (rules and skills only)."
fi

if [ -e "$CURRENT_DIR/AGENTS.md" ]; then
    echo "  WARN: AGENTS.md already exists at the project root. Not overwriting."
    echo "        The entry point lives at .agents/AGENTS.md."
else
    printf '%s' "$ROOT_AGENTS_TEMPLATE" > "$CURRENT_DIR/AGENTS.md"
    echo "  Root AGENTS.md entry point created."
fi

cat > "$CURRENT_DIR/.agents/.ai-guardrails-install" <<EOF
{
  "tool": "ai-guardrails",
  "versioned": "$([ "$VERSIONING" == "2" ] && echo no || echo yes)",
  "prompts": "$([ "$INCLUDE_PROMPTS" == "0" ] && echo yes || echo no)",
  "mode": "$MODE",
  "packs": "$PACKS"
}
EOF
echo "  install metadata written."

if [ "$ENABLE_TOOLING" == "1" ]; then
    mkdir -p "$CURRENT_DIR/.agents/prompts/tooling"
    cp "$GUARDRAILS_DIR/optional/prompts/tooling/PROMPT.md" "$CURRENT_DIR/.agents/prompts/tooling/PROMPT.md"
    echo "  tooling prompt installed."
fi

if [ "$ENABLE_RALPH" == "1" ]; then
    mkdir -p "$CURRENT_DIR/.agents/prompts/ralph-loop"
    cp "$GUARDRAILS_DIR/optional/prompts/ralph-loop/PROMPT.md" "$CURRENT_DIR/.agents/prompts/ralph-loop/PROMPT.md"
    echo "  ralph-loop prompt installed."
fi

install_pack() {
    local name="$1"
    if [ -d "$GUARDRAILS_DIR/optional/packs/$name" ]; then
        cp -R "$GUARDRAILS_DIR/optional/packs/$name" "$CURRENT_DIR/.agents/skills/$name"
        echo "  pack $name installed."
    else
        echo "  WARN: pack $name not found."
    fi
}

if [ -n "$PACKS" ] && [ "$PACKS" != "7" ]; then
    IFS=',' read -ra SELECTED <<< "$PACKS"
    for sel in "${SELECTED[@]}"; do
        case "$(echo "$sel" | tr -d ' ')" in
            0) install_pack "docker-expert" ;;
            1) install_pack "humanize-frontend" ;;
            2) install_pack "modernize-legacy" ;;
            3) install_pack "refactor-react" ;;
            4) install_pack "seo-optimizer" ;;
            5) install_pack "ui-to-code" ;;
            *) echo "  WARN: invalid pack selection '$sel' ignored." ;;
        esac
    done
fi

if [ -d "$CURRENT_DIR/.git" ]; then
    case "$VERSIONING" in
        2)
            add_git_exclude ".agents"
            add_git_exclude "AGENTS.md"
            add_git_exclude "/AGENTS.md"
            echo ""
            echo "Note: .agents and the generated AGENTS.md are local-only. They were"
            echo "added to .git/info/exclude and will not be committed."
            ;;
        *)
            echo ""
            echo "Note: .agents is versioned in git and will be shared with the team."
            ;;
    esac
else
    echo ""
    echo "Note: this directory is not a Git repository. Nothing was hidden from git."
fi

echo ""
echo "Done! Project configured."
echo "  - Entry point: .agents/AGENTS.md"
echo "  - Rules:       .agents/rules/"
echo "  - Skills:      .agents/skills/"
if [ "$INCLUDE_PROMPTS" == "0" ]; then
    echo "  - Prompts:     .agents/prompts/"
fi
echo ""
if [ "$INCLUDE_PROMPTS" == "0" ]; then
    echo "Next: open .agents/prompts/initial-setup/PROMPT.md, fill in the [brackets],"
    echo "and paste it into a new AI conversation to bootstrap the project workflow."
else
    echo "Next: open .agents/AGENTS.md and start with your first task."
fi