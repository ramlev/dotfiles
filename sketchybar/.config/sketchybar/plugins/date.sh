#!/usr/bin/env bash
# Click for the calendar events of today and the three days after, each with
# a dot in its calendar's colour (plugins/events.js).
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
popup_events

lower() { tr '[:upper:]' '[:lower:]'; }

sketchybar --set "$NAME" label="$(date '+%a %d %b' | lower)"

popup_open || exit 0

# Keep in sync with the date.dN / date.dN.M slots in sketchybarrc.
DAYS=4
SLOTS=6

if ! events="$(osascript -l JavaScript "$CONFIG_DIR/plugins/events.js" "$DAYS" 2>/dev/null)"; then
  events=""
  failed=1
fi

args=()
for ((d = 0; d < DAYS; d++)); do
  day="$(date -v+"$d"d '+%Y-%m-%d')"
  case "$d" in
    0) name="Today" ;;
    1) name="Tomorrow" ;;
    *) name="$(date -v+"$d"d '+%A')" ;;
  esac
  when="$(date -v+"$d"d '+%d %b' | lower)"

  rows=()
  while IFS= read -r line; do
    [ -n "$line" ] && rows+=("$line")
  done < <(printf '%s\n' "$events" | grep "^$day"$'\t')
  n=${#rows[@]}

  if [ -n "$failed" ]; then
    when="$when · calendar unavailable"
  elif [ "$n" -eq 0 ]; then
    when="$when · no events"
  fi
  args+=(--set "date.d$d" icon="$name" label="$when")

  for ((i = 1; i <= SLOTS; i++)); do
    if [ "$i" -gt "$n" ]; then
      args+=(--set "date.d$d.$i" drawing=off)
    elif [ "$i" -eq "$SLOTS" ] && [ "$n" -gt "$SLOTS" ]; then
      args+=(--set "date.d$d.$i" drawing=on icon.color=$TN_GUTTER
             label="+$((n - SLOTS + 1)) more" label.color=$TN_COMMENT)
    else
      IFS=$'\t' read -r _ time color text <<< "${rows[$((i - 1))]}"
      args+=(--set "date.d$d.$i" drawing=on icon.color="$color"
             label="$time  $text" label.color=$TN_FG)
    fi
  done
done

sketchybar "${args[@]}"
