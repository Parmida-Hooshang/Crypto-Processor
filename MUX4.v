`timescale 1ns / 1ps

module MUX4(
    input [1:0] select,
    input [31:0] source_A,
    input [31:0] source_B,
    input [31:0] source_C,
    input [31:0] source_D,
    output reg [31:0] result
    );

    always @(*) begin
        case (select)
            2'b00: result = source_A;
            2'b01: result = source_B;
            2'b10: result = source_C;
            2'b11: result = source_D;
            default: result = source_A;
        endcase
    end
    
endmodule