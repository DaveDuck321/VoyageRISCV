`include "define.vh"

module instruction_decode (
    input wire [31: 0] instruction,

    output wire [6: 0] opcode,
    output wire [4: 0] source_reg_1,
    output wire [4: 0] source_reg_2,
    output wire [4: 0] destination_reg,
    output wire [2: 0] subfunction_3,
    output wire [6: 0] subfunction_7,
    output wire [31: 0] itype_immediate,
    output wire [31: 0] stype_immediate,
    output wire [31: 0] btype_immediate,
    output wire [31: 0] utype_immediate,
    output wire [31: 0] jtype_immediate
);

assign opcode = instruction[6: 0];
assign source_reg_1 = instruction[19: 15];
assign source_reg_2 = instruction[24: 20];
assign destination_reg = instruction[11: 7];
assign subfunction_3 = instruction[11: 7];
assign subfunction_7 = instruction[31: 25];

wire[31: 0] sign_extension;
assign sign_extension = {32{instruction[31]}};

decode_itype_immediate decode_itype_immediate_instance (
    .instruction(instruction),
    .sign_extension(sign_extension),
    .immediate(itype_immediate)
);
decode_stype_immediate decode_stype_immediate_instance (
    .instruction(instruction),
    .sign_extension(sign_extension),
    .immediate(stype_immediate)
);
decode_btype_immediate decode_btype_immediate_instance (
    .instruction(instruction),
    .sign_extension(sign_extension),
    .immediate(btype_immediate)
);
decode_utype_immediate decode_utype_immediate_instance (
    .instruction(instruction),
    .sign_extension(sign_extension),
    .immediate(utype_immediate)
);
decode_jtype_immediate decode_jtype_immediate_instance (
    .instruction(instruction),
    .sign_extension(sign_extension),
    .immediate(jtype_immediate)
);
endmodule




module decode_itype_immediate (
    input wire [31: 0] instruction,
    input wire [31: 0] sign_extension,
    output wire [31: 0] immediate
);

// | imm[11:0] | rs1  | funct3 | rd | opcode |
assign immediate = {sign_extension[31: 12], instruction[31:20]};

endmodule


module decode_stype_immediate (
    input wire [31: 0] instruction,
    input wire [31: 0] sign_extension,
    output wire [31: 0] immediate
);

// | imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode | 
assign immediate = {sign_extension[31: 12], instruction[31: 25], instruction[11: 7]};

endmodule


module decode_btype_immediate (
    input wire [31: 0] instruction,
    input wire [31: 0] sign_extension,
    output wire [31: 0] immediate
);

// | imm[12|10:5] | rs2 | rs1 | funct3 | imm[4:1|11] | opcode | 
assign immediate = {instruction[31: 13], instruction[31], instruction[7], instruction[30: 25], instruction[11: 8], 1'b0};

endmodule


module decode_utype_immediate (
    input wire [31: 0] instruction,
    input wire [31: 0] sign_extension,
    output wire [31: 0] immediate
);

// | imm[31:12] | rd | opcode | 
assign immediate = {instruction[31: 12], 12'b0};

endmodule

module decode_jtype_immediate (
    input wire [31: 0] instruction,
    input wire [31: 0] sign_extension,
    output wire [31: 0] immediate
);

// | imm[20|10:1|11|19:12] | rd | opcode |
assign immediate = {sign_extension[31: 21], instruction[31], instruction[19: 12], instruction[20], instruction[30: 21], 1'b0};

endmodule
