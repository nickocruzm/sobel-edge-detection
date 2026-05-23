`timescale 1ns / 1ps

module shift_testbench;

  reg clk;
  reg [15:0] data_in;
  wire [15:0] data_out;

  shift uut(
    .clk(clk),
    .data_in(data_in),
    .data_out(data_out)
  );

  // Must match shift module's D parameter
  localparam D = 2;

  always #10 clk = ~clk;

  // Drive val for D cycles so it fully propagates, then check output
  task drive_and_check;
    input [15:0] val;
    begin
      data_in = val;
      repeat(D) @(posedge clk);
      #1;
      if (data_out !== val)
        $display("FAIL: expected data_out=%0d, got %0d", val, data_out);
      else
        $display("PASS: data_out=%0d", data_out);
    end
  endtask

  initial begin
    clk = 0;
    data_in = 0;

    drive_and_check(16'd100);
    drive_and_check(16'd10);
    drive_and_check(16'd30);
    drive_and_check(16'd21);
    drive_and_check(16'd110);

    $display("All tests completed.");
    $finish;
  end

  initial begin
    $dumpfile("shift_tb.vcd");
    $dumpvars(0, shift_testbench);
  end

endmodule
