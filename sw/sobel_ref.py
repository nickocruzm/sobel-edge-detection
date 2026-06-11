import sys
import numpy as np
from PIL import Image
from scipy.signal import convolve2d
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Kx kernel (-1 0 1 / -2 0 2 / -1 0 1) that matches Gx kernal of RTL design
Kx = np.array([
    [-1, 0, 1],
    [-2, 0, 2],
    [-1, 0, 1]
], dtype=np.int32)

# Ky kernel (1 2 1 / 0 0 0 / -1 -2 -1) that matches Gy kernal of RTL design
Ky = np.array([
    [ 1,  2,  1],
    [ 0,  0,  0],
    [-1, -2, -1]
], dtype=np.int32)


def load_input(path: Path):
    path = Path(path)

    # image input
    if path.suffix.lower() in [".png", ".jpg", ".jpeg"]:
        img = Image.open(path).convert("L").resize((32, 32))
        return np.array(img, dtype=np.int32)

    # txt input (1024 values)
    values = np.loadtxt(path, dtype=str)
    values = np.array([int(v, 2) for v in values], dtype=np.int32)

    if values.size != 1024:
        raise ValueError(f"Invalid pixel file: {path}")

    return values.reshape(32, 32)


def main():
    inp = Path(sys.argv[1])
    name = inp.stem

    img = load_input(inp)

    # RTL processes a streamed image with explicit 1-pixel zero-padding around the border.
    # The software model applies the same padding to produce matching outputs.
    padded = np.pad(img, 1, mode="constant")

    gx = convolve2d(padded, Kx, mode="valid")
    gy = convolve2d(padded, Ky, mode="valid")

    # The hardware implementation uses the L1-norm approximation of |Gx| + |Gy| — the cheap L1-norm approximation of edge strength
    # The software golden model is modified accordingly to ensure bit-exact comparison with RTL output.
    mag = np.abs(gx) + np.abs(gy)

    out_dir = Path("Material/sw_golden_model/output")
    out_dir.mkdir(parents=True, exist_ok=True)

    out_path = (REPO_ROOT / "Material" / "sw_golden_model" / "output" / f"{name}.txt")

    np.savetxt(out_path, mag.flatten(), fmt="%d")

    print(f"[SW] {name} -> {out_path.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()