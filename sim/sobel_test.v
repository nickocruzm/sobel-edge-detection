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

    /*
        TEST INPUT IMAGE 5X5
        simulates a sharp vertical intensity boundary (step-edge pattern)
        left 3 columns are 0
        right 2 columns are 255, applied uniformly across all rows.
    */
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
    reg [15:0] results  [0:8];
    integer out_idx;

    integer r_out, c_out;
    integer p00, p01, p02, p10, p11, p12, p20, p21, p22;
    integer gx_val, gy_val;

    // EXPECTED MATRIX after computation
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

        // 5x5 input image 0-255 values
        $display("Input %0dx%0d pixel matrix:", N, M);
        $display("  %3d %3d %3d %3d %3d", img[0],  img[1],  img[2],  img[3],  img[4]);
        $display("  %3d %3d %3d %3d %3d", img[5],  img[6],  img[7],  img[8],  img[9]);
        $display("  %3d %3d %3d %3d %3d", img[10], img[11], img[12], img[13], img[14]);
        $display("  %3d %3d %3d %3d %3d", img[15], img[16], img[17], img[18], img[19]);
        $display("  %3d %3d %3d %3d %3d", img[20], img[21], img[22], img[23], img[24]);

        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        for (i = 0; i < N*M; i = i + 1) begin
            pxl_in = img[i];
            @(posedge clk); #1;
        end

        pxl_in = 0;
        repeat (N + 4) @(posedge clk);

        $display("Expected magnitude matrix (3x3):");
        $display("  %5d %5d %5d", expected[0], expected[1], expected[2]);
        $display("  %5d %5d %5d", expected[3], expected[4], expected[5]);
        $display("  %5d %5d %5d", expected[6], expected[7], expected[8]);
        $display("Output magnitude matrix (3x3):");
        $display("  %5d %5d %5d", results[0], results[1], results[2]);
        $display("  %5d %5d %5d", results[3], results[4], results[5]);
        $display("  %5d %5d %5d", results[6], results[7], results[8]);
        $display("Result: %0d passed, %0d failed", pass, fail);
        $finish;
    end

    always @(posedge clk) begin
        if (valid) begin
            results[out_idx] = magnitude;

            r_out = out_idx / 3;
            c_out = out_idx % 3;
            p00 = img[(r_out+0)*N + (c_out+0)]; p01 = img[(r_out+0)*N + (c_out+1)]; p02 = img[(r_out+0)*N + (c_out+2)];
            p10 = img[(r_out+1)*N + (c_out+0)]; p11 = img[(r_out+1)*N + (c_out+1)]; p12 = img[(r_out+1)*N + (c_out+2)];
            p20 = img[(r_out+2)*N + (c_out+0)]; p21 = img[(r_out+2)*N + (c_out+1)]; p22 = img[(r_out+2)*N + (c_out+2)];

            gx_val = (p00*$signed(uut.conv_gx.K_00)) + (p01*$signed(uut.conv_gx.K_01)) + (p02*$signed(uut.conv_gx.K_02))
                   + (p10*$signed(uut.conv_gx.K_10)) + (p11*$signed(uut.conv_gx.K_11)) + (p12*$signed(uut.conv_gx.K_12))
                   + (p20*$signed(uut.conv_gx.K_20)) + (p21*$signed(uut.conv_gx.K_21)) + (p22*$signed(uut.conv_gx.K_22));

            gy_val = (p00*$signed(uut.conv_gy.K_00)) + (p01*$signed(uut.conv_gy.K_01)) + (p02*$signed(uut.conv_gy.K_02))
                   + (p10*$signed(uut.conv_gy.K_10)) + (p11*$signed(uut.conv_gy.K_11)) + (p12*$signed(uut.conv_gy.K_12))
                   + (p20*$signed(uut.conv_gy.K_20)) + (p21*$signed(uut.conv_gy.K_21)) + (p22*$signed(uut.conv_gy.K_22));

            $display("--- Output[%0d] window (row=%0d, col=%0d) ---", out_idx, r_out, c_out);
            $display("  Gx: (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p00,$signed(uut.conv_gx.K_00), p01,$signed(uut.conv_gx.K_01), p02,$signed(uut.conv_gx.K_02));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p10,$signed(uut.conv_gx.K_10), p11,$signed(uut.conv_gx.K_11), p12,$signed(uut.conv_gx.K_12));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d) = %0d", p20,$signed(uut.conv_gx.K_20), p21,$signed(uut.conv_gx.K_21), p22,$signed(uut.conv_gx.K_22), gx_val);
            $display("  Gy: (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p00,$signed(uut.conv_gy.K_00), p01,$signed(uut.conv_gy.K_01), p02,$signed(uut.conv_gy.K_02));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p10,$signed(uut.conv_gy.K_10), p11,$signed(uut.conv_gy.K_11), p12,$signed(uut.conv_gy.K_12));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d) = %0d", p20,$signed(uut.conv_gy.K_20), p21,$signed(uut.conv_gy.K_21), p22,$signed(uut.conv_gy.K_22), gy_val);
            $display("  magnitude = |%0d| + |%0d| = %0d", gx_val, gy_val, magnitude);
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
