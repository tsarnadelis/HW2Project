// Package for rnd enum 
package rnd_enum;
typedef enum logic [2:0] {IEEE_near, IEEE_zero, IEEE_pinf, IEEE_ninf, near_up, away_zero} rnd_t; 
endpackage

// Import rnd enum in unit
import rnd_enum::*;

module fp_mult(
	input logic [31:0] a, b,
	input logic [2:0] rnd,
	output logic [31:0] z,
	output logic [7:0] status
);

// Internal nets initialisation
logic sign_mult;
logic [9:0] added_exp, exp_mult;
const int exp_bias = 127;
logic [47:0] P;
logic [9:0] norm_exp;
logic [22:0] norm_mantissa;
logic guard, sticky;
logic [24:0] result;
logic inexact;
logic [31:0] z_calc;
logic overflow = 1'b0, underflow= 1'b0;


// Cast rnd to enum type
rnd_t rnd_e = rnd_t'(rnd);

// Sign calculation
assign sign_mult = (a[31] ^ b[31]);

// Exponent addition
assign added_exp = (a[30:23] + b[30:23]);

// Subtraction of bias
assign exp_mult = added_exp - exp_bias;  //--------NOT SURE IF CORRECT - CHECK AGAIN----------

// Mantissa multiplication
assign P = {1'b1,a[22:0]} * {1'b1,b[22:0]}; // Concatenate leading ones

// Truncation and normalization
normalize_mult normalizer(exp_mult, P, norm_exp, norm_mantissa, guard, sticky);

// Rounding
round_mult rounder({1'b1,norm_mantissa}, guard, sticky, sign_mult, rnd_e, result, inexact);

// Post-Rounding
always_comb begin
  if (result[24] == 1'b1) begin // MSB of mantissa is 1
	result = result >> 1; // Shift mantissa to the right by one
	norm_exp = norm_exp + 1; // Increase exponent by one
	end
end

// Make z_calc
assign z_calc = {sign_mult,norm_exp[8:0],result[22:0]};

// Calculate overflow and underflow signals
always_comb begin
if (norm_exp[9] == 1'b1 || norm_exp[8] == 1'b1) begin // Overflow
	overflow = 1;
	end
if (norm_exp[7:0] < 0) begin // Undeflow
	underflow = 1;
	end
end



// TODO: Exeption handling


endmodule