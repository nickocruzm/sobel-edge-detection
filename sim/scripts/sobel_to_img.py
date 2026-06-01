#!/usr/bin/env python3
"""
Reconstruct images from simulation output files.

Reads all .txt files from Material/img_conv/output and Material/sobel/output,
and writes the resulting images to Material/img_conv/produced and
Material/sobel/produced, respectively.

Usage:
    python3 sobel_to_img.py
"""

from pathlib import Path
import numpy as np
from PIL import Image

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
MATERIAL = REPO_ROOT / "Material"

IMG_W = 34  # padded width (32 + 2)
IMG_H = 34  # padded height (32 + 2)

CONVERSIONS = [
    (MATERIAL / "img_conv" / "output", MATERIAL / "img_conv" / "final"),
    (MATERIAL / "sobel"    / "output", MATERIAL / "sobel"    / "final"),
]


def txt_to_img(input_path: Path, output_path: Path):
    values = []
    with open(input_path) as f:
        for line in f:
            line = line.strip()
            if line:
                values.append(int(line))

    out_h = IMG_H - 2
    out_w = IMG_W - 2
    expected = out_h * out_w

    if len(values) != expected:
        print(f"  Warning: got {len(values)} values, expected {expected} ({out_h}x{out_w})")

    arr = np.array(values[:expected], dtype=np.float32)
    arr = np.clip(arr, 0, arr.max())
    if arr.max() > 0:
        arr = (arr / arr.max() * 255).astype(np.uint8)
    else:
        arr = arr.astype(np.uint8)

    img = Image.fromarray(arr.reshape(out_h, out_w), mode="L")
    img.save(output_path)
    print(f"  {input_path.name} -> {output_path}")


if __name__ == "__main__":
    for src_dir, dst_dir in CONVERSIONS:
        txt_files = sorted(src_dir.glob("*.txt")) if src_dir.exists() else []
        if not txt_files:
            print(f"No .txt files in {src_dir}, skipping.")
            continue
        dst_dir.mkdir(parents=True, exist_ok=True)
        print(f"{src_dir.relative_to(REPO_ROOT)} -> {dst_dir.relative_to(REPO_ROOT)}")
        for txt_file in txt_files:
            txt_to_img(txt_file, dst_dir / f"{txt_file.stem}.png")
