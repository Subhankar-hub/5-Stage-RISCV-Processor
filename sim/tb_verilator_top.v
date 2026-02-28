// Top for C++ testbench: clk and rst_n driven from C++
`timescale 1ns/1ps

`include "../rtl/defs.v"

module tb_verilator_top (
    input wire clk,
    input wire rst_n
);

    wire [31:0] instr_addr, instr_rdata, data_addr, data_wdata, data_rdata;
    wire instr_req, instr_gnt, data_we, data_req, data_gnt;
    wire [3:0] data_be;

    riscv_core u_core (
        .clk(clk), .rst_n(rst_n),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .instr_req(instr_req), .instr_gnt(instr_gnt),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata),
        .data_we(data_we), .data_be(data_be), .data_req(data_req), .data_gnt(data_gnt)
    );

    mem_model #(
        .ADDR_BITS(16),
        .MEM_SIZE(65536),
        .MEM_FILE("sim/tests/simple.hex")
    ) u_mem (
        .clk(clk), .rst_n(rst_n),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .instr_req(instr_req), .instr_gnt(instr_gnt),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata),
        .data_we(data_we), .data_be(data_be), .data_req(data_req), .data_gnt(data_gnt)
    );

endmodule
