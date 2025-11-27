`timescale 1ns / 1ps

module ALU(
    input [3:0] control,
    input [31:0] source_A,
    input [31:0] source_B,
    output zero,
    output [31:0] result
    );
	 
	always @(*) begin
		case (control)
            4'b0000: result = source_A & source_B;
            4'b0001: result = source_A | source_B;
            4'b0010: result = source_A + source_B;
            4'b0011: result = source_A ^ source_B;
            4'b0100: result = ~(source_A | source_B);
            4'b0101: result = ~(source_A & source_B);
            4'b0110: result = $signed(source_A) - $signed(source_B);
            4'b0111: result = ($signed(source_A) < $signed(source_B))? 32'b1: 32'b0;
            4'b1000: result = ($unsigned(source_A) < $unsigned(source_B))? 32'b1: 32'b0;
            4'b1100: result = source_A << source_B[4:0];
            4'b1101: result = source_A >> source_B[4:0];
            4'b1111: result = $signed(source_A) >>> source_B[4:0];
            default: result = 32'b0;
        endcase
	end
	
	assign zero = (result == 32'b0);

endmodule
