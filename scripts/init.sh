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

if [ ! -f "$GUARDRAILS_DIR/AGENTS.md" ]; then
    echo -e "\033[1;31mError: AGENTS.md entry point not found in $GUARDRAILS_DIR\033[0m"
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

# Removes only what ai-guardrails created in the root AGENTS.md:
# - the whole file when it is the generated entry point;
# - the managed section when it was appended to a pre-existing file.
clean_root_agents() {
    local file="$CURRENT_DIR/AGENTS.md"
    [ -f "$file" ] || return 0

    if grep -qF "generated-by: ai-guardrails" "$file" 2>/dev/null; then
        rm -f "$file"
        echo "Root AGENTS.md (generated entry point) removed."
    elif grep -qF "ai-guardrails:begin" "$file" 2>/dev/null; then
        awk '
            /<!-- ai-guardrails:begin -->/ { skip=1; next }
            /<!-- ai-guardrails:end -->/   { skip=0; next }
            !skip { print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        echo "ai-guardrails section removed from root AGENTS.md (file kept)."
    fi
}

join_list() {
    local out="" item
    for item in "$@"; do
        if [ -z "$out" ]; then
            out="$item"
        else
            out="$out, $item"
        fi
    done
    printf '%s' "$out"
}

# Prints the Markdown table that reflects the choices made in this run.
build_config_table() {
    local prompts_val="none"
    [ "$INCLUDE_PROMPTS" == "0" ] && prompts_val='`initial-setup`'

    local -a optional_items=()
    [ "$ENABLE_TOOLING" == "1" ] && optional_items+=('`tooling`')
    [ "$ENABLE_RALPH" == "1" ] && optional_items+=('`ralph-loop`')

    local -a pack_items=()
    if [ -n "$PACKS" ] && [ "$PACKS" != "7" ]; then
        local sel
        local -a selected=()
        IFS=',' read -ra selected <<< "$PACKS"
        for sel in "${selected[@]}"; do
            case "$(echo "$sel" | tr -d ' ')" in
                0) pack_items+=('`docker-expert`') ;;
                1) pack_items+=('`humanize-frontend`') ;;
                2) pack_items+=('`modernize-legacy`') ;;
                3) pack_items+=('`refactor-react`') ;;
                4) pack_items+=('`seo-optimizer`') ;;
                5) pack_items+=('`ui-to-code`') ;;
            esac
        done
    fi

    local optional_val packs_val git_val
    optional_val=$(join_list "${optional_items[@]}")
    packs_val=$(join_list "${pack_items[@]}")
    [ -z "$optional_val" ] && optional_val="none"
    [ -z "$packs_val" ] && packs_val="none"
    git_val="versioned"
    [ "$VERSIONING" == "2" ] && git_val="local-only (not committed)"

    printf '%s\n' '| Option | Value |'
    printf '%s\n' '|---|---|'
    printf '| Prompts | %s |\n' "$prompts_val"
    printf '| Optional prompts | %s |\n' "$optional_val"
    printf '| Stack packs | %s |\n' "$packs_val"
    printf '| Git | %s |\n' "$git_val"
}

# Keeps only the content that matches the chosen configuration.
# Supports line-level <!-- @if TAG --> annotations and block-level
# <!-- ai-guardrails:if TAG --> ... <!-- ai-guardrails:endif --> sections.
filter_agents_tags() {
    local src="$1" out="$2"
    local -a enabled=()
    [ "$INCLUDE_PROMPTS" == "0" ] && enabled+=("prompts")
    [ "$INCLUDE_PROMPTS" != "0" ] && enabled+=("no-prompts")
    [ "$ENABLE_TOOLING" == "1" ] && enabled+=("tooling")
    [ "$ENABLE_RALPH" == "1" ] && enabled+=("ralph")
    if [ "$ENABLE_TOOLING" == "1" ] || [ "$ENABLE_RALPH" == "1" ]; then
        enabled+=("any-optional")
    fi

    local enabled_list
    enabled_list=$(IFS=','; printf '%s' "${enabled[*]}")

    awk -v enabled_list="$enabled_list" '
        BEGIN {
            n = split(enabled_list, a, ",")
            for (i = 1; i <= n; i++) enabled[a[i]] = 1
            depth = 0
        }
        {
            if ($0 ~ /<!-- ai-guardrails:if [a-z0-9-]+ -->/) {
                tag = $0
                sub(/^.*<!-- ai-guardrails:if /, "", tag)
                sub(/ -->.*$/, "", tag)
                depth++
                cond[depth] = enabled[tag]
                next
            }
            if ($0 ~ /<!-- ai-guardrails:endif -->/) {
                if (depth > 0) depth--
                next
            }

            keep = 1
            for (i = 1; i <= depth; i++) if (!cond[i]) keep = 0
            if (!keep) next

            if (match($0, /<!-- @if [a-z0-9-]+ -->[[:space:]]*$/)) {
                tag = substr($0, RSTART, RLENGTH)
                sub(/^<!-- @if /, "", tag)
                sub(/ -->.*$/, "", tag)
                if (!enabled[tag]) next
                sub(/[[:space:]]*<!-- @if [a-z0-9-]+ -->[[:space:]]*$/, "")
            }
            print
        }
    ' "$src" > "$out"
}

# Updates only the Git row of the config table after a versioning switch.
update_agents_git_row() {
    local value="$1"
    local file="$CURRENT_DIR/AGENTS.md"
    [ -f "$file" ] || return 0
    grep -qF "ai-guardrails:config:begin" "$file" 2>/dev/null || return 0
    awk -v value="$value" '
        /<!-- ai-guardrails:config:begin -->/ { in_cfg=1; print; next }
        /<!-- ai-guardrails:config:end -->/   { in_cfg=0; print; next }
        in_cfg && /^\| Git \|/ { print "| Git | " value " |"; next }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# Renders the entry point: filters optional blocks and injects the config table
# between the ai-guardrails:config markers.
render_agents() {
    local target="$1"
    local src="$GUARDRAILS_DIR/AGENTS.md"
    local tmp="$target.tmp"
    local cfg="$target.cfg"

    filter_agents_tags "$src" "$tmp"
    build_config_table > "$cfg"

    awk -v block="$cfg" '
        /<!-- ai-guardrails:config:begin -->/ {
            print
            while ((getline line < block) > 0) print line
            close(block)
            in_block=1
            next
        }
        /<!-- ai-guardrails:config:end -->/ { in_block=0; print; next }
        !in_block { print }
    ' "$tmp" > "$target"

    rm -f "$tmp" "$cfg"
}

usage() {
    cat <<'EOF'
Usage: init.sh [OPTION]

Initialize this project with the ai-guardrails .agents template and a single
AGENTS.md entry point at the project root.

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
                         clean its .git/info/exclude entry. A generated root
                         AGENTS.md is also removed; a pre-existing one only loses
                         its ai-guardrails section. A versioned .agents is left
                         untouched.
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
        clean_root_agents
        echo "Symlink .agents removed."
    elif [ -d "$CURRENT_DIR/.agents" ] && [ "$IS_TRACKED" == "0" ] && [ -f "$MARKER" ]; then
        rm -rf "$CURRENT_DIR/.agents"
        clean_root_agents
        echo "Local-only .agents removed."
    elif [ -d "$CURRENT_DIR/.agents" ]; then
        if [ "$IS_TRACKED" == "1" ]; then
            echo -e "\033[1;31m$CURRENT_DIR/.agents is a real versioned directory.\033[0m"
            echo "It is tracked in git. Remove it manually (git rm -r .agents) if you no longer need it."
            echo "The root AGENTS.md is also versioned; remove it with git rm AGENTS.md if it was generated."
        else
            echo -e "\033[1;31m$CURRENT_DIR/.agents was not installed by ai-guardrails.\033[0m"
            echo "Remove it manually if you no longer need it."
        fi
    else
        echo "No .agents installation found."
        clean_root_agents
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
    ROOT_MODE=$(sed -n 's/.*"root_agents": *"\([^"]*\)".*/\1/p' "$MARKER" 2>/dev/null)
    if [ -z "$ROOT_MODE" ]; then
        if [ -f "$CURRENT_DIR/AGENTS.md" ] && grep -qF "generated-by: ai-guardrails" "$CURRENT_DIR/AGENTS.md" 2>/dev/null; then
            ROOT_MODE="generated"
        else
            ROOT_MODE="appended"
        fi
    fi

    if [ "$TARGET" == "no" ]; then
        add_git_exclude ".agents"
        if [ "$ROOT_MODE" == "generated" ]; then
            add_git_exclude "AGENTS.md"
            add_git_exclude "/AGENTS.md"
            echo "Switched to local-only. .agents and AGENTS.md are now hidden from git (.git/info/exclude)."
        else
            remove_git_exclude "AGENTS.md"
            remove_git_exclude "/AGENTS.md"
            echo "Switched to local-only. .agents is hidden from git; your AGENTS.md is kept tracked."
        fi
        sed -i 's/"versioned": *"[a-z]*"/"versioned": "no"/' "$MARKER"
        update_agents_git_row "local-only (not committed)"
    else
        remove_git_exclude ".agents"
        remove_git_exclude "/AGENTS.md"
        remove_git_exclude "AGENTS.md"
        sed -i 's/"versioned": *"[a-z]*"/"versioned": "yes"/' "$MARKER"
        update_agents_git_row "versioned"
        echo "Switched to versioned. Run 'git add .agents AGENTS.md' to track them."
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

ROOT_AGENTS_MODE="none"
if [ ! -e "$CURRENT_DIR/AGENTS.md" ]; then
    render_agents "$CURRENT_DIR/AGENTS.md"
    ROOT_AGENTS_MODE="generated"
    echo "  Root AGENTS.md entry point created."
elif grep -qF "generated-by: ai-guardrails" "$CURRENT_DIR/AGENTS.md" 2>/dev/null; then
    ROOT_AGENTS_MODE="generated"
    echo "  Root AGENTS.md already contains the ai-guardrails entry point; left untouched."
elif grep -qF "ai-guardrails:begin" "$CURRENT_DIR/AGENTS.md" 2>/dev/null; then
    ROOT_AGENTS_MODE="appended"
    echo "  Root AGENTS.md already contains the ai-guardrails section; left untouched."
else
    ROOT_AGENTS_MODE="appended"
    {
        printf '\n%s\n' '<!-- ai-guardrails:begin -->'
        printf '\n%s\n' '## AI guardrails'
        printf '\n%s\n' 'This repository uses the ai-guardrails template. Rules, skills and prompts live in `.agents/`.'
        printf '\n%s\n' '- Rules index: [`.agents/rules/README.md`](.agents/rules/README.md)'
        printf '%s\n' '- Skills index: [`.agents/skills/README.md`](.agents/skills/README.md)'
        if [ "$INCLUDE_PROMPTS" == "0" ]; then
            printf '%s\n' '- Prompts index: [`.agents/prompts/README.md`](.agents/prompts/README.md)'
        fi
        printf '\n%s\n' 'Installed configuration:'
        printf '\n%s\n' '<!-- ai-guardrails:config:begin -->'
        build_config_table
        printf '%s\n' '<!-- ai-guardrails:config:end -->'
        printf '\n%s\n' 'Apply the rules and skills from `.agents/` to every step.'
        printf '%s\n' '<!-- ai-guardrails:end -->'
    } >> "$CURRENT_DIR/AGENTS.md"
    echo "  Existing AGENTS.md preserved; ai-guardrails section appended."
fi

cat > "$CURRENT_DIR/.agents/.ai-guardrails-install" <<EOF
{
  "tool": "ai-guardrails",
  "versioned": "$([ "$VERSIONING" == "2" ] && echo no || echo yes)",
  "prompts": "$([ "$INCLUDE_PROMPTS" == "0" ] && echo yes || echo no)",
  "mode": "$MODE",
  "packs": "$PACKS",
  "root_agents": "$ROOT_AGENTS_MODE"
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
            echo ""
            if [ "$ROOT_AGENTS_MODE" == "generated" ]; then
                add_git_exclude "AGENTS.md"
                add_git_exclude "/AGENTS.md"
                echo "Note: .agents and the generated AGENTS.md are local-only. They were"
                echo "added to .git/info/exclude and will not be committed."
            else
                echo "Note: .agents is local-only and was added to .git/info/exclude."
                echo "Your existing AGENTS.md was kept and is NOT hidden from git."
            fi
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
echo "  - Entry point: AGENTS.md (project root)"
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
    echo "Next: open AGENTS.md and start with your first task."
fi