// E155, Lab 3 - Top Level Module for KeyPad Scanner lab (time multiplexes keypad segments on display using a keyboard)


// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/10/2025

module lab3_sn(
   input logic reset,
   input logic [3:0] row,
   output logic [3:0] col,
   output logic [6:0] seg,
   output logic [1:0] enable_seg,
   output logic [2:0] state_on
);


   // internal signals
   logic int_osc, pressed, enable_delay, high, delay_signal;
   logic clk_signal, high2, reset2, allowed, enable_scan;
   logic [1:0] scan_counter;
   logic [3:0] row_stable, col_stable;
   logic [4:0] s;
   logic [6:0] seg1, seg2;
   logic [1:0] state, next_state, debounce_next_state;
   logic [4:0] num;
   logic [4:0] first, second;
   logic [11:0] pressed_value;
   logic enable_toggle;
   
   
   assign enable_toggle = 1;

   // Internal high-speed oscillator
   HSOSC #(.CLKHF_DIV(2'b11))
       hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
  
   // the couter flop to wait for 20ms --> debouncing
   clock # (.freq(480000)) clock_delay_1(int_osc, reset2, enable_delay, delay_signal, high);


   // create the 60Hz clock for the seven segment display
   clock # (.freq(50000)) clock_delay_2(int_osc, reset, enable_toggle, clk_signal, high2);


   // keypad scanner
   keypad_scanner keypad_scanner1(
       .clk(int_osc),
       .reset(reset),
	   .enable_scan(enable_scan),
       .row(row),
       .col(col),
       .row_stable(row_stable),
	   .col_stable(col_stable)
   );


   // state machine to cycle through all the states
   state_fsm state_machine(
       .clk(int_osc), .reset(reset), .high(high),
       .row_stable(row_stable), .col(col_stable),
       .pressed_value(pressed_value), .state(state), .next_state(next_state),
       .first(first), .second(second),
       .allowed(allowed), .enable_delay(enable_delay), .reset2(reset2),
	   .enable_scan(enable_scan),
	   .state_on(state_on)
	   
   );


   // capture the key clicked on the keypad
   number_capture keyboard_number_capture(
       .allowed(allowed),
       .row_stable(row_stable),
       .col(col),
       .pressed_value(pressed_value)
   );

   
   always_comb begin
	enable_seg = (clk_signal == 0) ? 2'b10 : 2'b01;
	s = (clk_signal == 0) ? first : second;
   end
   

   // seven segment display
   seven_segment seven_segment_decoder2(s, seg);


endmodule







