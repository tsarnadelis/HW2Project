`timescale 1ns/1ps
`include "multiplication.sv"

module fp_mult_tb;

  // Internal nets
  logic clk, rst;
  logic [31:0] a, b, z;
  logic [31:0] expected_z;
  logic [2:0] rnd;
  logic [7:0] status;

  // Instantiate the Unit Under Test (UUT)
  fp_mult_top DUT (
      .clk(clk),
      .rst(rst),
      .rnd(rnd),
      .a(a),
      .b(b),
      .z(z),
      .status(status)
  );

  // Bind DUT to the status test module
  bind DUT test_status_bits dutbound (clk, status);

  // Bind DUT to the z combinations test module
  bind DUT test_status_z_combinations dutbound_z (clk, status, z ,a ,b);

  // Clock generation
  always #7.5 clk = ~clk; // Clock period is 15ns

  // Define corner cases
  typedef enum logic [3:0] {
      neg_snan, pos_snan,
      neg_qnan, pos_qnan,
      neg_inf, pos_inf,
      neg_norm, pos_norm,
      neg_denorm, pos_denorm,
      neg_zero, pos_zero
  } corner_case_t;

  function logic [31:0] corner_case_to_value(corner_case_t corner_case);
      case (corner_case)
          neg_snan:   return 32'hFF800001; // negative signaling NaN
          pos_snan:   return 32'h7F800001; // positive signaling NaN
          neg_qnan:   return 32'hFFC00001; // negative quiet NaN
          pos_qnan:   return 32'h7FC00001; // positive quiet NaN
          neg_inf:    return 32'hFF800000; // negative infinity
          pos_inf:    return 32'h7F800000; // positive infinity
          neg_norm:   return 32'hBF800000; // random negative normal (e.g., -1.0)
          pos_norm:   return 32'h3F800000; // random positive normal (e.g., 1.0)
          neg_denorm: return 32'h80000001; // random negative denormal
          pos_denorm: return 32'h00000001; // random positive denormal
          neg_zero:   return 32'h80000000; // negative zero
          pos_zero:   return 32'h00000000; // positive zero
          default:    return 32'h00000000;
      endcase
  endfunction

  corner_case_t cases[12] = '{neg_snan, pos_snan, neg_qnan, pos_qnan, neg_inf, pos_inf, neg_norm, pos_norm, neg_denorm, pos_denorm, neg_zero, pos_zero};

  initial begin
    clk = 0;
    rst = 1;
    #2 rst = 0;

    // Test IEEE_near
    a = $urandom(369);
    b = $urandom();
    rnd = 3'b000; // IEEE_near
    $display("IEEE_near Random Test: a=%d, b=%d", a, b);
    expected_z = multiplication("IEEE_near", a, b);
    #28
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Test IEEE_zero
    a = $urandom();
    b = $urandom();
    rnd = 3'b001; // IEEE_zero
    expected_z = multiplication("IEEE_zero", a, b);
    $display("IEEE_zero Random Test: a=%d, b=%d", a, b);
    #30
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Test IEEE_pinf
    a = $urandom();
    b = $urandom();
    rnd = 3'b010; // IEEE_pinf
    expected_z = multiplication("IEEE_pinf", a, b);
    $display("IEEE_pinf Random Test: a=%d, b=%d", a, b);
    #30
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Test IEEE_ninf
    a = $urandom();
    b = $urandom();
    rnd = 3'b011; // IEEE_ninf
    expected_z = multiplication("IEEE_ninf", a, b);
    $display("IEEE_ninf Random Test: a=%d, b=%d", a, b);
    #30
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Test near_up
    a = $urandom();
    b = $urandom();
    rnd = 3'b100; // near_up
    expected_z = multiplication("near_up", a, b);
    $display("near_up Random Test: a=%d, b=%d", a, b);
    #30
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Test away_zero
    a = $urandom();
    b = $urandom();
    rnd = 3'b101; // away_zero
    expected_z = multiplication("away_zero", a, b);
    $display("away_zero Random Test: a=%d, b=%d", a, b);
    #30
    // Check for mismatch and display error
    if (z !== expected_z) $display("ERROR: Mismatch detected!");
    else $display("Test PASSED!");

    // Check corner cases
    $display("\n--------Starting corner case testing.--------\n");
    rnd = 3'b001; // Set a default rounding mode (e.g., IEEE_near)

    for (int i = 0; i < 12; i++) begin
      for (int j = 0; j < 12; j++) begin
        a = corner_case_to_value(cases[i]);
        b = corner_case_to_value(cases[j]);
	expected_z = multiplication("IEEE_near", a, b);
        // Apply the inputs and wait for the result
        #30; // Wait for some time to simulate the operation

        // Print only the errors
	if (z !== expected_z)
	    begin
		$display("a = %h, b = %h, z = %h, expected = %h", a, b, z, expected_z);
		$display("ERROR: Mismatch detected!");
		$display("At time %0t", $time);
	    end
      end
    end
    $display("\n--------Corner case testing completed.--------\n");
    #500 $stop;
  end

endmodule

