module processor #(
    parameter INITIAL_DELAY = 0,
    parameter PROGRAM_PATH = "program/program.hex",
    parameter DATA_PATH = "program/data.hex"
) (
    input wire clk,

    output wire error,
    output wire opcode_decoding_error,
    output wire [31: 0] instruction,
    output wire [31: 0] program_counter,
    output wire [10: 0] opcode_selection,
    output wire [10: 0] instruction_errors,
    output wire [7: 0] output_io
);

reg in_initial_warmup = 1;
wire clk_with_stalls;

reg [31: 0] if_program_counter;
wire [31: 0] id_instruction;
wire [31: 0] id_pc_of_current_instruction;
program_memory #(.PROGRAM_PATH(PROGRAM_PATH)) if_program_memory_instance (
    .clk(clk_with_stalls),
    .address(if_program_counter),

    .instruction(id_instruction),
    .instruction_address(id_pc_of_current_instruction)
);

/* Begin: instruction decode stage */
wire id_opcode_decoding_error;
wire [4: 0] id_source_reg_1;
wire [4: 0] id_source_reg_2;
wire [4: 0] id_destination_reg;
wire [2: 0] id_subfunction_3;
wire [6: 0] id_subfunction_7;
wire [31: 0] id_immediate;
wire [10: 0] id_opcode_selection;

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

wire [31: 0] ex_source_reg_1_contents;
wire [31: 0] ex_source_reg_2_contents;

// These are driven by the wb pipeline stage
reg rd_write_enabled;
reg [4: 0] rd_index;
reg [31: 0] rd_write_value;

registers id_to_ex_registers_instance (
    .clk(clk_with_stalls),
    .read_index_1(id_source_reg_1),
    .read_index_2(id_source_reg_2),

    .write_enabled(rd_write_enabled),
    .write_index(rd_index),
    .write_value(rd_write_value),

    .read1_value(ex_source_reg_1_contents),
    .read2_value(ex_source_reg_2_contents)
);
/* End: instruction decode stage */

wire [31: 0] ex_pc_of_current_instruction;
wire [4: 0] ex_destination_reg;
wire [2: 0] ex_subfunction_3;
wire [6: 0] ex_subfunction_7;
wire [31: 0] ex_immediate;
wire [10: 0] ex_opcode_selection;

id_to_ex_pipeline id_to_ex_pipeline_instance (
    .clk(clk),
    .id_pc_of_current_instruction(id_pc_of_current_instruction),
    .id_destination_reg(id_destination_reg),
    .id_subfunction_3(id_subfunction_3),
    .id_subfunction_7(id_subfunction_7),
    .id_immediate(id_immediate),
    .id_opcode_selection(id_opcode_selection),

    .ex_pc_of_current_instruction(ex_pc_of_current_instruction),
    .ex_destination_reg(ex_destination_reg),
    .ex_subfunction_3(ex_subfunction_3),
    .ex_subfunction_7(ex_subfunction_7),
    .ex_immediate(ex_immediate),
    .ex_opcode_selection(ex_opcode_selection)
);


/* Begin: execute stage */
wire [10: 0] ex_errors;

wire [31: 0] wb_lui_write_to_rd;
lui ex_lui_instance (
    .clk(clk_with_stalls),
    .immediate(ex_immediate),

    .error(ex_errors[`ONEHOT_LUI_INDEX]),
    .result_to_write_rd(wb_lui_write_to_rd)
);

wire [31: 0] wb_auipc_write_to_rd;
auipc ex_auipc_instance (
    .clk(clk_with_stalls),
    .program_counter_of_lui(ex_pc_of_current_instruction),
    .immediate(ex_immediate),

    .error(ex_errors[`ONEHOT_AUIPI_INDEX]),
    .result_to_write_rd(wb_auipc_write_to_rd)
);

wire [31: 0] wb_jal_write_to_rd;
wire [31: 0] wb_jal_write_to_pc;
jal ex_jal_instance (
    .clk(clk_with_stalls),
    .program_counter_of_JAL(ex_pc_of_current_instruction),
    .immediate(ex_immediate),

    .error(ex_errors[`ONEHOT_JAL_INDEX]),
    .result_to_write_rd(wb_jal_write_to_rd),
    .result_to_write_to_pc(wb_jal_write_to_pc)
);

wire [31: 0] wb_jalr_write_to_rd;
wire [31: 0] wb_jalr_write_to_pc;
jalr ex_jalr_instance (
    .clk(clk_with_stalls),
    .program_counter_of_JALR(ex_pc_of_current_instruction),
    .subfunction_3(ex_subfunction_3),
    .input_register1_value(ex_source_reg_1_contents),
    .immediate(ex_immediate),

    .error(ex_errors[`ONEHOT_JALR_INDEX]),
    .result_to_write_rd(wb_jalr_write_to_rd),
    .result_to_write_to_pc(wb_jalr_write_to_pc)
);

wire [31: 0] wb_branches_write_to_pc;
branches ex_branches_instance (
    .clk(clk_with_stalls),
    .program_counter_of_branch(ex_pc_of_current_instruction),
    .subfunction_3(ex_subfunction_3),
    .immediate(ex_immediate),
    .input_register1_value(ex_source_reg_1_contents),
    .input_register2_value(ex_source_reg_2_contents),

    .error(ex_errors[`ONEHOT_BRANCH_INDEX]),
    .result_to_write_to_pc(wb_branches_write_to_pc)
);

wire [31: 0] wb_rtype_alu_write_rd;
alu_register_type ex_alu_register_type_instance (
    .clk(clk_with_stalls),
    .subfunction_3(ex_subfunction_3),
    .subfunction_7(ex_subfunction_7),
    .input_register1_value(ex_source_reg_1_contents),
    .input_register2_value(ex_source_reg_2_contents),

    .error(ex_errors[`ONEHOT_RTYPE_ALU_INDEX]),
    .result_to_write_rd(wb_rtype_alu_write_rd)
);

wire [31: 0] wb_itype_alu_write_rd;
alu_immediate_type ex_alu_immediate_type_instance (
    .clk(clk_with_stalls),
    .subfunction_3(ex_subfunction_3),
    .input_register_value(ex_source_reg_1_contents),
    .immediate(ex_immediate),

    .error(ex_errors[`ONEHOT_ITYPE_ALU_INDEX]),
    .result_to_write_rd(wb_itype_alu_write_rd)
);

fence ex_fence_instance (
    .clk(clk),

    .error(ex_errors[`ONEHOT_FENCE_INDEX])
);

debug ex_debug_instance (
    .clk(clk),

    .error(ex_errors[`ONEHOT_DEBUG_INDEX])
);

wire request_clock_stall;
wire [31: 0] wb_memory_read_write_to_rd;
memory_instruction #(.DATA_PATH(DATA_PATH)) ex_memory_instruction_instance (
    .clk(clk),
    .subfunction_3(ex_subfunction_3),
    .input_register1_value(ex_source_reg_1_contents),
    .input_register2_value(ex_source_reg_2_contents),
    .immediate(ex_immediate),
    .opcode_is_store(ex_opcode_selection[`ONEHOT_STORE_INDEX]),
    .opcode_is_load(ex_opcode_selection[`ONEHOT_LOAD_INDEX]),

    .clk_stall(request_clock_stall),
    .load_error(ex_errors[`ONEHOT_LOAD_INDEX]),
    .store_error(ex_errors[`ONEHOT_STORE_INDEX]),
    .result_to_write_rd(wb_memory_read_write_to_rd),
    .memory_mapped_io(output_io)
);

wire [31: 0] wb_program_counter_without_jump;
program_counter program_counter_instance (
    .clk(clk_with_stalls),
    .current_program_counter(ex_pc_of_current_instruction),

    .new_program_counter(wb_program_counter_without_jump)
);
/* End: execute stage */

wire [4: 0] wb_rd_index;
wire [10: 0] wb_opcode_selection;
ex_to_wb_pipeline ex_to_wb_pipeline_instance (
    .clk(clk_with_stalls),
    .ex_opcode_selection(ex_opcode_selection),
    .ex_rd_index(ex_destination_reg),

    .wb_opcode_selection(wb_opcode_selection),
    .wb_rd_index(wb_rd_index)
);


/* Begin register write stage */
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
/* End register write stage */


assign clk_with_stalls = clk && (!request_clock_stall) && (!error) && (!in_initial_warmup);
reg [1: 0] current_pipeline_stage;

// Debugging and error propagation
assign program_counter = if_program_counter;
assign opcode_selection = ex_opcode_selection;
assign instruction_errors = ex_errors;
assign opcode_decoding_error = id_opcode_decoding_error;
assign instruction = id_instruction;
error_propagation error_propagation_instance (
    .clk(clk),
    .id_opcode_decoding_error(id_opcode_decoding_error),
    .ex_errors(ex_errors),
    .ex_opcode_selection(ex_opcode_selection),
    .current_pipeline_stage(current_pipeline_stage),

    .error(error)
);


always @(posedge clk_with_stalls) begin
    case (current_pipeline_stage)
    2'd0: current_pipeline_stage <= 2'd1;  // IF
    2'd1: current_pipeline_stage <= 2'd2;  // ID
    2'd2: current_pipeline_stage <= 2'd3;  // EX
    2'd3: current_pipeline_stage <= 2'd0;  // WB
    endcase

    if (current_pipeline_stage == 2'd3) begin
        if_program_counter <= new_program_counter;
        rd_write_value <= wb_rd_write_value;
        rd_write_enabled <= wb_rd_write_enabled;
        rd_index <= wb_rd_index;
    end else begin
        rd_write_enabled <= 0;
    end
end

// Disable the processor for the first INITIAL_DELAY clockcycles
integer clock_cycles_since_start = 0;
always @(posedge clk) begin
    clock_cycles_since_start <= clock_cycles_since_start + 1;
    if (clock_cycles_since_start == INITIAL_DELAY) begin
        in_initial_warmup <= 1'b0;
    end
end

initial begin
    current_pipeline_stage = 0;
    rd_write_enabled = 0;
    if_program_counter = 0;
end
endmodule
