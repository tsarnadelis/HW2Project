
import rnd_enum::*;

module round_mult(
	input logic [23:0] mantissa,
	input logic guard, sticky, sign_mult,
	input rnd_t rnd,
	output logic [24:0] result,
	output logic inexact
);

// Internal nets
logic [24:0] temp_result;

always_comb begin
  temp_result = {1'b0,mantissa};
  inexact = (guard | sticky); // Calculate inexact signal

  case (rnd)
            IEEE_near: begin
                // Round to nearest, ties to even
                if (guard && (sticky || temp_result[0])) begin
                    temp_result = temp_result + 1;
                end
            end

            IEEE_zero: begin
                // Round towards zero: Do nothing since temp_result is already truncated
            end

            IEEE_pinf: begin
                // Round towards +Infinity
                if (!sign_mult && inexact) begin
                    temp_result = temp_result + 1;
                end
            end

            IEEE_ninf: begin
                // Round towards -Infinity
                if (sign_mult && inexact) begin
                    temp_result = temp_result + 1;
                end
            end

            near_up: begin
                // Round to the nearest representable value, if both are equally near, output the result closer to +Infinity
                if (guard && (sticky || temp_result[0])) begin
                    temp_result = temp_result + 1;
                end
            end

            away_zero: begin
                // Round away from zero
                if (inexact) begin
                    temp_result = temp_result + 1;
                end
            end

            default: begin
                // Default to IEEE_near
                if (guard && (sticky || temp_result[0])) begin
                    temp_result = temp_result + 1;
                end
            end
        endcase

        result = temp_result;
    end


endmodule
