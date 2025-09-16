// E155, Lab 3 - Testbench to test clock - used for debounce timer and 60Hz frequency for multiplexing

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025


`timescale 1ns / 1ps
module testbench_clock();


 logic        clk;
 logic        reset;
  logic clk_signal, exp_clk_signal, high, exp_high, enable;
  logic [23:0] counter;
 logic [2:0] complete;
 
 initial exp_clk_signal = 0;
 initial counter = 24'b0;
 initial complete = 0;
 initial enable = 1;




 // instantiate device to be tested
 clock # (.freq(200000)) dut(clk, reset, enable, clk_signal, high);
  // generate clock


 always
   begin
     clk = 0; #5; clk = 1; #5;
   end


 initial
   begin
     reset = 0; #22; reset = 1;
   end




 always @(*) begin
 if (clk_signal !== 1'bx && counter !== 24'b0) assert (clk_signal == exp_clk_signal) else $error("clock signal is not correct, actual: %b, expected: %b, counter: %b", clk_signal, exp_clk_signal, counter);
 if (high !== 1'bx && counter !== 24'b0) assert (high == exp_high) else $error("high counter signal correct, actual: %b, expected: %b, counter: %b", high, exp_high, counter); 
 end
  always @(posedge clk) begin
     if(reset == 0) begin
       counter <= 0;
       exp_clk_signal <= 0;
       exp_high <= 0;
     end
     else if (counter == 200000) begin
     $display("counter hit, actual: %b, expected: %b, counter: %b", clk_signal, exp_clk_signal, counter);
       counter <= 0;
       exp_high <= 1;
       exp_clk_signal <= ~exp_clk_signal;
       complete <= complete + 1;
     end else begin
      counter <= counter + 1;
     end
 end


//   always_comb begin
//      if (complete == 4'b0011) begin
//        $display("SUCCEEDED and DONE, clock succeeded");
//        $stop;
//      end
//   end




endmodule









