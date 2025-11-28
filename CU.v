`timescale 1ns / 1ps

module CU(
    input clk,
    input [5:0] operation,
    input [5:0] funct,
    input done,
    input zero,
    output reg PC_en,
    output reg PC_src,
    output reg ALU_srcA,
    output reg [1:0] ALU_srcB,
    output reg reg_write,
    output reg mem_to_reg,
    output reg reg_dest,
    output reg mem_write,
    output reg mem_read,
    output reg IR_write,
    output reg [3:0] ALU_control
    );

    localparam [3:0]
        Fetch = 4'd0,
        Decode = 4'd1,
        MemAdr = 4'd2,
        MemRead = 4'd3,
        MemWB = 4'd4,
        MemW = 4'd5,
        Exec = 4'd6,
        ALUWB = 4'd7,
        Branch = 4'd8,
        IExec = 4'd9,
        IWB = 4'd10,
        Jump = 4'd11;
    
    localparam [5:0]
        RType = 6'b0,
        LW = 6'b100011,
        SW = 6'b101011,
        Beq = 6'b000100,
        Imm = 6'b001000,
        Jmp = 6'b000010;

    reg [3:0] current_state, next_state;
    reg branch, PC_write, ALU_op, just_entered_MemRead;


    initial begin
        current_state = Fetch;
        mem_read = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
    end

    always @(posedge clk) begin
        current_state <= next_state;
    end

    always @(*) begin
        
        if ((zero == 1'b1 && branch == 1'b1) || PC_write == 1'b1)
            PC_en = 1'b1;
        else
            PC_en = 1'b0;

        case (current_state)
            Fetch: begin
                // $display("Fetch");
                ALU_srcA = 1'b0; ALU_srcB = 2'b01;
                ALU_op = 2'b00;
                IR_write = 1'b1; PC_write = 1'b1;
                reg_write = 1'b0;
                next_state = Decode;
            end 
            Decode: begin
                // $display("Decode --> %h", operation);
                ALU_srcA = 1'b0; ALU_srcB = 2'b11;
                ALU_op = 2'b00; PC_write = 1'b0;
                IR_write = 1'b0; PC_src = 1'b0;
                case (operation)
                    LW: next_state = MemAdr;
                    SW: next_state = MemAdr; 
                    RType: next_state = Exec;
                    Beq: next_state = Branch;
                    Imm: next_state = IExec;
                    Jmp: next_state = Jump;
                    default: next_state = Decode;
                endcase
            end
            MemAdr: begin
                // $display("MemAdr");
                PC_write = 1'b0;
                ALU_srcA = 1'b1; ALU_srcB = 2'b10;
                ALU_op = 2'b00;
                next_state = MemRead;
                just_entered_MemRead = 1'b1;
            end
            MemRead: begin
                // $display("MemRead");
                if (just_entered_MemRead == 1'b1) begin
                    mem_read = 1'b1;
                    just_entered_MemRead = 1'b0;
                end
                else
                    mem_read = 1'b0;
                if (done == 1'b1) begin
                    // $display("Shouldn't be here! --> %h", operation);
                    next_state = (operation == LW ? MemWB : MemW);
                end
                else
                    next_state = MemRead;
            end
            MemWB: begin
                // $display("MemWB");
                reg_dest = 1'b0; mem_to_reg = 1'b1;
                reg_write = 1'b1;
                next_state = Fetch;
            end
            MemW: begin
                // $display("MemW");
                mem_write = 1'b1;
                if (done == 1'b1) begin  
                    // $display("Too Early");
                    next_state = Fetch;
                    mem_write = 1'b0;
                end
                else 
                    next_state = MemW;
            end
            Exec: begin
                // $display("Exe");
                ALU_srcA = 1'b1; ALU_srcB = 2'b00;
                ALU_op = 2'b10; PC_write = 1'b0;
                next_state = ALUWB;
            end
            ALUWB: begin
                // $display("ALUWB");
                reg_dest = 1'b1; mem_to_reg = 1'b0;
                reg_write = 1'b1;
                next_state = Fetch;
            end
            Branch: begin
                $display("branch");
                ALU_srcA = 1'b1; ALU_srcB = 2'b00;
                ALU_op = 2'b01; PC_src = 1'b1;
                branch = 1'b1;
                next_state = Fetch;
            end
            IExec: begin
                // $display("IX");
                ALU_srcA = 1'b1; ALU_srcB = 2'b10;
                ALU_op = 2'b00; PC_write = 1'b0;
                next_state = IWB;
            end
            IWB: begin
                reg_dest = 1'b0; mem_to_reg = 1'b0;
                reg_write = 1'b1;
                next_state = Fetch;
            end
            Jump: begin
                PC_src = 2'b0; PC_write = 1'b1;
                next_state = Fetch;
            end
            default: next_state = Fetch;
        endcase
    end

    // ALU control
    always @(*) begin
        case (operation)
            RType: begin
                case (funct)
                    6'b100000: ALU_control = 4'b0010;
                    6'b100010: ALU_control = 4'b0110;
                    6'b100100: ALU_control = 4'b0000;
                    6'b100101: ALU_control = 4'b0001;
                    6'b101010: ALU_control = 4'b0111;
                    6'b000000: ALU_control = 4'b1100;
                    6'b000010: ALU_control = 4'b1101;
                    6'b000011: ALU_control = 4'b1111;
                    default: ALU_control = 4'b0000;
                endcase
            end
            LW: ALU_control = 4'b0010;
            SW: ALU_control = 4'b0010;
            Beq: ALU_control = 4'b0110;
            // from possible immediate instructions, 
            // only addi has been implemented
            Imm: ALU_control = 4'b0010;
            default: ALU_control = 4'b0010;
        endcase
    end
    
endmodule