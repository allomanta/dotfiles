#!/usr/bin/env python3
import subprocess
import sys
import time
from pathlib import Path

GPU_INDEX = "0"
RUNTIME_STATUS_PATH = Path(f"/sys/bus/pci/devices/0000:65:00.0/power/runtime_status")

ACTIVE_INTERVAL = 1.0
INACTIVE_INTERVAL = 1.0
LOWACTIVE_INTERVAL = 15.0


def rgb2hex(r: int, g: int, b: int) -> str:
    return f"#{r:02x}{g:02x}{b:02x}"


RED = rgb2hex(255, 128, 128)
BLUE = rgb2hex(138, 173, 244)
GREEN = rgb2hex(166, 218, 149)
ORANGE = rgb2hex(255, 195, 77)

INACTIVE_FORMATS = {
    "suspended": f"<span color='{BLUE}'>suspended</span>",
    "suspending": f"<span color='{GREEN}'>suspending</span>",
    "resuming": f"<span color='{ORANGE}'>resuming</span>",
}


def color_for_power(power_w: int) -> str:
    if power_w < 6:
        return GREEN
    if power_w < 20:
        return ORANGE
    return RED


def color_for_temp(temp_c: float) -> str:
    ratio = max(0.0, min(temp_c / 100.0, 1.0))
    base = 55
    return rgb2hex(base + int(200 * ratio), base + int(200 * (ratio**2)), base + int(200 * (1 - ratio)))


def color_for_util(util_pct: int) -> str:
    if util_pct < 5:
        return BLUE
    if util_pct < 50:
        return GREEN
    if util_pct < 75:
        return ORANGE
    return RED


def query_gpu() -> tuple[int, int, int]:
    result = subprocess.run(
        [
            "nvidia-smi",
            f"--id={GPU_INDEX}",
            "--query-gpu=power.draw,temperature.gpu,utilization.gpu",
            "--format=csv,noheader,nounits",
        ],
        check=True,
        capture_output=True,
        text=True,
    )

    line = result.stdout.strip()
    parts = [part.strip() for part in line.split(",")]
    if len(parts) != 3:
        raise ValueError(f"unexpected nvidia-smi output: {line!r}")

    power = int(round(float(parts[0])))
    temp = float(parts[1])
    util = int(parts[2])
    return power, temp, util


def format_active(power: int, temp: int, util: int) -> str:
    return (
        f'<span color="{color_for_power(power)}">{power}W</span>  '
        f'<span color="{color_for_temp(temp)}">{temp}C</span>  '
        f'<span color="{color_for_util(util)}">{util}%</span>'
    )


def main() -> int:
    while True:
        try:
            status = RUNTIME_STATUS_PATH.read_text().strip()

            if status != "active":
                if status == "suspended":
                    print(flush=True)
                else:
                    print(INACTIVE_FORMATS.get(status), flush=True)
                time.sleep(INACTIVE_INTERVAL)
                continue

            power, temp, util = query_gpu()
            print(format_active(power, temp, util), flush=True)
            if power < 10:
                time.sleep(LOWACTIVE_INTERVAL)
            else:
                time.sleep(ACTIVE_INTERVAL)

        except Exception as exc:
            print(f'<span color="#ed8796">gpu err: {type(exc).__name__}</span>', flush=True)
            time.sleep(INACTIVE_INTERVAL)


if __name__ == "__main__":
    sys.exit(main())
