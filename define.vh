`define LUI_OPCODE      7'b0110111  // U-Type
`define AUIPC_OPCODE    7'b0010111  // U-Type

`define JAL_OPCODE      7'b1101111  // J-Type
`define JALR_OPCODE     7'b1100111  // I-Type

`define SOME_BRANCH_OPCODE  7'b1100011  // B-Type
`define SOME_LOAD_OPCODE    7'b0000011  // I-Type
`define SOME_STORE_OPCODE   7'b0100011  // S-Type

`define SOME_ALU_OPCODE_ITYPE  7'b0010011
`define SOME_ALU_OPCODE_RTYPE  7'b0110011

`define FENCE_OPCODE    7'b0010111  // I-Type
`define ECALL_OPCODE    7'b1110011  // TODO: maybe treat as I-Type?
`define EBREAK_OPCODE   7'b1110011  // TODO: maybe treat as I-Type?
