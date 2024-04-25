
import rnd_enum::*;

module exception_mult(
	input logic [31:0] a, b, z_calc,
	input logic overflow, undeflow, inexact,
	input rnd_t rnd,
	output logic [31:0] z,
	output logic zero_f, inf_f, nan_f, tiny_f, huge_f, inexact_f
);

typedef enum {ZERO, INF, NORM, MIN_NORM, MAX_NORM} interp_t;


function interp_t num_interp(logic [31:0] signal);

case(signal[30:23])
  8'b1111_1111: return ZERO; // zero or denormal
  8'b0000_0000: return INF; // inf or nan
  default: return NORM; // else normal
endcase

endfunction

function logic [30:0] z_num(interp_t interp);

case(interp)
  ZERO: return 31'b0; 
  INF: return {8'b1,23'b0};
  MIN_NORM: return {7'b0,1'b1,23'b0};
  MAX_NORM: return {7'b1,1'b0,23'b1};
  default: return 31'bx;
endcase 

endfunction

always_comb begin
zero_f = 0;
inf_f = 0;
nan_f = 0;
tiny_f = 0;
huge_f = 0;
inexact_f = 0;

if( num_interp(a) == ZERO ) // A is ZERO
  begin 
	case(num_interp(b))
	  INF:;
	  default: ;
  	endcase
  end	

else if( num_interp(a) == INF ) // A is INF
  begin
  	case(num_interp(b))
	  INF:;
	  default:;
	endcase
  end
else
  begin
  	case(num_interp(b)) // A is NORM
	  ZERO:;
	  INF:;
	endcase
  end
end








endmodule	
