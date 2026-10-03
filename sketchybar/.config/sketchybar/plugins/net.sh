#!/usr/bin/env bash
# Download/upload rate of the default interface in the bar; click for the
# interface, IPs and VPN. The previous byte counters live in a state
# file so each run can compute the rate since the last one.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
popup_events

iface="$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')"
if [ -z "$iface" ]; then
  sketchybar --set "$NAME" icon=󰖪 icon.color=$TN_RED label="offline"
  exit 0
fi

port="$(networksetup -listallhardwareports | awk -v d="$iface" '/Hardware Port/ {p = substr($0, 16)} $2 == d {print p}')"
case "$port" in
  Wi-Fi) icon=󰖩 ;;
  "")    icon=󰒍 ;;  # VPN or tunnel as default route
  *)     icon=󰈀 ;;
esac

# Ibytes / Obytes from the interface's link row.
read -r rx tx < <(netstat -ibn -I "$iface" | awk '$3 ~ /^<Link/ {print $7, $10; exit}')
now="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"

state="${TMPDIR:-/tmp}/sketchybar_net"
read -r p_iface p_rx p_tx p_now 2>/dev/null < "$state"
printf '%s %s %s %s\n' "$iface" "$rx" "$tx" "$now" > "$state"

rate() {  # bytes delta, seconds -> 1.2M / 80K / 0K
  awk -v b="$1" -v s="$2" 'BEGIN {
    r = (s > 0 && b > 0) ? b / s : 0
    if (r >= 1048576) printf "%.1fM", r / 1048576
    else              printf "%.0fK", r / 1024
  }'
}
if [ "$p_iface" = "$iface" ] && [ -n "$p_now" ]; then
  dt="$(awk -v a="$now" -v b="$p_now" 'BEGIN { print a - b }')"
  down="$(rate $((rx - p_rx)) "$dt")"
  up="$(rate $((tx - p_tx)) "$dt")"
else
  down=0K up=0K
fi

sketchybar --set "$NAME" icon="$icon" icon.color=$TN_COMMENT label="↓$down ↑$up"

popup_open || exit 0

# A utun interface with an IPv4 address is a VPN (the built-in utuns have none).
vpn="$(ifconfig | awk '/^[a-z]/ {i = ($1 ~ /^utun/) ? $1 : ""} /inet / && i {sub(/:$/, "", i); print $2 " (" i ")"; exit}')"

# External IP from ipify, cached for 5 min per interface + VPN combination so
# the popup's 2s refresh doesn't hit the service every tick.
ext_cache="${TMPDIR:-/tmp}/sketchybar_extip"
vpn_key="${vpn:-novpn}"
key="$iface/${vpn_key// /}"
read -r c_time c_key c_ip 2>/dev/null < "$ext_cache"
if [ "$c_key" = "$key" ] && [ $(( $(date +%s) - ${c_time:-0} )) -lt 300 ] && [ -n "$c_ip" ]; then
  ext="$c_ip"
else
  ext="$(curl -s --max-time 3 https://api.ipify.org)"
  [ -n "$ext" ] && printf '%s %s %s\n' "$(date +%s)" "$key" "$ext" > "$ext_cache"
fi

sketchybar --set net.iface  label="${port:-Tunnel} ($iface)" \
           --set net.ip     label="$(ipconfig getifaddr "$iface" || echo -)" \
           --set net.public label="${ext:-–}" \
           --set net.vpn    label="${vpn:-off}" \
                            label.color=$([ -n "$vpn" ] && echo $TN_GREEN || echo $TN_COMMENT) \
           --set net.down   label="$down/s" \
           --set net.up     label="$up/s"
