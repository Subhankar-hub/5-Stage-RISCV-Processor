// Synchronous 32x32 Register File
// Dual read, single write. Register x0 hardwired to zero.
// Synthesizable Verilog

`include "defs.v"

module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [4:0]  waddr,
    input  wire [`XLEN-1:0] wdata,
    input  wire        we,
    output reg  [`XLEN-1:0] rdata1,
    output reg  [`XLEN-1:0] rdata2
);

    reg [`XLEN-1:0] regs [31:1];  // x1..x31; x0 is always 0

    integer i;

    // Read port 1 (combinational for same-cycle read)
    always @(*) begin
        if (raddr1 == 5'b0)
            rdata1 = 32'b0;
        else if (we && waddr == raddr1)
            rdata1 = wdata;
        else
            rdata1 = regs[raddr1];
    end

    // Read port 2
    always @(*) begin
        if (raddr2 == 5'b0)
            rdata2 = 32'b0;
        else if (we && waddr == raddr2)
            rdata2 = wdata;
        else
            rdata2 = regs[raddr2];
    end

    // Write port (synchronous)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (we && waddr != 5'b0) begin
            regs[waddr] <= wdata;
        end
    end

endmodule
