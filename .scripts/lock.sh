#!/bin/sh
# Usage: lock.sh          lock and return once locked (for swayidle before-sleep)
#        lock.sh --wait   lock and return only after unlock (for Stasis)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

CFG="$HOME/.config/swaylock/config.lock"
SHOT="$XDG_RUNTIME_DIR/lockscreen.png"
WAIT=0; [ "$1" = "--wait" ] && WAIT=1

if pidof -q swaylock; then
    [ $WAIT = 1 ] && while pidof -q swaylock; do sleep 1; done
    exit 0
fi

if grim -t png -l 0 "$SHOT" 2>/dev/null; then
    IMG="$SHOT"
else
    IMG=$(wpaperctl get-wallpaper eDP-1 2>/dev/null)
    [ -f "$IMG" ] || IMG=$(find "$HOME/Pictures/Wallpapers" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
fi
set -- -C "$CFG"
[ -f "$IMG" ] && set -- "$@" --scaling fill -i "$IMG"

if [ $WAIT = 1 ]; then
    (sleep 5; rm -f "$SHOT") &
    swaylock "$@"
else
    swaylock -f "$@"
    rm -f "$SHOT"
fi
