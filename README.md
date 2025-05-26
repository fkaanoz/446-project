# 446 Project

## Makefile Usage (for UNIX Shell)

At the root of the project, there is a `Makefile` to help you run all instruction tests easily.

To run all the tests sequentially, with pauses to review output between each, simply execute:

```bash
make
```


## Overview

This project implements a FIFO system and includes a testbench to verify its functionality.

While I wasn't able to resolve the issue with the UART module, the FIFO is working as expected.  
To demonstrate this, a separate test folder named `test_fifo` has been added. It includes a set of alternative instructions that execute a simple loop.

---

## Tools and Resources

- [RISC-V Instruction Generator](https://luplab.gitlab.io/rvcodecjs/)  
  → Used to generate RISC-V instructions.

- `converter.py` (located in `test/instructions/`)  
  → Converts instructions from **Big Endian** to **Little Endian** format.

---

## Instruction Sets

There are four different sets of instructions available for testing:

- **`arithmetic_instructions`**  
  Includes 21 different instructions:  
  `addi`, `sb`, `auipc`, `slti`, `sltiu`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`, `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`

- **`j_b_instructions`**  
  Includes 10 different instructions:  
  `auipc`, `sw`, `lw`, `bge`, `addi`, `ori`, `andi`, `beq`, `jal`, `lui`

- **`mixed_instructions`**  
  Includes 11 different instructions:  
  `addi`, `add`, `blt`, `jal`, `sw`, `lw`, `sh`, `lh`, `srl`, `sb`, `lb`

- **`store_load_instructions`**  
  Includes 8 different instructions:  
  `addi`, `slli`, `sw`, `sb`, `lb`, `lw`, `sh`, `lh`

### Usage

Instructions are generated using [luplab's RISC-V encoder](https://luplab.gitlab.io/rvcodecjs).  
Each instruction set can be compiled into the `Instructions.hex` file using (while pwd is test/instructions):

```bash
make jb_set
```