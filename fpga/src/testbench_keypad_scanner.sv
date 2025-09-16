// E155, Lab 3 - Testbench to test keypad scanner - applying voltage to cols and reading rows

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025

//`timescale 1ns / 1ps
module testbench_keypad_scanner();

 logic        clk;
 logic      reset;
logic enable_scan;
  logic [3:0] row, row_expected;
 logic [3:0] col, col_expected, col_stable;
 logic [3:0] row_stable, row_stable_expected;

 logic [1:0] counter;
 logic [3:0] intermediate_row;


 // instantiate device to be tested
 keypad_scanner dut(clk, reset, enable_scan, row, col, row_stable, col_stable);

  // generate clock
 always
   begin
     clk = 0; #10; clk = 1; #10;
   end

 initial
   begin
     reset = 0; #22; reset = 1; // resset is active low
     enable_scan = 1;
   end


 always @(posedge clk, negedge reset) begin
     if (reset == 0) begin
       counter <= 2'b00;
       row_expected <= 4'b0000;
       row_stable_expected <= 4'b0000;
     end
     else begin
       counter <= counter + 1;
       // synchronizer logic
       intermediate_row <= row; // sample the row input at the posedge of the clock
       row_stable_expected <= intermediate_row; // then store the stable value
     end
 end
  
  always @(*) begin #2
    assert (col === col_expected) else $error("ERROR on col, should be %b but actually %b", col_expected, col);
    // assert (row_stable === row_stable_expected) else $error("ERROR on row stable, should be %b but actually %b", row_stable_expected, row_stable);
 end


 always_comb begin
   case(counter)
     2'b00: col_expected = 4'b0001; // col is the output pins from the FPGA
     2'b01: col_expected = 4'b0010;
     2'b10: col_expected = 4'b0100;
     2'b11: col_expected = 4'b1000;
   endcase
 end

 


initial
   begin
       //$dumpfile("fsm.vcd");
       //$dumpvars(0, testbench);
       //$display("Starting FSM test...");
       // Apply reset
	reset = 0;
	@(posedge clk); @(posedge clk); // hold reset 2 cycles
	reset = 1;
	@(posedge clk);                // first post-reset cycle


       // Press row 0
      row = 4'b0001;
      @(posedge clk); // intermediate_row <= row
      @(posedge clk); #1;// row_stable <= intermediate_row
      assert (row_stable == 4'b0001) else $error("row_stable mismatch! Expected 0001, got %b", row_stable);

      // Press row 1
      row = 4'b0010;
      @(posedge clk); // intermediate_row <= row
     assert (row_stable == 4'b0001) else $error("row_stable should still be the previous value 0001 but is %b", row_stable);
      @(posedge clk); #1;// row_stable updates
      assert (row_stable == 4'b0010) else $error("row_stable mismatch! Expected 0010, got %b", row_stable);

      // Press row 2
      row = 4'b0100;
      @(posedge clk);
      @(posedge clk); #1;
      assert (row_stable == 4'b0100) else $error("row_stable mismatch! Expected 0100, got %b", row_stable);

      // Press row 3
      row = 4'b1000;
      @(posedge clk);
      @(posedge clk); #1;
      assert (row_stable == 4'b1000) else $error("row_stable mismatch! Expected 1000, got %b", row_stable);
     
      row = 4'b0100;
      @(posedge clk);
      row = 4'b0010; // should not count it on the next cycle as it should pick up 0100
      @(posedge clk); #1;
      assert (row_stable == 4'b0100) else $error("row_stable mismatch! Expected 0100, got %b", row_stable);
      @(posedge clk); #1;
      assert (row_stable == 4'b0010) else $error("row_stable mismatch! Expected 0010, got %b", row_stable);
      
      
     
     
     
       $finish;
   end

   


endmodule








