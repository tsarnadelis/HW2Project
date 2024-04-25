module normalize_mult(
	input logic [9:0] exp_mult,
	input logic [47:0] P,
	output logic [9:0] norm_exp,
	output logic [22:0] norm_mantissa,
	output logic guard, sticky
);

always_comb
  if (P[47]) begin
	norm_exp = exp_mult + 1'b1; // Exponent update
	norm_mantissa = P[46:24]; // Mantissa normalizer
	guard = P[23]; // Guard bit
	sticky = |P[22:0]; // Sticky bit //-----CHECK IF BITWISE OR WORKS-------
	end
  else begin
	norm_exp = exp_mult; // Exponent update
	norm_mantissa = P[45:23]; // Mantissa normalizer
	guard = P[22]; // Guard bit
	sticky = |P[21:0]; // Sticky bit //-----CHECK IF BITWISE OR WORKS-------
end

endmodule
