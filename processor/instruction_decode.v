`include "define.vh"

module instruction_decode (
    input wire [31: 0] instruction,

    output reg  decoding_error,

    output reg [10: 0] opcode_selection, // NOTE: This is still combinatorial and unclocked
    output wire [4: 0] source_reg_1,
    output wire [4: 0] source_reg_2,
    output wire [4: 0] destination_reg,
    output wire [2: 0] subfunction_3,
    output wire [6: 0] subfunction_7,
    output reg [31: 0] immediate
);
wire [6: 0] opcode;

wire [31: 0] itype_immediate;
wire [31: 0] stype_immediate;
wire [31: 0] btype_immediate;
wire [31: 0] utype_immediate;
wire [31: 0] jtype_immediate;

split_instruction_into_components instruction_parts (
    .instruction(instruction),
    .opcode(opcode),
    .source_reg_1(source_reg_1),
    .source_reg_2(source_reg_2),
    .destination_reg(destination_reg),
    .subfunction_3(subfunction_3),
    .subfunction_7(subfunction_7),
    .itype_immediate(itype_immediate),
    .stype_immediate(stype_immediate),
    .btype_immediate(btype_immediate),
    .utype_immediate(utype_immediate),
    .jtype_immediate(jtype_immediate)
);

always @(*) begin
    case(opcode) // Ugly case, maybe this can be split up
    `LUI_OPCODE: begin
        immediate = utype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_LUI_INDEX);
    end
    `AUIPC_OPCODE: begin
        immediate = utype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_AUIPI_INDEX);
    end
    `JAL_OPCODE: begin
        immediate = jtype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_JAL_INDEX);
    end
    `JALR_OPCODE: begin
        immediate = itype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_JALR_INDEX);
    end
    `SOME_BRANCH_OPCODE: begin
        immediate = btype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_BRANCH_INDEX);
    end
    `SOME_LOAD_OPCODE: begin
        immediate = itype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_LOAD_INDEX);
    end
    `SOME_STORE_OPCODE: begin
        immediate = stype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_STORE_INDEX);
    end
    `SOME_ALU_OPCODE_ITYPE: begin
        immediate = itype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_ITYPE_ALU_INDEX);
    end
    `SOME_ALU_OPCODE_RTYPE: begin
        immediate = {32{1'bX}};
        opcode_selection = (11'b1 << `ONEHOT_RTYPE_ALU_INDEX);
    end
    `FENCE_OPCODE: begin
        immediate = itype_immediate;
        opcode_selection = (11'b1 << `ONEHOT_FENCE_INDEX);
    end
    `DEBUG_OPCODE: begin
        immediate = itype_immediate; // TODO: is this right?
        opcode_selection = (11'b1 << `ONEHOT_DEBUG_OPCODE);
    end
    default: begin  // Error: unsupported opcode
        immediate = {32{1'bX}};
        opcode_selection = 11'b0;
    end
    endcase

    decoding_error = ^(|opcode_selection);
end

endmodule

module split_instruction_into_components (
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
assign subfunction_3 = instruction[14: 12];
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
