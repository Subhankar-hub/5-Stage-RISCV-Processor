# OpenLane config for riscv_core - asic/ is mounted as /design
# Use DESIGN_DIR (set by OpenLane before sourcing) instead of [info script],
# because prep copies this file to runs/<tag>/config_in.tcl before sourcing it.
set src_dir [file join $::env(DESIGN_DIR) src]
set ::env(DESIGN_NAME) "riscv_core"
set ::env(VERILOG_FILES) [list \
    [file join $src_dir defs.v] \
    [file join $src_dir regfile.v] \
    [file join $src_dir alu.v] \
    [file join $src_dir mul_div.v] \
    [file join $src_dir if_stage.v] \
    [file join $src_dir id_stage.v] \
    [file join $src_dir ex_stage.v] \
    [file join $src_dir mem_stage.v] \
    [file join $src_dir hazard_unit.v] \
    [file join $src_dir riscv_core.v] \
]
set ::env(VERILOG_INCLUDE_DIRS) [list $src_dir]
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 500 500"
# Global placement target density; OpenROAD suggested ~0.89 for this design.
set ::env(PL_TARGET_DENSITY) 0.89
set ::env(IO_PCT) "0.70"
set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
set ::env(SYNTH_STRATEGY) "AREA 0"
set ::env(MAX_FANOUT_CONSTRAINT) 6
# Skip linter (path/module resolution issues + warnings as errors)
set ::env(RUN_LINTER) 0
