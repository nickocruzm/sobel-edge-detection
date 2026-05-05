`timescale 1ns / 1ps

module img_conv_test;

    // Original image dimensions
    parameter IMG_W = 32;
    parameter IMG_H = 32;

    // Padded dimensions fed to conv (1 zero pixel per side)
    parameter PAD_W = IMG_W + 2;
    parameter PAD_H = IMG_H + 2;

    parameter TOTAL = IMG_W * IMG_H;

    // Pixel memory: loaded from binary text file
    reg [7:0] pixel_mem [0:TOTAL-1];

    // DUT signals
    reg        clk;
    reg        reset;
    reg  [7:0] pxl_in;

    wire [15:0] reg_00; wire [15:0] reg_01; wire [15:0] reg_02; wire [15:0] sr_0;
    wire [15:0] reg_10; wire [15:0] reg_11; wire [15:0] reg_12; wire [15:0] sr_1;
    wire [15:0] reg_20; wire [15:0] reg_21; wire [15:0] reg_22;
    wire [15:0] pxl_out;
    wire        valid;

    // Conv sees the padded image so valid output is IMG_W x IMG_H
    conv #(.N(PAD_W), .M(PAD_H)) uut (
        .clk(clk),
        .reset(reset),
        .pxl_in(pxl_in),
        .reg_00(reg_00), .reg_01(reg_01), .reg_02(reg_02), .sr_0(sr_0),
        .reg_10(reg_10), .reg_11(reg_11), .reg_12(reg_12), .sr_1(sr_1),
        .reg_20(reg_20), .reg_21(reg_21), .reg_22(reg_22),
        .pxl_out(pxl_out),
        .valid(valid)
    );

    // 10 ns half-period → 20 ns clock
    always #10 clk = ~clk;

    integer i, row, col;
    integer fd;

    // Write pxl_out to file whenever valid is high
    always @(posedge clk) begin
        if (valid)
            $fdisplay(fd, "%0d", pxl_out);
    end

    initial begin
        clk   = 0;
        reset = 1;
        pxl_in = 0;
        fd = $fopen("sobel_out.txt", "w");

        $readmemb("pixels.txt", pixel_mem);

        $monitor("t=%0t pxl_in=%0d | pxl_out=%0d valid=%b",
                 $time, pxl_in, pxl_out, valid);

        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        // Top padding row
        for (i = 0; i < PAD_W; i = i + 1) begin
            pxl_in = 0; @(posedge clk); #1;
        end

        // Each image row with 1 zero of left/right padding
        for (row = 0; row < IMG_H; row = row + 1) begin
            pxl_in = 0; @(posedge clk); #1;
            for (col = 0; col < IMG_W; col = col + 1) begin
                pxl_in = pixel_mem[row * IMG_W + col];
                @(posedge clk); #1;
            end
            pxl_in = 0; @(posedge clk); #1;
        end

        // Bottom padding row
        for (i = 0; i < PAD_W; i = i + 1) begin
            pxl_in = 0; @(posedge clk); #1;
        end

        pxl_in = 0;
        repeat (PAD_W + 4) @(posedge clk);

        $fclose(fd);
        $finish;
    end

    // Waveform dumps
    initial begin
        $dumpfile("img_conv.vcd");
        $dumpvars(0, img_conv_test);
    end

endmodule
