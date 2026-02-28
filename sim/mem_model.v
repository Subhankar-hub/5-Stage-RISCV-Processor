// Behavioral memory model - loads hex file, SRAM-like interface
// Synthesizable for simulation only (uses $readmemh)

`timescale 1ns/1ps

module mem_model #(
    parameter ADDR_BITS = 16,
    parameter MEM_SIZE = 65536,
    parameter MEM_FILE = "prog.hex"
) (
    input  wire         clk,
    input  wire         rst_n,
    // Instruction port
    input  wire [31:0]  instr_addr,
    output reg  [31:0]  instr_rdata,
    input  wire         instr_req,
    output reg          instr_gnt,
    // Data port
    input  wire [31:0]  data_addr,
    input  wire [31:0]  data_wdata,
    output reg  [31:0]  data_rdata,
    input  wire         data_we,
    input  wire [3:0]   data_be,
    input  wire         data_req,
    output reg          data_gnt
);

    reg [31:0] mem [0:MEM_SIZE/4-1];
    integer k;

    initial begin
        instr_rdata = 32'h00000013;
        instr_gnt = 1'b0;
        data_rdata = 32'b0;
        data_gnt = 1'b0;
        for (k = 0; k < MEM_SIZE/4; k = k + 1)
            mem[k] = 32'h00000013;
        $readmemh(MEM_FILE, mem, 0, 7);
    end

    wire [ADDR_BITS-1:2] instr_idx = instr_addr[ADDR_BITS-1:2];
    wire [ADDR_BITS-1:2] data_idx  = data_addr[ADDR_BITS-1:2];

    always @(posedge clk) begin
        instr_gnt <= instr_req;
        if (instr_req)
            instr_rdata <= mem[instr_idx];
    end
    always @(posedge clk) begin
        data_gnt <= data_req;
        if (data_req && !data_we)
            data_rdata <= mem[data_idx];
        if (data_req && data_we) begin
            if (data_be[0]) mem[data_idx][7:0]   <= data_wdata[7:0];
            if (data_be[1]) mem[data_idx][15:8]  <= data_wdata[15:8];
            if (data_be[2]) mem[data_idx][23:16] <= data_wdata[23:16];
            if (data_be[3]) mem[data_idx][31:24] <= data_wdata[31:24];
        end
    end

endmodule
