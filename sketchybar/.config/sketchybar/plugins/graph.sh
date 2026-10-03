#!/usr/bin/env bash
# sketchybar graphs always draw the newest value at the left edge. To scroll
# right-to-left instead, keep our own history and re-push the whole window
# each tick, newest first, so the oldest value is drawn at the left.
# graph_push <graph item> <width> <value 0..1>
graph_push() {
  local hist="${TMPDIR:-/tmp}/sketchybar_graph_$1"
  local values
  values="$( { cat "$hist" 2>/dev/null; echo "$3"; } | tail -n "$2")"
  printf '%s\n' "$values" > "$hist"
  # Pad with zeros so the whole width is overwritten, then reverse.
  sketchybar --push "$1" $( { yes 0 | head -n $(( $2 - $(printf '%s\n' "$values" | wc -l) )); printf '%s\n' "$values"; } | tail -r)
}
