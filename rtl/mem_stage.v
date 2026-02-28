// Memory Access Stage
// Load/store, byte/halfword/word, sign extension
// Synthesizable Verilog

`include "defs.v"

module mem_stage (
    input  wire        mem_we,
    input  wire        mem_re,
    input  wire [2:0]  mem_size,
    input  wire        mem_unsigned,
    input  wire [`XLEN-1:0] addr,
    input  wire [`XLEN-1:0] store_data,
    input  wire [`XLEN-1:0] mem_rdata,
    output wire [`XLEN-1:0] mem_wdata,
    output wire [`XLEN-1:0] load_data
);

    wire [1:0] addr_lo = addr[1:0];

    // Store data formatting (byte/half/word)
    assign mem_wdata = (mem_size == `F3_SB) ? {4{store_data[7:0]}} :
                       (mem_size == `F3_SH) ? {2{store_data[15:0]}} : store_data;

    // Load data extraction and sign extension
    wire [`XLEN-1:0] lb_data = (addr_lo == 2'b00) ? {{24{mem_rdata[7]}},  mem_rdata[7:0]} :
                               (addr_lo == 2'b01) ? {{24{mem_rdata[15]}}, mem_rdata[15:8]} :
                               (addr_lo == 2'b10) ? {{24{mem_rdata[23]}}, mem_rdata[23:16]} :
                               {{24{mem_rdata[31]}}, mem_rdata[31:24]};
    wire [`XLEN-1:0] lbu_data = (addr_lo == 2'b00) ? {24'b0, mem_rdata[7:0]} :
                                (addr_lo == 2'b01) ? {24'b0, mem_rdata[15:8]} :
                                (addr_lo == 2'b10) ? {24'b0, mem_rdata[23:16]} :
                                {24'b0, mem_rdata[31:24]};
    wire [`XLEN-1:0] lh_data = addr_lo[1] ? {{16{mem_rdata[31]}}, mem_rdata[31:16]} :
                               {{16{mem_rdata[15]}}, mem_rdata[15:0]};
    wire [`XLEN-1:0] lhu_data = addr_lo[1] ? {16'b0, mem_rdata[31:16]} :
                                {16'b0, mem_rdata[15:0]};
    wire [`XLEN-1:0] lw_data = mem_rdata;

    assign load_data = (mem_size == `F3_LB) ? lb_data :
                       (mem_size == `F3_LBU) ? lbu_data :
                       (mem_size == `F3_LH) ? lh_data :
                       (mem_size == `F3_LHU) ? lhu_data : lw_data;

endmodule
