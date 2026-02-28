// Instruction Decode Stage
// RV32IM decode, register file read, immediate generation, control signals
// Synthesizable Verilog

`include "defs.v"

module id_stage (
    input  wire [`XLEN-1:0] instr,
    input  wire [`XLEN-1:0] rs1_data,
    input  wire [`XLEN-1:0] rs2_data,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr,
    output wire [`XLEN-1:0] imm,
    output wire [3:0]  alu_op,
    output wire        alu_src,      // 0=rs2, 1=imm
    output wire        mem_we,
    output wire        mem_re,
    output wire [2:0]  mem_size,    // 000=byte, 001=half, 010=word
    output wire        mem_unsigned,
    output wire        reg_we,
    output wire        wb_sel,       // 0=alu, 1=mem
    output wire        branch,
    output wire        jal,
    output wire        jalr,
    output wire [2:0]  branch_type,
    output wire        mul_div_valid,
    output wire [2:0]  mul_div_op,
    output wire        is_muldiv,
    output wire        auipc,
    output wire        lui
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];

    // Immediate generation
    wire [`XLEN-1:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [`XLEN-1:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [`XLEN-1:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [`XLEN-1:0] imm_u = {instr[31:12], 12'b0};
    wire [`XLEN-1:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    assign imm = (opcode == `OPCODE_JAL) ? imm_j :
                 (opcode == `OPCODE_BRANCH) ? imm_b :
                 ((opcode == `OPCODE_STORE) || (opcode == `OPCODE_SYSTEM)) ? imm_s :
                 ((opcode == `OPCODE_LUI) || (opcode == `OPCODE_AUIPC)) ? imm_u : imm_i;

    // ALU control
    wire op_imm = (opcode == `OPCODE_OP_IMM) || (opcode == `OPCODE_OP_IMM_32);
    wire op_reg = (opcode == `OPCODE_OP) || (opcode == `OPCODE_OP_32);
    wire is_alu = op_imm || op_reg;

    wire [3:0] alu_ctrl;
    assign alu_ctrl = (funct3 == `F3_ADD_SUB) ? (funct7[5] ? `ALU_SUB : `ALU_ADD) :
                      (funct3 == `F3_SLL) ? `ALU_SLL :
                      (funct3 == `F3_SLT) ? `ALU_SLT :
                      (funct3 == `F3_SLTU) ? `ALU_SLTU :
                      (funct3 == `F3_XOR) ? `ALU_XOR :
                      (funct3 == `F3_SRL_SRA) ? (funct7[5] ? `ALU_SRA : `ALU_SRL) :
                      (funct3 == `F3_OR) ? `ALU_OR :
                      (funct3 == `F3_AND) ? `ALU_AND : `ALU_ADD;

    assign alu_op = (opcode == `OPCODE_LUI) ? `ALU_ADD : (opcode == `OPCODE_AUIPC ? `ALU_ADD : alu_ctrl);
    assign alu_src = op_imm || (opcode == `OPCODE_LOAD) || (opcode == `OPCODE_STORE) ||
                     (opcode == `OPCODE_JALR) || (opcode == `OPCODE_AUIPC) || (opcode == `OPCODE_LUI);
    assign auipc = (opcode == `OPCODE_AUIPC);
    assign lui = (opcode == `OPCODE_LUI);

    assign mem_we = (opcode == `OPCODE_STORE);
    assign mem_re = (opcode == `OPCODE_LOAD);
    assign mem_size = funct3;
    assign mem_unsigned = funct3[2];  // LBU, LHU

    assign reg_we = (opcode == `OPCODE_OP) || (opcode == `OPCODE_OP_IMM) || (opcode == `OPCODE_OP_32) ||
                    (opcode == `OPCODE_OP_IMM_32) || (opcode == `OPCODE_LOAD) || (opcode == `OPCODE_LUI) ||
                    (opcode == `OPCODE_AUIPC) || (opcode == `OPCODE_JAL) || (opcode == `OPCODE_JALR);

    assign wb_sel = (opcode == `OPCODE_LOAD);

    assign branch = (opcode == `OPCODE_BRANCH);
    assign jal = (opcode == `OPCODE_JAL);
    assign jalr = (opcode == `OPCODE_JALR);
    assign branch_type = funct3;

    // M-extension
    assign is_muldiv = ((opcode == `OPCODE_OP || opcode == `OPCODE_OP_32) && funct7 == `F7_MULDIV);
    assign mul_div_valid = is_muldiv;
    assign mul_div_op = funct3;

endmodule
