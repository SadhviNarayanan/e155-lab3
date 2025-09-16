module number_capture(
   input  logic allowed,
   input  logic [3:0] row_stable,
   input  logic [3:0] col,
   output logic [11:0] pressed_value
);


   // will determine which number was pressed
 always_comb begin
	 // only if allowed to sample the number (scan state)
     if (allowed) begin
         case ({row_stable,col}) // need to get what was 2 clock cycles before
             8'b0001_0001: pressed_value = {row_stable, 4'b0100, 4'h3}; // need to go two cols ahead, and get that value
             8'b0001_0010: pressed_value = {row_stable, 4'b1000, 4'hA};
             8'b0001_0100: pressed_value = {row_stable, 4'b0001, 4'h1};
             8'b0001_1000: pressed_value = {row_stable, 4'b0010, 4'h2};
             8'b0010_0001: pressed_value = {row_stable, 4'b0100, 4'h6};
             8'b0010_0010: pressed_value = {row_stable, 4'b1000, 4'hB};
             8'b0010_0100: pressed_value = {row_stable, 4'b0001, 4'h4};
             8'b0010_1000: pressed_value = {row_stable, 4'b0010, 4'h5};
             8'b0100_0001: pressed_value = {row_stable, 4'b0100, 4'h9};
             8'b0100_0010: pressed_value = {row_stable, 4'b1000, 4'hC};
             8'b0100_0100: pressed_value = {row_stable, 4'b0001, 4'h7};
             8'b0100_1000: pressed_value = {row_stable, 4'b0010, 4'h8}; // just go two earlier on the keypad to get orig
             8'b1000_0001: pressed_value = {row_stable, 4'b0100, 4'hF};
             8'b1000_0010: pressed_value = {row_stable, 4'b1000, 4'hD};
             8'b1000_0100: pressed_value = {row_stable, 4'b0001, 4'hE};
             8'b1000_1000: pressed_value = {row_stable, 4'b0010, 4'h0};
             default: pressed_value = {row_stable, col, 4'h0};
        endcase
     end else begin
		pressed_value = {row_stable, col, 4'h0};
     end
 end


endmodule





