`include "define.vh"

module alu_immediate_type (
    input wire clk,
    input wire [6: 0] opcode,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] input_register_value,
    input wire [31: 0] itype_immediate,

    output reg decoding_error,
    output reg alu_active,
    output reg [31: 0] result_to_write_rd
);

wire [31: 0] addition_result;
wire [31: 0] bitwise_and_result;
wire [31: 0] bitwise_or_result;
wire [31: 0] bitwise_xor_result;

assign addition_result = itype_immediate + input_register_value;
assign bitwise_and_result = itype_immediate & input_register_value;
assign bitwise_or_result = itype_immediate | input_register_value;
assign bitwise_xor_result = itype_immediate ^ input_register_value;


wire signed_compare;
wire unsigned_compare;
assign signed_compare = $signed(input_register_value) < $signed(itype_immediate);
assign unsigned_compare = $unsigned(input_register_value) < $unsigned(itype_immediate);

wire [31: 0] slt_result;
wire [31: 0] sltu_result;
assign slt_result = {31'b0, signed_compare};
assign sltu_result = {31'b0, unsigned_compare};


wire [4: 0] shift_amount;
wire [6: 0] shift_type_indicator;

assign shift_amount = itype_immediate[4: 0];
assign shift_type_indicator = itype_immediate[11: 5];

wire [31: 0] left_shift_result;
wire [31: 0] logical_right_shift_result;
wire [31: 0] arithmetic_right_shift_result;

assign left_shift_result = input_register_value << shift_amount;
assign logical_right_shift_result = input_register_value >> shift_amount;
assign arithmetic_right_shift_result = input_register_value >>> shift_amount;


wire enabled;
assign enabled = (opcode == `SOME_ALU_OPCODE_ITYPE);

initial begin
    alu_active = 0;
    decoding_error = 0;
end

always @(posedge clk) begin
    alu_active <= enabled;

    if (enabled) begin
        // TODO: I don't like the nested conditons
        case (subfunction_3)
        `ADD_SUBFUNC3:      result_to_write_rd <= addition_result;
        `SLT_SUBFUNC3:      result_to_write_rd <= slt_result;
        `SLTU_SUBFUNC3:     result_to_write_rd <= sltu_result;
        `XOR_SUBFUNC3:      result_to_write_rd <= bitwise_xor_result;
        `OR_SUBFUN3:        result_to_write_rd <= bitwise_or_result;
        `AND_SUBFUN3:       result_to_write_rd <= bitwise_and_result;
        `SLL_SUBFUNC3:      result_to_write_rd <= left_shift_result;
        `SRL_SUBFUNC3: begin
            // TODO: try putting this in the sequential logic
            case (shift_type_indicator)
            `SIGNED_MODE_IMMEDIATE_INDICATOR: result_to_write_rd <= arithmetic_right_shift_result;
            `UNSIGNED_MODE_IMMEDIATE_INDICATOR: result_to_write_rd <= logical_right_shift_result;
            default: decoding_error <= 1;
            endcase
        end
        default: decoding_error <= 1;
        endcase
    end
end

endmodule
