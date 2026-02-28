// ALU - RV32I integer operations
// ADD, SUB, SLT, SLTU, XOR, OR, AND, SLL, SRL, SRA
// Synthesizable Verilog

`include "defs.v"

module alu (
    input  wire [3:0]  alu_op,
    input  wire [`XLEN-1:0] a,
    input  wire [`XLEN-1:0] b,
    output reg  [`XLEN-1:0] result
);

    wire [`XLEN-1:0] sum = a + b;
    wire [`XLEN-1:0] diff = a - b;
    wire [`XLEN-1:0] sll_res = a << b[4:0];
    wire [`XLEN-1:0] srl_res = a >> b[4:0];
    wire signed [`XLEN-1:0] a_s = a;
    wire signed [`XLEN-1:0] b_s = b;
    wire [`XLEN-1:0] sra_res = a_s >>> b[4:0];

    always @(*) begin
        case (alu_op)
            `ALU_ADD:  result = sum;
            `ALU_SUB:  result = diff;
            `ALU_SLL:  result = sll_res;
            `ALU_SLT:  result = (a_s < b_s) ? 32'd1 : 32'd0;
            `ALU_SLTU: result = (a < b) ? 32'd1 : 32'd0;
            `ALU_XOR:  result = a ^ b;
            `ALU_SRL:  result = srl_res;
            `ALU_SRA:  result = sra_res;
            `ALU_OR:   result = a | b;
            `ALU_AND:  result = a & b;
            `ALU_PASS: result = a;
            default:   result = 32'b0;
        endcase
    end

endmodule
