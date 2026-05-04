#!/usr/bin/env python3
"""
Convert an image to 8-bit binary pixel values, one per line.
Converts to grayscale first. Output is suitable for hardware simulation input.

Usage:
    python3 img_to_binary.py <input_image> [output_file]

    If output_file is omitted, writes to <input_image_stem>.txt
"""

import sys
from pathlib import Path
from PIL import Image


def img_to_binary(input_path: str, output_path: str = None):
    img = Image.open(input_path).convert("L").resize((32,32))  # grayscale
    width, height = img.size

    if output_path is None:
        output_path = Path(input_path).stem + ".txt"

    pixels = list(img.getdata())

    with open(output_path, "w") as f:
        for px in pixels:
            f.write(f"{px:08b}\n")

    print(f"Image: {width}x{height} ({len(pixels)} pixels)")
    print(f"Output: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    img_to_binary(input_path, output_path)
