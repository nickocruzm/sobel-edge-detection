#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
import shutil
from pathlib import Path

ROOT = Path(__file__).parent.resolve()

SIM = ROOT / "sim"
SW = ROOT / "sw"
RTL = ROOT / "rtl"
PTPX = ROOT / "ptpx"

MATERIAL = ROOT / "Material"

PIXELS_DIR = MATERIAL / "pixels"

SW_OUT_DIR = MATERIAL / "sw_golden_model" / "output"
SW_FINAL_DIR = MATERIAL / "sw_golden_model" / "final"

RTL_OUT_DIR = MATERIAL / "sobel" / "output"
RTL_FINAL_DIR = MATERIAL / "sobel" / "final"

GENERATED = SIM / "generated"
BINARY = GENERATED / "img_conv_simv"

VCS_SOURCES = [
    SIM / "img_sobel_test.v",
    RTL / "conv.v",
    RTL / "mac.v",
    RTL / "register.v",
    RTL / "shift.v",
    RTL / "sobel.v",
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
    res = subprocess.run([str(c) for c in cmd], cwd=cwd, env=ENV)
    if check and res.returncode != 0:
        sys.exit(res.returncode)
    return res


# -----------------------------
# clean outputs
# -----------------------------
def clean():
    for d in [PIXELS_DIR, SW_OUT_DIR, SW_FINAL_DIR, RTL_OUT_DIR, RTL_FINAL_DIR]:
        shutil.rmtree(d, ignore_errors=True)
        d.mkdir(parents=True, exist_ok=True)


# -----------------------------
# Stage 0 - PNG → pixels
# -----------------------------
def run_img_to_binary():
    step("Convert PNG images to pixel txt")

    PIXELS_DIR.mkdir(parents=True, exist_ok=True)

    run([
        "python3",
        SIM / "scripts" / "img_to_binary.py",
        MATERIAL,
        PIXELS_DIR,
    ])


# -----------------------------
# Stage 1 - SW golden model
# -----------------------------
def run_sw():
    step("Run SW golden model")

    SW_OUT_DIR.mkdir(parents=True, exist_ok=True)

    for img in sorted(PIXELS_DIR.glob("*.txt")):
        name = img.stem
        out_file = SW_OUT_DIR / f"{name}.txt"

        run([
            "python3",
            SW / "sobel_ref.py",
            img,
            out_file,
        ])

        print(f"{img.relative_to(ROOT)} -> {out_file.relative_to(ROOT)}")


# -----------------------------
# RTL compile
# -----------------------------
def compile():
    step("Compile RTL")

    GENERATED.mkdir(parents=True, exist_ok=True)

    run([
        "vcs", "-sverilog", *VCS_SOURCES,
        "-full64", "-debug_access",
        f"-Mdir={GENERATED / 'csrc'}",
        "-o", BINARY,
    ])


# -----------------------------
# RTL simulation (kept original logic, single test)
# -----------------------------
def run_rtl():
    step("Run RTL simulation (batch)")

    images = sorted(PIXELS_DIR.glob("*.txt"))

    GENERATED.mkdir(parents=True, exist_ok=True)
    RTL_OUT_DIR.mkdir(parents=True, exist_ok=True)

    for img in images:
        name = img.stem
        rtl_output = RTL_OUT_DIR / f"{name}.txt"

        run([
            BINARY,
            f"+IN={img}",
            f"+OUT={rtl_output}"
        ], cwd=GENERATED)

        if not rtl_output.exists():
            print(f"ERROR: RTL output not generated for {name}")
            sys.exit(1)

        print(f"RTL done: {name}")

    print("RTL batch complete")


# -----------------------------
# SW output → image
# -----------------------------
def txt_to_img(in_path: Path, out_path: Path):
    import numpy as np
    from PIL import Image

    values = [int(x.strip()) for x in in_path.read_text().splitlines() if x.strip()]
    arr = np.array(values, dtype=np.float32)

    try:
        if arr.size == 1156:
            img_padded = arr.reshape(34, 34)
            img_core = img_padded[1:33, 1:33]
        else:
            img_core = arr.reshape(32, 32)
    except ValueError:
        print(f"Skip bad file: {in_path.relative_to(ROOT)}")
        return

    if img_core.max() > 0:
        img_core = img_core / img_core.max() * 255

    img = img_core.astype("uint8")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(img, mode="L").save(out_path)

    print(f"{in_path.relative_to(ROOT)} -> {out_path.relative_to(ROOT)}")


def convert_images():
    step("Convert SW outputs to images")

    for f in sorted(SW_OUT_DIR.glob("*.txt")):
        out_img = SW_FINAL_DIR / f"{f.stem}.png"
        txt_to_img(f, out_img)

# -----------------------------
# RTL output → image
# -----------------------------
def convert_rtl_txt_to_img(in_path: Path, out_path: Path):
    import numpy as np
    from PIL import Image

    values = [int(x.strip()) for x in in_path.read_text().splitlines() if x.strip()]
    arr = np.array(values, dtype=np.float32)

    try:
        # Sobel output should be 32x32 (no padding in output file)
        img_core = arr.reshape(32, 32)
    except ValueError:
        print(f"Skip bad RTL file: {in_path.relative_to(ROOT)}")
        return

    # normalize for visualization
    if img_core.max() > 0:
        img_core = img_core / img_core.max() * 255

    img = img_core.astype("uint8")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(img, mode="L").save(out_path)

    print(f"{in_path.relative_to(ROOT)} -> {out_path.relative_to(ROOT)}")


def convert_rtl_images():
    step("Convert RTL outputs to images")

    for f in sorted(RTL_OUT_DIR.glob("*.txt")):
        out_img = RTL_FINAL_DIR / f"{f.stem}.png"
        convert_rtl_txt_to_img(f, out_img)

# -----------------------------
# SW vs RTL compare
# -----------------------------
def run_compare():
    step("Compare SW vs RTL outputs")

    compare_script = SW / "compare.py"

    if not compare_script.exists():
        print(f"ERROR: missing {compare_script}")
        sys.exit(1)

    run([
        "python3",
        compare_script
    ])

    print("Comparison complete")

# -----------------------------
# main
# -----------------------------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-compile", action="store_true")
    parser.add_argument("--no-rtl", action="store_true")
    parser.add_argument("--no-compare", action="store_true")
    args = parser.parse_args()

    clean()

    run_img_to_binary()   # Stage 0
    run_sw()              # SW golden model
    convert_images()      # SW images

    if not args.no_compile:
        compile()

    if not args.no_rtl:
        run_rtl()
        convert_rtl_images()

    if not args.no_compare:
        run_compare()

    print("\nDONE")


if __name__ == "__main__":
    main()