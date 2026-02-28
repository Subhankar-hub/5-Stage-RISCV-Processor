# OpenLane design config - loaded when design dir is project root (Docker mount)
# Use DESIGN_DIR (set by OpenLane before sourcing) instead of [info script],
# because prep copies this file to runs/<tag>/config_in.tcl before sourcing it.
set rtl_dir [file join $::env(DESIGN_DIR) rtl]

set ::env(DESIGN_NAME) "riscv_core"
set ::env(VERILOG_FILES) [list \
    [file join $rtl_dir defs.v] \
    [file join $rtl_dir regfile.v] \
    [file join $rtl_dir alu.v] \
    [file join $rtl_dir mul_div.v] \
    [file join $rtl_dir if_stage.v] \
    [file join $rtl_dir id_stage.v] \
    [file join $rtl_dir ex_stage.v] \
    [file join $rtl_dir mem_stage.v] \
    [file join $rtl_dir hazard_unit.v] \
    [file join $rtl_dir riscv_core.v] \
]
set ::env(VERILOG_INCLUDE_DIRS) [list $rtl_dir]
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 500 500"
set ::env(PL_TARGET_DENSITY) 0.40
set ::env(IO_PCT) "0.70"
set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(SYNTH_MAX_FANOUT) 6
