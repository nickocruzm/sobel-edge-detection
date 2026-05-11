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
