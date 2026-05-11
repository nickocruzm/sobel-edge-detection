`timescale 1ns / 1ps

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
        .pxl_out(gx), .valid(valid),
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

    assign magnitude = (gx < 0 ? -gx : gx) + (gy < 0 ? -gy : gy);

endmodule
