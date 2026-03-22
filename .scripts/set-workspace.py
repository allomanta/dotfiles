#!/bin/env python3
from wayfire import WayfireSocket
import sys

if len(sys.argv) > 1:
    y, x = divmod(int(sys.argv[1]) - 1, 3)

    sock = WayfireSocket()

    sock.set_workspace(x, y)
