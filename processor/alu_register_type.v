`include "define.vh"

module alu_register_type (
    input wire clk,
    input wire [2: 0] subfunction_3,
    input wire [6: 0] subfunction_7,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] input_register2_value,

    output reg error,
    output reg [31: 0] result_to_write_rd
);

wire [31: 0] addition_result;
wire [31: 0] subtraction_result;
wire [31: 0] bitwise_and_result;
wire [31: 0] bitwise_or_result;
wire [31: 0] bitwise_xor_result;

assign addition_result = input_register2_value + input_register1_value;
assign subtraction_result = input_register2_value - input_register1_value;
assign bitwise_and_result = input_register2_value & input_register1_value;
assign bitwise_or_result = input_register2_value | input_register1_value;
assign bitwise_xor_result = input_register2_value ^ input_register1_value;


wire signed_compare;
wire unsigned_compare;
assign signed_compare = $signed(input_register1_value) < $signed(input_register2_value);
assign unsigned_compare = $unsigned(input_register1_value) < $unsigned(input_register2_value);

wire [31: 0] slt_result;
wire [31: 0] sltu_result;
assign slt_result = {31'b0, signed_compare};
assign sltu_result = {31'b0, unsigned_compare};


wire [4: 0] shift_amount;
assign shift_amount = input_register2_value[4: 0];

wire [31: 0] left_shift_result;
wire [31: 0] logical_right_shift_result;
wire [31: 0] arithmetic_right_shift_result;

assign left_shift_result = input_register1_value << shift_amount;
assign logical_right_shift_result = input_register1_value >> shift_amount;
assign arithmetic_right_shift_result = input_register1_value >>> shift_amount;


always @(*) begin
    case (subfunction_7)
    `SIGNED_MODE_IMMEDIATE_INDICATOR: begin
        case(subfunction_3)
        `ADD_SUBFUNC3,
        `SRL_SUBFUNC3:  error = 0;
        default:        error = 1;
        endcase
    end
    `UNSIGNED_MODE_IMMEDIATE_INDICATOR: begin
        case(subfunction_3)
        `ADD_SUBFUNC3,
        `SLL_SUBFUNC3,
        `SLT_SUBFUNC3,
        `SLTU_SUBFUNC3,
        `XOR_SUBFUNC3,
        `SRL_SUBFUNC3,
        `OR_SUBFUN3,
        `AND_SUBFUN3:   error = 0;
        default:        error = 1;
        endcase
    end
    default:            error = 1;
    endcase
end


always @(posedge clk) begin
    case (subfunction_3)
    `ADD_SUBFUNC3: begin
        case (subfunction_7)
        `SIGNED_MODE_IMMEDIATE_INDICATOR:   result_to_write_rd <= addition_result;
        `UNSIGNED_MODE_IMMEDIATE_INDICATOR: result_to_write_rd <= subtraction_result;
        default: result_to_write_rd <= {32{1'bX}};
        endcase
    end
    `SLT_SUBFUNC3:  result_to_write_rd <= slt_result;
    `SLTU_SUBFUNC3: result_to_write_rd <= sltu_result;
    `XOR_SUBFUNC3:  result_to_write_rd <= bitwise_xor_result;
    `OR_SUBFUN3:    result_to_write_rd <= bitwise_or_result;
    `AND_SUBFUN3:   result_to_write_rd <= bitwise_and_result;
    `SLL_SUBFUNC3:  result_to_write_rd <= left_shift_result;
    `SRL_SUBFUNC3: begin  // TODO: try putting this in the sequential logic
        case (subfunction_7)
        `SIGNED_MODE_IMMEDIATE_INDICATOR:   result_to_write_rd <= arithmetic_right_shift_result;
        `UNSIGNED_MODE_IMMEDIATE_INDICATOR: result_to_write_rd <= logical_right_shift_result;
        default: result_to_write_rd <= {32{1'bX}};
        endcase
    end
    default: result_to_write_rd <= {32{1'bX}};
    endcase
end

endmodule
