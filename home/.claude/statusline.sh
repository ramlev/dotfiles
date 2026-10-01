#!/usr/bin/env bash
# Claude Code status line.
# Reads the session JSON on stdin and prints a single line:
#   model·effort │ dir  branch ±dirty ↑↓ │ ctx bar % │ 5h % · 7d % │ $cost · time │ +add -del
# No network calls, no credentials — everything comes from stdin, git and settings.json.

set -f
input=$(cat)
[ -z "$input" ] && { printf 'Claude'; exit 0; }

# ---- colors -----------------------------------------------------------------
esc=$'\033'
c_reset="${esc}[0m"
c_dim="${esc}[2m"
c_bold="${esc}[1m"
c_blue="${esc}[38;2;97;175;239m"
c_cyan="${esc}[38;2;86;182;194m"
c_green="${esc}[38;2;152;195;121m"
c_yellow="${esc}[38;2;229;192;123m"
c_orange="${esc}[38;2;209;154;102m"
c_red="${esc}[38;2;224;108;117m"
c_magenta="${esc}[38;2;198;120;221m"
c_grey="${esc}[38;2;120;125;135m"

sep=" ${c_grey}│${c_reset} "

# Pick a color by percentage (green → yellow → orange → red).
pct_color() {
    local p=${1:-0}
    if   [ "$p" -ge 85 ]; then printf '%s' "$c_red"
    elif [ "$p" -ge 65 ]; then printf '%s' "$c_orange"
    elif [ "$p" -ge 40 ]; then printf '%s' "$c_yellow"
    else printf '%s' "$c_green"
    fi
}

# 10-cell bar for a percentage.
bar() {
    local p=${1:-0} width=10 filled i out=""
    [ "$p" -gt 100 ] && p=100
    filled=$(( (p * width + 50) / 100 ))
    for (( i = 0; i < width; i++ )); do
        if [ "$i" -lt "$filled" ]; then out+="━"; else out+="${c_grey}─"; fi
    done
    printf '%s' "$out"
}

human_tokens() {
    local n=${1:-0}
    if   [ "$n" -ge 1000000 ]; then LC_NUMERIC=C awk -v n="$n" 'BEGIN{printf "%.1fM", n/1000000}'
    elif [ "$n" -ge 1000 ];    then printf '%dk' $(( n / 1000 ))
    else printf '%d' "$n"
    fi
}

human_duration() {
    local s=$(( ${1:-0} / 1000 ))
    if   [ "$s" -ge 3600 ]; then printf '%dh%02dm' $(( s / 3600 )) $(( s % 3600 / 60 ))
    elif [ "$s" -ge 60 ];   then printf '%dm' $(( s / 60 ))
    else printf '%ds' "$s"
    fi
}

# Reset time: accepts epoch seconds or ISO 8601. Prints HH:MM today, otherwise "Mon HH:MM".
fmt_reset() {
    local v=$1 epoch now
    [ -z "$v" ] && return
    if [[ "$v" =~ ^[0-9]+$ ]]; then
        epoch=$v
    else
        local s=${v%%.*}; s=${s%Z}; s=${s%+00:00}
        epoch=$(TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%S' "$s" +%s 2>/dev/null \
            || date -d "$v" +%s 2>/dev/null) || return
    fi
    now=$(date +%s)
    if [ $(( epoch - now )) -lt 86400 ]; then
        date -r "$epoch" +%H:%M 2>/dev/null || date -d "@$epoch" +%H:%M
    else
        date -r "$epoch" '+%a %H:%M' 2>/dev/null || date -d "@$epoch" '+%a %H:%M'
    fi
}

# ---- parse input (one jq call) ---------------------------------------------
eval "$(jq -r '
    def n: (. // 0) | floor;
    @sh "model=\(.model.display_name // "Claude")",
    @sh "cwd=\(.workspace.current_dir // .cwd // "")",
    @sh "project_dir=\(.workspace.project_dir // "")",
    @sh "ctx_size=\(.context_window.context_window_size | n)",
    @sh "ctx_pct=\(.context_window.used_percentage // -1 | floor)",
    @sh "ctx_used=\((.context_window.current_usage // {}) | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)))",
    @sh "cost=\(.cost.total_cost_usd // 0)",
    @sh "duration_ms=\(.cost.total_duration_ms | n)",
    @sh "lines_add=\(.cost.total_lines_added | n)",
    @sh "lines_del=\(.cost.total_lines_removed | n)",
    @sh "rl5_pct=\(.rate_limits.five_hour.used_percentage // .rate_limits.five_hour.utilization // "" | if . == "" then "" else floor end)",
    @sh "rl5_reset=\(.rate_limits.five_hour.resets_at // "")",
    @sh "rl7_pct=\(.rate_limits.seven_day.used_percentage // .rate_limits.seven_day.utilization // "" | if . == "" then "" else floor end)",
    @sh "rl7_reset=\(.rate_limits.seven_day.resets_at // "")",
    @sh "output_style=\(.output_style.name // "")",
    @sh "vim_mode=\(.vim.mode // "")"
' <<<"$input" 2>/dev/null)"

# ---- model + effort ---------------------------------------------------------
effort=${CLAUDE_CODE_EFFORT_LEVEL:-}
if [ -z "$effort" ]; then
    effort=$(jq -r '.effortLevel // empty' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" 2>/dev/null)
fi

out="${c_bold}${c_blue}${model}${c_reset}"
if [ -n "$effort" ]; then
    case "$effort" in
        low)       e_color=$c_grey ;;
        medium)    e_color=$c_yellow; effort=med ;;
        high)      e_color=$c_orange ;;
        xhigh|max) e_color=$c_red ;;
        *)         e_color=$c_grey ;;
    esac
    out+="${c_grey}·${c_reset}${e_color}${effort}${c_reset}"
fi
[ -n "$output_style" ] && [ "$output_style" != "default" ] && out+=" ${c_magenta}[${output_style}]${c_reset}"
[ -n "$vim_mode" ] && out+=" ${c_grey}${vim_mode}${c_reset}"

# ---- directory + git --------------------------------------------------------
if [ -n "$cwd" ]; then
    if [ -n "$project_dir" ] && [ "$cwd" != "$project_dir" ] && [[ "$cwd" == "$project_dir"/* ]]; then
        dir="${project_dir##*/}/${cwd#"$project_dir"/}"
    elif [ "$cwd" = "$HOME" ]; then
        dir="~"
    else
        dir="${cwd##*/}"
    fi
    out+="${sep}${c_cyan}${dir}${c_reset}"

    # porcelain v2 gives branch, ahead/behind and file states in one call
    if git_status=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
        branch="" ahead=0 behind=0 staged=0 modified=0 untracked=0
        while IFS= read -r line; do
            case "$line" in
                "# branch.head "*) branch=${line#\# branch.head } ;;
                "# branch.oid "*)  oid=${line#\# branch.oid } ;;
                "# branch.ab "*)
                    read -r _ _ a b <<<"$line"
                    ahead=${a#+}; behind=${b#-} ;;
                "1 "*|"2 "*)
                    xy=${line:2:2}
                    [ "${xy:0:1}" != "." ] && staged=$(( staged + 1 ))
                    [ "${xy:1:1}" != "." ] && modified=$(( modified + 1 )) ;;
                "u "*) modified=$(( modified + 1 )) ;;
                "? "*) untracked=$(( untracked + 1 )) ;;
            esac
        done <<<"$git_status"
        [ "$branch" = "(detached)" ] && branch="@${oid:0:7}"

        out+=" ${c_grey}on${c_reset} ${c_magenta}${branch}${c_reset}"
        flags=""
        [ "$staged" -gt 0 ]    && flags+="${c_green}+${staged}${c_reset}"
        [ "$modified" -gt 0 ]  && flags+="${c_yellow}~${modified}${c_reset}"
        [ "$untracked" -gt 0 ] && flags+="${c_grey}?${untracked}${c_reset}"
        [ "$ahead" -gt 0 ]     && flags+="${c_cyan}↑${ahead}${c_reset}"
        [ "$behind" -gt 0 ]    && flags+="${c_red}↓${behind}${c_reset}"
        [ -n "$flags" ] && out+=" ${flags}"
    fi
fi

# ---- context window ---------------------------------------------------------
if [ "$ctx_pct" -lt 0 ] && [ "$ctx_size" -gt 0 ]; then
    ctx_pct=$(( ctx_used * 100 / ctx_size ))
fi
[ "$ctx_pct" -lt 0 ] && ctx_pct=0
cc=$(pct_color "$ctx_pct")
out+="${sep}${cc}$(bar "$ctx_pct")${c_reset} ${cc}${ctx_pct}%${c_reset}"
if [ "$ctx_used" -gt 0 ] && [ "$ctx_size" -gt 0 ]; then
    out+=" ${c_grey}$(human_tokens "$ctx_used")/$(human_tokens "$ctx_size")${c_reset}"
fi

# ---- plan rate limits (only present for subscription sessions) --------------
if [ -n "$rl5_pct" ] || [ -n "$rl7_pct" ]; then
    rl=""
    if [ -n "$rl5_pct" ]; then
        rl+="${c_grey}5h${c_reset} $(pct_color "$rl5_pct")${rl5_pct}%${c_reset}"
        r=$(fmt_reset "$rl5_reset"); [ -n "$r" ] && rl+=" ${c_grey}↻${r}${c_reset}"
    fi
    if [ -n "$rl7_pct" ]; then
        [ -n "$rl" ] && rl+=" ${c_grey}·${c_reset} "
        rl+="${c_grey}7d${c_reset} $(pct_color "$rl7_pct")${rl7_pct}%${c_reset}"
        r=$(fmt_reset "$rl7_reset"); [ -n "$r" ] && rl+=" ${c_grey}↻${r}${c_reset}"
    fi
    out+="${sep}${rl}"
fi

# ---- session cost, duration, lines changed ---------------------------------
session=""
cost_fmt=$(LC_NUMERIC=C awk -v c="$cost" 'BEGIN{ if (c > 0) printf "$%.2f", c }')
[ -n "$cost_fmt" ] && session+="${c_green}${cost_fmt}${c_reset}"
if [ "$duration_ms" -gt 0 ]; then
    [ -n "$session" ] && session+=" ${c_grey}·${c_reset} "
    session+="${c_grey}$(human_duration "$duration_ms")${c_reset}"
fi
if [ "$lines_add" -gt 0 ] || [ "$lines_del" -gt 0 ]; then
    [ -n "$session" ] && session+=" "
    session+="${c_green}+${lines_add}${c_reset} ${c_red}-${lines_del}${c_reset}"
fi
[ -n "$session" ] && out+="${sep}${session}"

printf '%s' "$out"
