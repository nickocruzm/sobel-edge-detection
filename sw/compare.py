import numpy as np
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

SW_DIR = ROOT / "Material" / "sw_golden_model" / "output"
HW_DIR = ROOT / "Material" / "sobel" / "output"
OUT_DIR = ROOT / "sw"


def compare_one(sw_path, hw_path):
    sw = np.loadtxt(sw_path).astype(np.int32)
    hw = np.loadtxt(hw_path).astype(np.int32)

    min_len = min(len(sw), len(hw))
    sw = sw[:min_len]
    hw = hw[:min_len]

    diff = np.abs(sw - hw)

    mae = float(np.mean(diff))
    error_rate = float(np.mean(diff > 1))
    max_error = int(np.max(diff))

    return mae, error_rate, max_error, len(sw), len(hw)


def main():
    OUT_DIR.mkdir(exist_ok=True, parents=True)

    sw_files = sorted(SW_DIR.glob("*.txt"))

    for sw_file in sw_files:
        name = sw_file.stem
        hw_file = HW_DIR / f"{name}.txt"

        if not hw_file.exists():
            print(f"[SKIP] missing HW file: {hw_file}")
            continue

        mae, err_rate, max_err, sw_len, hw_len = compare_one(sw_file, hw_file)

        out_file = OUT_DIR / f"compare_results_{name}.txt"

        with open(out_file, "w") as f:
            f.write(f"File: {name}\n")
            f.write(f"SW size: {sw_len}\n")
            f.write(f"HW size: {hw_len}\n")
            f.write(f"MAE: {mae}\n")
            f.write(f"Error rate (>1): {err_rate}\n")
            f.write(f"Max error: {max_err}\n")

        print(f"[OK] {name} -> {out_file}")


if __name__ == "__main__":
    main()