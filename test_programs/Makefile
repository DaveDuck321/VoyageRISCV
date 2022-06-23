AS = riscv32-unknown-elf-as
CC = riscv32-unknown-elf-gcc
OBJ_COPY = riscv32-unknown-elf-objcopy
SREC2HEX = srec2hex  # TODO: understand obj_copy well enough to remove this

BUILD_PREFIX = ../build/
OUTPUT_PREFIX = ../program/
OUT_ELF = program.out
OUT_SREC = program.sr

error:
	@echo "Choose a target"
	@exit 2

led_on_O0: led_on_O0_impl common
led_on_O0_impl:
	$(AS) -o $(BUILD_PREFIX)/$(OUT_ELF) led_on_O0.asm

led_on_O3: led_on_O3_impl common
led_on_O3_impl:
	$(AS) -o $(BUILD_PREFIX)/$(OUT_ELF) led_on_O3.asm

common:
	$(OBJ_COPY) -O srec $(BUILD_PREFIX)/$(OUT_ELF) $(BUILD_PREFIX)/$(OUT_SREC)

	cd $(BUILD_PREFIX);\
	$(SREC2HEX) -b 4096 $(OUT_SREC) 2> /dev/null

	mkdir -p $(OUTPUT_PREFIX)
	mv $(BUILD_PREFIX)/program.hex $(OUTPUT_PREFIX)
	mv $(BUILD_PREFIX)/data.hex $(OUTPUT_PREFIX)
