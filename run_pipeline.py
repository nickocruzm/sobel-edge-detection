#!/usr/bin/env python3
"""
Run the full Sobel edge-detection pipeline:
  1. Convert input image to binary pixel file  →  out/pixels.txt
  2. Compile img_conv_test.v with VCS          →  build/img_conv_simv
  3. Run simulation                            →  out/sobel_out.txt, out/img_conv.vcd
  4. Reconstruct edge image                    →  out/sobel_result.png (default)
  5. (Optional) Run PTPX power analysis

Usage:
    python3 run_pipeline.py <image.png> [options]

Options:
    --output      Output image path  (default: out/sobel_result.png)
    --ptpx        Also run PTPX power analysis after simulation
    --no-compile  Skip VCS compilation (reuse existing binary)

Directory layout:
    build/   VCS compile artifacts (binary, csrc/, .daidir/)
    out/     All generated pipeline files (pixels.txt, waveforms, result image)
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT      = Path(__file__).parent.resolve()
SIM       = ROOT / "sim"
RTL       = ROOT / "rtl"
PTPX      = ROOT / "ptpx"
GENERATED = SIM / "generated"

BINARY = GENERATED / "img_conv_simv"

VCS_SOURCES = [
    SIM / "img_conv_test.v",
    RTL / "conv.v",
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
]

ENV = {**os.environ, "VCS_TARGET_ARCH": "linux64"}

STEP = 0


def step(msg):
    global STEP
    STEP += 1
    print(f"\n[{STEP}] {msg}")
    print("-" * 60)


def run(cmd, cwd=None, check=True):
    print("$", " ".join(str(c) for c in cmd))
    result = subprocess.run(
        [str(c) for c in cmd],
        cwd=cwd,
        env=ENV,
        capture_output=False,
    )
    if check and result.returncode != 0:
        print(f"\nERROR: command exited with code {result.returncode}")
        sys.exit(result.returncode)
    return result


# ---------------------------------------------------------------------------
# Stage 1 – image → out/pixels.txt
# ---------------------------------------------------------------------------

def stage_img_to_pixels(image_path: Path):
    step("Convert image to binary pixels")
    GENERATED.mkdir(exist_ok=True)
    pixels_txt = GENERATED / "pixels.txt"
    run(
        ["python3", SIM / "img_to_binary.py", image_path.resolve(), pixels_txt],
    )
    print(f"Pixels written to {pixels_txt}")


# ---------------------------------------------------------------------------
# Stage 2 – VCS compile → build/img_conv_simv
# ---------------------------------------------------------------------------

def stage_compile():
    step("Compile with VCS")
    GENERATED.mkdir(exist_ok=True)
    run([
        "vcs", "-sverilog", *VCS_SOURCES,
        "-full64", "-debug_access",
        f"-Mdir={GENERATED / 'csrc'}",
        "-o", BINARY,
    ])
    print(f"Binary: {BINARY}")


# ---------------------------------------------------------------------------
# Stage 3 – simulation → out/sobel_out.txt, out/img_conv.vcd
#
# cwd is OUT so the Verilog-hardcoded relative paths ("pixels.txt",
# "sobel_out.txt", "img_conv.vcd") all resolve inside out/.
# ---------------------------------------------------------------------------

def stage_simulate():
    step("Run simulation")
    GENERATED.mkdir(exist_ok=True)
    run([BINARY], cwd=GENERATED, check=False)  # VCS returns 255 on normal $finish
    sobel_out = GENERATED / "sobel_out.txt"
    if not sobel_out.exists():
        print(f"ERROR: {sobel_out} not produced by simulation")
        sys.exit(1)
    print(f"Simulation output: {sobel_out}")


# ---------------------------------------------------------------------------
# Stage 4 – out/sobel_out.txt → result image
# ---------------------------------------------------------------------------

def stage_reconstruct(output_image: Path):
    step("Reconstruct edge image")
    output_image.parent.mkdir(parents=True, exist_ok=True)
    run([
        "python3", SIM / "sobel_to_img.py",
        GENERATED / "sobel_out.txt",
        output_image,
        "--img-w", "34",
        "--img-h", "34",
    ])
    print(f"Result image: {output_image}")


# ---------------------------------------------------------------------------
# Stage 5 – PTPX (optional)
# ---------------------------------------------------------------------------

def stage_ptpx():
    step("Run PTPX power analysis")
    run(["pt_shell", "-f", "ptpx.tcl"], cwd=PTPX)
    print(f"Reports in {PTPX / 'reports'}/")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Run the full Sobel edge-detection pipeline.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("image", help="Input image (PNG recommended)")
    parser.add_argument(
        "--output", default=str(GENERATED / "sobel_result.png"),
        help="Output edge image path (default: sim/generated/sobel_result.png)",
    )
    parser.add_argument(
        "--ptpx", action="store_true",
        help="Run PTPX power analysis after simulation",
    )
    parser.add_argument(
        "--no-compile", action="store_true",
        help="Skip VCS compilation (reuse existing binary)",
    )
    args = parser.parse_args()

    image_path = Path(args.image)
    if not image_path.exists():
        print(f"ERROR: image not found: {image_path}")
        sys.exit(1)

    output_image = Path(args.output)

    print("=" * 60)
    print("  Sobel Edge-Detection Pipeline")
    print("=" * 60)
    print(f"  Input  : {image_path.resolve()}")
    print(f"  Output : {output_image.resolve()}")
    print(f"  PTPX   : {'yes' if args.ptpx else 'no'}")
    print(f"  Compile: {'no (--no-compile)' if args.no_compile else 'yes'}")

    stage_img_to_pixels(image_path)

    if not args.no_compile:
        stage_compile()
    else:
        if not BINARY.exists():
            print(f"ERROR: --no-compile set but binary not found: {BINARY}")
            sys.exit(1)
        print(f"\n[skipped] VCS compile — using {BINARY}")

    stage_simulate()
    stage_reconstruct(output_image)

    if args.ptpx:
        stage_ptpx()

    print("\n" + "=" * 60)
    print("  Pipeline complete!")
    print(f"  Edge image: {output_image.resolve()}")
    if args.ptpx:
        print(f"  PTPX reports: {PTPX / 'reports'}/")
    print("=" * 60)


if __name__ == "__main__":
    main()
