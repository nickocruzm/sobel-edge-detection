# Final Project CS220: Sobel Edge-Detector Optimization

UCR, Spring 2026, CS220 Synthesis of Digital Systems

**Team:** Alice (@alice8625), Sydney (@sydnyepie), Nicko (@nickocruzm)

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
