`timescale 1ns / 1ps

module DMEM(
    input clk,
    input read_enable,
    output reg [127:0] read_data,
    output reg data_ready
    );

    reg [7:0] sbox_table [0:255];
    wire [127:0] data=128'h5;
    wire [127:0] key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    reg [1407:0] keys;
    reg [127:0] round_keys [0:10];

    reg [3:0] round_counter;
    reg busy;
    reg [127:0] state;
    integer i;

    initial begin
        // SBox implemented as lookup table for simplicity
        $readmemh("SBoxROM.mem", sbox_table);
        keys = GenerateKeys(key);
        
        for (i=0;i<11;i=i+1)
            round_keys[10 - i] = keys[128*(i+1)-1 -: 128];

        data_ready = 0;
        busy = 0;
    end

    // FSM
    always @(posedge clk) begin
        if (read_enable && !busy) begin
            busy <= 1;
            // TODO: read data from memory here
            
            state <= data ^ round_keys[0];
            round_counter <= 1;
            data_ready <= 0;
        end
        else if (busy) begin
            if (round_counter<10) begin
                state <= MixColumns(ShiftRows(SubByte(state))) ^ round_keys[round_counter];
                round_counter <= round_counter + 1;
            end
            else begin
                read_data <= ShiftRows(SubByte(state)) ^ round_keys[round_counter];
                busy <= 0;
                data_ready <= 1;
            end
        end
    end

    

    



    // ---------- AES Functions ---------- //
    function [127:0] SubByte;
        input [127:0] data;

        integer i;
        begin
            for (i=0;i<16;i=i+1) 
                SubByte[(i+1)*8-1 -: 8] = sbox_table[data[(i+1)*8-1 -: 8]];
        end
    endfunction

    function [127:0] ShiftRows;
        input [127:0] data;

        reg [7:0] bytes [15:0];
        integer i;
        begin
            for (i=0;i<16;i=i+1) begin
                bytes[i] = data[(i+1)*8-1 -: 8];
            end
            
            ShiftRows = {
                bytes[15],  bytes[10],  bytes[5], bytes[0],
                bytes[11],  bytes[6],  bytes[1], bytes[12],
                bytes[7],  bytes[2], bytes[13],  bytes[8],
                bytes[3], bytes[14],  bytes[9],  bytes[4]
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
            for (i=0;i<16;i=i+1)
                bytes[i] = data[(i+1)*8-1 -: 8];

            column = MixColumn({bytes[15], bytes[14], bytes[13],  bytes[12]});
            bytes[15] = column[31:24];
            bytes[14] = column[23:16];
            bytes[13] = column[15:8];
            bytes[12] = column[7:0];

            column = MixColumn({bytes[11], bytes[10], bytes[9],  bytes[8]});
            bytes[11] = column[31:24];
            bytes[10] = column[23:16];
            bytes[9] = column[15:8];
            bytes[8] = column[7:0];

            column = MixColumn({bytes[7], bytes[6], bytes[5], bytes[4]});
            bytes[7] = column[31:24];
            bytes[6] = column[23:16];
            bytes[5] = column[15:8];
            bytes[4] = column[7:0];

            column = MixColumn({bytes[3], bytes[2], bytes[1], bytes[0]});
            bytes[3] = column[31:24];
            bytes[2] = column[23:16];
            bytes[1] = column[15:8];
            bytes[0] = column[7:0];
            
            MixColumns = {
                bytes[15], bytes[14], bytes[13], bytes[12],
                bytes[11], bytes[10], bytes[9], bytes[8],
                bytes[7], bytes[6], bytes[5], bytes[4],
                bytes[3], bytes[2], bytes[1], bytes[0]
            };

        end
    endfunction

    function [1407:0] GenerateKeys;
        input [127:0] key;
        
        reg [127:0] keys [0:10];
        reg [31:0] temp;
        reg [31:0] w [0:43];
        integer i;
        
        begin
            w[0] = key[127:96];
            w[1] = key[95:64];
            w[2] = key[63:32];
            w[3] = key[31:0];
            
            for (i=4;i<44;i=i+1) begin
                temp = w[i-1];
                
                if (i%4==0)
                    temp = SubWord(Rotate(temp)) ^ Rconst(i/4);
                
                w[i] = w[i-4] ^ temp;
            end
            
            for (i=0;i<11;i=i+1)
                keys[i] = {w[4*i], w[4*i+1], w[4*i+2], w[4*i+3]};
            
            GenerateKeys = {
                        keys[0], keys[1], keys[2], keys[3],
                        keys[4], keys[5], keys[6], keys[7],
                        keys[8], keys[9], keys[10]
                    };
        end
    endfunction

    function [31:0] Rotate;
        input [31:0] w;
        begin
            Rotate = {w[23:0], w[31:24]};
        end
    endfunction

    function [31:0] SubWord;
        input [31:0] w;
        begin
            SubWord = {sbox_table[w[31:24]], sbox_table[w[23:16]], sbox_table[w[15:8]], sbox_table[w[7:0]]};
        end
    endfunction

    function [31:0] Rconst;
        input [3:0] round;
        reg [7:0] const;
        begin
            case (round)
                4'h1: const = 8'h01;
                4'h2: const = 8'h02;
                4'h3: const = 8'h04;
                4'h4: const = 8'h08;
                4'h5: const = 8'h10;
                4'h6: const = 8'h20;
                4'h7: const = 8'h40;
                4'h8: const = 8'h80;
                4'h9: const = 8'h1b;
                4'ha: const = 8'h36;
                default: const = 8'h00;
            endcase
            Rconst = {const, 8'h00, 8'h00, 8'h00};
        end
    endfunction


endmodule
