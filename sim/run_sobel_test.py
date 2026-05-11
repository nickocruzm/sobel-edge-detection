#!/usr/bin/env python3
"""Compile and run sobel_test.v with VCS, then report pass/fail."""

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
SIM  = ROOT / "sim"
RTL  = ROOT / "rtl"

SOURCES = [
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "conv.v",
    RTL / "sobel.v",
    SIM / "sobel_test.v",
]

BINARY = SIM / "sobel_simv"


ENV = {**os.environ, "VCS_TARGET_ARCH": "linux64"}


def run(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, env=ENV, **kwargs)


def compile():
    print("Compiling...")
    result = run(["vcs", "-sverilog", *[str(s) for s in SOURCES], "-o", str(BINARY)])
    if result.returncode != 0:
        print("COMPILE FAILED")
        print(result.stdout)
        print(result.stderr)
        sys.exit(1)
    print("Compile OK\n")


def simulate():
    print("Running simulation...")
    result = run([str(BINARY)], cwd=SIM)
    if result.returncode != 0:
        print("SIMULATION ERROR")
        print(result.stderr)
        sys.exit(1)
    return result.stdout


def parse(output):
    print(output)
    passed = failed = 0
    for line in output.splitlines():
        if line.startswith("PASS"):
            passed += 1
        elif line.startswith("FAIL"):
            failed += 1

    total = passed + failed
    print("-" * 40)
    if total == 0:
        print("No valid outputs captured — check timing or valid signal.")
        sys.exit(1)

    print(f"{passed}/{total} passed")
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    compile()
    parse(simulate())
