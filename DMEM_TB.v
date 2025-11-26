`timescale  1ns / 1ps
`include "DMEM.v"

module DMEM_TB;

// DMEM Parameters
parameter PERIOD  = 50;


// DMEM Inputs
reg   clk                                  = 0 ;
reg   read_enable                          = 0 ;
reg   write_enable                         = 0 ;

// DMEM Outputs
wire  [127:0]  read_data                   ;
wire  data_ready                           ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


DMEM  u_DMEM (
    .clk                     ( clk                  ),     
    .read_enable             ( read_enable          ), 
    .write_enable            ( write_enable         ),    

    .read_data               ( read_data            ),     
    .data_ready              ( data_ready           )      
);

initial
begin

    read_enable = 1;

    
    @(posedge data_ready)
    $display("plain text = %h", read_data);

    $finish;
end

endmodule