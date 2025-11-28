`timescale 1ns / 1ps
`include "ALU.v"
`include "CU.v"
`include "DMEM.v"
`include "IMEM.v"
`include "MUX2.v"
`include "MUX4.v"
`include "PC.v"
`include "RF.v"
`include "SignEXT.v"
`include "InterReg.v"
`include "MUX4_128.v"
`include "MUX2_5.v"


module Processor(
    input clk
    );

    wire mem_write, mem_read, IR_write, PC_src, PC_en, ALU_srcA, reg_write, mem_to_reg, reg_dest, done, zero;
    wire [3:0] ALU_control;
    wire [1:0] ALU_srcB;
    wire [31:0] PC, PC_prime, instr, IMEM_to_reg, write_data_line, ALU_out, DMEM_reg,
                RF_to_A, RF_to_B, A, B, sign_imm, srcA, srcB, ALU_res, DMEM_mux_to_reg;
    wire [4:0] write_reg_line;
    wire [127:0] DMEM_to_mux, DMEM_write_data;

    CU control_unit(
        .clk(clk),
        .operation(instr[31:26]),
        .funct(instr[5:0]),
        .done(done),
        .zero(zero),
        .PC_en(PC_en),
        .PC_src(PC_src),
        .ALU_srcA(ALU_srcA),
        .ALU_srcB(ALU_srcB),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .reg_dest(reg_dest),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .IR_write(IR_write),
        .ALU_control(ALU_control)
    );

    PC program_counter(
        .clk(clk),
        .enable(PC_en),
        .next_pc(PC_prime),
        .pc(PC)
    );

    IMEM instruction_memory(
        .address(PC),
        .instruction(IMEM_to_reg)
    );

    InterReg IMEM_to_RF(
        .clk(clk),
        .enable(IR_write),
        .inp(IMEM_to_reg),
        .out(instr)
    );

    MUX2_5 instr_to_write_reg(
        .select(reg_dest),
        .source_A(instr[20:16]),
        .source_B(instr[15:11]),
        .result(write_reg_line)
    );

    MUX2 RF_write_data(
        .select(mem_to_reg),
        .source_A(ALU_out),
        .source_B(DMEM_reg),
        .result(write_data_line)
    );

    RF register_file(
        .clk(clk),
        .write_enable(reg_write),
        .reg_1(instr[25:21]),
        .reg_2(instr[20:16]),
        .write_reg(write_reg_line),
        .write_data(write_data_line),
        .data_1(RF_to_A),
        .data_2(RF_to_B)
    );

    InterReg RF_A(
        .clk(clk),
        .enable(1'b1),
        .inp(RF_to_A),
        .out(A)
    );

    InterReg RF_B(
        .clk(clk),
        .enable(1'b1),
        .inp(RF_to_B),
        .out(B)
    );

    SignEXT sign_extend(
        .sign(1'b1),
        .immediate_16(instr[15:0]),
        .immediate_32(sign_imm)
    );

    MUX2 ALU_source_A(
        .select(ALU_srcA),
        .source_A(PC),
        .source_B(A),
        .result(srcA)
    );

    MUX4 ALU_source_B(
        .select(ALU_srcB),
        .source_A(B),
        .source_B(32'b100),
        .source_C(sign_imm),
        .source_D(sign_imm << 2),
        .result(srcB)
    );

    ALU alu(
        .control(ALU_control),
        .source_A(srcA),
        .source_B(srcB),
        .zero(zero),
        .result(ALU_res)
    );

    InterReg ALU_result(
        .clk(clk),
        .enable(1'b1),
        .inp(ALU_res),
        .out(ALU_out)
    );

    MUX2 ALU_to_PC(
        .select(PC_src),
        .source_A(ALU_res),
        .source_B(ALU_out),
        .result(PC_prime)
    );

    DMEM data_memory(
        .clk(clk),
        .read_enable(mem_read),
        .write_enable(mem_write),
        .address(ALU_out),
        .write_data(DMEM_write_data),
        .read_data(DMEM_to_mux),
        .done(done)
    );

    MUX4_128 DMEM_WD(
        .select(ALU_out[3:2]),
        .source_A({DMEM_to_mux[127:32], B}),
        .source_B({DMEM_to_mux[127:64], B, DMEM_to_mux[31:0]}),
        .source_C({DMEM_to_mux[127:96], B, DMEM_to_mux[63:0]}),
        .source_D({B, DMEM_to_mux[95:0]}),
        .result(DMEM_write_data)
    );

    MUX4 DMEM_pick(
        .select(ALU_out[3:2]),
        .source_A(DMEM_to_mux[31:0]),
        .source_B(DMEM_to_mux[63:32]),
        .source_C(DMEM_to_mux[95:64]),
        .source_D(DMEM_to_mux[127:96]),
        .result(DMEM_mux_to_reg)
    );

    InterReg DMEM_register(
        .clk(clk),
        .enable(1'b1),
        .inp(DMEM_mux_to_reg),
        .out(DMEM_reg)
    );

    
endmodule