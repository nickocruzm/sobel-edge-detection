#!/usr/bin/env python3
"""
Convert all images in Material/ to 8-bit binary pixel values, one pixel per line.
Output written to Material/<stem>.txt.

1. *.png image converted to grayscale using .conver("L")
2. resize image to 32x32
3. writes pixels values (binary represented) to Material/pixels/<img>.txt

Usage:
    python3 img_to_binary.py
"""
import sys
from pathlib import Path
from PIL import Image

IMAGE_EXTENSIONS = {".png"}

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
MATERIAL = REPO_ROOT / "Material"

def img_to_binary(image_path: Path):
    img = Image.open(image_path).convert("L").resize((32, 32))  # grayscale
    width, height = img.size

    output_path = MATERIAL / "pixels" / f"{image_path.stem}.txt"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    pixels = list(img.getdata())
    with open(output_path, "w") as f:
        for px in pixels:
            f.write(f"{px:08b}\n")

    print(f"{image_path.name}: {width}x{height} ({len(pixels)} pixels) -> {output_path.relative_to(REPO_ROOT)}")

def images_to_binary():
    image_files = [p for p in MATERIAL.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS]
    if not image_files:
        print(f"No images found in {MATERIAL}")
        sys.exit(1)
    for image_path in sorted(image_files):
        img_to_binary(image_path)

if __name__ == "__main__":
    images_to_binary()