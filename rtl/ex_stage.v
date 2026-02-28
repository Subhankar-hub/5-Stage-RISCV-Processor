// Execute Stage
// ALU/MulDiv mux, branch target, branch condition evaluation
// Synthesizable Verilog

`include "defs.v"

module ex_stage (
    input  wire [3:0]  alu_op,
    input  wire        alu_src,
    input  wire        auipc,
    input  wire        lui,
    input  wire [`XLEN-1:0] rs1_data,
    input  wire [`XLEN-1:0] rs2_data,
    input  wire [`XLEN-1:0] imm,
    input  wire [`XLEN-1:0] pc,
    input  wire        branch,
    input  wire [2:0]  branch_type,
    input  wire        jal,
    input  wire        jalr,
    input  wire        is_muldiv,
    input  wire [`XLEN-1:0] alu_result,
    input  wire [`XLEN-1:0] mul_div_result,
    input  wire        mul_div_ready,
    output wire [`XLEN-1:0] result,
    output wire [`XLEN-1:0] branch_target,
    output wire        branch_taken,
    output wire        mul_div_stall
);

    wire [`XLEN-1:0] alu_a = lui ? 32'b0 : (auipc ? pc : rs1_data);
    wire [`XLEN-1:0] alu_b = alu_src ? imm : rs2_data;
    wire [`XLEN-1:0] alu_out = alu_result;

    assign branch_target = jalr ? (rs1_data + imm) : (pc + imm);

    wire eq = (rs1_data == rs2_data);
    wire lt = (rs1_data[31] ^ rs2_data[31]) ? rs1_data[31] : (rs1_data < rs2_data);
    wire ltu = rs1_data < rs2_data;

    wire beq_ok = (branch_type == `F3_BEQ) & eq;
    wire bne_ok = (branch_type == `F3_BNE) & ~eq;
    wire blt_ok = (branch_type == `F3_BLT) & lt;
    wire bge_ok = (branch_type == `F3_BGE) & ~lt;
    wire bltu_ok = (branch_type == `F3_BLTU) & ltu;
    wire bgeu_ok = (branch_type == `F3_BGEU) & ~ltu;

    assign branch_taken = branch & (beq_ok | bne_ok | blt_ok | bge_ok | bltu_ok | bgeu_ok) | jal | jalr;

    assign result = (is_muldiv & mul_div_ready) ? mul_div_result :
                    (jal | jalr) ? (pc + 32'd4) : alu_out;

    assign mul_div_stall = is_muldiv & ~mul_div_ready;

endmodule
