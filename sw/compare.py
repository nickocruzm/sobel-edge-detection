import numpy as np

sw = np.loadtxt("sw_output.txt").astype(np.int32)
hw = np.loadtxt("../sim/sobel_out.txt").astype(np.int32)

min_len = min(len(sw), len(hw))
sw = sw[:min_len]
hw = hw[:min_len]

diff = np.abs(sw - hw)

print("Size of SW output:", len(sw))
print("Size of HW output:", len(hw))
print("MAE:", np.mean(diff))
print("Error rate:", np.mean(diff > 1))
print("Max error:", np.max(diff))