`timescale 1ns/1ps
`include "multiplication.sv"

module fp_mult_tb;

  // Internal nets
  logic clk, rst;
  logic [31:0] a, b, z, expected_z;
  logic [2:0] rnd;
  logic [7:0] status;


  fp_mult_top DUT(clk, rst, rnd, a, b, z, status);

  // Clock generation
  always #(15/2) clk = ~clk; // Clock period is 15ns


  initial begin
	clk = 0;
	rst = 1; 
	#2 rst = 0;

	// Test IEEE_near
    	a = $urandom(253);
    	b = $urandom();
	rnd = 3'b000; // IEEE_near
  	$display("IEEE_near Random Test: a=%d, b=%d", a, b);
	expected_z = multiplication("IEEE_near",a,b);
	#28
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");

	// Test IEEE_zero
    	a = $urandom();
    	b = $urandom();
	rnd = 3'b001; // IEEE_zero
	expected_z = multiplication("IEEE_zero",a,b);
  	$display("IEEE_zero Random Test: a=%d, b=%d", a, b);
	#30
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");
	
	// Test IEEE_pinf
    	a = $urandom();
    	b = $urandom();
	rnd = 3'b010; // IEEE_pinf
	expected_z = multiplication("IEEE_pinf",a,b);
  	$display("IEEE_pinf Random Test: a=%d, b=%d", a, b);
	#30
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");
	
	// Test IEEE_ninf
    	a = $urandom();
    	b = $urandom();
	rnd = 3'b011; // IEEE_ninf
	expected_z = multiplication("IEEE_ninf",a,b);
  	$display("IEEE_ninf Random Test: a=%d, b=%d", a, b);
	#30
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");

	// Test near_up
    	a = $urandom();
    	b = $urandom();
	rnd = 3'b100; // near_up
	expected_z = multiplication("near_up",a,b);
  	$display("near_up Random Test: a=%d, b=%d", a, b);
	#30
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");

	// Test away_zero
    	a = $urandom();
    	b = $urandom();
	rnd = 3'b101; // away_zero
	expected_z = multiplication("away_zero",a,b);
  	$display("away_zero Random Test: a=%d, b=%d", a, b);
	#30
      	// Check for mismatch and display error
      	if (z !== expected_z) $display("ERROR: Mismatch detected!");
	else $display("Test PASSED!");

	#200 $stop;    
	end


endmodule

