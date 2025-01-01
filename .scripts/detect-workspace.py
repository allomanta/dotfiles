#!/usr/bin/python3
from wayfire import WayfireSocket
from wayfire.extra.ipc_utils import WayfireUtils
import sys

sock = WayfireSocket()
utils = WayfireUtils(sock)

sock.watch(["wset-workspace-changed"])
active_ws = utils.get_active_workspace()

if len(sys.argv) > 1:
    this_ws = int(sys.argv[1])

    while True:
        is_current = int((1 + active_ws["x"] + active_ws["y"] * 3) == this_ws)

        if is_current:
            print('<span color="#a6da95"></span>')
        else:
            print("")

        sys.stdout.flush()
        try:
            msg = sock.read_next_event()
            active_ws = msg["new-workspace"]
            # print(1 + active_workspace["x"] + active_workspace["y"] * 3)
        except KeyboardInterrupt:
            exit(0)

while True:
    print(1 + active_ws["x"] + active_ws["y"] * 3)
    sys.stdout.flush()
    try:
        msg = sock.read_next_event()
        active_ws = msg["new-workspace"]
        # print(1 + active_workspace["x"] + active_workspace["y"] * 3)
    except KeyboardInterrupt:
        exit(0)
