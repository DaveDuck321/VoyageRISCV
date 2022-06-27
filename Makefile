PROJ = riscv
COMMON_FILES_RELATIVE = error_propagation.v fence.v debug.v pipelines.v program_counter.v mux.v block_memory.v ram.v lui.v auipc.v branches.v jumps.v alu_immediate_type.v alu_register_type.v instruction_decode.v registers.v processor.v
COMMON_FILES = $(addprefix processor/, $(COMMON_FILES_RELATIVE))
BUILD_DIR = build

simulation: lint
	iverilog -o $(BUILD_DIR)/$(PROJ).out iverilog_toplevel.v $(COMMON_FILES)

hardware_ice40: lint
	yosys -q -p "synth_ice40 -top top -json $(BUILD_DIR)/$(PROJ).json" icefun/*.v $(COMMON_FILES)
	nextpnr-ice40 -r --hx8k --json $(BUILD_DIR)/$(PROJ).json --package cb132 --asc $(BUILD_DIR)/$(PROJ).asc --opt-timing --pcf icefun/constraints.pcf
	icepack $(BUILD_DIR)/$(PROJ).asc $(BUILD_DIR)/$(PROJ).bin

# NOTE: the OSS toolchain is missing BRAM support: project is unsynthesizable atm. 
hardware_tangnano9k: lint
	yosys -q -p "synth_gowin -top top -json $(BUILD_DIR)/$(PROJ).json" tangnano9k_toplevel.v $(COMMON_FILES)
	nextpnr-gowin --json $(BUILD_DIR)/$(PROJ).json --write $(BUILD_DIR)/$(PROJ).pnr.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst pcf/tangnano9k.cst
	gowin_pack -d GW1NR-LV9QN88PC6/I5 -o $(BUILD_DIR)/$(PROJ).bin $(BUILD_DIR)/$(PROJ).pnr.json

lint:
	verilator -Wall -Wno-DECLFILENAME -Wno-UNUSED --lint-only $(COMMON_FILES)

clean:
	rm *.asc *.bin *blif
