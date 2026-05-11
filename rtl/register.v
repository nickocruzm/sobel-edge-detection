/*

- Instantiates conv_gx with the Gx kernel (-1 0 1 / -2 0 2 / -1 0 1)
- Instantiates conv_gy with the Gy kernel (1 2 1 / 0 0 0 / -1 -2 -1)
- Both receive the same pxl_in stream
- magnitude = |Gx| + |Gy| — the cheap L1-norm approximation of edge strength
- valid is taken from conv_gx (both instances have identical timing)
*/

`timescale 1ns / 1ps

module register(
    input clk,
    input reset,
    input signed [15:0] d,
    output reg signed [15:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 0;
        else q <= d;
    end
endmodule
