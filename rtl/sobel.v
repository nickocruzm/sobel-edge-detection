`timescale 1ns / 1ps
/*

- Instantiates conv_gx with the Gx kernel (-1 0 1 / -2 0 2 / -1 0 1)
- Instantiates conv_gy with the Gy kernel (1 2 1 / 0 0 0 / -1 -2 -1)
- Both receive the same pxl_in stream
- magnitude = |Gx| + |Gy| — the cheap L1-norm approximation of edge strength
- valid is taken from conv_gx (both instances have identical timing)
*/
module sobel(
    input clk,
    input reset,
    input [7:0] pxl_in,
    output [15:0] magnitude,
    output valid
);

    parameter N = 5;
    parameter M = 5;
    parameter K = 3;

    wire signed [15:0] gx, gy;
    wire conv_valid_wire;

    // Gx kernel:
    // -1  0  1
    // -2  0  2
    // -1  0  1
    conv #(
        .N(N), .M(M), .K(K),
        .K_00(-1), .K_01(0), .K_02(1),
        .K_10(-2), .K_11(0), .K_12(2),
        .K_20(-1), .K_21(0), .K_22(1)
    ) conv_gx (
        .clk(clk), .reset(reset), .pxl_in(pxl_in),
        .pxl_out(gx), .valid(conv_valid_wire),
        .reg_00(), .reg_01(), .reg_02(), .sr_0(),
        .reg_10(), .reg_11(), .reg_12(), .sr_1(),
        .reg_20(), .reg_21(), .reg_22()
    );

    // Gy kernel:
    //  1  2  1
    //  0  0  0
    // -1 -2 -1
    conv #(
        .N(N), .M(M), .K(K),
        .K_00(1),  .K_01(2),  .K_02(1),
        .K_10(0),  .K_11(0),  .K_12(0),
        .K_20(-1), .K_21(-2), .K_22(-1)
    ) conv_gy (
        .clk(clk), .reset(reset), .pxl_in(pxl_in),
        .pxl_out(gy), .valid(),
        .reg_00(), .reg_01(), .reg_02(), .sr_0(),
        .reg_10(), .reg_11(), .reg_12(), .sr_1(),
        .reg_20(), .reg_21(), .reg_22()
    );


    // absolute value of (gx) + (gy)
    reg [15:0] magnitude_reg;
    reg [3:0]  valid_delay;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            magnitude_reg <= 0;
            valid_delay   <= 0;
        end else begin
            // Register the L1 norm calculation (1 cycle of latency introduced here)
            magnitude_reg <= (gx < 0 ? -gx : gx) + (gy < 0 ? -gy : gy);
            
            // Delay the incoming valid signal by 4 total cycles to compensate 
            // for the conv inaccuracy + our new magnitude register stage
            valid_delay <= {valid_delay[2:0], conv_valid_wire}; 
        end
    end

    assign magnitude = magnitude_reg;
    assign valid     = valid_delay[3];

endmodule
