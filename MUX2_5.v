`timescale 1ns / 1ps

module MUX2_5(
    input select,
    input [4:0] source_A,
    input [4:0] source_B,
    output [4:0] result
    );

    assign result = select? source_A: source_B;
    
endmodule