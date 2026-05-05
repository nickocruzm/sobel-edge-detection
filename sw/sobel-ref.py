import sys
import numpy as np
from PIL import Image
from scipy.signal import convolve2d

# Sobel kernels
Gx = np.array([[-1, 0, 1],
                [-2, 0, 2],
                [-1, 0, 1]])

Gy = np.array([[ 1, 2, 1],
               [ 0, 0, 0],
               [-1,-2,-1]])

img_path = sys.argv[1]

# Load image
img = Image.open(img_path).convert("L").resize((32,32))
img = np.array(img, dtype=np.int32)

# Convolution (MATCH RTL streaming behavior)
gx = convolve2d(img, Gx, mode="valid")
gy = convolve2d(img, Gy, mode="valid")

# Sobel magnitude (L1 approximation)
sobel = np.abs(gx) + np.abs(gy)

# Flatten to match hw_output.txt format
np.savetxt("sw_output.txt", sobel.flatten(), fmt="%d")