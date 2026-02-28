// Instruction Fetch Stage
// PC logic, instruction memory interface (SRAM-like)
// Synthesizable Verilog

`include "defs.v"

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    input  wire        pc_src,           // 0=pc+4, 1=branch_target
    input  wire [`XLEN-1:0] branch_target,
    input  wire [`XLEN-1:0] instr_rdata,
    input  wire        instr_gnt,
    output reg  [`XLEN-1:0] pc,
    output reg  [`XLEN-1:0] pc_plus4,
    output wire [`XLEN-1:0] instr_addr,
    output wire        instr_req
);

    wire [`XLEN-1:0] next_pc = pc_src ? branch_target : (pc + 32'd4);
    assign instr_addr = pc;
    assign instr_req = !stall;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
            pc_plus4 <= 32'd4;
        end else if (!stall) begin
            if (flush) begin
                pc <= branch_target;
                pc_plus4 <= branch_target + 32'd4;
            end else if (instr_gnt || !instr_req) begin
                pc <= next_pc;
                pc_plus4 <= next_pc + 32'd4;
            end
        end
    end

endmodule
