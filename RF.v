`timescale 1ns / 1ps

module RF(
    input clk,
    input write_enable,
    input [4:0] reg_1,
    input [4:0] reg_2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] data_1,
    output [31:0] data_2
    );

    reg [31:0] registers [0:31];

    integer i;
    initial begin
        for (i=0;i<32;i=i+1)
            registers[i] = 32'b0;
    end

    assign data_1 = (reg_1 == 0)? 32'b0: registers[reg_1];
    assign data_2 = (reg_2 == 0)? 32'b0: registers[reg_2];

    always @(posedge clk) begin
        if (write_enable && write_reg != 0)
            registers[write_reg] <= write_data;
    end
	

endmodule
