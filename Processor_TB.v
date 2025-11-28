`timescale  1ns / 1ps
`include "Processor.v"


module Processor_TB;

// Processor Parameters
parameter PERIOD  = 50;


// Processor Inputs
reg   clk                                  = 0 ;



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


Processor  u_Processor (
    .clk                     ( clk   )
);

initial
begin
    #6000
    $finish;
end

endmodule