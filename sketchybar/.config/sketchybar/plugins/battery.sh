#!/usr/bin/env bash
# Muted like the rest; yellow below 30%, red below 15% (tmux's bell/activity dots).
# Click for status, time remaining, health, cycle count and charger.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
popup_events

info="$(pmset -g batt)"
pct="$(printf '%s' "$info" | grep -Eo '[0-9]+%' | tr -d '%')"
[ -z "$pct" ] && exit 0

case "$pct" in
  100|9[0-9]) icon=󰁹 ;;
  [7-8][0-9]) icon=󰂁 ;;
  [5-6][0-9]) icon=󰁿 ;;
  [3-4][0-9]) icon=󰁽 ;;
  [1-2][0-9]) icon=󰁻 ;;
  *)          icon=󰂎 ;;
esac
printf '%s' "$info" | grep -q 'AC Power' && icon=󰂄

color=$TN_COMMENT
[ "$pct" -lt 30 ] && color=$TN_YELLOW
[ "$pct" -lt 15 ] && color=$TN_RED

sketchybar --set "$NAME" icon="$icon" icon.color=$color label="$pct%"

popup_open || exit 0

# pmset line: "40%; discharging; 3:50 remaining present: true"
status="$(printf '%s' "$info" | awk -F'; ' '/InternalBattery/ {print $2}')"
remaining="$(printf '%s' "$info" | grep -Eo '[0-9]+:[0-9]+ remaining' | cut -d' ' -f1)"
case "$status" in
  discharging) remaining="${remaining:+$remaining left}" ;;
  charging)    remaining="${remaining:+$remaining to full}" ;;
  *)           remaining="" ;;
esac

ioreg="$(ioreg -rn AppleSmartBattery)"
key() { printf '%s' "$ioreg" | grep -Eo "\"$1\"=[0-9]+" | head -1 | cut -d= -f2; }
cycles="$(printf '%s' "$ioreg" | awk -F' = ' '/"CycleCount" =/ {print $2; exit}')"
health="$(awk -v n="$(key NominalChargeCapacity)" -v d="$(key DesignCapacity)" \
  'BEGIN { if (d > 0) printf "%.0f%%", n / d * 100; else print "-" }')"
watts="$(key Watts)"
charger="none"
printf '%s' "$info" | grep -q 'AC Power' && charger="${watts:+${watts}W }connected"

sketchybar --set battery.status    label="$(printf '%s' "${status:-unknown}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')" \
           --set battery.remaining label="${remaining:-–}" \
           --set battery.health    label="$health" \
           --set battery.cycles    label="${cycles:-–}" \
           --set battery.charger   label="$charger"
