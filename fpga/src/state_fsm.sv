// E155, Lab 3 - Finite state machine to switch between scanning the keypad, allowing time for debouncing, and
// shifting/displaying the number on the dual-display


// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025

module state_fsm(
   input  logic clk, reset,
   input  logic high,
   input  logic [3:0] row_stable, row,
   input  logic [3:0] col,
   input  logic [11:0] pressed_value,
   output logic [1:0] state, next_state,
   output logic [4:0] first, second,
   output logic allowed,
   output logic enable_delay,
   output logic reset2,
   output logic enable_scan,
   output logic [2:0] state_on
); 

 // internal signals
 typedef enum logic [1:0] {SCAN, DEBOUNCE_WAIT, CAPTURE} state_t;
 state_t debounce_next_state;
 
 // registers because the values need to persist across clock cycles
 logic [4:0] first_reg, second_reg;
 logic [3:0] num_reg;
 logic [3:0] captured_row, captured_col; // Store which key was pressed
 logic captured_reg;

 // these are the reg values which we are assigning to the outputs
 assign first = first_reg;
 assign second = second_reg;

 // state logic
 always_ff @(posedge clk, negedge reset) begin
     if (reset == 0) begin
       state <= SCAN;
     end
     else state <= next_state;
 end

 // data registers to capture numbers, presses, column/row pressed, etc.
 always_ff @(posedge clk, negedge reset) begin
     if (reset == 0) begin
         first_reg <= 5'b11111;
         second_reg <= 5'b11111;
         num_reg <= 4'h0;
         captured_row <= 4'h0;
         captured_col <= 4'h0;
         captured_reg <= 1'b0;
		 debounce_next_state <= SCAN;
     end else begin
         if (state == SCAN && |row_stable) begin
             // Capture the key value and remember which key was pressed
             num_reg <= pressed_value[3:0];
             captured_row <= pressed_value[11:8]; // storing the row that was pressed (synchronized)
             captured_col <= pressed_value[7:4]; // storing the column that was pressed (synchronized)
             captured_reg <= 1'b1;
			 debounce_next_state <= CAPTURE;
         end else if (state == CAPTURE && !captured_reg) begin
             // Store the number in our display registers
             second_reg <= first_reg; // shift old first to second
             first_reg <= num_reg;    // store new number in first
             captured_reg <= 1'b1;    // mark as captured
			 debounce_next_state <= SCAN;
         end else if (state == SCAN) begin
			 captured_reg <= 1'b1;
			 debounce_next_state <= CAPTURE;
		 end else if (state == DEBOUNCE_WAIT) begin
			 captured_reg <= 1'b0;
		 end else if (state == CAPTURE) begin
			 debounce_next_state <= SCAN;
			 captured_reg <= 1'b1;
		 end
     end
 end

 // next state logic
 always_comb begin
     // defaults
     next_state = state;
     allowed = 1'b0;
     enable_delay = 1'b0;
     reset2 = 1'b1; // inactive reset
     enable_scan = 1'b0;
	 state_on = 3'b000;

     case(state)
         SCAN: begin
             enable_scan = 1'b1; // enable applying voltage to cols
             allowed = 1'b1; // allow number capture
             reset2 = 1'b0;  // keep counter reset
			 state_on = 3'b001; // state for LED display
             
             if (|row_stable) begin // using synchronized row to check if there are any 1's when voltage applied to cols
                 next_state = DEBOUNCE_WAIT;
             end else begin
                 next_state = SCAN;
             end
         end
         
         DEBOUNCE_WAIT: begin
             allowed = 1'b0; // do not update number pressed variables
             enable_scan = 1'b0; // STOP scanning during debounce
             reset2 = 1'b1;      // release counter reset
             enable_delay = 1'b1; // start 20ms timer
			 state_on = 3'b010;
             
             if (high) begin
				 state_on = 3'b111; 
                 next_state = debounce_next_state; // Always go to CAPTURE after debounce
             end else begin
                 next_state = DEBOUNCE_WAIT;
             end
         end
         
         CAPTURE: begin
             allowed = 1'b0; // not allowed to update number pressed
             enable_scan = 1'b1; // Keep scanning to detect release
             enable_delay = 1'b0; // turn off delay counter for debouncing
             reset2 = 1'b0; // reset counter for debouncing
			 state_on = 3'b100; 
             
             // Check if the SPECIFIC key that was pressed is released
             // Only check when scanner is on the right column
             if ((col == captured_col) && ((row_stable & captured_row) == 4'b0000)) begin // so when false it registers it. when this is a true cond, it never shows capture led and goes to scan aft, but when its false 
                 next_state = DEBOUNCE_WAIT; // Go directly to SCAN (no debounce on release)
             end else begin
                 next_state = CAPTURE; // key still pressed or wrong column
             end
         end
     endcase
 end

endmodule




