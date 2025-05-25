There 4 different instructions file.
    - arithmetic_instructions:
        21 different instructions : 
        addi, sb, auipc, slti, sltiu, xori, ori, andi, slli, srli, srai, add, sub, sll, slt, sltu, xor, srl, sra, or, and

    - j_b_instructions:
        10 different instructions :
        auipc, sw, lw, bge, addi, ori, andi, beq, jal, lui

    - mixed_instructions
        11 different instructions : 
        addi, add, blt, jal, sw, lw, sh, lh, srl, sb, lb

    - store_load_instructions
        8 different instructions :
        addi, slli, sw, sb, lb, lw, sh, lh


Instructions are created with help of the site : https://luplab.gitlab.io/rvcodecjs


example: make jb_set   => updates Instructions.hex file in outer directory!
                
converter.py deals with Big Endian to Little Endian conversion.