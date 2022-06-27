// Opcodes
`define LUI_OPCODE      7'b0110111  // U-Type
`define AUIPC_OPCODE    7'b0010111  // U-Type

`define JAL_OPCODE      7'b1101111  // J-Type
`define JALR_OPCODE     7'b1100111  // I-Type

`define SOME_BRANCH_OPCODE  7'b1100011  // B-Type
`define SOME_LOAD_OPCODE    7'b0000011  // I-Type
`define SOME_STORE_OPCODE   7'b0100011  // S-Type

`define SOME_ALU_OPCODE_ITYPE  7'b0010011
`define SOME_ALU_OPCODE_RTYPE  7'b0110011

`define FENCE_OPCODE    7'b0001111  // I-Type
`define DEBUG_OPCODE    7'b1110011  // TODO: maybe treat as I-Type?


// ALU subfunctions
`define ADD_SUBFUNC3    3'b000
`define SLL_SUBFUNC3    3'b001
`define SLT_SUBFUNC3    3'b010
`define SLTU_SUBFUNC3   3'b011
`define XOR_SUBFUNC3    3'b100
`define SRL_SUBFUNC3    3'b101
`define OR_SUBFUN3      3'b110
`define AND_SUBFUN3     3'b111

// Branching subfunctions
`define BEQ_SUBFUNC3    3'b000
`define BNE_SUBFUNC3    3'b001
`define BLT_SUBFUNC3    3'b100
`define BGT_SUBFUNC3    3'b101
`define BLTU_SUBFUNC3   3'b110
`define BGEU_SUBFUNC3   3'b111

`define SIGNED_MODE_IMMEDIATE_INDICATOR     7'b0100000
`define UNSIGNED_MODE_IMMEDIATE_INDICATOR   7'b0000000

`define LB_SUBFUN3  3'b000
`define LH_SUBFUN3  3'b001
`define LW_SUBFUN3  3'b010
`define LBU_SUBFUN3 3'b100
`define LHU_SUBFUN3 3'b101

`define SB_SUBFUN3  3'b000
`define SH_SUBFUN3  3'b001
`define SW_SUBFUN3  3'b010


// Microarchitecture specific defines
`define ONEHOT_DEBUG_INDEX      0
`define ONEHOT_LUI_INDEX        1
`define ONEHOT_AUIPI_INDEX      2
`define ONEHOT_JAL_INDEX        3
`define ONEHOT_JALR_INDEX       4
`define ONEHOT_BRANCH_INDEX     5
`define ONEHOT_LOAD_INDEX       6
`define ONEHOT_STORE_INDEX      7
`define ONEHOT_ITYPE_ALU_INDEX  8
`define ONEHOT_RTYPE_ALU_INDEX  9
`define ONEHOT_FENCE_INDEX      10


`define PROGRAM_MEMORY_SIZE     10
`define BLOCK_MEMORY_SIZE       10
