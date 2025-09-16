// E155, Lab 3 - Scans the keypad for button presses by applying voltage to the columns and reading the rows


// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025

module keypad_scanner(
   input  logic clk,
   input  logic reset,
   input logic enable_scan,
   input  logic [3:0] row,
   output logic [3:0] col,
   output logic [3:0] row_stable,
   output logic [3:0] col_stable
);


  
  // intenal signals
 logic [1:0] counter;
 logic [3:0] intermediate_row, intermediate_col;

 // begin counter to start tracing through the columns if enabled (only in scan and capture state)
 always_ff @(posedge clk, negedge reset) begin
     if (reset == 0) counter <= 0;
     else 
		 if (enable_scan) begin
			counter <= counter + 1;
		 end else begin
			 counter <= 0;
		 end
 end
   
  // converts the counter to the columns
  always_comb begin
	  if (~enable_scan) begin
		  col = 4'b0000;
	  end else begin
		 case(counter)
			 2'b00: col = 4'b0001; // col is the output pins from the FPGA
			 2'b01: col = 4'b0010;
			 2'b10: col = 4'b0100;
			 2'b11: col = 4'b1000;
		 endcase
	  end
 end


 // synchronizer --> for getting the synchronized columns and rows (especially rows since this is async)
 always_ff @(posedge clk, negedge reset) begin // TODO: maybe add if allowed here?
     if (!reset) begin
            intermediate_row <= 4'b0;
            row_stable       <= 4'b0;
			intermediate_col <= 4'b0;
            col_stable       <= 4'b0;
     end else begin
     		intermediate_row <= row; // sample the row input at the posedge of the clock
     		row_stable <= intermediate_row; // then store the stable value
			
			intermediate_col <= col; // sample the row input at the posedge of the clock
     		col_stable <= intermediate_col;
     end
 end

endmodule




