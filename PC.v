`timescale 1ns / 1ps

module PC(
    input clk,
    input [31:0] next_pc,
    output reg [31:0] pc;
    );
	
    always @(posedge clk) begin
        pc <= next_pc;
    end

endmodule