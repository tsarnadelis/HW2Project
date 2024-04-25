
import rnd_enum::*;

module round_mult(
	input logic [23:0] mantissa,
	input logic guard, sticky, sign_mult,
	input rnd_t rnd,
	output logic [24:0] result,
	output logic inexact
);

always_comb begin
  inexact = (guard | sticky); // Calculate inexact signal
  // TODO: case statement based on rnd signal
  result = {1'b0,mantissa};
  // Temporary result returns the original mantissa
  // because i dont understand how rounding works.
  // Currently this does nothing.
end

endmodule
