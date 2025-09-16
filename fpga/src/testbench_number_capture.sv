// E155, Lab 3 - Testbench to test number capture - based on col and row, the correct number should be displayed

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025
`timescale 1ns / 1ps
module testbench_number_capture();

 logic        clk;
 logic      reset;
  logic allowed;
 logic [3:0] row_stable;
 logic [3:0] col;
 logic [11:0] pressed_value, expected_pressed_value;
 logic [7:0] counter;


 // instantiate device to be tested
 number_capture dut(allowed, row_stable, col, pressed_value);
  // generate clock
	 always
	   begin
		 clk = 0; #10; clk = 1; #10;
	   end

	 initial
	   begin
		 reset = 0; #22; reset = 1; // resset is active low
	   end

	 always @(posedge clk, negedge reset) begin
		 if (reset == 0) begin
		   counter <= 8'b0;
		 end
		 else begin
		   counter <= counter + 1;
		end
	 end

	 assign {row_stable, col} = counter[7:0]; // will cycle through all the combinations of row and col
	 assign allowed = 1; // always allowed to capture for this testbench

	 always @(*) begin
		if (row_stable !== 4'bxxx && col !== 4'bxxx) begin
		 assert (pressed_value === expected_pressed_value) else $error("ERROR on pressed_value, with row %b and col %b should be %b but actually %b", row_stable, col, expected_pressed_value, pressed_value);
	 	end
	 end

	 always_comb begin
	   if (allowed) begin
		case ({row_stable,col}) // need to get what was 2 clock cycles before
             		8'b0001_0001: expected_pressed_value = {row_stable, 4'b0100, 4'h3}; // need to go two cols ahead, and get that value
             		8'b0001_0010: expected_pressed_value = {row_stable, 4'b1000, 4'hA};
             		8'b0001_0100: expected_pressed_value = {row_stable, 4'b0001, 4'h1};
             		8'b0001_1000: expected_pressed_value = {row_stable, 4'b0010, 4'h2};
             		8'b0010_0001: expected_pressed_value = {row_stable, 4'b0100, 4'h6};
             		8'b0010_0010: expected_pressed_value = {row_stable, 4'b1000, 4'hB};
             		8'b0010_0100: expected_pressed_value = {row_stable, 4'b0001, 4'h4};
             		8'b0010_1000: expected_pressed_value = {row_stable, 4'b0010, 4'h5};
             		8'b0100_0001: expected_pressed_value = {row_stable, 4'b0100, 4'h9};
             		8'b0100_0010: expected_pressed_value = {row_stable, 4'b1000, 4'hC};
             		8'b0100_0100: expected_pressed_value = {row_stable, 4'b0001, 4'h7};
            		8'b0100_1000: expected_pressed_value = {row_stable, 4'b0010, 4'h8}; // just go two earlier on the keypad to get orig
             		8'b1000_0001: expected_pressed_value = {row_stable, 4'b0100, 4'hF};
             		8'b1000_0010: expected_pressed_value = {row_stable, 4'b1000, 4'hD};
             		8'b1000_0100: expected_pressed_value = {row_stable, 4'b0001, 4'hE};
             		8'b1000_1000: expected_pressed_value = {row_stable, 4'b0010, 4'h0};
             		default: expected_pressed_value = {row_stable, col, 4'h0}; // do nothing
        	endcase
	 end else begin
		// do nothing
		expected_pressed_value = {row_stable, col, 4'h0};
     	   end
	end


endmodule






