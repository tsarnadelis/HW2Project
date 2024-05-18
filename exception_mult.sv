
import rnd_enum::*;

module exception_mult(
	input logic [31:0] a, b, z_calc,
	input logic overflow, underflow, inexact,
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

// Check if z_calc is NaN
if (z_calc[30:23] === 8'b11111111 && z_calc[22:0] > 0) nan_f = 1;

if( num_interp(a) == ZERO ) // A is ZERO 
	case(num_interp(b))
	  INF: begin
		inf_f = 1; // Infinite flag
		z = {1'b0, z_num(INF)};
		end
	  default: begin
		zero_f = 1; // Zero flag
		z = {a[31]+b[31], z_num(ZERO)};
		end	
  	endcase	

else if( num_interp(a) == INF ) // A is INF
  	case(num_interp(b))
	  ZERO:begin
		inf_f = 1; // Infinite flag
		z = {1'b0, z_num(INF)};
		end
	  default: begin
		inf_f = 1; // Infinite flag
		z = {a[31]+b[31], z_num(INF)};
		end			
	endcase

else // A is NORM
  	case(num_interp(b))
	  ZERO: begin
		zero_f = 1; // Zero flag
		z = {a[31]+b[31], z_num(ZERO)};
		end
	  INF: 	begin
		inf_f = 1; // Infinite flag
		z = {a[31]+b[31], z_num(INF)};
		end
	default: if(overflow) // B is NORM
		begin
			huge_f = 1;
			case(rnd)
			IEEE_near: z = {z_calc[31],z_num(MAX_NORM)}; 
			IEEE_zero: z = {z_calc[31],z_num(MAX_NORM)};
			away_zero: z = {z_calc[31],z_num(INF)};
			IEEE_pinf: if(z_calc[31]) z = {z_calc[31],z_num(MAX_NORM)};
				   else z = {z_calc[31],z_num(INF)};
			IEEE_ninf: if(z_calc[31]) z = {z_calc[31],z_num(INF)};
				   else z = {z_calc[31],z_num(MAX_NORM)};
			near_up: if(z_calc[31]) z = {z_calc[31],z_num(MAX_NORM)};
				   else z = {z_calc[31],z_num(INF)};
			endcase
		end	
		else if(underflow)
		begin
			tiny_f = 1;
			case(rnd)
			IEEE_near: z = {z_calc[31],z_num(MIN_NORM)}; 
			IEEE_zero: z = {z_calc[31],z_num(ZERO)};
			away_zero: z = {z_calc[31],z_num(MIN_NORM)};
			IEEE_pinf: if(z_calc[31]) z = {z_calc[31],z_num(ZERO)};
				   else z = {z_calc[31],z_num(MIN_NORM)};
			IEEE_ninf: if(z_calc[31]) z = {z_calc[31],z_num(MIN_NORM)};
				   else z = {z_calc[31],z_num(ZERO)};
			near_up: if(z_calc[31]) z = {z_calc[31],z_num(ZERO)};
				   else z = {z_calc[31],z_num(MIN_NORM)};
			endcase
		end
		else // Neither overflow or underflow
		begin
			z = z_calc;
			inexact_f = inexact;	
		end	

	endcase

end








endmodule	
