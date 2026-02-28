# Floorplan - 5-Stage RV32IM RISC-V Core

## Die and Core Area

- **Die area:** 500 x 500 um (configurable via OpenLane `DIE_AREA`)
- **Core utilization:** ~35–40% target (set by `PL_TARGET_DENSITY`)
- **Aspect ratio:** 1:1

## IO Pin Placement

| Side   | Signals                                                       |
|--------|---------------------------------------------------------------|
| North  | Instruction bus: instr_addr, instr_rdata, instr_req, instr_gnt |
| South  | Data bus: data_addr, data_wdata, data_rdata, data_we, data_be, data_req, data_gnt |
| West   | clk, rst_n                                                    |

## Macro Placement (Logical Blocks)

- **Core:** Pipeline control, hazard unit
- **ALU/MulDiv:** Execute stage datapath
- **Register File:** 32x32 synchronous RF
- **Pipeline registers:** IF/ID, ID/EX, EX/MEM, MEM/WB

OpenLane performs flat synthesis by default. Hierarchy can be preserved for floorplanning by setting synthesis hierarchy options.

## OpenLane Setup

1. Clone OpenLane and Sky130 PDK
2. Run `make` in OpenLane to build
3. Set `OPENLANE_ROOT` to the OpenLane directory
4. Run `make asic` from this project

## Clock Tree

- Single clock domain
- Target period: 10 ns (100 MHz) for Sky130
- CTS: OpenROAD builds balanced H-tree
