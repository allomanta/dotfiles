#!/bin/env python3
import sh

name = "disconnected"
state = ""
signal = -90


def get_icon_from_strength():
    if signal <= -90:
        return '<span color="#ed8796">󰤮</span>'
    elif signal <= -80:
        return '<span color="#ee99a0">󰤯</span>'
    elif signal <= -60:
        return '<span color="#f5a97f">󰤟</span>'
    elif signal <= -50:
        return '<span color="#eed49f">󰤢</span>'
    elif signal <= -40:
        return '<span color="#a6da95">󰤥</span>'
    else:
        return '<span color="#a6da95">󰤨</span>'


for line in (l.split() for l in sh.iwctl.station.wlan0.show().splitlines()):
    if len(line) < 2:
        continue
    if line[0] == "Connected":
        name = " ".join(line[2:])
    elif line[0] == "State":
        state = line[1]
    elif line[0] == "RSSI":
        signal = int(line[1])

if state == "connected":
    name = f'<span color="#a6da95">{name}</span>'
    icon = get_icon_from_strength()
else:
    name = f'<span color="#ed8796">{name}</span>'
    icon = '<span color="#ed8796">󰤮</span>'

print(name, icon)
