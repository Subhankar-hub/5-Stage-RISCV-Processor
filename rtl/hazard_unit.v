// Hazard Detection and Forwarding Unit
// Data hazards: forward from EX/MEM and MEM/WB to ID/EX
// Load-use: stall one cycle
// Control hazards: flush on branch/jump taken
// MULDIV: stall until ready
// Synthesizable Verilog

`include "defs.v"

module hazard_unit (
    input  wire [4:0]  if_id_rs1,
    input  wire [4:0]  if_id_rs2,
    input  wire [4:0]  id_ex_rs1,
    input  wire [4:0]  id_ex_rs2,
    input  wire [4:0]  id_ex_rd,
    input  wire [4:0]  ex_mem_rd,
    input  wire [4:0]  mem_wb_rd,
    input  wire        ex_mem_reg_we,
    input  wire        mem_wb_reg_we,
    input  wire        id_ex_mem_re,
    input  wire        ex_mem_mem_re,
    input  wire        id_ex_mul_div_stall,
    output wire [1:0]  fwd_rs1,   // 00=no fwd, 01=ex_mem, 10=mem_wb
    output wire [1:0]  fwd_rs2,
    output wire        stall,
    output wire        load_use
);

    wire rs1_ex = ex_mem_reg_we && !ex_mem_mem_re && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1);
    wire rs2_ex = ex_mem_reg_we && !ex_mem_mem_re && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2);
    wire rs1_mem = mem_wb_reg_we && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1);
    wire rs2_mem = mem_wb_reg_we && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2);

    assign fwd_rs1 = rs1_ex ? 2'b01 : (rs1_mem ? 2'b10 : 2'b00);
    assign fwd_rs2 = rs2_ex ? 2'b01 : (rs2_mem ? 2'b10 : 2'b00);

    wire load_use_int = id_ex_mem_re && (id_ex_rd != 0) &&
                        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    assign load_use = load_use_int;
    assign stall = load_use_int | id_ex_mul_div_stall;

endmodule
