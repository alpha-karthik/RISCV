# RISCV

This Repository contains the source files and test files for the design of RISC-V RV32I Core and It's Implementation using Verilog.

## Contents 
 ---
- [RISCV ISA](#riscv-isa)
- RV32I base core ISA
- Micro-architecture Implementation 
- RTL Coding for each Block in the Mirco-architecture
- Writing Test Bench 
- Results

---
### RISCV ISA
RISC-V is an open-source instruction set architecture(ISA) based on the reduced instruction set computer (RISC) principles. It ws developed at the University of California, Berkeley in 2010.

An Instruction set architecture defiines the set of instructions that a processor can execute and the underlying structure of those instructions. The RISC-V ISA is designed to be simple, modular, and extensible, providing a solid foundation for a wide range of computing devices, from embedded systems to high-performace servers.

---
### RV32I Base Core
The RV32I base core refers to the base integer instruction set of the RISC-V ISA with a 32-bit word size. It is the fundamental and minimal instruction set for RISC-V processors that implement 32-bit architecture.

Here "RV32" part indicates that the base core operated on 32-bit data. Each instruction in the RV32I instruction set is 32 bits long. The "I" stands for "integer", indicating that base core provides a set of instructions for basic integer operations.

The RV32I Instruction set includes instructions for common operations such as arithemetic(addition, subtraction, multiplication), logical operations(bitwise AND, OR, XOR), shifting, loading/storing data from/to memory, branching and comparisons. It also includes instructions for manipulating control flow, such as unconditional jumps and conditional branches.The RV32I base core is the foundation upon which other standard extensions, such as multiplication and floating-point arithmetic, can be added. These extensions provide additional functionality beyond the base integer instructions.

The RV32I base core is often used in embedded systems, low-power devices, and applications where a 32-bit word size is sufficient. It provides a minimal yet powerful instruction set that forms the basis for RISC-V processor.

RV32I Core consists of a total of 47 instructions. Out of those 47 i've implemented 42 instructions excluding  FENCE, FENCE.TSO, PAUSE, ECALL, EBREAK. 
I am attaching the link for the image of those instruction set and instruction types. Link[ ]





