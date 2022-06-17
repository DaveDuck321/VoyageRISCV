PROJ = riscv
FILES = lui.v auipc.v branches.v jumps.v alu_immediate_type.v alu_register_type.v instruction_decode.v registers.v toplevel.v
BUILD_DIR = build

simulation: lint
	iverilog -o $(BUILD_DIR)/$(PROJ).out $(FILES)

hardware: lint
	yosys -p "synth_ice40 -top top -json $(BUILD_DIR)/$(PROJ).json" $(FILES)
	nextpnr-ice40 -r --hx8k --json $(BUILD_DIR)/$(PROJ).json --package cb132 --asc $(BUILD_DIR)/$(PROJ).asc --opt-timing --pcf pcf/iceFUN.pcf
	icepack $(BUILD_DIR)/$(PROJ).asc $(BUILD_DIR)/$(PROJ).bin

lint:
	verilator -Wall -Wno-DECLFILENAME -Wno-UNUSED --lint-only $(FILES)

clean:
	rm *.asc *.bin *blif
