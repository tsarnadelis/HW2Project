module test_status_z_combinations(
    input logic clk,
    input logic [7:0] status_bits,
    input logic [31:0] z, a, b
);

    // Sequence for checking NaN condition two cycles before
    sequence nan_condition;
        ($past(a[30:23],2) == 8'b0 && $past(b[30:23],2) == 8'b11111111) || 
        ($past(a[30:23],2) == 8'b11111111 && $past(b[30:23],2) == 8'b0);
    endsequence

    // Concurrent Assertions
    assert property (@(posedge clk) status_bits[0] |-> (z[30:23] == 8'b0))
        else $error("Zero status bit set but exponent of 'z' is not zero");

    assert property (@(posedge clk) status_bits[1] |-> (z[30:23] == 8'b11111111)) 
        else $error("Infinity status bit set but exponent of 'z' is not all ones");

    assert property (@(posedge clk) status_bits[2] |-> ##2 nan_condition) 
        else $error("NaN status bit set but exponents of 'a' and 'b' are not in required condition");

    assert property (@(posedge clk) status_bits[4] |-> (((a[30:23] == 8'b0 && b[30:23] == 8'b11111111) || 
                                                        (a[30:23] == 8'b11111111 && b[30:23] == 8'b0))))
        else $error("Huge status bit set but exponent and mantissa of 'z' are not in required condition");

    assert property (@(posedge clk) status_bits[3] |-> (z[30:23] == 8'b0 || 
                                                         (z[30:23] == 8'b00000001 && z[22:0] == 23'b0)))
        else $error("Tiny status bit set but exponent and mantissa of 'z' are not in required condition");

endmodule

