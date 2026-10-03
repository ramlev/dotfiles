#!/usr/bin/env bash
# Open btop in a new iTerm2 window (closes again when btop quits).
osascript <<'OSA'
tell application "iTerm2"
  activate
  create window with default profile command "/opt/homebrew/bin/btop"
end tell
OSA
