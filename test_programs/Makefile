include config.mk

BUILD_PREFIX = ../build
OUTPUT_PREFIX = ../program/
OUT_SREC = program.sr

INIT_OBJECT = $(BUILD_PREFIX)/init.o
BUILD_DIR_PLACEHOLDER = $(BUILD_PREFIX)/.keep

error:
	@echo "Choose a target"
	@exit 2

$(BUILD_DIR_PLACEHOLDER):
	mkdir $(BUILD_PREFIX) -p
	touch $@

$(BUILD_PREFIX)/%.o: %.asm $(BUILD_DIR_PLACEHOLDER)
	$(AS) $(C_FLAGS) $< -o $@

$(BUILD_PREFIX)/%.o: %.cpp $(BUILD_DIR_PLACEHOLDER)
	$(CXX) $(C_FLAGS) -c $< -o $@

$(INIT_OBJECT): init.S $(BUILD_DIR_PLACEHOLDER)
	$(AS) $(C_FLAGS) $< -o $@

$(BUILD_PREFIX)/%.elf: $(BUILD_PREFIX)/%.o $(INIT_OBJECT) link.ld
	$(LD) $(LD_FLAGS) $(INIT_OBJECT) $< -o $@ -lgcc

flash/%: $(BUILD_PREFIX)/%.elf $(BUILD_PREFIX)/%.o $(INIT_OBJECT)
	$(OBJ_COPY) -O srec $< $(BUILD_PREFIX)/$(OUT_SREC)

	cd $(BUILD_PREFIX);\
	$(SREC2HEX) -b 4096 $(OUT_SREC) 2> /dev/null

	mkdir -p $(OUTPUT_PREFIX)
	mv $(BUILD_PREFIX)/program.hex $(OUTPUT_PREFIX)
	mv $(BUILD_PREFIX)/data.hex $(OUTPUT_PREFIX)

.PHONY : error test/%
.PRECIOUS: $(BUILD_PREFIX)/%.elf $(BUILD_PREFIX)/%.o
