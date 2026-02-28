# 5-Stage RV32IM RISC-V Processor - Master Makefile
# Targets: sim, gds-setup, gds, gds-view, gds-clean

RTL_DIR = rtl
SIM_DIR = sim

# RTL sources (order matters: defs first)
RTL_FILES = $(RTL_DIR)/defs.v $(RTL_DIR)/regfile.v $(RTL_DIR)/alu.v \
            $(RTL_DIR)/mul_div.v $(RTL_DIR)/if_stage.v $(RTL_DIR)/id_stage.v \
            $(RTL_DIR)/ex_stage.v $(RTL_DIR)/mem_stage.v $(RTL_DIR)/hazard_unit.v \
            $(RTL_DIR)/riscv_core.v

# OpenLane2 environment
# Locally, run inside a Nix shell or Python venv where `openlane` is on PATH
# and PDK_ROOT points at your Sky130 PDK (e.g. /home/smith/asic/pdks).
# In CI, we install OpenLane2 with pip and run it in Dockerized mode.

# Extra flags passed to the `openlane` CLI (e.g. --dockerized in CI).
OPENLANE_EXTRA_FLAGS ?=

# Simulation
.PHONY: sim sim-iverilog
sim: $(SIM_DIR)/run_sim
	cd $(SIM_DIR) && vvp run_sim

sim-iverilog: $(SIM_DIR)/run_sim
	cd $(SIM_DIR) && vvp run_sim

$(SIM_DIR)/run_sim: $(RTL_FILES) $(SIM_DIR)/mem_model.v $(SIM_DIR)/tb_top.v
	iverilog -g2012 -I $(RTL_DIR) -o $@ $(RTL_FILES) $(SIM_DIR)/mem_model.v $(SIM_DIR)/tb_top.v

# ──────────────────────────────────────────────
#  ASIC flow  (OpenLane classic / Sky130)
# ──────────────────────────────────────────────

## Copy RTL into OpenLane design directory (plain Verilog, no sv2v)
asic/src/riscv_core.v: $(RTL_FILES)
	mkdir -p asic/src
	cp $(RTL_FILES) asic/src/

## Optional: quick environment check
gds-setup:
	@echo "Using OpenLane2 CLI: openlane $(OPENLANE_EXTRA_FLAGS) --pdk-root=$${PDK_ROOT:-<unset>}"
	@openlane --version || echo "openlane not found on PATH"

## Run full RTL-to-GDS flow via OpenLane2 (Classic flow)
gds: asic/src/riscv_core.v
	openlane $(OPENLANE_EXTRA_FLAGS) --pdk-root $(PDK_ROOT) $(CURDIR)/asic/config.tcl

## Open final GDS in KLayout
gds-view:
	@gds=$$(find asic -path "*/results/final/gds/*.gds" 2>/dev/null | head -1); \
	if [ -z "$$gds" ]; then echo "No GDS found. Run 'make gds' first."; exit 1; fi; \
	echo "Opening $$gds"; \
	klayout "$$gds" &

## Aliases
.PHONY: syn asic view
syn: gds
asic: gds
view: gds-view

## Remove ASIC outputs
gds-clean:
	rm -rf asic/runs
	rm -f asic/src/*.v

# Generate Verilator headers (fixes IDE/linter; run once for IntelliSense)
.PHONY: verilator-gen
verilator-gen:
	@verilator -Wall -Wno-fatal --cc --trace --no-timing -I$(RTL_DIR) \
		$(RTL_FILES) $(SIM_DIR)/mem_model.v $(SIM_DIR)/tb_verilator_top.v 2>/dev/null || true; \
	echo "Generated obj_dir/ - IDE should resolve Vtb_verilator_top.h"

# Verilator (optional, for cycle-accurate sim + VCD for GTKWave)
.PHONY: sim-verilator
sim-verilator:
	@if command -v verilator >/dev/null 2>&1; then \
		verilator -Wall -Wno-fatal --cc --exe --trace --no-timing -I$(RTL_DIR) --top-module tb_verilator_top --build \
			$(RTL_FILES) $(SIM_DIR)/mem_model.v $(SIM_DIR)/tb_verilator_top.v $(SIM_DIR)/tb_verilator.cpp; \
		./obj_dir/Vtb_verilator_top; \
	else \
		echo "Verilator not found. Use: make sim for Icarus Verilog."; \
	fi

# View Verilator waveforms in GTKWave (run sim-verilator first)
.PHONY: wave
wave:
	@if [ -f sim.vcd ]; then \
		gtkwave sim.vcd; \
	else \
		echo "Run 'make sim-verilator' first to generate sim.vcd"; \
		exit 1; \
	fi

clean: gds-clean
	rm -f $(SIM_DIR)/run_sim sim.vcd
	rm -rf obj_dir Vivado vivado/utilization.txt vivado/timing.txt
