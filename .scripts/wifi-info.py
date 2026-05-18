#!/usr/bin/env python3
import subprocess
import time

IFACE = "wlan0"


def icon(signal):
    if signal <= -90:
        return '<span color="#ed8796">󰤮</span>'
    if signal <= -80:
        return '<span color="#ee99a0">󰤯</span>'
    if signal <= -60:
        return '<span color="#f5a97f">󰤟</span>'
    if signal <= -50:
        return '<span color="#eed49f">󰤢</span>'
    if signal <= -40:
        return '<span color="#a6da95">󰤥</span>'
    return '<span color="#a6da95">󰤨</span>'


def get_wifi():
    name = "disconnected"
    state = ""
    signal = -90

    out = subprocess.run(
        ["iwctl", "station", IFACE, "show"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        timeout=2,
    ).stdout

    for row in out.splitlines():
        parts = row.split()
        if len(parts) < 2:
            continue
        if parts[0] == "Connected":
            name = " ".join(parts[2:])
        elif parts[0] == "State":
            state = parts[1]
        elif parts[0] == "RSSI":
            signal = int(parts[1])

    if state == "connected":
        return f'<span color="#a6da95">{name}</span> {icon(signal)}'
    return f'<span color="#ed8796">{name}</span> <span color="#ed8796">󰤮</span>'


last = None

while True:
    try:
        current = get_wifi()
    except Exception:
        current = '<span color="#ed8796">disconnected</span> <span color="#ed8796">󰤮</span>'

    if current != last:
        print(current, flush=True)
        last = current

    time.sleep(5)
