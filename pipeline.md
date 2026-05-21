# Pipeline
## Stage 1

Calls `sim/img_to_binary.py`, which:

> Opens the PNG and calls .convert("L") to convert to grayscale.Resizes to exactly 32×32 pixels. 
> Writes each pixel as an 8-bit binary string (e.g. 01101011), one per line — 1024 lines total.
> The output is written explicitly to sim/pixels.txt. This matters because the Verilog testbench hardcodes $readmemb("pixels.txt", pixel_mem), so the file must be named exactly that and present in the sim working directory when the binary runs.

## Stage 2
Invokes VCS to compile the testbench + RTL into a simulation binary at `sim/img_conv_simv

Key flags:

    `-sverilog` enables SystemVerilog parsing.
    `-full64` 64-bit build.
    `-debug_access` enables waveform dumping ($dumpvars in the testbench).

The testbench instantiates conv with `#(.N(34), .M(34))` that's 32 image pixels + 1 zero-padding pixel on each side overriding the 5×5 defaults in conv.v

> With `--no-compile`, this stage is skipped and the existing img_conv_simv binary is reused.

## Stage 3

`run([BINARY], cwd=SIM)`

Runs the compiled binary from `sim/` so that relative file paths inside the Verilog (`pixels.txt`, `sobel_out.txt`, `img_conv.vcd`) resolve correctly.

What the testbench does during this run:

1. `Loads `pixels.txt` into a 1024-entry register array.
2. Drives a 3 ns clock (333 MHz).
3. Feeds pixels into `conv` with zero-padding (one top row of 34 zeros), then each image row flanked by a zero on each side, then one bottom row of 34 zeros.
4. Whenever `conv` asserts `valid`, writes `pxl_out` (a 16-bit convolution result) as a decimal integer to `sobel_out.txt`.
5. Dumps all signal activity to `img_conv.vcd` — this VCD is what PTPX consumes for switching activity.


> After the run, the script checks that sobel_out.txt actually exists — if the simulation crashed silently it would be missing.

## Stage 4

`run(["python3", SIM / "sobel_to_img.py", SIM / "sobel_out.txt", output_image,"--img-w", "34", "--img-h", "34"], cwd=SIM)`

Calls `sim/sobel_to_img.py`, which:

1. Reads the 1024 decimal integers from `sobel_out.txt`.
2. Clips negative values to 0, normalizes the range to 0–255.
3. Reshapes to a 32×32 array (output is img_h-2 × img_w-2 = 32×32, stripping the padding border).
4. Saves as a grayscale PNG.

> The --img-w 34 --img-h 34 arguments are the padded dimensions — the script subtracts 2 from each to get the output pixel grid size.

## Stage 5

`run(["pt_shell", "-f", "ptpx.tcl"], cwd=PTPX)`

Only runs when you pass --ptpx. Launches Synopsys PrimeTime PX with ptpx/ptpx.tcl, which:

1. Loads the synthesized netlist from `syn/conv_synthesized.v`
2. Reads the VCD produced in Stage 3 and maps switching activity onto the netlist.
3. Writes power reports (`total_power.rpt`, `cell_power.rpt`, `unannotated.rpt`) into `ptpx/reports/`.

