PROJ = riscv
COMMON_FILES_RELATIVE = ex_to_wb_pipeline.v program_counter.v mux.v memory.v lui.v auipc.v branches.v jumps.v alu_immediate_type.v alu_register_type.v instruction_decode.v registers.v processor.v
COMMON_FILES = $(addprefix processor/, $(COMMON_FILES_RELATIVE))
BUILD_DIR = build

simulation: lint
	iverilog -o $(BUILD_DIR)/$(PROJ).out iverilog_toplevel.v $(COMMON_FILES)

hardware: lint
	yosys -q -p "synth_ice40 -top top -json $(BUILD_DIR)/$(PROJ).json" icefun_toplevel.v $(COMMON_FILES)
	nextpnr-ice40 -r --hx8k --json $(BUILD_DIR)/$(PROJ).json --package cb132 --asc $(BUILD_DIR)/$(PROJ).asc --opt-timing --pcf pcf/iceFun.pcf
	icepack $(BUILD_DIR)/$(PROJ).asc $(BUILD_DIR)/$(PROJ).bin

lint:
	verilator -Wall -Wno-DECLFILENAME -Wno-UNUSED --lint-only $(COMMON_FILES)

clean:
	rm *.asc *.bin *blif
