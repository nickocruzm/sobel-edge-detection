`timescale 1ns / 1ps
// Streams a real 32x32 image (loaded from pixels.txt) through the sobel module
// with 1-pixel zero padding on every side, so the valid output is IMG_W x IMG_H.
// Each valid magnitude is written to sobel_out.txt (one value per line).
module img_sobel_test;
    // Original image dimensions
    parameter IMG_W = 32;
    parameter IMG_H = 32;
    // Padded dimensions fed to sobel (1 zero pixel per side)
    parameter PAD_W = IMG_W + 2;
    parameter PAD_H = IMG_H + 2;
    parameter TOTAL = IMG_W * IMG_H;

    // Pixel memory: loaded from binary text file
    reg [7:0] pixel_mem [0:TOTAL-1];

    // DUT signals
    reg        clk;
    reg        reset;
    reg  [7:0] pxl_in;
    wire [15:0] magnitude;
    wire        valid;

    // Sobel sees the padded image so valid output is IMG_W x IMG_H
    sobel #(.N(PAD_W), .M(PAD_H)) uut (
        .clk(clk),
        .reset(reset),
        .pxl_in(pxl_in),
        .magnitude(magnitude),
        .valid(valid)
    );

    // 1.5 ns half-period -> 3 ns clock (333 MHz)
    always #1.5 clk = ~clk;

    integer i, row, col;
    integer fd;

    // Write magnitude to file whenever valid is high
    always @(posedge clk) begin
        if (valid)
            $fdisplay(fd, "%0d", magnitude);
    end
    
    string in_file;
    string out_file;

    initial begin
        clk    = 0;
        reset  = 1;
        pxl_in = 0;
        if (!$value$plusargs("IN=%s", in_file)) in_file = "../../Material/pixels/002.txt";
        if (!$value$plusargs("OUT=%s", out_file)) out_file = "../../Material/sobel/output/002.txt";

        fd = $fopen(out_file, "w");
        $readmemb(in_file, pixel_mem);
        $monitor("t=%0t pxl_in=%0d | magnitude=%0d valid=%b",
                 $time, pxl_in, magnitude, valid);

        @(posedge clk); #0.1;
        @(posedge clk); #0.1;
        reset = 0;

        // Top padding row
        for (i = 0; i < PAD_W; i = i + 1) begin
            pxl_in = 0; @(posedge clk); #0.1;
        end

        // Each image row with 1 zero of left/right padding
        for (row = 0; row < IMG_H; row = row + 1) begin
            pxl_in = 0; @(posedge clk); #0.1;
            for (col = 0; col < IMG_W; col = col + 1) begin
                pxl_in = pixel_mem[row * IMG_W + col];
                @(posedge clk); #0.1;
            end
            pxl_in = 0; @(posedge clk); #0.1;
        end

        // Bottom padding row
        for (i = 0; i < PAD_W; i = i + 1) begin
            pxl_in = 0; @(posedge clk); #0.1;
        end

        pxl_in = 0;
        repeat (PAD_W + 4) @(posedge clk);

        $fclose(fd);
        $finish;
    end

    // Waveform dumps
    initial begin
        $dumpfile("generated/img_sobel.vcd");
        $dumpvars(0, img_sobel_test);
    end
endmodule