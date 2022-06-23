.global _start
.align	4

_start:

init:
    nop
    lui     a0, 2
    li      a1, 240
    sb      a1, 0(a0)
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
    j       .LBB0_1
