#!/usr/bin/env bash
# Redraws every workspace item: "#I #W" with the focused one in a pill.
source "$CONFIG_DIR/colors.sh"

focused="${FOCUSED:-$(aerospace list-workspaces --focused)}"
focused_app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
windows="$(aerospace list-windows --all --format '%{workspace}|%{app-name}')"

args=()
for ws in $(aerospace list-workspaces --all); do
  apps="$(printf '%s\n' "$windows" | awk -F'|' -v ws="$ws" '$1 == ws && !seen[$2]++ { print $2 }')"
  count="$(printf '%s' "$apps" | grep -c .)"

  if [ "$ws" = "$focused" ] && [ -n "$focused_app" ]; then
    name="$focused_app"
  else
    name="$(printf '%s\n' "$apps" | head -n1)"
  fi
  name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
  [ "$count" -gt 1 ] && name="$name +$((count - 1))"

  if [ "$ws" = "$focused" ]; then
    args+=(--set "space.$ws" background.drawing=on
           icon.color=$TN_CYAN label.color=$TN_FG)
  else
    args+=(--set "space.$ws" background.drawing=off
           icon.color=$TN_COMMENT label.color=$TN_FG_DARK)
  fi

  if [ -n "$name" ]; then
    args+=(label="$name" label.drawing=on icon.padding_right=6)
  else
    # Empty workspace: just the number, dimmed unless focused.
    args+=(label.drawing=off icon.padding_right=10)
    [ "$ws" != "$focused" ] && args+=(icon.color=$TN_BLACK)
  fi
done

sketchybar "${args[@]}"
