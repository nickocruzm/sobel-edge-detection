# TestBenches

## conv_test.v

Unit testbench for the conv module (single 3×3 convolution). Drives a stream of 8-bit pixels into the DUT one clock at a time using reusable tasks (send_pixel, send_and_check). Runs 20 hand-crafted 5×5 test cases — zero matrix, identity, checkerboard, gradients, triangular patterns — and reports pass/fail counts per check. Includes a timeout watchdog and dumps waveforms to conv.vcd.


## img_conv_test.v

Integration testbench that feeds a real 32×32 pixel image through conv. Loads pixel data from pixels.txt using $readmemb, applies zero-padding (one row/column per side), streams the padded image pixel-by-pixel, and writes each valid output to sobel_out.txt. Intended to be paired with the Python script that reconstructs the output image.

## shift_testbench.v

Minimal testbench for the shift (delay line) module. Drives five 16-bit values through the shift register, waits D clock cycles for full propagation, and checks that data_out matches the input. Dumps waveforms to shift_tb.vcd.

## sobel_test.v

Combined testbench that instantiates both sobel and conv in the same harness. Uses a 5×5 step-edge image (left half 0, right half 255) to verify the Sobel magnitude output against precomputed expected values. The conv section auto-derives expected values at runtime from the DUT's own kernel constants (K_*), so no hand-calculated numbers are needed. Prints formatted 3×3 result matrices and a final pass/fail summary.