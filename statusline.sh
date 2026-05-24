#!/usr/bin/env bash

raw=$(cat)

cwd=""
model_name=""
thinking_enabled="false"
current_tokens=""
max_tokens=200000
session_cost=""
five_hour_pct=""
seven_day_pct=""

if [ -n "$raw" ] && command -v jq &>/dev/null; then
    cwd=$(echo "$raw" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
    model_name=$(echo "$raw" | jq -r '.model.display_name // empty' 2>/dev/null)
    thinking_enabled=$(echo "$raw" | jq -r 'if .thinking.enabled == true then "true" else "false" end' 2>/dev/null)
    session_cost=$(echo "$raw" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
    current_tokens=$(echo "$raw" | jq -r 'if .context_window.total_input_tokens then (.context_window.total_input_tokens | floor | tostring) else empty end' 2>/dev/null)
    max_tokens=$(echo "$raw" | jq -r '(.context_window.context_window_size // 200000) | floor' 2>/dev/null)
    five_hour_pct=$(echo "$raw" | jq -r 'if .rate_limits.five_hour.used_percentage then (.rate_limits.five_hour.used_percentage | floor | tostring) else empty end' 2>/dev/null)
    seven_day_pct=$(echo "$raw" | jq -r 'if .rate_limits.seven_day.used_percentage then (.rate_limits.seven_day.used_percentage | floor | tostring) else empty end' 2>/dev/null)
fi

[ -z "$cwd" ] && cwd=$(pwd)

branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

format_tokens() {
    local n=$1
    [[ ! "$n" =~ ^[0-9]+$ ]] && echo "$n" && return
    if [ "$n" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fM\", $n/1000000}"
    elif [ "$n" -ge 1000 ]; then
        awk "BEGIN {printf \"%.1fK\", $n/1000}"
    else
        echo "$n"
    fi
}

format_bar() {
    local pct=$1
    local filled=$(( pct / 10 ))
    [ "$filled" -gt 10 ] && filled=10
    local empty=$(( 10 - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}▰"; done
    for ((i=0; i<empty; i++)); do bar="${bar}▱"; done
    echo "$bar"
}

join_by() {
    local sep="$1"; shift
    local result=""
    for item in "$@"; do
        [ -z "$result" ] && result="$item" || result="${result}${sep}${item}"
    done
    echo "$result"
}

parts=()

[ -n "$cwd" ] && parts+=("📁 $(basename "$cwd")")
[ -n "$branch" ] && parts+=("🌿 $branch")

if [ -n "$model_name" ]; then
    model_part="🤖 $model_name"
    [ "$thinking_enabled" = "true" ] && model_part="$model_part 🧠"
    cur_str="-"
    [ -n "$current_tokens" ] && cur_str=$(format_tokens "$current_tokens")
    max_str=$(format_tokens "$max_tokens")
    parts+=("$model_part ($cur_str/$max_str)")
fi

rate_parts=()
[ -n "$five_hour_pct" ] && rate_parts+=("📊 5h (${five_hour_pct}%) $(format_bar "$five_hour_pct")")
[ -n "$seven_day_pct" ] && rate_parts+=("📊 1w (${seven_day_pct}%) $(format_bar "$seven_day_pct")")

if [ "${#rate_parts[@]}" -gt 0 ]; then
    rate_line=$(join_by "  " "${rate_parts[@]}")
    if [ -n "$five_hour_pct" ] && [ "$five_hour_pct" -ge 100 ] 2>/dev/null; then
        cost_str=""
        [ -n "$session_cost" ] && cost_str=" \$$(printf '%.2f' "$session_cost")"
        rate_line="💰${cost_str}  ${rate_line}"
    fi
    parts+=("$rate_line")
fi

[ "${#parts[@]}" -gt 0 ] && echo "$(join_by ' | ' "${parts[@]}")"
