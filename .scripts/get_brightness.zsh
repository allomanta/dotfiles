#!/bin/zsh
max_brightness=$(</sys/class/backlight/amdgpu_bl2/max_brightness)
inotifywait -q -m -e close_write /sys/class/backlight/amdgpu_bl2/brightness|


while 
  brightness=$(</sys/class/backlight/amdgpu_bl2/brightness)
  percentage=$((brightness * 100 / max_brightness))

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
