import numpy as np

# Load software and hardware outputs
sw = np.loadtxt("sw_output.txt")
hw = np.loadtxt("../sim/sobel_out.txt")

# Compute pixel-wise absolute difference
diff = np.abs(sw - hw)

# Metrics
mae = np.mean(diff)
error_rate = np.sum(diff > 1) / diff.size

print("MAE:", mae)
print("Error rate:", error_rate)

# Save comparison report
with open("compare_report.txt", "w") as f:
    f.write(f"MAE: {mae}\n")
    f.write(f"Error rate: {error_rate}\n")
    f.write(f"Max error: {np.max(diff)}\n")
    f.write(f"Min error: {np.min(diff)}\n")