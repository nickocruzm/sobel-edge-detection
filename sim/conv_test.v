`timescale 1ns / 1ps

module conv_tb;

    // ─── Signals ──────────────────────────────────────────
    reg        clk;
    reg        reset;
    reg  [7:0] pxl_in;
    wire [15:0] pxl_out;
    wire        valid;

	// Instantiate the Unit Under Test (UUT)
	conv uut (
		.clk(clk), 
		.reset(reset), 
		.pxl_in(pxl_in),
		.reg_00(reg_00), 
		.reg_01(reg_01),
		.reg_02(reg_02),
		.sr_0(sr_0),
		.reg_10(reg_10),
		.reg_11(reg_11),
		.reg_12(reg_12),
		.sr_1(sr_1),
		.reg_20(reg_20),
		.reg_21(reg_21),
		.reg_22(reg_22),
		.pxl_out(pxl_out),
		.valid(valid)
	);

initial begin
	// Initialize Inputs
	clk = 0;
	reset = 0;
	pxl_in = 0;

	$monitor("t=%0t clk=%b pxl_in=%0d | pxl_out=%0d valid=%b", $time, clk, pxl_in, pxl_out, valid);

	// 5*5 image: Test 1 (1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5)
        #20 pxl_in = 1;
        #20 pxl_in = 2;
        #20 pxl_in = 3;
        #20 pxl_in = 4;
        #20 pxl_in = 5;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 2;
        #20 pxl_in = 3; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 1.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 1.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 1.3: expected 32, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 1; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 2; #20
        pxl_in = 3; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 3.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 3.3: expected 32, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 1");
        reset = 0;
        #100

	//Test 2 (0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0 | 1 2 3 4 5 | 0 1 0 1 0)
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 2;
        #20 pxl_in = 3;
        #20 pxl_in = 4;
        #20 pxl_in = 5;
	#20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 2; #20
        pxl_in = 3; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 2.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 2.3: expected 32, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 1; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.3: expected 4, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 2");
        reset = 0;
        #100

	//Test 3 (5 4 3 2 1 | 0 1 0 1 0 | 5 4 3 2 1 | 0 1 0 1 0 | 5 4 3 2 1)
        #20 pxl_in = 5;
        #20 pxl_in = 4;
        #20 pxl_in = 3;
        #20 pxl_in = 2;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 5;
        #20 pxl_in = 4;
        #20 pxl_in = 3; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 1.1: expected 32, got %d", pxl_out);
                $finish;
        end
        pxl_in = 2; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 1.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 1.3: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 1; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        pxl_in = 4; #20
        pxl_in = 3; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 3.1: expected 32, got %d", pxl_out);
                $finish;
        end
        pxl_in = 2; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 3.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.3: expected 16, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 3");
        reset = 0;
        #100

	//Test 4 (1 2 3 4 5 | 1 0 1 0 1 | 1 2 3 4 5 | 1 0 1 0 1 | 1 2 3 4 5)
        #20 pxl_in = 1;
        #20 pxl_in = 2;
        #20 pxl_in = 3;
        #20 pxl_in = 4;
        #20 pxl_in = 5;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 2;
        #20 pxl_in = 3; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 1.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 1.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 1.3: expected 32, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 1; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 2; #20
        pxl_in = 3; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd24) begin
                $display("ERROR 3.2: expected 24, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd32) begin
                $display("ERROR 3.3: expected 32, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 4");
        reset = 0;
        #100

	//Test 5 Zero Matrix
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 1.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 1.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 1.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 3.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 3.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 3.3: expected 0, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 5");
        reset = 0;
        #100

	//Test 6 Ones Matrix
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 1; #20
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 1; #20
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 3.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 3.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 3.3: expected 8, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 6");
        reset = 0;
        #100

	//Test 7: (1 1 1 1 1 | 0 0 0 0 0 | 0 0 0 0 0 | 0 0 0 0 0 | 1 1 1 1 1)
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 1; #20
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.3: expected 4, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 7");
        reset = 0;
        #100

	//Test 8: (0 0 0 0 0 | 0 1 1 1 0 | 0 1 1 1 0 | 0 1 1 1 0 | 0 0 0 0 0)
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 1; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 1.1: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 1.3: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 1; #20
        pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 2.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 2.3: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 3.1: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 3.3: expected 3, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 8");
        reset = 0;
        #100

	//Test 9 Ones Matrix
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1;
        #20 pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        pxl_in = 1; #20
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.3: expected 4, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 9");
        reset = 0;
        #100

	//Test 10 Identity Matrix
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 1;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.1: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 1.3: expected 1, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 2.1: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 2.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 2.3: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 3.1: expected 1, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 3.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 3.3: expected 2, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 10");
        reset = 0;
        #100


	//Test 11 Matrix (1 0 1 0 1 | 2 1 2 1 2 | 3 0 3 0 3 | 4 1 4 1 4 | 5 0 5 0 5)

        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1;
        #20 pxl_in = 2; #20 pxl_in = 1; #20 pxl_in = 2; #20 pxl_in = 1; #20 pxl_in = 2;
        #20 pxl_in = 3; #20 pxl_in = 0; #20 pxl_in = 3; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 3; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20 pxl_in = 1; #20 pxl_in = 4; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.2: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.3: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20 pxl_in = 0; #20 pxl_in = 5; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.2: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.3: expected 16, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 11");
        reset = 0;
        #100

	//Test 12 Matrix (0 1 0 1 0 | 1 2 1 2 1 | 0 3 0 3 0 | 1 4 1 4 1 | 0 5 0 5 0)

        #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 2; #20 pxl_in = 1; #20 pxl_in = 2; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 3; #20 pxl_in = 0; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.1: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 3; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20 pxl_in = 4; #20 pxl_in = 1; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.2: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 2.3: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 5; #20 pxl_in = 0; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.1: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.2: expected 16, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd16) begin
                $display("ERROR 3.3: expected 16, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 12");
        reset = 0;
        #100

	//Test 13 Matrix (1 0 1 0 1 | 0 1 0 1 0 | 1 0 1 0 1 | 0 1 0 1 0 | 1 0 1 0 1)

        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 1.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 2.3: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.1: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.2: expected 4, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd4) begin
                $display("ERROR 3.3: expected 4, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 13");
        reset = 0;
        #100

	//Test 14: (0 32 32 32 0 | 0 32 32 32 0 | 0 32 32 32 0 | 0 32 32 32 0 | 0 32 32 32 0)

        #20 pxl_in = 0;
        #20 pxl_in = 32;
        #20 pxl_in = 32;
        #20 pxl_in = 32;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 32;
        #20 pxl_in = 32;
        #20 pxl_in = 32;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 32;
        #20 pxl_in = 32; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 1.1: expected 192, got %d", pxl_out);
                $finish;
        end
        pxl_in = 32; #20
        if (pxl_out != 16'd256) begin
                $display("ERROR 1.2: expected 256, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 1.3: expected 192, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 32; #20
        pxl_in = 32; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 2.1: expected 192, got %d", pxl_out);
                $finish;
        end
        pxl_in = 32; #20
        if (pxl_out != 16'd256) begin
                $display("ERROR 2.2: expected 256, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 2.3: expected 192, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 32; #20
        pxl_in = 32; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 3.1: expected 192, got %d", pxl_out);
                $finish;
        end
        pxl_in = 32; #20
        if (pxl_out != 16'd256) begin
                $display("ERROR 3.2: expected 256, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd192) begin
                $display("ERROR 3.3: expected 192, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 14");
        reset = 0;
        #100

	//Test 15: (0 126 0 126 0 | 0 0 0 0 0 | 0 0 0 0 0 | 0 0 0 0 0 | 0 126 0 126 0)

        #20 pxl_in = 0;
        #20 pxl_in = 126;
        #20 pxl_in = 0;
        #20 pxl_in = 126;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0;
        #20 pxl_in = 0; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 1.1: expected 252, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 1.2: expected 252, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 1.3: expected 252, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 0; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        pxl_in = 126; #20
        pxl_in = 0; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 3.1: expected 252, got %d", pxl_out);
                $finish;
        end
        pxl_in = 126; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 3.2: expected 252, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd252) begin
                $display("ERROR 3.3: expected 252, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 15");
        reset = 0;
        #100

	//Test 16 Matrix (0 0 1 0 0 | 0 1 0 0 0 | 1 0 0 0 1 | 0 0 1 0 0 | 0 0 0 0 0)

        #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0;
        #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.1: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.3: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 2.1: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 2.2: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 2.3: expected 1, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 3.1: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 3.2: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 3.3: expected 1, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 16");
        reset = 0;
        #100


	//Test 17 Matrix (1 0 1 0 1 | 0 2 1 0 0 | 1 0 3 0 1 | 0 0 0 4 1 | 1 0 1 0 5)

        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 2; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 3; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 1.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 1.3: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0; #20
        if (pxl_out != 16'd5) begin
                $display("ERROR 2.1: expected 5, got %d", pxl_out);
                $finish;
        end
        pxl_in = 4; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd10) begin
                $display("ERROR 2.3: expected 10, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 3.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 3.2: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 5; #20
        if (pxl_out != 16'd10) begin
                $display("ERROR 3.3: expected 10, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 17");
        reset = 0;
        #100

	//Test 18 Matrix (1 1 1 1 1 | 0 1 1 1 1 | 0 0 1 1 1 | 0 0 0 1 1 | 0 0 0 0 1)

        #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd5) begin
                $display("ERROR 1.1: expected 5, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd7) begin
                $display("ERROR 1.2: expected 7, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 2.1: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd5) begin
                $display("ERROR 2.2: expected 5, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd7) begin
                $display("ERROR 2.3: expected 7, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0; #20
        if (pxl_out != 16'd1) begin
                $display("ERROR 3.1: expected 1, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd3) begin
                $display("ERROR 3.2: expected 3, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd5) begin
                $display("ERROR 3.3: expected 5, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 18");
        reset = 0;
        #100

	//Test 19 Matrix (0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1 | 0 0 1 1 1)

        #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 1;
        #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.1: expected 5, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 1.2: expected 7, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 1.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 2.1: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 2.2: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 2.3: expected 8, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 1; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 3.1: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 3.2: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20
        if (pxl_out != 16'd8) begin
                $display("ERROR 3.3: expected 8, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 19");
        reset = 0;
        #100

	//Test 20 Matrix (1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0 | 1 1 0 0 0)

        #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 0; #20 pxl_in = 0; #20 pxl_in = 0;
        #20 pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 0; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 1.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 1.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 1.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 0; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 2.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 2.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 2.3: expected 0, got %d", pxl_out);
                $finish;
        end
        pxl_in = 1; #20 pxl_in = 1; #20 pxl_in = 0; #20
        if (pxl_out != 16'd6) begin
                $display("ERROR 3.1: expected 6, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd2) begin
                $display("ERROR 3.2: expected 2, got %d", pxl_out);
                $finish;
        end
        pxl_in = 0; #20
        if (pxl_out != 16'd0) begin
                $display("ERROR 3.3: expected 0, got %d", pxl_out);
                $finish;
        end
	$display("PASS ALL TESTS 20");
        reset = 0;
        #100


	$display("ALL TESTS PASSED");	
	$finish;
	end
	always #10 clk = ~ clk;

	   // Dump file for waveform viewing
   	initial begin
      		$fsdbDumpfile("conv.fsdb");
      		$fsdbDumpvars(0, conv_test, "+all");
      		$dumpfile("conv.vcd");
      		$dumpvars(0, conv_test);
   	end
endmodule
