`timescale  1ns / 1ps
`include "DMEM.v"

module DMEM_TB;

// DMEM Parameters
parameter PERIOD  = 50;


// DMEM Inputs
reg   clk                                  = 0 ;
reg   read_enable                          = 0 ;
reg   write_enable                         = 0 ;
reg [31:0] address                             ;
reg [127:0] write_data                          ;

// DMEM Outputs
wire  [127:0]  read_data                   ;
wire  done                           ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end


DMEM  u_DMEM (
    .clk                     ( clk                  ),     
    .read_enable             ( read_enable          ), 
    .write_enable            ( write_enable         ), 
    .address                 ( address              ), 
    .write_data              ( write_data           ),    

    .read_data               ( read_data            ),     
    .done              ( done           )      
);

initial
begin

    address = 32'b1110000;
    write_data = 128'h12;
    write_enable = 1;
    #60
    address = 32'b1010000;
    write_enable = 0;
    #60
    write_data = 1;
    #60
    write_data = 0;

    #700
    address = 32'b1110000;
    read_enable = 1;


    
    @(posedge done)
    $display("plain text = %h", read_data);

    $finish;
end

endmodule