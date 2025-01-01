#!/bin/sh
swayidle timeout 600 'swaylock -C $HOME/.config/swaylock/config.idle' timeout 1000 'systemctl suspend' before-sleep 'swaylock -C $HOME/.config/swaylock/config.lock' lock 'swaylock -C $HOME/.config/swaylock/config.lock'
