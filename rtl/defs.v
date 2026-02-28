// RV32IM RISC-V 5-Stage Pipeline - Constants and Opcodes
// Synthesizable Verilog - No non-synthesizable constructs

`ifndef DEFS_V
`define DEFS_V

// Data width
`define XLEN 32

// RV32I Opcodes (inst[6:0])
`define OPCODE_LOAD     7'b0000011
`define OPCODE_LOAD_FP  7'b0000111
`define OPCODE_MISC_MEM 7'b0001111
`define OPCODE_OP_IMM   7'b0010011
`define OPCODE_AUIPC    7'b0010111
`define OPCODE_OP_IMM_32 7'b0011011
`define OPCODE_STORE    7'b0100011
`define OPCODE_STORE_FP 7'b0100111
`define OPCODE_AMO      7'b0101111
`define OPCODE_OP       7'b0110011
`define OPCODE_LUI      7'b0110111
`define OPCODE_BRANCH   7'b1100011
`define OPCODE_JALR     7'b1100111
`define OPCODE_JAL      7'b1101111
`define OPCODE_SYSTEM   7'b1110011
`define OPCODE_OP_32    7'b0111011   // M-extension 32-bit ops

// Funct3 for ALU ops (OP_IMM, OP, BRANCH)
`define F3_ADD_SUB  3'b000
`define F3_SLL      3'b001
`define F3_SLT      3'b010
`define F3_SLTU     3'b011
`define F3_XOR      3'b100
`define F3_SRL_SRA  3'b101
`define F3_OR       3'b110
`define F3_AND      3'b111

// Funct7 for OP/OP_IMM (disambiguation)
`define F7_NORMAL  7'b0000000
`define F7_SUB     7'b0100000  // SUB, SRA
`define F7_MULDIV  7'b0000001  // M-extension

// Funct3 for loads
`define F3_LB  3'b000
`define F3_LH  3'b001
`define F3_LW  3'b010
`define F3_LBU 3'b100
`define F3_LHU 3'b101

// Funct3 for stores
`define F3_SB  3'b000
`define F3_SH  3'b001
`define F3_SW  3'b010

// Funct3 for branches
`define F3_BEQ  3'b000
`define F3_BNE  3'b001
`define F3_BLT  3'b100
`define F3_BGE  3'b101
`define F3_BLTU 3'b110
`define F3_BGEU 3'b111

// Funct3 for M-extension (OP, OP_32)
`define F3_MUL    3'b000
`define F3_MULH   3'b001
`define F3_MULHSU 3'b010
`define F3_MULHU  3'b011
`define F3_DIV    3'b100
`define F3_DIVU   3'b101
`define F3_REM    3'b110
`define F3_REMU   3'b111

// ALU control (internal)
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b0001
`define ALU_SLL  4'b0010
`define ALU_SLT  4'b0011
`define ALU_SLTU 4'b0100
`define ALU_XOR  4'b0101
`define ALU_SRL  4'b0110
`define ALU_SRA  4'b0111
`define ALU_OR   4'b1000
`define ALU_AND  4'b1001
`define ALU_PASS 4'b1010  // pass-through

`endif
