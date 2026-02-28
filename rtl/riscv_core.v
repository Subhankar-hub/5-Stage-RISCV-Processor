// 5-Stage Pipelined RV32IM RISC-V Core - Top Level
// Synthesizable Verilog

`include "defs.v"

module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    // Instruction memory interface
    output wire [`XLEN-1:0] instr_addr,
    input  wire [`XLEN-1:0] instr_rdata,
    output wire        instr_req,
    input  wire        instr_gnt,
    // Data memory interface
    output wire [`XLEN-1:0] data_addr,
    output wire [`XLEN-1:0] data_wdata,
    input  wire [`XLEN-1:0] data_rdata,
    output wire        data_we,
    output wire [3:0]  data_be,
    output wire        data_req,
    input  wire        data_gnt
);

    // Pipeline stall and flush
    wire stall, load_use;
    wire flush;
    wire branch_taken;
    wire [`XLEN-1:0] branch_target;

    // IF stage
    wire [`XLEN-1:0] pc, pc_plus4;

    // IF/ID
    reg [`XLEN-1:0] if_id_pc, if_id_pc_plus4, if_id_instr;

    // ID stage
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [`XLEN-1:0] imm;
    wire [3:0] alu_op;
    wire alu_src, mem_we, mem_re, reg_we, wb_sel;
    wire [2:0] mem_size;
    wire mem_unsigned;
    wire branch, jal, jalr;
    wire [2:0] branch_type;
    wire mul_div_valid;
    wire [2:0] mul_div_op;
    wire is_muldiv, auipc, lui;
    wire [`XLEN-1:0] rs1_data, rs2_data;

    // ID/EX
    reg [`XLEN-1:0] id_ex_pc, id_ex_rs1, id_ex_rs2, id_ex_imm;
    reg [4:0] id_ex_rd, id_ex_rs1_addr, id_ex_rs2_addr;
    reg [3:0] id_ex_alu_op;
    reg id_ex_alu_src, id_ex_mem_we, id_ex_mem_re, id_ex_reg_we, id_ex_wb_sel;
    reg [2:0] id_ex_mem_size;
    reg id_ex_mem_unsigned;
    reg id_ex_branch, id_ex_jal, id_ex_jalr;
    reg [2:0] id_ex_branch_type;
    reg id_ex_mul_div_valid;
    reg [2:0] id_ex_mul_div_op;
    reg id_ex_is_muldiv, id_ex_auipc, id_ex_lui;

    // EX stage - forwarding
    wire [1:0] fwd_rs1, fwd_rs2;
    wire [`XLEN-1:0] rs1_fwd = (fwd_rs1 == 2'b01) ? ex_mem_result :
                                (fwd_rs1 == 2'b10) ? wb_data : id_ex_rs1;
    wire [`XLEN-1:0] rs2_fwd = (fwd_rs2 == 2'b01) ? ex_mem_result :
                                (fwd_rs2 == 2'b10) ? wb_data : id_ex_rs2;

    wire [`XLEN-1:0] alu_a = id_ex_lui ? 32'b0 : (id_ex_auipc ? id_ex_pc : rs1_fwd);
    wire [`XLEN-1:0] alu_b = id_ex_alu_src ? id_ex_imm : rs2_fwd;

    wire [`XLEN-1:0] alu_result;
    wire [`XLEN-1:0] mul_div_result;
    wire mul_div_ready;
    wire [`XLEN-1:0] ex_result;
    wire ex_branch_taken;
    wire mul_div_stall;

    // EX/MEM
    reg [`XLEN-1:0] ex_mem_result, ex_mem_rs2;
    reg [4:0] ex_mem_rd;
    reg ex_mem_mem_we, ex_mem_mem_re;
    reg [2:0] ex_mem_mem_size;
    reg ex_mem_mem_unsigned;
    reg ex_mem_reg_we, ex_mem_wb_sel;

    // MEM stage
    wire [`XLEN-1:0] mem_load_data;

    // MEM/WB
    reg [`XLEN-1:0] mem_wb_alu_result, mem_wb_load_data;
    reg [4:0] mem_wb_rd;
    reg mem_wb_reg_we, mem_wb_wb_sel;

    // WB stage
    wire [`XLEN-1:0] wb_data = mem_wb_wb_sel ? mem_wb_load_data : mem_wb_alu_result;

    // Submodules
    if_stage u_if (
        .clk(clk), .rst_n(rst_n), .stall(stall), .flush(flush),
        .pc_src(branch_taken), .branch_target(branch_target),
        .instr_rdata(instr_rdata), .instr_gnt(instr_gnt),
        .pc(pc), .pc_plus4(pc_plus4), .instr_addr(instr_addr), .instr_req(instr_req)
    );

    regfile u_rf (
        .clk(clk), .rst_n(rst_n),
        .raddr1(rs1_addr), .raddr2(rs2_addr),
        .waddr(mem_wb_rd), .wdata(wb_data), .we(mem_wb_reg_we),
        .rdata1(rs1_data), .rdata2(rs2_data)
    );

    id_stage u_id (
        .instr(if_id_instr), .rs1_data(rs1_data), .rs2_data(rs2_data),
        .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
        .imm(imm), .alu_op(alu_op), .alu_src(alu_src),
        .mem_we(mem_we), .mem_re(mem_re), .mem_size(mem_size), .mem_unsigned(mem_unsigned),
        .reg_we(reg_we), .wb_sel(wb_sel), .branch(branch), .jal(jal), .jalr(jalr),
        .branch_type(branch_type), .mul_div_valid(mul_div_valid), .mul_div_op(mul_div_op),
        .is_muldiv(is_muldiv), .auipc(auipc), .lui(lui)
    );

    alu u_alu (.alu_op(id_ex_alu_op), .a(alu_a), .b(alu_b), .result(alu_result));

    mul_div u_muldiv (
        .clk(clk), .rst_n(rst_n), .valid(id_ex_mul_div_valid),
        .op(id_ex_mul_div_op), .a(rs1_fwd), .b(rs2_fwd),
        .result(mul_div_result), .ready(mul_div_ready)
    );

    ex_stage u_ex (
        .alu_op(id_ex_alu_op), .alu_src(id_ex_alu_src), .auipc(id_ex_auipc), .lui(id_ex_lui),
        .rs1_data(rs1_fwd), .rs2_data(rs2_fwd), .imm(id_ex_imm), .pc(id_ex_pc),
        .branch(id_ex_branch), .branch_type(id_ex_branch_type), .jal(id_ex_jal), .jalr(id_ex_jalr),
        .is_muldiv(id_ex_is_muldiv), .alu_result(alu_result), .mul_div_result(mul_div_result),
        .mul_div_ready(mul_div_ready),
        .result(ex_result), .branch_target(branch_target), .branch_taken(ex_branch_taken),
        .mul_div_stall(mul_div_stall)
    );

    mem_stage u_mem (
        .mem_we(ex_mem_mem_we), .mem_re(ex_mem_mem_re),
        .mem_size(ex_mem_mem_size), .mem_unsigned(ex_mem_mem_unsigned),
        .addr(ex_mem_result), .store_data(ex_mem_rs2), .mem_rdata(data_rdata),
        .mem_wdata(data_wdata), .load_data(mem_load_data)
    );

    hazard_unit u_hazard (
        .if_id_rs1(rs1_addr), .if_id_rs2(rs2_addr),
        .id_ex_rs1(id_ex_rs1_addr), .id_ex_rs2(id_ex_rs2_addr), .id_ex_rd(id_ex_rd),
        .ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_we(ex_mem_reg_we), .mem_wb_reg_we(mem_wb_reg_we),
        .id_ex_mem_re(id_ex_mem_re), .ex_mem_mem_re(ex_mem_mem_re),
        .id_ex_mul_div_stall(mul_div_stall),
        .fwd_rs1(fwd_rs1), .fwd_rs2(fwd_rs2), .stall(stall), .load_use(load_use)
    );

    assign branch_taken = ex_branch_taken;
    assign flush = branch_taken;

    // Byte enable for stores (mem_size: 000=byte, 001=half, 010=word)
    wire [1:0] data_addr_lo = ex_mem_result[1:0];
    assign data_be = ex_mem_mem_we ?
        ((ex_mem_mem_size == 3'b010) ? 4'b1111 :
         (ex_mem_mem_size == 3'b001) ? (data_addr_lo[1] ? 4'b1100 : 4'b0011) :
         (data_addr_lo == 2'b00 ? 4'b0001 : (data_addr_lo == 2'b01 ? 4'b0010 : (data_addr_lo == 2'b10 ? 4'b0100 : 4'b1000)))) : 4'b0000;
    assign data_addr = ex_mem_result;
    assign data_we = ex_mem_mem_we;
    assign data_req = ex_mem_mem_we | ex_mem_mem_re;

    // Pipeline registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_id_pc <= 32'b0; if_id_pc_plus4 <= 32'd4; if_id_instr <= 32'h00000013;
        end else if (stall) begin
            // hold
        end else if (flush) begin
            if_id_instr <= 32'h00000013;  // NOP (flush)
        end else if (instr_gnt || !instr_req) begin
            if_id_pc <= pc; if_id_pc_plus4 <= pc_plus4; if_id_instr <= instr_rdata;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex_pc <= 32'b0; id_ex_rs1 <= 32'b0; id_ex_rs2 <= 32'b0; id_ex_imm <= 32'b0;
            id_ex_rd <= 5'b0; id_ex_rs1_addr <= 5'b0; id_ex_rs2_addr <= 5'b0;
            id_ex_alu_op <= 4'b0; id_ex_alu_src <= 0; id_ex_mem_we <= 0; id_ex_mem_re <= 0;
            id_ex_reg_we <= 0; id_ex_wb_sel <= 0; id_ex_mem_size <= 3'b0;
            id_ex_mem_unsigned <= 0; id_ex_branch <= 0; id_ex_jal <= 0; id_ex_jalr <= 0;
            id_ex_branch_type <= 3'b0; id_ex_mul_div_valid <= 0; id_ex_mul_div_op <= 3'b0;
            id_ex_is_muldiv <= 0; id_ex_auipc <= 0; id_ex_lui <= 0;
        end else if (stall && load_use) begin
            id_ex_rd <= 5'b0; id_ex_reg_we <= 0; id_ex_mem_we <= 0; id_ex_mem_re <= 0;
            id_ex_mul_div_valid <= 0; id_ex_is_muldiv <= 0;
        end else if (stall) begin
            id_ex_mul_div_valid <= 0;
        end else if (flush) begin
            id_ex_rd <= 5'b0; id_ex_reg_we <= 0; id_ex_mem_we <= 0; id_ex_mem_re <= 0;
            id_ex_mul_div_valid <= 0; id_ex_is_muldiv <= 0;
        end else begin
            id_ex_pc <= if_id_pc; id_ex_rs1 <= rs1_data; id_ex_rs2 <= rs2_data; id_ex_imm <= imm;
            id_ex_rd <= rd_addr; id_ex_rs1_addr <= rs1_addr; id_ex_rs2_addr <= rs2_addr;
            id_ex_alu_op <= alu_op; id_ex_alu_src <= alu_src; id_ex_mem_we <= mem_we;
            id_ex_mem_re <= mem_re; id_ex_reg_we <= reg_we; id_ex_wb_sel <= wb_sel;
            id_ex_mem_size <= mem_size; id_ex_mem_unsigned <= mem_unsigned;
            id_ex_branch <= branch; id_ex_jal <= jal; id_ex_jalr <= jalr;
            id_ex_branch_type <= branch_type; id_ex_mul_div_valid <= mul_div_valid;
            id_ex_mul_div_op <= mul_div_op; id_ex_is_muldiv <= is_muldiv; id_ex_auipc <= auipc; id_ex_lui <= lui;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_result <= 32'b0; ex_mem_rs2 <= 32'b0; ex_mem_rd <= 5'b0;
            ex_mem_mem_we <= 0; ex_mem_mem_re <= 0; ex_mem_mem_size <= 3'b0;
            ex_mem_mem_unsigned <= 0; ex_mem_reg_we <= 0; ex_mem_wb_sel <= 0;
        end else begin
            ex_mem_result <= ex_result; ex_mem_rs2 <= rs2_fwd; ex_mem_rd <= id_ex_rd;
            ex_mem_mem_we <= id_ex_mem_we; ex_mem_mem_re <= id_ex_mem_re;
            ex_mem_mem_size <= id_ex_mem_size; ex_mem_mem_unsigned <= id_ex_mem_unsigned;
            ex_mem_reg_we <= id_ex_reg_we; ex_mem_wb_sel <= id_ex_wb_sel;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_alu_result <= 32'b0; mem_wb_load_data <= 32'b0;
            mem_wb_rd <= 5'b0; mem_wb_reg_we <= 0; mem_wb_wb_sel <= 0;
        end else begin
            mem_wb_alu_result <= ex_mem_result; mem_wb_load_data <= mem_load_data;
            mem_wb_rd <= ex_mem_rd; mem_wb_reg_we <= ex_mem_reg_we; mem_wb_wb_sel <= ex_mem_wb_sel;
        end
    end

endmodule
