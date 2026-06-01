#!/usr/bin/env python3
"""Compile and run img_sobel_test.v with VCS, then report results."""

import os
import subprocess
import sys
from pathlib import Path

ROOT     = Path(__file__).resolve().parent.parent.parent
SIM      = ROOT / "sim"
RTL      = ROOT / "rtl"
MATERIAL = ROOT / "Material"

IMG_CONV_SOURCES = [
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "conv.v",
    SIM / "img_conv_test.v",
]

IMG_SOBEL_SOURCES = [
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "conv.v",
    RTL / "sobel.v",
    SIM / "img_sobel_test.v",
]

IMG_CONV_BINARY  = SIM / "bin/img_conv_simv"
IMG_SOBEL_BINARY = SIM / "bin/img_sobel_simv"
PIXELS_DIR        = MATERIAL / "pixels"
CONV_OUTPUT_FILE  = MATERIAL / "img_conv" / "output" / "002.txt"
SOBEL_OUTPUT_FILE = MATERIAL / "sobel"    / "output" / "002.txt"

ENV = {**os.environ, "VCS_TARGET_ARCH": "linux64"}


def run(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, env=ENV, **kwargs)


def compile(name, sources, binary):
    print(f"Compiling {name}...")
    result = run(["vcs", "-sverilog", *[str(s) for s in sources], "-o", str(binary)])
    if result.returncode != 0:
        print(f"COMPILE FAILED ({name})")
        print(result.stdout)
        print(result.stderr)
        sys.exit(1)
    print(f"Compile OK ({name})\n")


def simulate(name, binary):
    print(f"Running {name} simulation...")
    result = run([str(binary)], cwd=SIM)
    if result.returncode != 0:
        print(f"SIMULATION ERROR ({name})")
        print(result.stdout)
        print(result.stderr)
        sys.exit(1)
    if result.stdout:
        print(result.stdout)
    return result


def report(output_file, label):
    if not output_file.exists():
        print(f"ERROR: output file not found: {output_file}")
        sys.exit(1)

    lines = [l.strip() for l in output_file.read_text().splitlines() if l.strip()]
    print(f"{label}: {len(lines)} pixels written to {output_file.name}")
    return len(lines)


if __name__ == "__main__":
    if not any(PIXELS_DIR.glob("*.txt")):
        print(f"ERROR: no pixel files found in {PIXELS_DIR}")
        sys.exit(1)

    compile("img_conv_test",  IMG_CONV_SOURCES,  IMG_CONV_BINARY)
    compile("img_sobel_test", IMG_SOBEL_SOURCES, IMG_SOBEL_BINARY)

    simulate("img_conv_test",  IMG_CONV_BINARY)
    simulate("img_sobel_test", IMG_SOBEL_BINARY)

    conv_count  = report(CONV_OUTPUT_FILE,  "img_conv_test")
    sobel_count = report(SOBEL_OUTPUT_FILE, "img_sobel_test")

    print(f"\nDone. conv: {conv_count} pixels, sobel: {sobel_count} magnitudes.")
    sys.exit(0)
