`timescale 1ns / 1ps

// Validates sobel.v with a 5x5 vertical step edge:
//   left 3 cols = 0, right 2 cols = 255
// Expected valid outputs (9 values, row-major):
//   0, 1020, 1020,  0, 1020, 1020,  0, 1020, 1020
module sobel_test;

    parameter N = 5;
    parameter M = 5;

    reg clk, reset;
    reg [7:0] pxl_in;

    wire [15:0] magnitude;
    wire valid;

    sobel #(.N(N), .M(M)) uut (
        .clk(clk), .reset(reset),
        .pxl_in(pxl_in),
        .magnitude(magnitude),
        .valid(valid)
    );

    always #5 clk = ~clk;

    // Step-edge image: cols 0-2 = 0, cols 3-4 = 255
    reg [7:0] img [0:24];
    integer i;

    initial begin
        img[0]=0;   img[1]=0;   img[2]=0;   img[3]=255; img[4]=255;
        img[5]=0;   img[6]=0;   img[7]=0;   img[8]=255; img[9]=255;
        img[10]=0;  img[11]=0;  img[12]=0;  img[13]=255; img[14]=255;
        img[15]=0;  img[16]=0;  img[17]=0;  img[18]=255; img[19]=255;
        img[20]=0;  img[21]=0;  img[22]=0;  img[23]=255; img[24]=255;
    end

    integer pass, fail;

    // Expected outputs in valid-output order
    reg [15:0] expected [0:8];
    integer out_idx;

    initial begin
        expected[0]=0;    expected[1]=1020; expected[2]=1020;
        expected[3]=0;    expected[4]=1020; expected[5]=1020;
        expected[6]=0;    expected[7]=1020; expected[8]=1020;
    end

    initial begin
        $dumpfile("sobel_test.vcd");
        $dumpvars(0, sobel_test);

        clk = 0; reset = 1; pxl_in = 0;
        pass = 0; fail = 0; out_idx = 0;

        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        for (i = 0; i < N*M; i = i + 1) begin
            pxl_in = img[i];
            @(posedge clk); #1;
        end

        pxl_in = 0;
        repeat (N + 4) @(posedge clk);

        $display("Result: %0d passed, %0d failed", pass, fail);
        $finish;
    end

    always @(posedge clk) begin
        if (valid) begin
            if (magnitude === expected[out_idx])
                $display("PASS [%0d] magnitude=%0d", out_idx, magnitude);
            else begin
                $display("FAIL [%0d] magnitude=%0d (expected %0d)", out_idx, magnitude, expected[out_idx]);
                fail = fail + 1;
            end
            if (magnitude === expected[out_idx]) pass = pass + 1;
            out_idx = out_idx + 1;
        end
    end

endmodule
