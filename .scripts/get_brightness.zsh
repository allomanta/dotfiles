#!/bin/zsh
inotifywait -q -m -e close_write /sys/class/backlight/intel_backlight/brightness |

while 
  brightness=$(</sys/class/backlight/intel_backlight/brightness)
  percentage=$((brightness / 960))

  if [[ $1 ]]; then
    echo $percentage
  else
    icon=""

    if (( $percentage <= 15 )); then
      icon=""
    elif (( $percentage <= 30 )); then
      icon=""
    elif (( $percentage <= 40 )); then
      icon=""
    elif (( $percentage <= 50 )); then
      icon=""
    elif (( $percentage <= 60 )); then
      icon=""
    elif (( $percentage <= 70 )); then
      icon=""
    elif (( $percentage <= 80 )); then
      icon=""
    elif (( $percentage <= 90 )); then
      icon=""
    fi

    echo ${(l:3:: :)percentage}% $icon

  fi

  read events; do :;
done
