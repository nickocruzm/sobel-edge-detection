# Journal

## 05-20 (Nicko)

- Created `run_pipeline.py`
    1. image -> `pixels.txt`: `sim/img_to_binary.py`, writes to sim/pixels.txt 

    2. VCS compile: builds `sim/img_conf_simv` from all RTL sources
    3. Simulate: runs the binary, produces sim/sobel_out.txt + sim/img_conv.vcd
    4. Reconstruct image: calls `sim/sobel_to_img.py` with the 34x34 padded dimensions.

```sh
    # Full run with default input image
    python3 run_pipeline.py Material/001.png

    # Custom output path
    python3 run_pipeline.py Material/001.png --output results/edges.png

    # Skip recompile if binary is already built
    python3 run_pipeline.py Material/001.png --no-compile

    # Full run including PTPX power analysis
    python3 run_pipeline.py Material/001.png --ptpx
```