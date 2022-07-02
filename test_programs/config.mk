GCC_ROOT = <path-to-riscv-gnu-toolchain>/bin/lib/gcc/riscv32-unknown-elf/11.1.0/
TOOLCHAIN_ROOT = <path-to-riscv-gnu-toolchain>/bin/

AS 	= $(TOOLCHAIN_ROOT)/bin/riscv32-unknown-elf-as
CC 	= $(TOOLCHAIN_ROOT)/bin/riscv32-unknown-elf-gcc
CXX = $(TOOLCHAIN_ROOT)/bin/riscv32-unknown-elf-g++
LD 	= $(TOOLCHAIN_ROOT)/bin/riscv32-unknown-elf-ld
OBJ_COPY = $(TOOLCHAIN_ROOT)/bin/riscv32-unknown-elf-objcopy
SREC2HEX = srec2hex  # TODO: understand obj_copy well enough to remove this


C_FLAGS = -march=rv32i -mabi=ilp32
LD_INCLUDE_DIR = -L$(GCC_ROOT) -L$(TOOLCHAIN_ROOT)/riscv32-unknown-elf/lib/
LD_FLAGS = $(LD_INCLUDE_DIR) -Tlink.ld
