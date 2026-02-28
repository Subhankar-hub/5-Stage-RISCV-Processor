#include "Vtb_verilator_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;

    Vtb_verilator_top* top = new Vtb_verilator_top;
    top->trace(tfp, 99);
    tfp->open("sim.vcd");

    int max_cycles = 500;
    if (argc > 1) max_cycles = atoi(argv[1]);

    top->rst_n = 0;
    top->clk = 0;
    top->eval();
    for (int i = 0; i < 5; i++) {
        top->clk = !top->clk;
        top->eval();
    }
    top->rst_n = 1;

    for (int i = 0; i < max_cycles; i++) {
        top->clk = 0;
        top->eval();
        tfp->dump((5 + i) * 10);
        top->clk = 1;
        top->eval();
        tfp->dump((5 + i) * 10 + 5);
    }
    tfp->dump((5 + max_cycles) * 10);
    std::cout << "Simulated " << max_cycles << " cycles. Waveform in sim.vcd" << std::endl;
    tfp->close();
    delete tfp;
    delete top;
    return 0;
}
