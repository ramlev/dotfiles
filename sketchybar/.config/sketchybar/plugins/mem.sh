#!/usr/bin/env bash
# Memory used % (app + wired + compressed, like Activity Monitor) in the bar;
# click for the breakdown, swap, pressure and top processes.
# Colour follows the kernel's memory pressure: yellow = warn, red = critical.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
source "$CONFIG_DIR/plugins/graph.sh"
popup_events

vm="$(vm_stat)"
page="$(printf '%s\n' "$vm" | awk '/page size of/ {print $8}')"
pages() { printf '%s\n' "$vm" | awk -F: -v k="$1" '$1 == k {gsub(/[ .]/, "", $2); print $2}'; }
anon=$(pages "Anonymous pages")
purge=$(pages "Pages purgeable")
wired=$(pages "Pages wired down")
comp=$(pages "Pages occupied by compressor")
file=$(pages "File-backed pages")
total=$(sysctl -n hw.memsize)
[ -z "$anon" ] && exit 0

# All sizes in GB.
gb() { awk -v p="$1" -v s="$page" 'BEGIN { printf "%.1f", p * s / 1073741824 }'; }
app=$(gb $((anon - purge)))
wir=$(gb "$wired")
cmp=$(gb "$comp")
cache=$(gb $((file + purge)))
used=$(awk -v a="$app" -v w="$wir" -v c="$cmp" 'BEGIN { printf "%.1f", a + w + c }')
tot=$(awk -v t="$total" 'BEGIN { printf "%.0f", t / 1073741824 }')
pct=$(awk -v u="$used" -v t="$tot" 'BEGIN { printf "%.0f", u / t * 100 }')

case "$(sysctl -n kern.memorystatus_vm_pressure_level)" in
  4) color=$TN_RED;    pressure="Critical" ;;
  2) color=$TN_YELLOW; pressure="Warning" ;;
  *) color=$TN_COMMENT; pressure="Normal" ;;
esac

sketchybar --set "$NAME" icon.color=$color label="${pct}%"
graph_push mem.graph 230 "$(awk -v p="$pct" 'BEGIN { print p / 100 }')"

popup_open || exit 0

swap="$(sysctl -n vm.swapusage | awk '{print $6}' | sed 's/M$//')"
args=(
  --set mem.used     label="$used / $tot GB"
  --set mem.app      label="$app GB"
  --set mem.wired    label="$wir GB"
  --set mem.comp     label="$cmp GB"
  --set mem.cache    label="$cache GB"
  --set mem.swap     label="$(awk -v s="$swap" 'BEGIN { printf "%.1f GB", s / 1024 }')"
  --set mem.pressure label="$pressure" label.color=$color
)
i=1
while read -r kb name; do
  args+=(--set "mem.top.$i" icon="$(awk -v k="$kb" 'BEGIN { m = k / 1024; if (m >= 1024) printf "%.1fG", m / 1024; else printf "%.0fM", m }')" label="${name:0:22}")
  i=$((i + 1))
done < <(ps -Aceo rss=,comm= -m | head -5)

sketchybar "${args[@]}"
