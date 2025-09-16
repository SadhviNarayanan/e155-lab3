
`timescale 1ns/1ps
module testbench_lab3_sn;
   logic reset, clk;
   logic [3:0] row;

   logic [3:0] col;
   logic [6:0] seg;
   logic [1:0] enable_seg;
   logic [2:0] state_on;

   lab3_sn dut (
     .int_osc(clk),
      .reset(reset),
      .row(row),
      .col(col),
      .seg(seg),
      .enable_seg(enable_seg),
      .state_on(state_on)
   );
  
   // Clock generation - 20ns period
 	always begin
     	clk = 0; #10; clk = 1; #10;
	 end



   // Stimulus + checks
   initial begin
     $display("Starting FSM test...");

      reset = 0;
      row   = 4'b0000;   // no key pressed
      #100;
      reset = 1;
      // === 1. Simple press on row 0 ===
      #500;
      row = 4'b0001;  // press row0
      assert (state_on == 3'b001) else $error("we should be in SCAN, but actually in %b", state_on);
     @(posedge clk); # 0.1
     @(posedge clk);
     @(posedge clk);
     @(posedge clk);
     assert (state_on == 3'b010) else $error("we should be in DEBOUNCE_WAIT, but actually in %b", state_on);
      #10000000;          // wait enough for debounce // #10000000; put it in capture
     assert (state_on == 3'b100) else $error("we should be in CAPTURE, but actually in %b", state_on);
      row = 4'b0000;
      // === 2. Bounce on row 1 ===
      #1000;
      row = 4'b0010; #5;
      assert (state_on == 3'b010) else $error("We should be in DEBOUNCE, but actually in %b", state_on);
      row = 4'b0000; #5;
      assert (state_on == 3'b010) else $error("We should be in DEBOUNCE, but actually in %b", state_on);
      row = 4'b0010; #5;
      assert (state_on == 3'b010) else $error("We should be in DEBOUNCE, but actually in %b", state_on);
      row = 4'b0000; #5;
      assert (state_on == 3'b010) else $error("We should be in DEBOUNCE, but actually in %b", state_on);
      row = 4'b0010;
	  assert (state_on == 3'b010) else $error("We should be in DEBOUNCE, but actually in %b", state_on);
     #20000000 // wait enough time to get to capture
     assert (state_on == 3'b100) else $error("we should be in CAPTURE, but actually in %b", state_on);
     #20000000 // wait enough time to get to capture
     assert (state_on == 3'b100) else $error("we should still be in CAPTURE since butyton isnt released, but actually in %b", state_on);
     row = 4'b0000;
     @(posedge clk); # 0.1
     @(posedge clk);
     #1000
     assert (state_on == 3'b010) else $error("we should be in DEBOUNCE_WAIT after capture, but actually in %b", state_on);
     #20000000
     assert (state_on == 3'b001) else $error("we should be in SCAN, but actually in %b", state_on);
      // === 3. Long hold row 2 ===
      #1000;
      row = 4'b0100;
      #20;
      assert (state_on == 3'b001) else $error("we should be in SCAN, but actually in %b", state_on);
     #20000000
     #20000000
     #20000000
      assert (state_on == 3'b100) else $error("we should still be in CAPTURE since butyton isnt released, but actually in %b", state_on);
      row = 4'b0000;
      // === 4. Multiple keys pressed ===
      #1000;
      row = 4'b1000;   // row2 + row3
      #10
      row = 4'b0100;
      #1000;
      assert (state_on == 3'b010) else $error("we should be in DEBOUNCE_WAIT after capture, but actually in %b", state_on);
      #20000000
     assert (state_on == 3'b100) else $error("we should still be in CAPTURE since butyton isnt released, but actually in %b", state_on);
      row = 4'b0000;
      $display("All tests completed");
      $finish;
   end
endmodule




