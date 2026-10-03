#!/usr/bin/env bash
# Volume % in the bar (muted icon when muted); click for a slider, mute
# toggle and the current output device.
# $INFO carries the new volume on volume_change.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"

# The slider lives in the popup and reports its own clicks.
if [ "$NAME" = "volume.slider" ]; then
  [ "$SENDER" = "mouse.clicked" ] && osascript -e "set volume output volume $PERCENTAGE without output muted"
  exit 0
fi

popup_events

vol="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"
muted="$(osascript -e 'output muted of (get volume settings)')"
case "$vol" in
  [6-9][0-9]|100) icon=󰕾 ;;
  [3-5][0-9])     icon=󰖀 ;;
  [1-9]|[1-2][0-9]) icon=󰕿 ;;
  *)              icon=󰖁 ;;
esac
[ "$muted" = "true" ] && icon=󰖁

sketchybar --set "$NAME" icon="$icon" label="$vol%" \
           --set volume.slider slider.percentage="$vol"

popup_open || exit 0

device="$(system_profiler SPAudioDataType | awk '/^        [^ ].*:$/ {d = $0} /Default Output Device: Yes/ {gsub(/^ +|:$/, "", d); print d; exit}')"
sketchybar --set volume.device label="${device:-Unknown}" \
           --set volume.mute icon="$([ "$muted" = "true" ] && echo 󰕾 || echo 󰖁)" \
                             label="$([ "$muted" = "true" ] && echo Unmute || echo Mute)"
