#!/usr/bin/env python3
"""Compile and run conv_test.v and sobel_test.v with VCS, then report pass/fail."""

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
SIM  = ROOT / "sim"
RTL  = ROOT / "rtl"

CONV_SOURCES = [
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "conv.v",
    SIM / "conv_test.v",
]

SOBEL_SOURCES = [
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "conv.v",
    RTL / "sobel.v",
    SIM / "sobel_test.v",
]

CONV_BINARY  = SIM / "conv_simv"
SOBEL_BINARY = SIM / "sobel_simv"

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
        print(result.stderr)
        sys.exit(1)
    return result.stdout


def parse(name, output):
    print(f"--- {name} ---")
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

    print(f"{passed}/{total} passed\n")
    return failed


if __name__ == "__main__":
    compile("conv_test",  CONV_SOURCES,  CONV_BINARY)
    compile("sobel_test", SOBEL_SOURCES, SOBEL_BINARY)

    conv_failures  = parse("conv_test",  simulate("conv_test",  CONV_BINARY))
    sobel_failures = parse("sobel_test", simulate("sobel_test", SOBEL_BINARY))

    sys.exit(0 if (conv_failures + sobel_failures) == 0 else 1)
