# Notes

## img_conv_test.v

### 1. Init

- clk=0, reset=1, pxl_in=0
- Opens sobel_out.txt for writing
- Calls `$readmemb("pixels.txt", pixel_mem)`, loads all 1024 binary pixel values into a register array
- Instantiates conv with N=34, M=34 (the padded dimensions: 32+1 per side)
- Holds reset for 2 clock edges, then deasserts it


### 2. Zero-padded pixel streaming (img_conv_test.v, lines 68-91)

The testbench feeds a 34×34 zero-padded version of the 32×32 image, one pixel per clock:

- Top padding row — 34 zeros
- Each of the 32 image rows: `0, pixel_mem[row*32+0..31], 0` (34 pixels total)
- Bottom padding row — 34 zeros

Total stream: 34 × 34 = 1156 pixels, then 38 more idle clocks before `$finish`.

### 3. Streaming 3x3 convolution `rtl/conv.v`

kernel is hardcoded as:

```sh
1  2  1
0  0  0
1  2  1
```

The hardware implements a systolic (specialized parallel processing systems) pipeline with three chained rows of MACs (Mutliply Accumulate Operations):

**Row 1 MACs — horizontal accumulation (conv.v, lines: 35-43)**

Each clock, the current `pxl_in` combines with the previous cycle's register values. After 3 cycles of streaming:

- `reg_02[t]` holds the 1D convolution `pxl[t-1]*1 + pxl[t-2]*2 + pxl[t-3]*1` (top kernel row applied horizontally)

**Shift register row_1 (conv.v, line: 44):**

Delays `reg_02` by `D=2` cycles to pass the `row-1` result down to `row-2` MACs. 


**Row 2 MACs (kernel_10/11/12 = 0, 0, 0) (conv.v, lines: 47-56)**

Contributes zero (the middle kernel row is all zeros), but still advances the accumulator pipeline.

**Shift register row_2 + Row 3 MACs (conv.v, lines: 56-66):**

Applies the bottom kernel row `[1, 2, 1]` to the shifted-down values. The final result lands in `reg_22`, which is directly wired to `pxl_out`.

### 4: Valid signal gating (conv.v, lines: 72-90)

An internal counter increments every clock. valid goes high when:

```sh
    counter > (K-1)*N + (K-1)  →  counter > 70
    counter < M*N + (K-1)       →  counter < 1158
    (counter - 2) % N > 1       →  not in the left/right padding columns
```

This produces 32 valid outputs per row × 32 rows = 1024 valid pulses, matching the original 32×32 image size. The zero-padding is what makes the output the same size as the input ("same" convolution semantics).

### 5: Output capture and file write (img_conv_test.v, lines: 48-51)

On every positive clock edge where `valid=1`, the testbench writes `pxl_out` (decimal) to `sobel_out.txt`. At the end, you get (should) 1024 lines.

VCD waveform data is also dumped to `img_conv.vcd` for signal inspection

### 6. Post Processing

`sobel_to_img.py` reads `sobel_out.txt`, normalizes the 16-bit output values to [0, 255]. Updated script to default to the dimensions needed for 32x32 output.

From `sim/` directory:
`python3 sobel_to_img.py sobel_out.txt`

That uses the new defaults (--img-w 34 --img-h 34) and writes `sobel_result.png` in the same directory.

From repo root:
`python3 sim/sobel_to_img.py sim/sobel_out.txt sim/sobel_result.png`
