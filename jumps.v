module JALR(
    input wire clk,
    input wire [31: 0] program_counter_of_JALR,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] immediate,

    output reg decoding_error,
    output reg [31: 0] result_to_write_rd,
    output reg [31: 0] result_to_write_to_pc
);

initial begin
    decoding_error = 0;
end

wire [31: 0] instruction_after_jalr;
assign instruction_after_jalr = (program_counter_of_JALR + 4);

wire [31: 0] target_jump_address;
assign target_jump_address = (immediate + input_register1_value) & (~32'b1);

always @(posedge clk) begin
    if (subfunction_3 != 3'b000) decoding_error <= 1;

    result_to_write_rd <= instruction_after_jalr;
    result_to_write_to_pc <= target_jump_address;
end

endmodule



module JAL(
    input wire clk,
    input wire [31: 0] program_counter_of_JAL,
    input wire [31: 0] immediate,

    output reg [31: 0] result_to_write_rd,
    output reg [31: 0] result_to_write_to_pc
);

wire [31: 0] instruction_after_jal;
assign instruction_after_jal = (program_counter_of_JAL + 4);

wire [31: 0] target_jump_address;
assign target_jump_address = (immediate + program_counter_of_JAL);

always @(posedge clk) begin
    result_to_write_rd <= instruction_after_jal;
    result_to_write_to_pc <= target_jump_address;
end

endmodule
