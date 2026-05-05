#!/usr/bin/env python3
"""
Reconstruct a Sobel edge-detection image from simulation output.

Usage:
    python3 sobel_to_img.py <sobel_out.txt> [output_image] [--img-w W] [--img-h H]

    sobel_out.txt  — decimal pxl_out values written by img_conv_test.v (one per line)
    output_image   — path for the saved image (default: sobel_result.png)
    --img-w        — original image width fed into simulation (default: 32)
    --img-h        — original image height fed into simulation (default: 32)

The output image is (img_h - 2) rows x (img_w - 2) cols (valid region after 3x3 kernel).
"""

import sys
import argparse
import numpy as np
from PIL import Image


def sobel_to_img(input_path, output_path, img_w, img_h):
    values = []
    with open(input_path) as f:
        for line in f:
            line = line.strip()
            if line:
                values.append(int(line))

    out_h = img_h - 2
    out_w = img_w - 2
    expected = out_h * out_w

    if len(values) != expected:
        print(f"Warning: got {len(values)} values, expected {expected} ({out_h}x{out_w})")

    arr = np.array(values[:expected], dtype=np.float32)
    arr = np.clip(arr, 0, arr.max())
    if arr.max() > 0:
        arr = (arr / arr.max() * 255).astype(np.uint8)
    else:
        arr = arr.astype(np.uint8)

    img = Image.fromarray(arr.reshape(out_h, out_w), mode="L")
    img.save(output_path)
    print(f"Saved {out_h}x{out_w} image to {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="sobel_out.txt from simulation")
    parser.add_argument("output", nargs="?", default="sobel_result.png")
    parser.add_argument("--img-w", type=int, default=32)
    parser.add_argument("--img-h", type=int, default=32)
    args = parser.parse_args()

    sobel_to_img(args.input, args.output, args.img_w, args.img_h)
