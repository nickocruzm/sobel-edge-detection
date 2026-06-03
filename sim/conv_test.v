`timescale 1ns / 1ps
module conv_tb;
        // ─── Signals ──────────────────────────────────────────
    reg        clk;
    reg        reset;
    reg  [7:0] pxl_in;
    wire [15:0] pxl_out;
    wire        valid;
    // ─── Test bookkeeping ─────────────────────────────────
    integer pass_count;
    integer fail_count;

    // ─── DUT Instantiation ────────────────────────────────
    conv uut (
        .clk    (clk),
        .reset  (reset),
        .pxl_in (pxl_in),
        .pxl_out(pxl_out),
        .valid  (valid)
    );

    // ─── Clock Generation ─────────────────────────────────
    initial clk = 0;
    always #10 clk = ~clk;

    // ─── Timeout Watchdog ─────────────────────────────────
    initial begin
        #200000;
        $display("TIMEOUT: simulation exceeded limit at t=%0t", $time);
        $finish;
    end

    // ─── Tasks ────────────────────────────────────────────

    task do_reset;
        begin
            reset = 1;
            repeat(2) @(posedge clk); #1;
            reset = 0;
            @(posedge clk); #1;
        end
    endtask

    // basically a function (reusable block)
    task send_pixel;
    // 8-bit input arg
        input [7:0] val;
        begin
            // Drive the DUT's input signal
            pxl_in = val;
            // Wait for next rising clock edge
            @(posedge clk);
            // wait 1 time unit after edge
            #1;
        end
    endtask

    // Send all 25 pixels of a 5x5 image from a flat array
    task send_image;
        input [7:0] img [0:24];
        integer i;
        begin
            for (i = 0; i < 25; i = i + 1)
                send_pixel(img[i]);
        end
    endtask

    task check;
        input [15:0] expected;
        input integer test_num;
        input integer check_num;
        begin
            if (pxl_out !== expected) begin
                $display("FAIL %0d.%0d: expected %0d, got %0d  (t=%0t)",
                          test_num, check_num, expected, pxl_out, $time);
                $display("  window: [%3d %3d %3d] [%3d %3d %3d] [%3d %3d %3d]",
                          uut.reg_00, uut.reg_01, uut.reg_02,
                          uut.reg_10, uut.reg_11, uut.reg_12,
                          uut.reg_20, uut.reg_21, uut.reg_22);
                fail_count = fail_count + 1;
                // $finish;
            end else begin
                $display("PASS %0d.%0d: (t=%0t)",
                            test_num, check_num, $time);
                $display("  window: [%3d %3d %3d] [%3d %3d %3d] [%3d %3d %3d]",
                          uut.reg_00, uut.reg_01, uut.reg_02,
                          uut.reg_10, uut.reg_11, uut.reg_12,
                          uut.reg_20, uut.reg_21, uut.reg_22);
                pass_count = pass_count + 1;
            end
        end
    endtask

    // Send pixel, then immediately check pxl_out
    task send_and_check;
        input [7:0]  val;
        input [15:0] expected;
        input integer test_num;
        input integer check_num;
        begin
            send_pixel(val);
            check(expected, test_num, check_num);
        end
    endtask

    // ─── Stimulus ─────────────────────────────────────────
    initial begin
        pass_count = 0;
        fail_count = 0;
        pxl_in     = 0;

        $monitor("t=%0t pxl_in=%0d | pxl_out=%0d valid=%b",
                  $time, pxl_in, $signed(pxl_out), valid);

        do_reset;

        // ── Test 1: (1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5) ──
        send_pixel(1); send_pixel(2); send_pixel(3); send_pixel(4); send_pixel(5);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(1); send_pixel(2);
        // args: last_pixel_value, expected_value, Test, test number
        send_and_check(3,  16'd0, 1, 1);
        send_and_check(4,  16'd0, 1, 2);
        send_and_check(5,  16'd0, 1, 3);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd16,  1, 4);
        send_and_check(1,  16'd16,  1, 5);
        send_and_check(0,  16'd16,  1, 6);
        send_pixel(1); send_pixel(2);
        send_and_check(3,  16'd0, 1, 7);
        send_and_check(4,  16'd0, 1, 8);
        send_and_check(5,  16'd0, 1, 9);
        $display("PASS TEST 1"); do_reset;

        // ── Test 2: (0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0) ──
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(1); send_pixel(2); send_pixel(3); send_pixel(4); send_pixel(5);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd16,  2, 1);
        send_and_check(1,  16'd16,  2, 2);
        send_and_check(0,  16'd16,  2, 3);
        send_pixel(1); send_pixel(2);
        send_and_check(3,  16'd0, 2, 4);
        send_and_check(4,  16'd0, 2, 5);
        send_and_check(5,  16'd0, 2, 6);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd16,  2, 7);
        send_and_check(1,  16'd16,  2, 8);
        send_and_check(0,  16'd16,  2, 9);
        $display("PASS TEST 2"); do_reset;

        // ── Test 3: (5 4 3 2 1 | 0 1 0 1 0 | 5 4 3 2 1 | 0 1 0 1 0 | 5 4 3 2 1) ──
        send_pixel(5); send_pixel(4); send_pixel(3); send_pixel(2); send_pixel(1);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(5); send_pixel(4);
        send_and_check(3,  16'd32, 3, 1);
        send_and_check(2,  16'd24, 3, 2);
        send_and_check(1,  16'd16, 3, 3);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd4,  3, 4);
        send_and_check(1,  16'd4,  3, 5);
        send_and_check(0,  16'd4,  3, 6);
        send_pixel(5); send_pixel(4);
        send_and_check(3,  16'd32, 3, 7);
        send_and_check(2,  16'd24, 3, 8);
        send_and_check(1,  16'd16, 3, 9);
        $display("PASS TEST 3"); do_reset;

        // ── Test 4: (1 2 3 4 5 | 1 0 1 0 1 | 1 2 3 4 5 | 1 0 1 0 1 | 1 2 3 4 5) ──
        send_pixel(1); send_pixel(2); send_pixel(3); send_pixel(4); send_pixel(5);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(1); send_pixel(2);
        send_and_check(3,  16'd16, 4, 1);
        send_and_check(4,  16'd24, 4, 2);
        send_and_check(5,  16'd32, 4, 3);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd4,  4, 4);
        send_and_check(1,  16'd4,  4, 5);
        send_and_check(0,  16'd4,  4, 6);
        send_pixel(1); send_pixel(2);
        send_and_check(3,  16'd16, 4, 7);
        send_and_check(4,  16'd24, 4, 8);
        send_and_check(5,  16'd32, 4, 9);
        $display("PASS TEST 4"); do_reset;

        // ── Test 5: Zero Matrix ────────────────────────────
        repeat(12) send_pixel(0);
        send_and_check(0, 16'd0, 5, 1);
        send_and_check(0, 16'd0, 5, 2);
        send_and_check(0, 16'd0, 5, 3);
        repeat(2) send_pixel(0);
        send_and_check(0, 16'd0, 5, 4);
        send_and_check(0, 16'd0, 5, 5);
        send_and_check(0, 16'd0, 5, 6);
        repeat(2) send_pixel(0);
        send_and_check(0, 16'd0, 5, 7);
        send_and_check(0, 16'd0, 5, 8);
        send_and_check(0, 16'd0, 5, 9);
        $display("PASS TEST 5"); do_reset;

        // ── Test 6: Ones Matrix ────────────────────────────
        repeat(12) send_pixel(1);
        send_and_check(1, 16'd8, 6, 1);
        send_and_check(1, 16'd8, 6, 2);
        send_and_check(1, 16'd8, 6, 3);
        repeat(2) send_pixel(1);
        send_and_check(1, 16'd8, 6, 4);
        send_and_check(1, 16'd8, 6, 5);
        send_and_check(1, 16'd8, 6, 6);
        repeat(2) send_pixel(1);
        send_and_check(1, 16'd8, 6, 7);
        send_and_check(1, 16'd8, 6, 8);
        send_and_check(1, 16'd8, 6, 9);
        $display("PASS TEST 6"); do_reset;

        // ── Test 7: (1 1 1 1 1 | 0 0 0 0 0 | 0 0 0 0 0 | 0 0 0 0 0 | 1 1 1 1 1) ──
        repeat(5) send_pixel(1);
        repeat(7) send_pixel(0);
        send_and_check(0, 16'd4, 7, 1);
        send_and_check(0, 16'd4, 7, 2);
        send_and_check(0, 16'd4, 7, 3);
        repeat(2) send_pixel(0);
        send_and_check(0, 16'd0, 7, 4);
        send_and_check(0, 16'd0, 7, 5);
        send_and_check(0, 16'd0, 7, 6);
        repeat(2) send_pixel(1);
        send_and_check(1, 16'd4, 7, 7);
        send_and_check(1, 16'd4, 7, 8);
        send_and_check(1, 16'd4, 7, 9);
        $display("PASS TEST 7"); do_reset;

        // ── Test 8: (0 0 0 0 0 | 0 1 1 1 0 | 0 1 1 1 0 | 0 1 1 1 0 | 0 0 0 0 0) ──
        repeat(5) send_pixel(0);
        send_pixel(0); send_pixel(1); send_pixel(1); send_pixel(1); send_pixel(0);
        send_pixel(0); send_pixel(1);
        send_and_check(1,  16'd3, 8, 1);
        send_and_check(1,  16'd4, 8, 2);
        send_and_check(0,  16'd3, 8, 3);
        send_pixel(0); send_pixel(1);
        send_and_check(1,  16'd6, 8, 4);
        send_and_check(1,  16'd8, 8, 5);
        send_and_check(0,  16'd6, 8, 6);
        repeat(3) send_pixel(0);
        send_and_check(0,  16'd3, 8, 7);
        send_and_check(0,  16'd4, 8, 8);
        send_and_check(0,  16'd3, 8, 9);
        $display("PASS TEST 8"); do_reset;

        // ── Test 9: (0 0 0 0 0 | 1 1 1 1 1 | 1 1 1 1 1 | 1 1 1 1 1 | 0 0 0 0 0) ──
        repeat(5) send_pixel(0);
        repeat(7) send_pixel(1);
        send_and_check(1, 16'd4, 9, 1);
        send_and_check(1, 16'd4, 9, 2);
        send_and_check(1, 16'd4, 9, 3);
        repeat(2) send_pixel(1);
        send_and_check(1, 16'd8, 9, 4);
        send_and_check(1, 16'd8, 9, 5);
        send_and_check(1, 16'd8, 9, 6);
        repeat(2) send_pixel(0);
        send_and_check(0, 16'd4, 9, 7);
        send_and_check(0, 16'd4, 9, 8);
        send_and_check(0, 16'd4, 9, 9);
        $display("PASS TEST 9"); do_reset;

        // ── Test 10: Identity Matrix ───────────────────────
        send_pixel(1); send_pixel(0); send_pixel(0); send_pixel(0); send_pixel(0);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(0); send_pixel(0);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd2, 10, 1);
        send_and_check(0,  16'd2, 10, 2);
        send_and_check(0,  16'd1, 10, 3);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd2, 10, 4);
        send_and_check(1,  16'd2, 10, 5);
        send_and_check(0,  16'd2, 10, 6);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd1, 10, 7);
        send_and_check(0,  16'd2, 10, 8);
        send_and_check(1,  16'd2, 10, 9);
        $display("PASS TEST 10"); do_reset;

        // ── Test 11: (1 0 1 0 1 | 2 1 2 1 2 | 3 0 3 0 3 | 4 1 4 1 4 | 5 0 5 0 5) ──
        send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1);
        send_pixel(2); send_pixel(1); send_pixel(2); send_pixel(1); send_pixel(2);
        send_pixel(3); send_pixel(0);
        send_and_check(3,  16'd8,  11, 1);
        send_and_check(0,  16'd8,  11, 2);
        send_and_check(3,  16'd8,  11, 3);
        send_pixel(4); send_pixel(1);
        send_and_check(4,  16'd16, 11, 4);
        send_and_check(1,  16'd16, 11, 5);
        send_and_check(4,  16'd16, 11, 6);
        send_pixel(5); send_pixel(0);
        send_and_check(5,  16'd16, 11, 7);
        send_and_check(0,  16'd16, 11, 8);
        send_and_check(5,  16'd16, 11, 9);
        $display("PASS TEST 11"); do_reset;

        // ── Test 12: (0 1 0 1 0 | 1 2 1 2 1 | 0 3 0 3 0 | 1 4 1 4 1 | 0 5 0 5 0) ──
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(1); send_pixel(2); send_pixel(1); send_pixel(2); send_pixel(1);
        send_pixel(0); send_pixel(3);
        send_and_check(0,  16'd8,  12, 1);
        send_and_check(3,  16'd8,  12, 2);
        send_and_check(0,  16'd8,  12, 3);
        send_pixel(1); send_pixel(4);
        send_and_check(1,  16'd16, 12, 4);
        send_and_check(4,  16'd16, 12, 5);
        send_and_check(1,  16'd16, 12, 6);
        send_pixel(0); send_pixel(5);
        send_and_check(0,  16'd16, 12, 7);
        send_and_check(5,  16'd16, 12, 8);
        send_and_check(0,  16'd16, 12, 9);
        $display("PASS TEST 12"); do_reset;

        // ── Test 13: Checkerboard (1 0 1 0 1 | 0 1 0 1 0 | ...) ──
        send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0);
        send_pixel(1); send_pixel(0);
        send_and_check(1,  16'd4, 13, 1);
        send_and_check(0,  16'd4, 13, 2);
        send_and_check(1,  16'd4, 13, 3);
        send_pixel(0); send_pixel(1);
        send_and_check(0,  16'd4, 13, 4);
        send_and_check(1,  16'd4, 13, 5);
        send_and_check(0,  16'd4, 13, 6);
        send_pixel(1); send_pixel(0);
        send_and_check(1,  16'd4, 13, 7);
        send_and_check(0,  16'd4, 13, 8);
        send_and_check(1,  16'd4, 13, 9);
        $display("PASS TEST 13"); do_reset;

        // ── Test 14: (0 32 32 32 0 | 0 32 32 32 0 | ...) ──
        send_pixel(0);  send_pixel(32); send_pixel(32); send_pixel(32); send_pixel(0);
        send_pixel(0);  send_pixel(32); send_pixel(32); send_pixel(32); send_pixel(0);
        send_pixel(0);  send_pixel(32);
        send_and_check(32,  16'd192, 14, 1);
        send_and_check(32,  16'd256, 14, 2);
        send_and_check(0,   16'd192, 14, 3);
        send_pixel(0);  send_pixel(32);
        send_and_check(32,  16'd192, 14, 4);
        send_and_check(32,  16'd256, 14, 5);
        send_and_check(0,   16'd192, 14, 6);
        send_pixel(0);  send_pixel(32);
        send_and_check(32,  16'd192, 14, 7);
        send_and_check(32,  16'd256, 14, 8);
        send_and_check(0,   16'd192, 14, 9);
        $display("PASS TEST 14"); do_reset;

        // ── Test 15: (0 126 0 126 0 | 0 0 0 0 0 | ... | 0 126 0 126 0) ──
        send_pixel(0); send_pixel(126); send_pixel(0); send_pixel(126); send_pixel(0);
        repeat(7) send_pixel(0);
        send_and_check(0,   16'd252, 15, 1);
        send_and_check(0,   16'd252, 15, 2);
        send_and_check(0,   16'd252, 15, 3);
        repeat(2) send_pixel(0);
        send_and_check(0,   16'd0,   15, 4);
        send_and_check(0,   16'd0,   15, 5);
        send_and_check(0,   16'd0,   15, 6);
        send_pixel(0); send_pixel(126);
        send_and_check(0,   16'd252, 15, 7);
        send_and_check(126, 16'd252, 15, 8);
        send_and_check(0,   16'd252, 15, 9);
        $display("PASS TEST 15"); do_reset;

        // ── Test 16: (0 0 1 0 0 | 0 1 0 0 0 | 1 0 0 0 1 | 0 0 1 0 0 | 0 0 0 0 0) ──
        send_pixel(0); send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(0);
        send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(0); send_pixel(0);
        send_pixel(1); send_pixel(0);
        send_and_check(0,  16'd2, 16, 1);
        send_and_check(0,  16'd2, 16, 2);
        send_and_check(1,  16'd2, 16, 3);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd3, 16, 4);
        send_and_check(0,  16'd3, 16, 5);
        send_and_check(0,  16'd1, 16, 6);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd1, 16, 7);
        send_and_check(0,  16'd0, 16, 8);
        send_and_check(0,  16'd1, 16, 9);
        $display("PASS TEST 16"); do_reset;

        // ── Test 17: (1 0 1 0 1 | 0 2 1 0 0 | 1 0 3 0 1 | 0 0 0 4 1 | 1 0 1 0 5) ──
        send_pixel(1); send_pixel(0); send_pixel(1); send_pixel(0); send_pixel(1);
        send_pixel(0); send_pixel(2); send_pixel(1); send_pixel(0); send_pixel(0);
        send_pixel(1); send_pixel(0);
        send_and_check(3,  16'd6,  17, 1);
        send_and_check(0,  16'd8,  17, 2);
        send_and_check(1,  16'd6,  17, 3);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd5,  17, 4);
        send_and_check(4,  16'd8,  17, 5);
        send_and_check(1,  16'd10, 17, 6);
        send_pixel(1); send_pixel(0);
        send_and_check(1,  16'd6,  17, 7);
        send_and_check(0,  16'd8,  17, 8);
        send_and_check(5,  16'd10, 17, 9);
        $display("PASS TEST 17"); do_reset;

        // ── Test 18: Upper-triangular (1 1 1 1 1 | 0 1 1 1 1 | 0 0 1 1 1 | ...) ──
        send_pixel(1); send_pixel(1); send_pixel(1); send_pixel(1); send_pixel(1);
        send_pixel(0); send_pixel(1); send_pixel(1); send_pixel(1); send_pixel(1);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd5, 18, 1);
        send_and_check(1,  16'd7, 18, 2);
        send_and_check(1,  16'd8, 18, 3);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd3, 18, 4);
        send_and_check(1,  16'd5, 18, 5);
        send_and_check(1,  16'd7, 18, 6);
        send_pixel(0); send_pixel(0);
        send_and_check(0,  16'd1, 18, 7);
        send_and_check(0,  16'd3, 18, 8);
        send_and_check(1,  16'd5, 18, 9);
        $display("PASS TEST 18"); do_reset;

        // ── Test 19: (0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1) ──
        send_pixel(0); send_pixel(0); send_pixel(1); send_pixel(1); send_pixel(1);
        send_pixel(0); send_pixel(0); send_pixel(1); send_pixel(1); send_pixel(1);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd2, 19, 1);
        send_and_check(1,  16'd6, 19, 2);
        send_and_check(1,  16'd8, 19, 3);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd2, 19, 4);
        send_and_check(1,  16'd6, 19, 5);
        send_and_check(1,  16'd8, 19, 6);
        send_pixel(0); send_pixel(0);
        send_and_check(1,  16'd2, 19, 7);
        send_and_check(1,  16'd6, 19, 8);
        send_and_check(1,  16'd8, 19, 9);
        $display("PASS TEST 19"); do_reset;

        // ── Test 20: (1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0) ──
        send_pixel(1); send_pixel(1); send_pixel(0); send_pixel(0); send_pixel(0);
        send_pixel(1); send_pixel(1); send_pixel(0); send_pixel(0); send_pixel(0);
        send_pixel(1); send_pixel(1);
        send_and_check(0,  16'd6, 20, 1);
        send_and_check(0,  16'd2, 20, 2);
        send_and_check(0,  16'd0, 20, 3);
        send_pixel(1); send_pixel(1);
        send_and_check(0,  16'd6, 20, 4);
        send_and_check(0,  16'd2, 20, 5);
        send_and_check(0,  16'd0, 20, 6);
        send_pixel(1); send_pixel(1);
        send_and_check(0,  16'd6, 20, 7);
        send_and_check(0,  16'd2, 20, 8);
        send_and_check(0,  16'd0, 20, 9);
        $display("PASS TEST 20"); do_reset;

        // ── Summary ───────────────────────────────────────
        $display("ALL TESTS PASSED  (%0d checks)", pass_count);
        $finish;
    end

    // ─── Waveform Dump ────────────────────────────────────
    initial begin
        $dumpfile("conv.vcd");
        $dumpvars(0, conv_tb);
    end

endmodule