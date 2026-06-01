// Merged testbench:
//   - Section 1: original sobel test (5x5 vertical step edge), checks magnitude
//   - Section 2: conv test in the same harness style, checks pxl_out against
//                an auto-computed convolution using the conv instance's own kernel
//
// Both DUTs are driven from the same img[] array via the same loop structure.
// Expected values are auto-derived from the kernel constants (uut.K_*), so no
// hand-calculated constants are needed.

module sobel_test;

    parameter N = 5;
    parameter M = 5;

    reg clk, reset;
    reg [7:0] pxl_in;

    // ─── Sobel DUT ────────────────────────────────────────
    wire [15:0] magnitude;
    wire        valid;

    sobel #(.N(N), .M(M)) uut (
        .clk(clk),
        .reset(reset),
        .pxl_in(pxl_in),
        .magnitude(magnitude),
        .valid(valid)
    );

    // ─── Conv DUT (default kernel: 1 2 1 / 0 0 0 / -1 -2 -1) ──
    wire signed [15:0] c_pxl_out;
    wire               c_valid;
    // Unused window-register outputs
    wire signed [15:0] c00, c01, c02, csr0;
    wire signed [15:0] c10, c11, c12, csr1;
    wire signed [15:0] c20, c21, c22;

    conv #(.N(N), .M(M)) uut_conv (
        .clk(clk),
        .reset(reset),
        .pxl_in(pxl_in),
        .reg_00(c00), .reg_01(c01), .reg_02(c02), .sr_0(csr0),
        .reg_10(c10), .reg_11(c11), .reg_12(c12), .sr_1(csr1),
        .reg_20(c20), .reg_21(c21), .reg_22(c22),
        .pxl_out(c_pxl_out),
        .valid(c_valid)
    );

    always #5 clk = ~clk;

    // ─── Shared image: cols 0-2 = 0, cols 3-4 = 255 ───────
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

    // ─── Sobel bookkeeping ────────────────────────────────
    reg [15:0] expected [0:8];
    reg [15:0] results  [0:8];
    integer out_idx;

    integer r_out, c_out;
    integer p00, p01, p02, p10, p11, p12, p20, p21, p22;
    integer gx_val, gy_val;

    // ─── Conv bookkeeping ─────────────────────────────────
    reg signed [15:0] c_results [0:8];
    integer c_out_idx;
    integer cr_out, cc_out;
    integer cp00, cp01, cp02, cp10, cp11, cp12, cp20, cp21, cp22;
    integer c_expected_val;

    // EXPECTED sobel magnitude matrix after computation
    initial begin
        expected[0]=0;    expected[1]=1020; expected[2]=1020;
        expected[3]=0;    expected[4]=1020; expected[5]=1020;
        expected[6]=0;    expected[7]=1020; expected[8]=1020;
    end

    // ─── Stimulus ─────────────────────────────────────────
    initial begin
        $dumpfile("generated/sobel_test.vcd");
        $dumpvars(0, sobel_test);

        clk = 0; reset = 1; pxl_in = 0;
        pass = 0; fail = 0;
        out_idx = 0; c_out_idx = 0;

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

        // ── Sobel report ──
        $display("");
        $display("===== SOBEL =====");
        $display("Expected magnitude matrix (3x3):");
        $display("  %5d %5d %5d", expected[0], expected[1], expected[2]);
        $display("  %5d %5d %5d", expected[3], expected[4], expected[5]);
        $display("  %5d %5d %5d", expected[6], expected[7], expected[8]);
        $display("Output magnitude matrix (3x3):");
        $display("  %5d %5d %5d", results[0], results[1], results[2]);
        $display("  %5d %5d %5d", results[3], results[4], results[5]);
        $display("  %5d %5d %5d", results[6], results[7], results[8]);

        // ── Conv report ──
        $display("");
        $display("===== CONV =====");
        $display("Output pxl_out matrix (3x3):");
        $display("  %6d %6d %6d", c_results[0], c_results[1], c_results[2]);
        $display("  %6d %6d %6d", c_results[3], c_results[4], c_results[5]);
        $display("  %6d %6d %6d", c_results[6], c_results[7], c_results[8]);

        $display("");
        $display("Result: %0d passed, %0d failed", pass, fail);
        $finish;
    end

    // ─── Sobel capture / check (auto-computed expected) ───
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

            $display("--- SOBEL Output[%0d] window (row=%0d, col=%0d) ---", out_idx, r_out, c_out);
            $display("  Gx: (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p00,$signed(uut.conv_gx.K_00), p01,$signed(uut.conv_gx.K_01), p02,$signed(uut.conv_gx.K_02));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p10,$signed(uut.conv_gx.K_10), p11,$signed(uut.conv_gx.K_11), p12,$signed(uut.conv_gx.K_12));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d) = %0d", p20,$signed(uut.conv_gx.K_20), p21,$signed(uut.conv_gx.K_21), p22,$signed(uut.conv_gx.K_22), gx_val);
            $display("  Gy: (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p00,$signed(uut.conv_gy.K_00), p01,$signed(uut.conv_gy.K_01), p02,$signed(uut.conv_gy.K_02));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", p10,$signed(uut.conv_gy.K_10), p11,$signed(uut.conv_gy.K_11), p12,$signed(uut.conv_gy.K_12));
            $display("    + (%0d*%0d)+(%0d*%0d)+(%0d*%0d) = %0d", p20,$signed(uut.conv_gy.K_20), p21,$signed(uut.conv_gy.K_21), p22,$signed(uut.conv_gy.K_22), gy_val);
            $display("  magnitude = |%0d| + |%0d| = %0d", gx_val, gy_val, magnitude);
            if (magnitude === expected[out_idx])
                $display("PASS SOBEL[%0d] magnitude=%0d", out_idx, magnitude);
            else begin
                $display("FAIL SOBEL[%0d] magnitude=%0d (expected %0d)", out_idx, magnitude, expected[out_idx]);
                fail = fail + 1;
            end
            if (magnitude === expected[out_idx]) pass = pass + 1;
            out_idx = out_idx + 1;
        end
    end

    // ─── Conv capture / check (auto-computed expected) ────
    always @(posedge clk) begin
        if (c_valid) begin
            c_results[c_out_idx] = c_pxl_out;

            cr_out = c_out_idx / 3;
            cc_out = c_out_idx % 3;
            cp00 = img[(cr_out+0)*N + (cc_out+0)]; cp01 = img[(cr_out+0)*N + (cc_out+1)]; cp02 = img[(cr_out+0)*N + (cc_out+2)];
            cp10 = img[(cr_out+1)*N + (cc_out+0)]; cp11 = img[(cr_out+1)*N + (cc_out+1)]; cp12 = img[(cr_out+1)*N + (cc_out+2)];
            cp20 = img[(cr_out+2)*N + (cc_out+0)]; cp21 = img[(cr_out+2)*N + (cc_out+1)]; cp22 = img[(cr_out+2)*N + (cc_out+2)];

            c_expected_val = (cp00*$signed(uut_conv.K_00)) + (cp01*$signed(uut_conv.K_01)) + (cp02*$signed(uut_conv.K_02))
                           + (cp10*$signed(uut_conv.K_10)) + (cp11*$signed(uut_conv.K_11)) + (cp12*$signed(uut_conv.K_12))
                           + (cp20*$signed(uut_conv.K_20)) + (cp21*$signed(uut_conv.K_21)) + (cp22*$signed(uut_conv.K_22));

            $display("--- CONV Output[%0d] window (row=%0d, col=%0d) ---", c_out_idx, cr_out, cc_out);
            $display("  conv: (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", cp00,$signed(uut_conv.K_00), cp01,$signed(uut_conv.K_01), cp02,$signed(uut_conv.K_02));
            $display("      + (%0d*%0d)+(%0d*%0d)+(%0d*%0d)", cp10,$signed(uut_conv.K_10), cp11,$signed(uut_conv.K_11), cp12,$signed(uut_conv.K_12));
            $display("      + (%0d*%0d)+(%0d*%0d)+(%0d*%0d) = %0d", cp20,$signed(uut_conv.K_20), cp21,$signed(uut_conv.K_21), cp22,$signed(uut_conv.K_22), c_expected_val);
            if (c_pxl_out === c_expected_val[15:0])
                $display("PASS CONV[%0d] pxl_out=%0d", c_out_idx, c_pxl_out);
            else begin
                $display("FAIL CONV[%0d] pxl_out=%0d (expected %0d)", c_out_idx, c_pxl_out, c_expected_val);
                fail = fail + 1;
            end
            if (c_pxl_out === c_expected_val[15:0]) pass = pass + 1;
            c_out_idx = c_out_idx + 1;
        end
    end

endmodule
