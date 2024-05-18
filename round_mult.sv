
import rnd_enum::*;

module round_mult(
	input logic [23:0] mantissa,
	input logic guard, sticky, sign_mult,
	input rnd_t rnd,
	output logic [24:0] result,
	output logic inexact
);

// Internal nets
logic [24:0] rounded_mantissa;

always_comb begin
  rounded_mantissa = {1'b0,mantissa};
  inexact = (guard | sticky); // Calculate inexact signal
  if (!inexact) result = rounded_mantissa; // Result is exact, do nothing
  else begin // Result is inexact and needs rounding
	case(rnd)
	IEEE_near: result = rounded_mantissa; // Do nothing

	IEEE_zero: begin
                if (!sign_mult && guard && sticky) result = mantissa - 1;
		else if(sign_mult && guard && sticky) result = mantissa + 1;
                else result = mantissa;
            end
	away_zero: if (sign_mult && !sticky) result = mantissa + 1;
                   else if (!sign_mult && !guard) result = mantissa + 1;
                   else result = mantissa;

	IEEE_pinf: if(sign_mult && guard) result = mantissa - 1;
		   else if (!sign_mult && guard) result = mantissa + 1;
		   else result = mantissa;

	IEEE_ninf: if(sign_mult && !guard) result = mantissa - 1;
		   else if (!sign_mult && !guard) result = mantissa + 1;
		   else result = rounded_mantissa;

//------------NOT SURE IF NEAR UP WORKS AS INTENTED-----------------------//
	near_up: if(sign_mult) result = rounded_mantissa - 1; // Negative, decrease absolute
		   else result = rounded_mantissa + 1; // Positive, increase absolute;

	default: result = rounded_mantissa; // Do nothing, same as IEEE_near
	endcase	
	end
end

endmodule
