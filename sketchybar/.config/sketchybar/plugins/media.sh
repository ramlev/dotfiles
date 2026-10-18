#!/usr/bin/env bash
# Spotify's current track in the bar, hidden while nothing is loaded or
# Spotify isn't running; click for album and transport controls.
# Runs on Spotify's own playback notification (spotify_change), so no polling.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
popup_events

# "playing<TAB>title<TAB>artist<TAB>album", empty when there is nothing to
# show. The running check sits outside the tell block so this never launches
# Spotify.
info="$(osascript 2>/dev/null <<'EOF'
if application "Spotify" is running then
  tell application "Spotify"
    if player state is stopped then return ""
    return (player state as text) & tab & (name of current track) & tab & ¬
           (artist of current track) & tab & (album of current track)
  end tell
end if
EOF
)"
IFS=$'\t' read -r state track artist album <<< "$info"

if [ -z "$track" ]; then
  sketchybar --set "$NAME" drawing=off popup.drawing=off
  exit 0
fi

if [ "$state" = "playing" ]; then
  color=$TN_GREEN toggle_icon=󰏤 toggle_label="Pause"
else
  color=$TN_COMMENT toggle_icon=󰐊 toggle_label="Play"
fi

sketchybar --set "$NAME" drawing=on icon.color=$color label="${artist:+$artist – }$track" \
           --set media.track  icon="$track" label="${artist:-–}" \
           --set media.album  label="${album:-–}" \
           --set media.toggle icon="$toggle_icon" label="$toggle_label"
