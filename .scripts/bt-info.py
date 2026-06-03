#!/usr/bin/env python3

from gi.repository import GLib
from pydbus import SystemBus

BLUEZ = "org.bluez"
ADAPTER_PATH = "/org/bluez/hci0"

GREEN = "#a6da95"
DARK = "#6e738d"
FLAMINGO = "#f0c6c6"
MAROON = "#ee99a0"
PEACH = "#f5a97f"

bus = SystemBus()
adapter = bus.get(BLUEZ, ADAPTER_PATH)
manager = bus.get(BLUEZ, "/")

last_output = None
update_queued = False


def render_state() -> str:
    try:
        if not adapter.Powered:
            return f'<span color="{DARK}">󰂲</span>'

        name = ""

        for obj in manager.GetManagedObjects().values():
            dev = obj.get("org.bluez.Device1")
            if dev and dev.get("Connected", False):
                name = dev.get("Alias") or dev.get("Name") or ""
                break

        if name:
            short_name = name[:15] + ("..." if len(name) > 15 else "")
            return f'<span color="{GREEN}">{short_name} </span>'

        color = GREEN

        if not adapter.Discoverable and adapter.Pairable:
            color = FLAMINGO
        elif not adapter.Pairable:
            color = PEACH
        elif not adapter.Connectable:
            color = MAROON

        return f'<span color="{color}">󰂯</span>'

    except Exception:
        # BlueZ may briefly disappear/restart. Keep the script alive.
        return f'<span color="{MAROON}">󰂯!</span>'


def schedule_update(*_args) -> None:
    global last_output, update_queued

    if update_queued:
        return

    update_queued = True

    def update_once() -> bool:
        global last_output, update_queued

        output = render_state()

        if output != last_output:
            print(output, flush=True)
            last_output = output

        update_queued = False
        return False

    GLib.timeout_add(250, update_once)


# Initial output.
schedule_update()

bus.subscribe(
    sender=BLUEZ,
    iface="org.freedesktop.DBus.Properties",
    signal="PropertiesChanged",
    signal_fired=lambda _sender, path, _iface, _signal, params: (
        schedule_update()
        if path.startswith("/org/bluez/") and params[0] in ("org.bluez.Adapter1", "org.bluez.Device1")
        else None
    ),
)

bus.subscribe(
    sender=BLUEZ,
    iface="org.freedesktop.DBus.ObjectManager",
    signal="InterfacesAdded",
    signal_fired=lambda _sender, path, *_args: (schedule_update() if path.startswith("/org/bluez/") else None),
)

bus.subscribe(
    sender=BLUEZ,
    iface="org.freedesktop.DBus.ObjectManager",
    signal="InterfacesRemoved",
    signal_fired=lambda _sender, path, *_args: (schedule_update() if path.startswith("/org/bluez/") else None),
)

GLib.MainLoop().run()
