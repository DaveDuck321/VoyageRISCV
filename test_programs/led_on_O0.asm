.global _start
.align	4
.set DATA_MEM_SIZE, 64

_start:

init:
    li		sp, DATA_MEM_SIZE

    addi    sp, sp, -16
    sw      ra, 12(sp)                      # 4-byte Folded Spill
    sw      s0, 8(sp)                       # 4-byte Folded Spill
    addi    s0, sp, 16
    li      a0, 0
    sw      a0, -12(s0)
    lui     a0, 2
    sw      a0, -16(s0)
    lw      a1, -16(s0)
    li      a0, 240
    sb      a0, 0(a1)

.FINISH:
    j       .FINISH
