
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
  8'b1111_1111: return INF; // inf or nan
  8'b0000_0000: return ZERO; // zero or denormal
  default: return NORM; // else normal
endcase

endfunction

function logic [30:0] z_num(interp_t interp);

case(interp)
  ZERO:     return 31'b00000000_00000000000000000000000; 
  INF:      return 31'b11111111_00000000000000000000000;
  MIN_NORM: return 31'b00000001_00000000000000000000000;
  MAX_NORM: return 31'b11111110_11111111111111111111111;
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

case ({num_interp(a),num_interp(b)})

	{ZERO, ZERO}, {ZERO, NORM}, {NORM, ZERO}:
		begin
			zero_f = 1; // Infinite flag
			z = {z_calc[31], z_num(ZERO)};
		end

	{ZERO, INF}, {INF, ZERO}:
		begin
			inf_f = 1; // Infinite flag
			z = {1'b0, z_num(INF)}; // +INF
		end
		
	{INF, INF}, {INF, NORM}, {NORM, INF}:
		begin
			inf_f = 1; // Infinite flag
			z = {z_calc[31], z_num(INF)};
		end
	
	{NORM, NORM}:
                begin
                    if (overflow) begin
			huge_f = 1;
			inexact_f = 1;
			case(rnd)
			IEEE_near, away_zero: // Round to pos or neg INF
				begin
				    z = {z_calc[31], z_num(INF)};
				    inf_f = 1;
				end
			IEEE_zero: // Round to pos os neg MAX NORM
				begin
				    z = {z_calc[31], z_num(MAX_NORM)};
				end
			IEEE_pinf, near_up: // If pos +INF, if neg -MAX NORM
				begin
				    if( !z_calc[31] ) 
					begin
					    z = {z_calc[31], z_num(INF)};
					    inf_f = 1;
					end
				    else
					begin
					    z = {z_calc[31], z_num(MAX_NORM)};
					end
				end
							
			IEEE_ninf: // If pos +MAX NORM, if neg -INF
				begin
				    if( !z_calc[31] ) 
					begin
					    z = {z_calc[31], z_num(MAX_NORM)};
					end
				    else
					begin
					    z = {z_calc[31], z_num(INF)};
					    inf_f = 1;
					end
				end
			endcase
			end else if ( underflow ) begin
			tiny_f = 1;
			inexact_f = 1;
			case(rnd)
			// I SUPPOSE NEAR AND AWAY ZERO DO THE SAME THING
			IEEE_near, away_zero: // Round to pos or neg MIN NORM
				begin
				    z = {z_calc[31], z_num(MIN_NORM)};
				end
			IEEE_zero: // Round to pos os neg ZERO
				begin
				    z = {z_calc[31], z_num(ZERO)};
				    zero_f = 1;
				end
			// I SUPPOSE PINF AND NEAR UP DO THE SAME THING
			IEEE_pinf, near_up: // If pos +MIN NORM, if neg -ZERO
				begin
				    if( !z_calc[31] ) 
					begin
					    z = {z_calc[31], z_num(MIN_NORM)};
					end
				    else
					begin
					    z = {z_calc[31], z_num(ZERO)};
				    	    zero_f = 1;
					end
				end
							
			IEEE_ninf: // If pos +ZERO, if neg -MIN NORM
				begin
				    if( !z_calc[31] ) 
					begin
					    z = {z_calc[31], z_num(ZERO)};
					    zero_f = 1;
					end
				    else
					begin
					    z = {z_calc[31], z_num(MIN_NORM)};
					end
				end
			endcase
			end else begin// No overflow or undeflow
				z = z_calc;
				inexact_f = inexact;
			end
		end

	default: 
	    begin
            	// Handle other unexpected cases, result as zero
                z = {z_calc[31], 31'b0};
                zero_f = 1'b1;
            end
        endcase

// Check if z_calc is NaN
nan_f = (z_calc[30:23] == 8'hFF & z_calc[22:0] > 23'b0);

end

endmodule	
