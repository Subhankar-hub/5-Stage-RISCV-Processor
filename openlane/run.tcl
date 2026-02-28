#!/usr/bin/env openlane
# OpenLane run script - use: ./flow.tcl -design openlane -init_design_config
# Or with openlane container: make mount, then ./flow.tcl -design .
#
# For a local setup, run from OpenLane root:
# flow.tcl -design /path/to/5-Stage-RISCV-Processor/openlane

# Load design config
if { [info exists ::env(DESIGN_NAME)] } {
    puts "Design: $::env(DESIGN_NAME)"
} else {
    puts "Run this from OpenLane: flow.tcl -design [pwd] -overwrite"
    exit 1
}
