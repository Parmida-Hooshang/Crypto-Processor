`timescale 1ns / 1ps

module DMEM(
    output reg [127:0] out
    );

    reg [7:0] sbox_table [0:255];
    wire [127:0] data=5;

    initial begin
        // SBox implemented as lookup table for simplicity
        $readmemh("SBoxROM.mem", sbox_table);
        out = MixColumns(ShiftRows(SubByte(data)));
        $display("out = %h", out);
    end


    



    // ---------- AES Functions ---------- //
    function [127:0] SubByte;
        input [127:0] data;

        integer i;
        begin
            for (i=0;i<16;i=i+1) 
                SubByte[i*8 +: 8] = sbox_table[data[i*8 +: 8]];
        end
        
    endfunction

    function [127:0] ShiftRows;
        input [127:0] data;

        reg [7:0] bytes [15:0];
        integer i;
        begin
            for (i=0;i<16;i=i+1) begin
                bytes[i] = data[i*8 +: 8];
            end
            
            ShiftRows = {
                bytes[15],  bytes[14],  bytes[13], bytes[12],
                bytes[10],  bytes[9],  bytes[8], bytes[11],
                bytes[5],  bytes[4], bytes[7],  bytes[6],
                bytes[0], bytes[3],  bytes[2],  bytes[1]
            };
        end
        
    endfunction

    function [31:0] MixColumn;
        input [31:0] column;

        reg [7:0] a0, a1, a2, a3;
        reg [7:0] b0, b1, b2, b3;
        begin
            a0 = column[31:24];
            a1 = column[23:16]; 
            a2 = column[15:8];
            a3 = column[7:0];
            
            b0 = Mul2(a0) ^ Mul2(a1) ^ a1 ^ a2 ^ a3;
            b1 = a0 ^ Mul2(a1) ^ Mul2(a2) ^ a2 ^ a3;
            b2 = a0 ^ a1 ^ Mul2(a2) ^ Mul2(a3) ^ a3;
            b3 = Mul2(a0) ^ a0 ^ a1 ^ a2 ^ Mul2(a3);
            
            MixColumn = {b0, b1, b2, b3};
        end
    endfunction

    function [7:0] Mul2;
        input [7:0] a;
        begin
            Mul2 = (a << 1) ^ (8'h1b & {8{a[7]}});
        end
    endfunction

    function [127:0] MixColumns;
        input [127:0] data;

        reg [7:0] bytes [15:0];
        reg [31:0] column;
        integer i;

        begin
            for (i = 0; i < 16; i = i + 1) begin
                bytes[i] = data[i*8 +: 8];
            end

            column = MixColumn({bytes[15], bytes[11], bytes[7],  bytes[3]});
            bytes[15] = column[31:24];
            bytes[11] = column[23:16];
            bytes[7] = column[15:8];
            bytes[3] = column[7:0];

            column = MixColumn({bytes[14], bytes[10], bytes[6],  bytes[2]});
            bytes[14] = column[31:24];
            bytes[10] = column[23:16];
            bytes[6] = column[15:8];
            bytes[2] = column[7:0];

            column = MixColumn({bytes[13], bytes[9], bytes[5], bytes[1]});
            bytes[13] = column[31:24];
            bytes[9] = column[23:16];
            bytes[5] = column[15:8];
            bytes[1] = column[7:0];

            column = MixColumn({bytes[12], bytes[8], bytes[4], bytes[0]});
            bytes[12] = column[31:24];
            bytes[8] = column[23:16];
            bytes[4] = column[15:8];
            bytes[0] = column[7:0];
            
            MixColumns = {
                bytes[15], bytes[14], bytes[13], bytes[12],
                bytes[11], bytes[10], bytes[9], bytes[8],
                bytes[7], bytes[6], bytes[5], bytes[4],
                bytes[3], bytes[2], bytes[1], bytes[0]
            };

        end
    endfunction

endmodule
