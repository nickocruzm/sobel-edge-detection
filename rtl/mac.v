// Multiply Accumulate Unit

`timescale 1ns / 1ps

module mac(
    input [7:0] in,
    input signed [7:0] w,
    input signed [15:0] b,
    output signed [15:0] out
);

/*
    The {1'b0, in} zero-extends in to 9 bits so it stays positive when treated as signed. Without that, values >= 128 would be interpreted as negative.

*/
    wire signed [15:0] d;
    assign d = $signed({1'b0, in}) * w;
    assign out = d + b;
 
endmodule
