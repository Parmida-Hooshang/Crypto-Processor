`timescale 1ns / 1ps

module MUX2(
    input select,
    input [31:0] source_A,
    input [31:0] source_B,
    output reg [31:0] result
    );

    always @(*) begin
        if (select == 1'b0)
            result = source_A;
        else
            result = source_B;
    end
    
endmodule