#!/usr/bin/env bash
# Current temperature in the bar; click for conditions and a four day
# forecast. Location comes from the public IP (ipinfo.io, cached for a day),
# weather from open-meteo.com (cached for 10 min so clicks don't refetch).
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/popup.sh"
popup_events

age() { echo $(( $(date +%s) - $(stat -f %m "$1" 2>/dev/null || echo 0) )); }

loc_cache="${TMPDIR:-/tmp}/sketchybar_weather_loc"
if [ "$(age "$loc_cache")" -ge 86400 ]; then
  loc="$(curl -s --max-time 5 https://ipinfo.io/json | jq -r 'select(.loc) | "\(.loc)\t\(.city // "")"')"
  [ -n "$loc" ] && printf '%s\n' "$loc" > "$loc_cache"
fi
IFS=$'\t' read -r latlon city 2>/dev/null < "$loc_cache"
[ -z "$latlon" ] && exit 0

cache="${TMPDIR:-/tmp}/sketchybar_weather.json"
if [ "$(age "$cache")" -ge 600 ]; then
  json="$(curl -s --max-time 5 "https://api.open-meteo.com/v1/forecast?latitude=${latlon%,*}&longitude=${latlon#*,}&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&wind_speed_unit=ms&timezone=auto&forecast_days=4")"
  printf '%s' "$json" | jq -e '.current and .daily' > /dev/null 2>&1 && printf '%s' "$json" > "$cache"
fi
[ -s "$cache" ] || exit 0

# WMO weather code (+ is_day) -> icon / description
wmo_icon() {
  case "$1" in
    0|1)            [ "${2:-1}" = 1 ] && echo 󰖙 || echo 󰖔 ;;
    2)              [ "${2:-1}" = 1 ] && echo 󰖕 || echo 󰼱 ;;
    3)              echo 󰖐 ;;
    45|48)          echo 󰖑 ;;
    65|82)          echo 󰖖 ;;
    5?|61|63|80|81) echo 󰖗 ;;
    66|67)          echo 󰙿 ;;
    7?|85|86)       echo 󰖘 ;;
    95)             echo 󰖓 ;;
    96|99)          echo 󰙾 ;;
    *)              echo 󰖐 ;;
  esac
}
wmo_text() {
  case "$1" in
    0)        echo "Clear" ;;
    1)        echo "Mostly clear" ;;
    2)        echo "Partly cloudy" ;;
    3)        echo "Overcast" ;;
    45|48)    echo "Fog" ;;
    5?)       echo "Drizzle" ;;
    61|63)    echo "Rain" ;;
    65)       echo "Heavy rain" ;;
    66|67)    echo "Freezing rain" ;;
    7?)       echo "Snow" ;;
    80|81)    echo "Showers" ;;
    82)       echo "Heavy showers" ;;
    85|86)    echo "Snow showers" ;;
    95|96|99) echo "Thunderstorm" ;;
    *)        echo "–" ;;
  esac
}

IFS=$'\t' read -r temp feels hum wind code is_day < <(jq -r '.current |
  [(.temperature_2m | round), (.apparent_temperature | round), .relative_humidity_2m,
   (.wind_speed_10m | round), .weather_code, .is_day] | @tsv' "$cache")

sketchybar --set "$NAME" icon="$(wmo_icon "$code" "$is_day")" label="${temp}°"

popup_open || exit 0

args=(--set weather.header   icon="${city:-Weather}" label="$(wmo_text "$code")"
      --set weather.feels    label="${feels}°"
      --set weather.wind     label="$wind m/s"
      --set weather.humidity label="$hum%")
d=0
while IFS=$'\t' read -r c lo hi rain; do
  case "$d" in
    0) name="Today" ;;
    1) name="Tomorrow" ;;
    *) name="$(date -v+"$d"d '+%A')" ;;
  esac
  label="$(wmo_icon "$c")  $(printf '%3s° /%3s°' "$lo" "$hi")"
  [ "$rain" != "0" ] && label="$label  $rain mm"
  args+=(--set "weather.d$d" icon="$name" label="$label")
  d=$((d + 1))
done < <(jq -r '.daily | range(0; .time | length) as $i |
  [.weather_code[$i], (.temperature_2m_min[$i] | round), (.temperature_2m_max[$i] | round),
   (.precipitation_sum[$i] * 10 | round / 10)] | @tsv' "$cache")

sketchybar "${args[@]}"
