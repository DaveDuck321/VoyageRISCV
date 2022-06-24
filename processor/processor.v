module processor(
    input wire clk,
    output wire [7: 0] output_io
);

wire clk_with_stalls;

reg [31: 0] if_program_counter;
wire [31: 0] id_instruction;
wire [31: 0] id_pc_of_current_instruction;
program_memory if_program_memory_instance (
    .clk(clk_with_stalls),
    .address(if_program_counter),

    .instruction(id_instruction),
    .instruction_address(id_pc_of_current_instruction)
);


/* Begin: instruction decoding */
wire id_opcode_decoding_error;
wire [4: 0] id_source_reg_1;
wire [4: 0] id_source_reg_2;
wire [4: 0] id_destination_reg;
wire [2: 0] id_subfunction_3;
wire [6: 0] id_subfunction_7;
wire [31: 0] id_immediate;
wire [10: 0] id_opcode_selection;
wire [10: 0] wb_decoding_errors;

// NOTE: these are not pipelined into latches
instruction_decode id_instruction_decode_instance (
    .instruction(id_instruction),

    .decoding_error(id_opcode_decoding_error),

    .opcode_selection(id_opcode_selection),
    .source_reg_1(id_source_reg_1),
    .source_reg_2(id_source_reg_2),
    .destination_reg(id_destination_reg),
    .subfunction_3(id_subfunction_3),
    .subfunction_7(id_subfunction_7),
    .immediate(id_immediate)
);

wire [31: 0] id_source_reg_1_contents;
wire [31: 0] id_source_reg_2_contents;

// These are filled in the wb pipeline stage
reg rd_write_enabled;
reg [4: 0] rd_index;
reg [31: 0] rd_write_value;

registers id_wb_registers_instance (
    .clk(clk_with_stalls),
    .read_index_1(id_source_reg_1),
    .read_index_2(id_source_reg_2),

    .write_enabled(rd_write_enabled),
    .write_index(rd_index),
    .write_value(rd_write_value),

    .read1_value(id_source_reg_1_contents),
    .read2_value(id_source_reg_2_contents)
);

/* End: instruction decoding */

// TODO: it makes sense to add a pipeline stage here IMO
//  Note: if this is pipelined we could actucally select the correct type intermediate
//    For now lets ignore it and see what happens to the critical path

/* Begin: instructions */
wire [31: 0] wb_lui_write_to_rd;
lui ex_lui_instance (
    .clk(clk_with_stalls),
    .immediate(id_immediate),

    .result_to_write_rd(wb_lui_write_to_rd)
);

wire [31: 0] wb_auipc_write_to_rd;
auipc ex_auipc_instance (
    .clk(clk_with_stalls),
    .program_counter_of_lui(id_pc_of_current_instruction),
    .immediate(id_immediate),

    .result_to_write_rd(wb_auipc_write_to_rd)
);

wire [31: 0] wb_jal_write_to_rd;
wire [31: 0] wb_jal_write_to_pc;
jal ex_jal_instance (
    .clk(clk_with_stalls),
    .program_counter_of_JAL(id_pc_of_current_instruction),
    .immediate(id_immediate),

    .result_to_write_rd(wb_jal_write_to_rd),
    .result_to_write_to_pc(wb_jal_write_to_pc)
);

wire [31: 0] wb_jalr_write_to_rd;
wire [31: 0] wb_jalr_write_to_pc;
jalr ex_jalr_instance (
    .clk(clk_with_stalls),
    .program_counter_of_JALR(id_pc_of_current_instruction),
    .subfunction_3(id_subfunction_3),
    .input_register1_value(id_source_reg_1_contents),
    .immediate(id_immediate),

    .decoding_error(wb_decoding_errors[`ONEHOT_JALR_INDEX]),
    .result_to_write_rd(wb_jalr_write_to_rd),
    .result_to_write_to_pc(wb_jalr_write_to_pc)
);

wire [31: 0] wb_branches_write_to_pc;
branches branches_instance (
    .clk(clk_with_stalls),
    .program_counter_of_branch(id_pc_of_current_instruction),
    .subfunction_3(id_subfunction_3),
    .immediate(id_immediate),
    .input_register1_value(id_source_reg_1_contents),
    .input_register2_value(id_source_reg_2_contents),

    .decoding_error(wb_decoding_errors[`ONEHOT_JALR_INDEX]),
    .result_to_write_to_pc(wb_branches_write_to_pc)
);

wire [31: 0] wb_rtype_alu_write_rd;
alu_register_type alu_register_type_instance (
    .clk(clk_with_stalls),
    .subfunction_3(id_subfunction_3),
    .subfunction_7(id_subfunction_7),
    .input_register1_value(id_source_reg_1_contents),
    .input_register2_value(id_source_reg_2_contents),

    .decoding_error(wb_decoding_errors[`ONEHOT_RTYPE_ALU_INDEX]),
    .result_to_write_rd(wb_rtype_alu_write_rd)
);

wire [31: 0] wb_itype_alu_write_rd;
alu_immediate_type alu_immediate_type_instance (
    .clk(clk_with_stalls),
    .subfunction_3(id_subfunction_3),
    .input_register_value(id_source_reg_1_contents),
    .immediate(id_immediate),

    .decoding_error(wb_decoding_errors[`ONEHOT_ITYPE_ALU_INDEX]),
    .result_to_write_rd(wb_itype_alu_write_rd)
);

wire request_clock_stall;
wire wb_memory_decoding_error;
wire [31: 0] wb_memory_read_write_to_rd;
memory memory_instance (
    .clk(clk),
    .subfunction_3(id_subfunction_3),
    .input_register1_value(id_source_reg_1_contents),
    .input_register2_value(id_source_reg_2_contents),
    .immediate(id_immediate),
    .request_write(id_opcode_selection[`ONEHOT_STORE_INDEX]),
    .request_read(id_opcode_selection[`ONEHOT_LOAD_INDEX]),

    .clk_stall(request_clock_stall),
    .decoding_error(wb_memory_decoding_error),
    .result_to_write_rd(wb_memory_read_write_to_rd),
    .memory_mapped_io(output_io)
);

assign clk_with_stalls = clk && (!request_clock_stall);

/* End: instructions */

wire [31: 0] wb_program_counter_without_jump;
program_counter program_counter_instance (
    .clk(clk_with_stalls),
    .current_program_counter(id_pc_of_current_instruction),

    .new_program_counter(wb_program_counter_without_jump)
);

wire [4: 0] wb_rd_index;
wire [10: 0] wb_opcode_selection;
ex_to_wb_pipeline ex_to_wb_pipeline_instance (
    .clk(clk_with_stalls),
    .ex_opcode_selection(id_opcode_selection),
    .ex_rd_index(id_destination_reg),

    .wb_opcode_selection(wb_opcode_selection),
    .wb_rd_index(wb_rd_index)
);

wire wb_rd_write_enabled;
wire [31: 0] wb_rd_write_value;
rd_mux wb_rd_mux_instance (
    .opcode_selection(wb_opcode_selection),

    .lui_write(wb_lui_write_to_rd),
    .auipc_write(wb_auipc_write_to_rd),
    .jal_write(wb_jal_write_to_rd),
    .jalr_write(wb_jalr_write_to_rd),
    .load_write(wb_memory_read_write_to_rd),
    .itype_alu_write(wb_itype_alu_write_rd),
    .rtype_alu_write(wb_rtype_alu_write_rd),

    .write_enabled(wb_rd_write_enabled),
    .write_value(wb_rd_write_value)
);

wire [31: 0] new_program_counter;
pc_mux wb_pc_mux_instance (
    .opcode_selection(wb_opcode_selection), 

    .jal_pc_write(wb_jal_write_to_pc),
    .jalr_pc_write(wb_jalr_write_to_pc),
    .branching_pc_write(wb_branches_write_to_pc),
    .default_pc_write(wb_program_counter_without_jump),

    .new_pc(new_program_counter)
);

integer current_pipeline_stage;
always @(posedge clk_with_stalls) begin
    case (current_pipeline_stage)
    0: current_pipeline_stage <= 1;
    1: current_pipeline_stage <= 2;
    2: current_pipeline_stage <= 3;
    3: current_pipeline_stage <= 0;
    endcase

    if (current_pipeline_stage == 3) begin
        if_program_counter <= new_program_counter;
        rd_write_value <= wb_rd_write_value;
        rd_write_enabled <= wb_rd_write_enabled;
        rd_index <= wb_rd_index;
    end else begin
        rd_write_enabled <= 0;
    end
end

initial begin
    current_pipeline_stage = 0;
    if_program_counter = 0;
end

endmodule
