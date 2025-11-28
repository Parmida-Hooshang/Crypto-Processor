`timescale 1ns / 1ps

module MUX2_5(
    input select,
    input [4:0] source_A,
    input [4:0] source_B,
    output reg [4:0] result
    );

    always @(*) begin
        if (select == 1'b0)
            result = source_A;
        else
            result = source_B;
    end
    
endmodule