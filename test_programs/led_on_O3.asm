.global main
.align	4

main:
    lui     a0, 2
    li      a1, 240
    sb      a1, 0(a0)

.FINISH:
    j       .FINISH
