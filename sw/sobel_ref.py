import sys
import numpy as np
from PIL import Image
from scipy.signal import convolve2d

# Match RTL kernel EXACTLY
K = np.array([
    [1,2,1],
    [0,0,0],
    [1,2,1]
])

# Load and resize original image
img = Image.open(sys.argv[1]).convert("L").resize((32, 32))
img = np.array(img, dtype=np.int32)

# -----------------------------
# ADD ZERO PADDING (32 -> 34)
# -----------------------------
img_padded = np.pad(img, pad_width=1, mode='constant', constant_values=0)

assert img_padded.shape == (34, 34)

# -----------------------------
# CONVOLUTION (match RTL "valid output region")
# -----------------------------
out = convolve2d(img_padded, K, mode="valid")

# Should be 32x32
assert out.shape == (32, 32)

# Save flattened result (matches RTL stream order expectation)
np.savetxt("sw_output.txt", out.flatten(), fmt="%d")