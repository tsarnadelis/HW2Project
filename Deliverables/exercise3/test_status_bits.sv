module test_status_bits(
    input logic clk,
    input logic [7:0] status_bits
);
    // Immediate Assertions sensitive to posedge clk
    always @(posedge clk) begin
	if (!$isunknown(status_bits)) begin
        assert (!(status_bits[0] & status_bits[1])) else $error("Zero and Infinity asserted simultaneously");
        assert (!(status_bits[0] && status_bits[2])) else $error("Zero and Invalid asserted simultaneously");
        assert (!(status_bits[0] && status_bits[3])) else $error("Zero and Tiny asserted simultaneously");
        assert (!(status_bits[0] && status_bits[4])) else $error("Zero and Huge asserted simultaneously");
        assert (!(status_bits[0] && status_bits[5])) else $error("Zero and Inexact asserted simultaneously");
        assert (!(status_bits[1] && status_bits[3])) else $error("Infinity and Tiny asserted simultaneously");
        assert (!(status_bits[1] && status_bits[4])) else $error("Infinity and Huge asserted simultaneously");
        assert (!(status_bits[1] && status_bits[5])) else $error("Infinity and Inexact asserted simultaneously");
        assert (!(status_bits[2] && status_bits[3])) else $error("Invalid and Tiny asserted simultaneously");
        assert (!(status_bits[2] && status_bits[4])) else $error("Invalid and Huge asserted simultaneously");
        assert (!(status_bits[2] && status_bits[5])) else $error("Invalid and Inexact asserted simultaneously");
	end
    end
endmodule
