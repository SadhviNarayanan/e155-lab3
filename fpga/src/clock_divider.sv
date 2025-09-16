// E155, Lab 3 - Clock divider which toggles at 60Hz


// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/03/2025


module clock_divider #(parameter freq = 2000000)(
   input logic clk,
   input logic reset,
   input logic enable,
   output logic clk_signal,
   output logic high
);


 logic [23:0] counter;
 logic [23:0] freq_24_bits;
 

  // clock is toggling at 60Hz
 always_ff @(posedge clk, negedge reset) begin
   if(reset == 0) begin // reset
       counter <= 0;
       clk_signal <= 0;
       high <= 0;
   end else if (enable) begin
       if (counter == freq) begin
           counter <= 0;
           clk_signal <= ~clk_signal; // toggles the ouput to create 60Hz frequency
           high <= 1;
       end else begin
          counter <= counter + 1;
          high <= 0;
       end
   end else begin
	   counter <= 0;
	   high <= 0;
	end
 end
endmodule













