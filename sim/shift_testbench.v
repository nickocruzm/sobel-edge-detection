`timescale 1ns / 1ps

module shift_testbench;

  //Inputs
  reg clk;
  reg [15:0] data_in;
  wire [15:0] data_out;
  
  shift uut(
	.clk(clk),
	.data_in(data_in),
	.data_out(data_out)
	);
  
  initial begin
    	clk = 0;
    	data_in = 100;
    
    	#100;
		
    	data_in = 10;
	#40;
	
    	data_in = 30;
	#40;
	
    	data_in = 21;
	#40;

	data_in = 110;
	#40;
	
    	$display("All tests completed successfully\n\n");
    	$finish;
    end
	
    //always #10 clk = ~ clk; //part of original code but causes infinite
    //looping
    
    initial begin
        $fsdbDumpfile("shift_tb.fsdb");
        $fsdbDumpvars(0, shift_testbench, "+all");
        $dumpfile("shift_tb.vcd");
        $dumpvars(0, shift_testbench);
    end



endmodule
