`timescale 1ns / 1ps

module IMEM(
    input [31:0] address,
    output [31:0] instruction
    );
	 
	reg [31:0] memory[0:1023];
	 
	initial begin
		$readmemh("IMEM.mem", memory);
	end
	
	assign instruction = memory[address[31:2]];

endmodule