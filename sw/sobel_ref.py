import sys
import numpy as np
from PIL import Image
from scipy.signal import convolve2d

# Match RTL kernels EXACTLY
Kx = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
], dtype=np.int32)

Ky = np.array([
    [ 1,  2,  1],
    [ 0,  0,  0],
    [-1, -2, -1]
], dtype=np.int32)

# Load and resize original image
img = Image.open(sys.argv[1]).convert("L").resize((32, 32))
img = np.array(img, dtype=np.int32)

# -----------------------------
# ZERO PADDING (32 -> 34)
# -----------------------------
img_padded = np.pad(img, pad_width=1, mode='constant', constant_values=0)

assert img_padded.shape == (34, 34)

# -----------------------------
# CONVOLUTION (match RTL valid region)
# -----------------------------
gx = convolve2d(img_padded, Kx, mode="valid")
gy = convolve2d(img_padded, Ky, mode="valid")

assert gx.shape == (32, 32)
assert gy.shape == (32, 32)

# -----------------------------
# L1 MAGNITUDE (|Gx| + |Gy|)
# -----------------------------
magnitude = np.abs(gx) + np.abs(gy)

# Save flattened result (matches RTL stream order expectation)
np.savetxt("sw_output.txt", magnitude.flatten(), fmt="%d")