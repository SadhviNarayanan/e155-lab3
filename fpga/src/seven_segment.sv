// E155, Lab 3 Code to output a seven segment display based on hex values

// Name: Sadhvi Narayanan
// Email: sanarayanan@g.hmc.edu
// Date: 09/14/2025


// seven segment display module to convert a 4 bit hex into segments on a seven segment display
module seven_segment(
	input logic [4:0] s,
	output logic [6:0] seg
);
	// combinational cases to trigger seven segment display
	always_comb begin
		case(s)
			5'h0: seg = 7'b1000000;
			5'h1: seg = 7'b1001111;
			5'h2: seg = 7'b0100100;
			5'h3: seg = 7'b0110000;
			5'h4: seg = 7'b0011001;
			5'h5: seg = 7'b0010010;
			5'h6: seg = 7'b0000010;
			5'h7: seg = 7'b1111000;
			5'h8: seg = 7'b0000000;
			5'h9: seg = 7'b0011000;
			5'hA: seg = 7'b0001000;
			5'hB: seg = 7'b0000011;
			5'hC: seg = 7'b1000110;
			5'hD: seg = 7'b0100001;
			5'hE: seg = 7'b0000110;
			5'hF: seg = 7'b0001110;
			default: seg = 7'b1111111;
		endcase
	end
endmodule



