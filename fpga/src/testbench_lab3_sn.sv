// E155, Lab 3 - Testbench to test top level module - applying inputs and measuring outputs with the clock

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/14/2025

`timescale 1ns/1ps

module testbench_lab3_sn;

 logic clk, reset, reset2;
 logic [3:0] row_stable, row, col;
 logic [11:0] pressed_value;
 logic [1:0] state, next_state;
 logic [3:0] first, second;
 logic [2:0] state_on;
 logic allowed, enable_delay, enable_scan;
 logic high;
 
 typedef enum logic [1:0] {SCAN = 2'b00, DEBOUNCE_WAIT = 2'b01, CAPTURE = 2'b10} state_t;

 // Instantiate DUT
 state_fsm dut (
   .clk(clk), .reset(reset), .high(high),
   .row_stable(row_stable), .row(row), .col(col),
   .pressed_value(pressed_value), .state(state), .next_state(next_state),
   .first(first), .second(second),
   .allowed(allowed), .enable_delay(enable_delay), .reset2(reset2),
   .enable_scan(enable_scan), .state_on(state_on)
 );

 // Clock generation - 20ns period
 always begin
     clk = 0; #10; clk = 1; #10;
 end

 // Stimulus
 initial begin
     $dumpfile("fsm.vcd");
     $dumpvars(0, testbench_state_fsm);
     $display("Starting FSM test...");

     // Initialize signals
     row_stable = 4'b0000;
     col = 4'b0000;
     pressed_value = 12'h000;
     high = 1'b0;
     
     // Apply reset
     reset = 0;
     #22; // Hold reset for a bit
     reset = 1;
     #22; // Wait for reset to take effect
     
     $display("Time: %0t - After reset, state = %b", $time, state);

     // FSM should start in SCAN
     assert(state == SCAN) else $error("Expected SCAN after reset, got %b", state);
     $display("FSM starts in SCAN state");

     // Test 1: Press key 0xA (row=0001, col=1000)
     $display("=== Testing key press 0xA ===");
     
     // Apply key press signals for A
     row_stable = 4'b0001; 
     col = 4'b1000; 
     pressed_value = {4'b0001, 4'b1000, 4'hA};
     
     // Wait for combinational logic to settle
     #0.1;
     $display("Time: %0t - After key press setup, next_state = %b", $time, next_state);
     
     // Clock edge - state should transition to DEBOUNCE_WAIT
     @(posedge clk); #0.1; // Give time for data to settle
     $display("Time: %0t - After clock, state = %b", $time, state);
     assert(state == DEBOUNCE_WAIT) else $error("Expected state DEBOUNCE_WAIT, got %b", state);
     assert(enable_delay == 1) else $error("Expected enable_delay=1 in DEBOUNCE_WAIT");
     assert(allowed == 0) else $error("Expected allowed=0 in DEBOUNCE_WAIT");
     assert(enable_scan == 0) else $error("Expected enable_scan=0 in DEBOUNCE_WAIT");

     // Simulate debounce completion by asserting high
     high = 1; 
     #0.1; // Let combinational logic settle
     $display("Time: %0t - High asserted, next_state = %b", $time, next_state);
     
     @(posedge clk); #0.1; // State should update to CAPTURE
     high = 0; // Clear high signal after clock edge
     
     $display("Time: %0t - After debounce, state = %b", $time, state);
     assert(state == CAPTURE) else $error("Expected CAPTURE, got %b", state);
     assert(enable_scan == 1) else $error("Expected enable_scan=1 in CAPTURE");

     // Give one more clock for the data to be captured
     @(posedge clk); #0.1;
     $display("Time: %0t - After capture clock, first = %h, second = %h", $time, first, second);
     assert(first == 4'hA) else $error("First capture failed, expected 0xA got %h", first);

     // Release key (must be on the same column as when pressed)
     $display("Testing key release");
     row_stable = 4'b0000; 
     // Keep col = 4'b1000 (same as when pressed) for proper release detection
     col = 4'b1000;
     
     #0.1; // Let combinational logic settle
     $display("Time: %0t - After release setup, next_state = %b", $time, next_state);
     
     @(posedge clk); #0.1; // State should update to SCAN
     $display("Time: %0t - After release clock, state = %b", $time, state);
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT after release, got %b", state);
     assert(enable_scan == 0) else $error("Expected enable_scan=0 in DEBOUNCE_WAIT");
     high = 1;
     @(posedge clk); #0.1;
     assert(state == SCAN) else $error("Expected SCAN, got %b", state);

     // Test 2: Press key 0x7 (row=0100, col=0001)
     $display("=== Testing key press 0x7 ===");
     row_stable = 4'b0100; 
     col = 4'b0001; 
     pressed_value = {4'b0100, 4'b0001, 4'h7};
     
     #0.1; // Let signals settle
     @(posedge clk); #0.1; // Move to DEBOUNCE_WAIT
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT state, got %b", state);

     // Complete debounce
     high = 1; 
     #0.1;
     @(posedge clk); #0.1; // Move to CAPTURE
     high = 0;
     
     $display("Time: %0t - After 7 press, state = %b, first = %h, second = %h", $time, state, first, second);
     assert(state == CAPTURE) else $error("Expected CAPTURE, got %b", state);
     high = 1;
     @(posedge clk); #0.1;
     $display("Time: %0t - After 7 press, state = %b, first = %h, second = %h", $time, state, first, second);
     assert(first == 4'h7) else $error("First capture failed, expected 0xA got %h", first);
     @(posedge clk); #0.1;
     assert(second == 4'hA) else $error("Second should be 0xA, got %h", second);

     // Release key 7 (on correct column)
     row_stable = 4'b0000;
     col = 4'b0001; // Same column as when pressed
     #0.1;
     @(posedge clk); #0.1; // Move back to DEBOUNCE_WAIT
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT after release, got %b", state);
     high = 1;
     @(posedge clk); #0.1; // Move back to SCAN (directly)
     

     // Test 3: Press key 0x3 (row=0001, col=0100)
     $display("=== Testing key press 0x3 ===");
     assert(allowed == 1) else $error("Allowed should be 1 in SCAN state, got %b", allowed);
     
     row_stable = 4'b0001; 
     col = 4'b0100; 
     pressed_value = {4'b0001, 4'b0100, 4'h3};
     
     #0.1; // Let signals settle
     @(posedge clk); #0.1; // Move to DEBOUNCE_WAIT
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT after press 3, got %b", state);
     
     high = 1; 
     #0.1;
     @(posedge clk); #0.1; // Move to CAPTURE
     high = 0;
     
     // Wait for data capture
     @(posedge clk); #0.1;
     $display("Time: %0t - After 3 press, first = %h, second = %h", $time, first, second);
     assert(state == CAPTURE) else $error("Expected CAPTURE after press 3, got %b", state);
     assert(first == 4'h3) else $error("Expected first=3, got %h", first);
     assert(second == 4'h7) else $error("Expected second=7, got %h", second);
     
     // Test that values persist while button held
     repeat(3) begin
         @(posedge clk);
         assert(state == CAPTURE) else $error("Expected CAPTURE while button held, got %b", state);
         assert(first == 4'h3 && second == 4'h7) else $error("Values should persist while held, first=%h second=%h", first, second);
     end
     
     // Release button 3 (on correct column)
     row_stable = 4'b0000;
     col = 4'b0100; // Same column as when pressed
     #0.1; // Let release be detected
     
     @(posedge clk); #0.1;
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT after release, got %b", state);
     high = 1;
     @(posedge clk); #0.1;

     $display("Time: %0t - After button 3 release, state = %b", $time, state);
     assert(state == SCAN) else $error("Expected SCAN after release, got %b", state);

     // Test 4: Test wrong column release detection
     $display("=== Testing wrong column during release ===");
     
     // Press key 0x5 (row=0010, col=0010)
     row_stable = 4'b0010; 
     col = 4'b0010; 
     pressed_value = {4'b0010, 4'b0010, 4'h5};
     
     #0.1;
     @(posedge clk); #0.1; // SCAN -> DEBOUNCE_WAIT
     
     high = 1; 
     #0.1;
     @(posedge clk); #0.1; // DEBOUNCE_WAIT -> CAPTURE
     high = 0;
     @(posedge clk); #0.1; // Allow capture
     
     assert(state == CAPTURE) else $error("Expected CAPTURE, got %b", state);
     
     // Try to release on WRONG column (should not release)
     row_stable = 4'b0000;
     col = 4'b0001; // Wrong column!
     #0.1;
     @(posedge clk); #0.1;
     assert(state == CAPTURE) else $error("Should stay in CAPTURE with wrong column, got %b", state);
  
     // Now release on correct column
     col = 4'b0010; // Correct column
     #0.1;
     @(posedge clk); #0.1;
     assert(state == DEBOUNCE_WAIT) else $error("Expected DEBOUNCE_WAIT with correct column release, got %b", state);
     high = 1;

     @(posedge clk); #0.1;
     assert(state == SCAN) else $error("Expected SCAN with correct column release, got %b", state);

     $display("All FSM tests completed successfully!");
     $finish;
 end

endmodule


