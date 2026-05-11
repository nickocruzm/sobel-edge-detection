# Final Project CS220: Sobel Edge-Detector Optimization

UCR, Spring 2026, CS220 Synthesis of Digital Systems

**Team:** Alice (@alice8625), Sydney (@sydnyepie), Nicko (@nickocruzm)

---

# Steps


## 1. Convert Image to Pixels

- In the `sim` directory there is a python file `img_to_binary.py`
- This file takes an image's path and output file name, `python3 img_to_binary.py <path_to_image.png> [output_file]`
- Currently ensure that img files are `.png`

Example
```bash
cd sim/
python3 img_to_binary.py ../Material/001.png

```

- If the image isn't already 32x32 it will be resized but this will degrade the quality of the image.
- the image is also converted to grayscale 
- Each pixel is written as an 8-bit binary string. one per line. (1024 lines total)

## 2. Compile the image convolution testbench

Still in `sim/` directory, compile with VCS:

```bash
vcs img_conv_test.v ../rtl/conv.v ../rtl/mac.v ../rtl/register.v ../rtl/shift.v \
    -full64 -debug_access -o img_conv_simv
```

The testbench (img_conv_test.v) instantiates conv at line 30, and conv.v itself instantiates mac, register, and shift. So the full dependency chain is:


img_conv_test
  └── conv          ← defined in conv.v
        ├── mac     ← defined in mac.v
        ├── register← defined in register.v
        └── shift   ← defined in shift.v


All four RTL files need to be passed to the compiler because VCS doesn't auto-discover source files — you have to explicitly list every module definition it needs to resolve. conv.v is the top-level design under test, and the other three are its sub-modules

`img_conv_test` is just a harness it drives inputs, read outputs, and check results but has no synthesizeable logic. conv is the actual hardware module being verified.


- The Dimensions explicitly in `conv.v` are `N=5,M=5` which don't match the `32x32` image but that is overidden at instantion time in our test best (line 30)
`conv #(.N(PAD_W), .M(PAD_H)) uut (`
With PAD_W = 34 and PAD_H = 34 (32 + 1 zero-padding pixel on each side). Verilog's #(.param(value)) syntax replaces the module's defaults entirely, so conv runs with N=34, M=34 during simulation regardless of what the defaults say.
The defaults of 5×5 are just leftover from early development and would only matter if someone instantiated conv without overriding the parameters.

## 3. execute

./img_conv_simv

## Recreate image

python3 sobel_to_img.py <pixels>.txt <output>.png --img-w <width> --img-h <height>

---

## PTPX

### How to run?
Assuming current working dir is `ptpx`

1. `cd ptpx`
2. `pt_shell -f ptpx.tcl` this will run both the conv analyses.


shift must be synthesized seperately.


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
