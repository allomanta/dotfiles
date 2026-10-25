#!/bin/zsh
dev=( /sys/class/backlight/amdgpu_bl*(N[1]) )
[[ -n $dev ]] || dev=( /sys/class/backlight/*(N[1]) )
[[ -n $dev ]] || { echo "no backlight device found" >&2; exit 1; }

max_brightness=$(<$dev/max_brightness)
inotifywait -q -m -e close_write $dev/brightness|


while 
  brightness=$(<$dev/brightness)
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
