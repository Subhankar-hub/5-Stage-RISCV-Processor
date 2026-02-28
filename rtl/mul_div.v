// M-extension: Multiply and Divide unit
// MUL, MULH, MULHSU, MULHU: combinational (1 cycle)
// DIV, DIVU, REM, REMU: iterative (~32 cycles), ready when done
// Synthesizable Verilog

`include "defs.v"

module mul_div (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid,
    input  wire [2:0]  op,      // F3: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
    input  wire [`XLEN-1:0] a,
    input  wire [`XLEN-1:0] b,
    output reg  [`XLEN-1:0] result,
    output reg         ready
);

    // Combinational multiply result (signed * signed, signed * unsigned, unsigned * unsigned)
    wire signed [63:0] mul_ss = ({{32{a[31]}}, a} * {{32{b[31]}}, b});
    wire [63:0] mul_uu = {32'b0, a} * {32'b0, b};
    wire signed [63:0] mul_su = ({{32{a[31]}}, a} * {32'b0, b});

    wire [`XLEN-1:0] mul_result;
    assign mul_result = (op == 3'b000) ? mul_ss[31:0] :
                        (op == 3'b001) ? mul_ss[63:32] :
                        (op == 3'b010) ? mul_su[63:32] :
                        (op == 3'b011) ? mul_uu[63:32] : 32'b0;

    localparam IDLE = 1'b0, DIVIDE = 1'b1;
    reg state;
    reg [2:0] op_reg;
    reg [63:0] div_sh;
    reg [`XLEN-1:0] div_quot, div_rem, div_divisor;
    reg div_neg_q, div_neg_r;
    reg [5:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            result <= 32'b0;
            ready <= 1'b0;
            op_reg <= 3'b0;
            div_quot <= 32'b0;
            div_rem <= 32'b0;
            div_divisor <= 32'b0;
            div_neg_q <= 1'b0;
            div_neg_r <= 1'b0;
            count <= 6'b0;
        end else case (state)
            IDLE: begin
                ready <= 1'b0;
                if (valid) begin
                    op_reg <= op;
                    if (op[2]) begin  // DIV, DIVU, REM, REMU
                        state <= DIVIDE;
                        count <= 6'b0;
                        if (op[0]) begin  // DIVU, REMU - unsigned, dividend in div_quot
                            div_quot <= a;
                            div_rem <= 32'b0;
                            div_divisor <= b;
                            div_neg_q <= 1'b0;
                            div_neg_r <= 1'b0;
                        end else begin  // DIV, REM - signed, use abs values
                            div_neg_q <= a[31] ^ b[31];
                            div_neg_r <= a[31];
                            div_divisor <= (b[31] ? -b : b);
                            div_quot <= (a[31] ? -a : a);
                            div_rem <= 32'b0;
                        end
                    end else begin  // MUL - combinational, done immediately
                        result <= mul_result;
                        ready <= 1'b1;
                    end
                end
            end
            DIVIDE: begin
                if (op_reg[0]) begin  // DIVU, REMU - restoring division
                    if (count < 6'd32) begin
                        div_sh = {div_rem, div_quot} << 1;
                        if (div_sh[63:32] >= div_divisor) begin
                            div_rem <= div_sh[63:32] - div_divisor;
                            div_quot <= div_sh[31:0] | 32'd1;
                        end else begin
                            div_rem <= div_sh[63:32];
                            div_quot <= div_sh[31:0];
                        end
                        count <= count + 1;
                    end else begin
                        result <= op_reg[1] ? div_rem : div_quot;
                        ready <= 1'b1;
                        state <= IDLE;
                    end
                end else begin  // DIV, REM signed - same restoring division
                    if (count < 6'd32) begin
                        div_sh = {div_rem, div_quot} << 1;
                        if (div_sh[63:32] >= div_divisor) begin
                            div_rem <= div_sh[63:32] - div_divisor;
                            div_quot <= div_sh[31:0] | 32'd1;
                        end else begin
                            div_rem <= div_sh[63:32];
                            div_quot <= div_sh[31:0];
                        end
                        count <= count + 1;
                    end else begin
                        if (op_reg[1])  // REM
                            result <= div_neg_r ? -div_rem : div_rem;
                        else             // DIV
                            result <= div_neg_q ? -div_quot : div_quot;
                        ready <= 1'b1;
                        state <= IDLE;
                    end
                end
            end
            default: state <= IDLE;
        endcase
    end

endmodule
