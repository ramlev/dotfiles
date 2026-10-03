#!/usr/bin/env bash
# Blue pill in AeroSpace's main mode, red with the mode name otherwise.
source "$CONFIG_DIR/colors.sh"

mode="$(aerospace list-modes --current)"
if [ "$mode" = "main" ]; then
  sketchybar --set "$NAME" background.color=$TN_BLUE label.drawing=off \
                           icon.padding_right=12
else
  sketchybar --set "$NAME" background.color=$TN_RED label="$mode" \
                           label.drawing=on icon.padding_right=6
fi
