// Top testbench - instantiates riscv_core and memory, self-checking
`timescale 1ns/1ps

`include "../rtl/defs.v"

module tb_top;

    parameter MEM_FILE = "tests/simple.hex";
    parameter MAX_CYCLES = 10000;

    reg clk, rst_n;
    wire [31:0] instr_addr, instr_rdata, data_addr, data_wdata, data_rdata;
    wire instr_req, instr_gnt, data_we, data_req, data_gnt;
    wire [3:0] data_be;

    integer cycle_count;
    integer exit_code;

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
        .MEM_FILE(MEM_FILE)
    ) u_mem (
        .clk(clk), .rst_n(rst_n),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .instr_req(instr_req), .instr_gnt(instr_gnt),
        .data_addr(data_addr), .data_wdata(data_wdata), .data_rdata(data_rdata),
        .data_we(data_we), .data_be(data_be), .data_req(data_req), .data_gnt(data_gnt)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        cycle_count = 0;
        #100;
        rst_n = 1;
    end

    always @(posedge clk) begin
        if (rst_n)
            cycle_count <= cycle_count + 1;
        if (cycle_count > MAX_CYCLES) begin
            $display("FAIL: Timeout after %0d cycles", MAX_CYCLES);
            $finish(1);
        end
    end


    // Exit on store to 0 with data 0 (pass) - from sw x0,0(x5) when x5=0x1000 or sw x0,0(x0)
    always @(posedge clk) begin
        if (rst_n && data_req && data_we && data_addr == 32'h00000000 && data_wdata == 0) begin
            exit_code = 0;
            $display("PASS");
            $finish(0);
        end
    end

endmodule
