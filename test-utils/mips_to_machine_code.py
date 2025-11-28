from sys import argv
from assets import sign_extended_bin

# Crypto-Processor can be extended to support more instructions
# adding the folowing opcodes won't require changing this python script:
# subi, jal, jra

# opcodes supported by the current version of our processor 
opcode = {
    "addi": 8,
    "lw":   35,
    "sw":   43,
    "jmp":  2,
    "beq":  4
}


# adding the folowing function codes won't require changing this python script:
# mul, xor, rol, ror

# function codes supported by the current version of our processor 
func_code = {
    "add":  32,
    "sub":  34,
    "and":  36,
    "or":   37,
    "sll":  0,
    "srl":  2,
    "sra":  3,
    "slt":  42
}

labels = {}

reg = {
    '$zero': 0, 
    '$at' :  1,
    '$v0' :  2,
    '$v1' :  3,
    '$a0' :  4,
    '$a1' :  5,
    '$a2' :  6,
    '$a3' :  7,
    '$t0' :  8,
    '$t1' :  9,
    '$t2' :  10,
    '$t3' :  11,
    '$t4' :  12,
    '$t5' :  13,
    '$t6' :  14,
    '$t7' :  15,
    '$s0' :  16,
    '$s1' :  17,
    '$s2' :  18,
    '$s3' :  19,
    '$s4' :  20,
    '$s5' :  21,
    '$s6' :  22,
    '$s7' :  23,
    '$t8' :  24,
    '$t9' :  25,
    '$k0' :  26,
    '$k1' :  27,
    '$gp' :  28,
    '$sp' :  29,
    '$s8' :  30,
    '$ra' : 31
}

def binary_code(inst, pc):
    if inst[0] in opcode:
        op = bin(opcode[inst[0]])[2:]
        op = (6 - len(op)) * '0' + op

        if inst[0][0] == 'j':
            if inst[0] == 'jra':
                rs = bin(reg[inst[1]])[2:]
                rs = (5 - len(rs)) * '0' + rs
                return op + rs + '0' * 21
            else:
                imm = bin(labels[inst[1]] // 4)[2:]
                imm = (26 - len(imm)) * '0' + imm
                return op + imm

        rt = bin(reg[inst[1]])[2:]
        rt = (5 - len(rt)) * '0' + rt

        if inst[0] == 'lw' or inst[0] == 'sw':
            imm = sign_extended_bin(int(inst[2].split('(')[0]), 16)

            # imm = bin(int(inst[2].split('(')[0]))[2:]
            # imm = (16 - len(imm)) * '0' + imm

            rs = bin(reg[inst[2].split('(')[1][:-1]])[2:]
            rs = (5 - len(rs)) * '0' + rs

        else:
            rs = bin(reg[inst[2]])[2:]
            rs = (5 - len(rs)) * '0' + rs

            if inst[0] == 'beq':
                imm = sign_extended_bin((labels[inst[3]] - pc) // 4, 16)
            else:
                imm = sign_extended_bin(int(inst[3]), 16)
        
        return op + rs + rt + imm

        
    else:
        # R-Type
        op = 6 * '0'

        func = bin(func_code[inst[0]])[2:]
        func = (6 - len(func)) * '0' + func

        rd = bin(reg[inst[1]])[2:]
        rd = (5 - len(rd)) * '0' + rd

        if inst[0] not in ['sll', 'srl', 'sra', 'rol', 'ror']:
            rs = bin(reg[inst[2]])[2:]
            rs = (5 - len(rs)) * '0' + rs

            rt = bin(reg[inst[3]])[2:]
            rt = (5 - len(rt)) * '0' + rt

            shamt = '0' * 5
        
        else:
            rt = bin(reg[inst[2]])[2:]
            rt = (5 - len(rt)) * '0' + rt

            rs = 5 * '0'

            shamt = bin(int(inst[3]))[2:]
            shamt = (5 - len(shamt)) * '0' + shamt

        return op + rs + rt + rd + shamt + func
    

instructions = list()

with open(argv[1], 'r') as asm:
    lines = asm.readlines()
    in_main = False
    cnt = 0

    # finding lebels
    for line in lines:
        line = line.replace('\t', ' ')
        line = line.strip().split(' ')
        line = [element for element in line if element != '']
        line = [element if element[-1] != ',' else element[:-1] for element in line]

        if 'main:' in line:
            in_main = True
            labels['main'] = 0
            continue

        if not in_main or line == [] or line == [""] or line[0][0] == '#':
            # it's not an instruction or a label
            continue

        if line[0][-1] == ':':
            labels[line[0][:-1]] = cnt * 4
            continue

        cnt += 1
    
    in_main = False
    cnt = 0
    
    # translation
    for line in lines:
        line = line.replace('\t', ' ')
        line = line.strip().split(' ')
        line = [element for element in line if element != '']
        line = [element if element[-1] != ',' else element[:-1] for element in line]

        if 'main:' in line:
            in_main = True
            continue

        if not in_main or line == [] or line == [""] or line[0][-1] == ':' or line[0][0] == '#':
            # it's a blank line or a label or a comment
            continue
        
        cnt += 4
        instruction = hex(int(binary_code(line, cnt), 2))[2:]
        instructions.append((8 - len(instruction)) * '0' + instruction)
        


with open(argv[2], 'w') as mem:
    for instruction in instructions:
        mem.write(instruction + '\n')

print('Instruction Memory is Ready!')






