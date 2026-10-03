#!/usr/bin/env bash
# Shared popup behaviour, sourced by item plugins:
# click toggles the popup, moving the mouse away closes it.
popup_events() {
  case "$SENDER" in
    mouse.clicked)       sketchybar --set "$NAME" popup.drawing=toggle ;;
    mouse.exited.global) sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
  esac
}

popup_open() {
  [ "$(sketchybar --query "$NAME" | jq -r '.popup.drawing')" = "on" ]
}
