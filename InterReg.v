`timescale 1ns / 1ps

module InterReg(
    input clk,
    input enable,
    input [31:0] inp,
    output reg [31:0] out
    );
	
    always @(posedge clk) begin
        if (enable)
            out <= inp;
    end

endmodule