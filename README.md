# Final Project CS220: Sobel Edge-Detector Optimization

UCR, Spring 2026, CS220 Synthesis of Digital Systems

**Team:** Alice (@alice8625), Sydney (@sydnyepie), Nicko (@nickocruzm)

---

## Recreate image

# 1. Convert input image to pixels.txt
python3 sim/img_to_binary.py Material/001.png sim/pixels.txt

# 2. Run simulation (produces sobel_out.txt)
cd sim && ./img_conv_simv

# 3. Reconstruct the Sobel output image
python3 sobel_to_img.py sobel_out.txt sobel_result.png


## How to pass an image and test

### Prerequisites
Install Pillow (Python is already on the remote machine):
```bash
pip3 install Pillow
```

### Step 1 — Convert the image to pixel data
From the `sim/` directory, run `img_to_binary.py` with your image:
```bash
cd sim/
python3 img_to_binary.py <path_to_image> [output_file]
```
- The image is resized to **32×32** and converted to grayscale automatically.
- `output_file` defaults to `<image_stem>.txt` if omitted.
- The testbench reads from `pixels.txt`, so either name it that directly or copy/rename afterwards:
```bash
python3 img_to_binary.py ../Material/<img_name>.png pixels.txt
```
- Currently only use .png images if you want to add images.
- 

### Step 2 — Compile the image convolution testbench
Still in `sim/`, compile with VCS:
```bash
vcs img_conv_test.v ../rtl/conv.v ../rtl/mac.v ../rtl/register.v ../rtl/shift.v \
    -full64 -debug_access -o img_conv_simv
```

### Step 3 — Run the simulation
```bash
./img_conv_simv
```
- Console output shows `pxl_in` / `pxl_out` / `valid` for every clock cycle.
- `valid=1` marks cycles where the output pixel is meaningful (pipeline has filled).
- A waveform file `img_conv.vcd` is written automatically and can be opened in DVE or GTKWave.

### Step 4 — Run PTPX power analysis
> **Requires synthesis to have been run first** — `syn/conv_synthesized.v` must exist.
> If it doesn't, run synthesis first (see **How to Run → Step 2** below).

From the `ptpx/` directory, launch PrimeTime PX using the image convolution script:
```bash
cd ptpx/
pt_shell -f img_conv_ptpx.tcl |& tee logs/img_conv_ptpx_run.log
```

This reads `../sim/img_conv.vcd` (the waveform from Step 3) and annotates switching
activity onto the synthesized netlist to compute real dynamic power.

Power reports are written to `ptpx/`:
| File | Contents |
|------|----------|
| `img_conv_total_power.log` | Total dynamic + leakage power summary |
| `img_conv_cell_power.log` | Per-cell power breakdown |
| `img_conv_unannotated.log` | Nets with no VCD activity annotation (debug) |

### Where to find all benchmark numbers

| Metric | File |
|--------|------|
| **Dynamic power** | `ptpx/img_conv_total_power.log` |
| **Per-cell power** | `ptpx/img_conv_cell_power.log` |
| **Timing / WNS** | `syn/reports/conv_timing_reports.log` |
| **Area** | `syn/reports/conv_area_reports.log` |
| **Static power** | `syn/reports/conv_power_reports.log` |
| **QoR summary** | `syn/reports/conv_qor_reports.log` |

---

## How to Run

### Prerequisites
- Synopsys VCS (simulation)
- Synopsys Design Compiler / `dc_shell` (synthesis)
- SAED32 standard cell library

### Project Structure
```
sobel-edge-detection/
├── rtl/          # Verilog source files
├── sim/          # Testbenches
└── syn/          # Synthesis script and outputs
```

### Step 1 — RTL Simulation (pre-synthesis)

From the `sim/` directory, compile and run with VCS:

**Full convolution test:**
```bash
cd sim/
vcs conv_test.v ../rtl/conv.v ../rtl/mac.v ../rtl/register.v ../rtl/shift.v -full64 -debug_access
./simv
```

**Shift register test:**
```bash
cd sim/
vcs shift_testbench.v ../rtl/shift.v -full64 -debug_access
./simv
```

### Step 2 — Synthesis

1. Open `syn/syn.tcl` and update the two path variables at the top:
   ```tcl
   set HOME      "/your/home/directory"
   set DIRECTORY "path/to/sobel-edge-detection"
   ```

2. From the `syn/` directory, run Design Compiler:
   ```bash
   cd syn/
   dc_shell -f syn.tcl
   ```

   Outputs written to `syn/`:
   - `conv_synthesized.v` — gate-level netlist
   - `conv_synthesized.ddc` — DC design database
   - `conv_const.sdc` / `conv_const.sdf` — timing constraints and SDF annotations
   - `reports/` — area, timing, power, and QoR reports

### Step 3 — Post-Synthesis Simulation

After synthesis, simulate the gate-level netlist with SDF back-annotation:

```bash
cd sim/
vcs conv_test.v ../syn/conv_synthesized.v -full64 -debug_access \
  /usr/local/synopsys/verdi/W-2024.09-SP2-5/share/PLI/VCS/LINUX64/pli.a +neg_tchk \
  -sdf max:conv_test.uut:../syn/conv_const.sdf \
  -v /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v
./simv
```

---

Below this point is the original README.md provided by original author
## Implementation of Sobel Filter on Verilog
---
The code currently computes convolution of an image with a fixed kernel to find a gradient. By extending the logic to two gradients along x and y axes, and computing the square root of the squared sums, Sobel filter can be implemented.

The convolution approach has been adopted from [this paper](http://ieeexplore.ieee.org/document/5272559/).

## Example

Assume we have a 5*5 image.

| 1    |    2 |    3 |   4 |   5 |
| ------------- |:-------------:| -----:|:-------------:| -----:|
| 0    |    1 |    0 |   1 |   0 |
| 1    |    2 |    3 |   4 |   5 |
| 0    |    1 |    0 |   1 |   0 |
| 1    |    2 |    3 |   4 |   5 |

and a 3*3 kernel

| 1    |    2 |    1 |
| ------------- |:-------------:| -----:|
| 0    |    0 |    0 |
| 1    |    2 |    1 |

The output result would be

| 7    |    12 |    16 |
| ------------- |:-------------:| -----:|
| 4    |    4  |    4  |
| 7    |    12 |    16 |

## Simulation 

The result can be verified from the screenshot here. Note that the pxl_out bits are considered only when the valid bit is `1`.

![alt tag](Material/Simulation.png)
