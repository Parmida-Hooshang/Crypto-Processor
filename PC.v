`timescale 1ns / 1ps

module PC(
    input clk,
    input enable,
    input [31:0] next_pc,
    output reg [31:0] pc
    );
	

    initial begin
        pc = 0;
    end

    always @(posedge clk) begin
        if (enable == 1'b1)
            pc <= (next_pc === 32'bx ? 0 : next_pc);
    end

endmodule