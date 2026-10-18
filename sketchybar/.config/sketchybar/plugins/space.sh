#!/usr/bin/env bash
# Redraws one macOS desktop item: "#I #W" with the focused one in a pill.
# sketchybar hands us $SID (desktop number) and $SELECTED (true when focused).
source "$CONFIG_DIR/colors.sh"

# space_windows_change only reports one desktop at a time, so each item keeps
# its own app list (one per line) between events. The focused desktop also
# records the frontmost app, which only front_app_switched tells us.
CACHE="${TMPDIR:-/tmp}/sketchybar-spaces"
mkdir -p "$CACHE"

case "$SENDER" in
  mouse.clicked)
    # macOS has no API for jumping to a desktop, so walk there with the
    # ctrl+arrow Mission Control shortcuts.
    steps=$((SID - $(cat "$CACHE/selected" 2>/dev/null || echo "$SID")))
    [ "$steps" -eq 0 ] && exit 0
    key=124; [ "$steps" -lt 0 ] && key=123 && steps=$((-steps))
    osascript -e 'tell application "System Events"' \
              -e "repeat $steps times" \
              -e "key code $key using control down" \
              -e 'delay 0.3' \
              -e 'end repeat' \
              -e 'end tell'
    exit 0
    ;;
  space_windows_change)
    [ "$(printf '%s\n' "$INFO" | sed -n 's/.*"space": *\([0-9]*\).*/\1/p')" = "$SID" ] || exit 0
    printf '%s\n' "$INFO" | sed -n 's/^[[:space:]]*"\(.*\)": *[0-9]*,*$/\1/p' \
      | grep -v '^space$' > "$CACHE/$SID"
    ;;
esac

apps="$(cat "$CACHE/$SID" 2>/dev/null)"
count="$(printf '%s' "$apps" | grep -c .)"
name="$(printf '%s\n' "$apps" | head -n1)"

args=()
if [ "$SELECTED" = true ]; then
  echo "$SID" > "$CACHE/selected"
  # Prefer the frontmost app when it has a window on this desktop.
  [ "$SENDER" = front_app_switched ] && printf '%s\n' "$INFO" > "$CACHE/front"
  front="$(cat "$CACHE/front" 2>/dev/null)"
  printf '%s\n' "$apps" | grep -qxF -- "$front" && name="$front"
  args+=(background.drawing=on icon.color=$TN_CYAN label.color=$TN_FG)
else
  args+=(background.drawing=off icon.color=$TN_COMMENT label.color=$TN_FG_DARK)
fi

name="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
[ "$count" -gt 1 ] && name="$name +$((count - 1))"

if [ -n "$name" ]; then
  args+=(label="$name" label.drawing=on icon.padding_right=6)
else
  # Empty desktop: just the number, dimmed unless focused.
  args+=(label.drawing=off icon.padding_right=10)
  [ "$SELECTED" != true ] && args+=(icon.color=$TN_BLACK)
fi

sketchybar --set "$NAME" "${args[@]}"
