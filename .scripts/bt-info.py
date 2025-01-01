#!/bin/env python3
import pydbus

bus = pydbus.SystemBus()

adapter = bus.get("org.bluez", "/org/bluez/hci0")
mngr = bus.get("org.bluez", "/")

green = "#a6da95"
dark = "#6e738d"
flamingo = "#f0c6c6"
maroon = "#ee99a0"
peach = "#f5a97f"


def first_connected_device():
    # print(dir(adapter))
    mngd_objs = mngr.GetManagedObjects()
    for path in mngd_objs:
        con_state = mngd_objs[path].get("org.bluez.Device1", {}).get("Connected", False)
        if con_state:
            return mngd_objs[path].get("org.bluez.Device1", {}).get("Name")
    return ""


if not adapter.Powered:
    print(f'<span color="{dark}">󰂲</span>')
else:
    name = first_connected_device()
    if name:
        print(f'<span color="{green}">{name} </span>')
    else:
        color = green
        if not adapter.Discoverable and adapter.Pairable:
            color = flamingo
        elif not adapter.Pairable:
            color = peach
        elif not adapter.Connectable:
            color = maroon

        print(f'<span color="{color}">󰂯</span>')

# list_connected_devices()
