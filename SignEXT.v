`timescale 1ns / 1ps

module SignEXT(
    input sign,
    input [15:0] immediate_16,
    output reg [31:0] immediate_32
    );
    
    always @(*) begin
        immediate_32 = ((sign == 1'b1) ? {{16{immediate_16[15]}}, immediate_16} : {16'b0, immediate_16});
    end

endmodule