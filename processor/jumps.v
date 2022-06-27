module jalr(
    input wire clk,
    input wire [31: 0] program_counter_of_JALR,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] immediate,

    output wire error,
    output reg [31: 0] result_to_write_rd,
    output reg [31: 0] result_to_write_to_pc
);

wire [31: 0] instruction_after_jalr;
assign instruction_after_jalr = (program_counter_of_JALR + 4);

wire [31: 0] target_jump_address;
assign target_jump_address = (immediate + input_register1_value) & (~32'b1);  // Sets LSB to 0

// Error on either invalid jump instruction or misaligned jump
assign error = (subfunction_3 != 3'b000) || (target_jump_address[1] != 1'b0);

always @(posedge clk) begin
    result_to_write_rd <= instruction_after_jalr;
    result_to_write_to_pc <= target_jump_address;
end

endmodule



module jal(
    input wire clk,
    input wire [31: 0] program_counter_of_JAL,
    input wire [31: 0] immediate,

    output wire error,
    output reg [31: 0] result_to_write_rd,
    output reg [31: 0] result_to_write_to_pc
);

wire [31: 0] instruction_after_jal;
assign instruction_after_jal = (program_counter_of_JAL + 4);

wire [31: 0] target_jump_address;
assign target_jump_address = (immediate + program_counter_of_JAL);

// Error on misaligned jump
assign error = (target_jump_address[1] != 1'b0);

always @(posedge clk) begin
    result_to_write_rd <= instruction_after_jal;
    result_to_write_to_pc <= target_jump_address;
end

endmodule
