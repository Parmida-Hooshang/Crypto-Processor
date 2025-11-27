`timescale 1ns / 1ps

module MUX2(
    input select,
    input [31:0] source_A,
    input [31:0] source_B,
    output [31:0] result,
    );

    assign result = select? source_A: source_B;
    
endmodule