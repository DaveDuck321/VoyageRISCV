`include "define.vh"

module branches(
    input wire clk,
    input wire [31: 0] program_counter_of_branch,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] immediate,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] input_register2_value,

    output reg decoding_error,
    output reg [31: 0] result_to_write_to_pc
);

initial begin
    decoding_error = 0;
end

wire [31: 0] pc_after_taking_branch;
wire [31: 0] pc_without_taking_branch;  // TODO: this is duplicated: remove later

assign pc_after_taking_branch = (program_counter_of_branch + immediate);
assign pc_without_taking_branch = (program_counter_of_branch + 4);

wire are_equal;
wire is_less_than_signed;
wire is_less_than_unsigned;
wire is_gte_signed;
wire is_gte_unsigned;

assign are_equal = (input_register1_value == input_register2_value);
assign is_less_than_signed = ($signed(input_register1_value) < $signed(input_register2_value));
assign is_less_than_unsigned = ($unsigned(input_register1_value) < $unsigned(input_register2_value));
assign is_gte_signed = ($signed(input_register1_value) >= $signed(input_register2_value));
assign is_gte_unsigned = ($unsigned(input_register1_value) >= $unsigned(input_register2_value));

always @(posedge clk) begin
    case(subfunction_3)
    `BEQ_SUBFUNC3:  result_to_write_to_pc <= (are_equal             ? pc_after_taking_branch : pc_without_taking_branch);
    `BNE_SUBFUNC3:  result_to_write_to_pc <= ((!are_equal)          ? pc_after_taking_branch : pc_without_taking_branch);
    `BLT_SUBFUNC3:  result_to_write_to_pc <= (is_less_than_signed   ? pc_after_taking_branch : pc_without_taking_branch);
    `BGT_SUBFUNC3:  result_to_write_to_pc <= (is_gte_signed         ? pc_after_taking_branch : pc_without_taking_branch);
    `BLTU_SUBFUNC3: result_to_write_to_pc <= (is_less_than_unsigned ? pc_after_taking_branch : pc_without_taking_branch);
    `BGEU_SUBFUNC3: result_to_write_to_pc <= (is_gte_unsigned       ? pc_after_taking_branch : pc_without_taking_branch);
    default: decoding_error <= 1;
    endcase
end

endmodule
