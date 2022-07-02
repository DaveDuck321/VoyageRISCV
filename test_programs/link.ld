OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)

ENTRY(_start)

MEMORY
{
    INSTRUCTION_MEMORY (X) : ORIGIN = 0x0000, LENGTH = 0x1000
    RAM (RW) : ORIGIN = 0x1000, LENGTH = 0x1000
}

SECTIONS
{
    . = 0x00;
    .text 0x0000 : {
        . = ALIGN(4);
        *(.text)
    } > INSTRUCTION_MEMORY

    .data 0x1000 : {
        BYTE(0)     /* Initialize the memory-mapped IO to zero*/
        . = ALIGN(4);
        *(.rodata)
        *(.strings)
        *(.data)
        *(.bss)
        *(COMMON)
    } > RAM
}
