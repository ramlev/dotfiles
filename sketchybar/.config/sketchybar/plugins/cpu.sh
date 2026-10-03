#!/usr/bin/env bash
# CPU % in the bar; click toggles a popup with a load graph, user/sys/idle,
# load average and the top processes. Yellow above 50%, red above 80%.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
source "$CONFIG_DIR/plugins/graph.sh"
popup_events

# Second sample of `top` is the real 1s delta (the first is since boot).
stats="$(top -l 2 -n 0 -s 1)"
usage="$(printf '%s\n' "$stats" | grep 'CPU usage' | tail -1)"
load="$(printf '%s\n' "$stats" | grep 'Load Avg' | tail -1 | sed 's/Load Avg: //; s/ *$//')"
user="$(printf '%s' "$usage" | awk '{print $3}' | tr -d '%')"
sys="$(printf '%s' "$usage" | awk '{print $5}' | tr -d '%')"
idle="$(printf '%s' "$usage" | awk '{print $7}' | tr -d '%')"
[ -z "$idle" ] && exit 0

pct="$(awk -v i="$idle" 'BEGIN { printf "%.0f", 100 - i }')"

color=$TN_COMMENT
[ "$pct" -ge 50 ] && color=$TN_YELLOW
[ "$pct" -ge 80 ] && color=$TN_RED

sketchybar --set "$NAME" icon.color=$color label="${pct}%"
graph_push cpu.graph 230 "$(awk -v p="$pct" 'BEGIN { print p / 100 }')"

# Only fill in the details while the popup is actually open.
popup_open || exit 0

args=(
  --set cpu.user label="$(printf '%.1f%%' "$user")"
  --set cpu.sys  label="$(printf '%.1f%%' "$sys")"
  --set cpu.idle label="$(printf '%.1f%%' "$idle")"
  --set cpu.load label="$load"
)
i=1
while read -r p name; do
  args+=(--set "cpu.top.$i" icon="$(printf '%.1f%%' "$p")" label="${name:0:22}")
  i=$((i + 1))
done < <(ps -Aceo pcpu=,comm= -r | head -5)

sketchybar "${args[@]}"
