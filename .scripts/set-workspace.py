#!/bin/env python3
from wayfire import WayfireSocket, get_msg_template
import sys

if len(sys.argv) > 1:
    y, x = divmod(int(sys.argv[1]) - 1, 3)

    sock = WayfireSocket()

    msg = get_msg_template("vswitch/set-workspace")
    msg["data"]["x"] = x
    msg["data"]["y"] = y
    msg["data"]["output-id"] = 1
    sock.send_json(msg)
