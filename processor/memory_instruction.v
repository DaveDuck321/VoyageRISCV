`include "define.vh"

module memory_instruction #(
    parameter DATA_PATH = ""
) (
    input wire clk,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] input_register2_value,
    input wire [31: 0] immediate,
    input wire opcode_is_store,
    input wire opcode_is_load,

    output reg clk_stall = 0,
    output reg load_error,
    output reg store_error,
    output reg [31: 0] result_to_write_rd,
    output reg [7: 0] memory_mapped_io = 8'h00
);

reg read_in_progress = 0;
reg write_in_progress = 0;
wire read_enabled;
wire write_enabled;
wire [31: 0] read_result;
reg [31: 0] word_to_write_to_block_memory;

// Write operations require a read so that adjacent memory is not overwritten
assign read_enabled = (opcode_is_load || opcode_is_store) && !(read_in_progress || write_in_progress);
assign write_enabled = write_in_progress;

wire [31: 0] effective_address;
wire [`BLOCK_MEMORY_SIZE - 1: 0] transformed_block_address;

assign effective_address = input_register1_value + immediate - 32'h1000;
assign transformed_block_address = effective_address[`BLOCK_MEMORY_SIZE + 1: 2];

block_memory #(
    .ADDRESS_SIZE(`BLOCK_MEMORY_SIZE),
    .INITIALIZATION_LOCATION(DATA_PATH)
) block_memory_instance (
    .clk(clk),
    .read_enable(read_enabled),
    .write_enable(write_enabled),
    .read_address(transformed_block_address),
    .write_address(transformed_block_address),
    .write_data(word_to_write_to_block_memory),

    .read_data(read_result)
);

reg alignment_error;
always @(*) begin
    case (subfunction_3)
    `LB_SUBFUN3, `LBU_SUBFUN3 /*, `SB_SUBFUN3 */: alignment_error = 0;
    `LH_SUBFUN3, `LHU_SUBFUN3 /*, `SH_SUBFUN3 */: alignment_error = (effective_address[0] != 1'b0);
    `LW_SUBFUN3 /*, `SW_SUBFUN3 */: alignment_error = (effective_address[1: 0] != 2'b00);
    default: alignment_error = 1'bX;
    endcase

    case (subfunction_3)
    `SB_SUBFUN3,
    `SH_SUBFUN3,
    `SW_SUBFUN3: store_error = alignment_error;
    default:     store_error = 1'b1;  // Decode error
    endcase

    case (subfunction_3)
    `LB_SUBFUN3, `LBU_SUBFUN3,
    `LH_SUBFUN3, `LHU_SUBFUN3,
    `LW_SUBFUN3:    load_error = alignment_error;
    default:        load_error = 1'b1;  // Decode error
    endcase
end

wire [7: 0] byte_1 = read_result[7: 0];
wire [7: 0] byte_2 = read_result[15: 8];
wire [7: 0] byte_3 = read_result[23: 16];
wire [7: 0] byte_4 = read_result[31: 24];


// Loading combinatorial logic
reg [7: 0] byte_to_load;
reg [15: 0] half_word_to_load;

wire [31: 0] load_signed_byte_result        = {{24{byte_to_load[7]}}, byte_to_load};
wire [31: 0] load_unsigned_byte_result      = {24'b0, byte_to_load};
wire [31: 0] load_signed_half_word_result   = {{16{half_word_to_load[15]}}, half_word_to_load};
wire [31: 0] load_unsigned_half_word_result = {16'b0, half_word_to_load};
wire [31: 0] load_word_result               = read_result;

always @(*) begin
    case(effective_address[1: 0])
    2'b00:      byte_to_load = byte_1;
    2'b01:      byte_to_load = byte_2;
    2'b10:      byte_to_load = byte_3;
    2'b11:      byte_to_load = byte_4;
    endcase

    case(effective_address[1: 0])
    2'b00:      half_word_to_load = {byte_2, byte_1};
    2'b10:      half_word_to_load = {byte_4, byte_3};
    default:    half_word_to_load = {16{1'bX}};  // TODO: Misaligned access is currently invalid
    endcase
end


// Storing combinatorial logic
reg [31: 0] store_byte_write_data;
reg [31: 0] store_half_word_write_data;

always @(*) begin
    case(effective_address[1: 0])
    2'b00:      store_byte_write_data = {byte_4, byte_3, byte_2, input_register2_value[7: 0]};
    2'b01:      store_byte_write_data = {byte_4, byte_3, input_register2_value[7: 0], byte_1};
    2'b10:      store_byte_write_data = {byte_4, input_register2_value[7: 0], byte_2, byte_1};
    2'b11:      store_byte_write_data = {input_register2_value[7: 0], byte_3, byte_2, byte_1};
    endcase

    case(effective_address[1: 0])
    2'b00:      store_half_word_write_data = {byte_4, byte_3, input_register2_value[15: 0]};
    2'b10:      store_half_word_write_data = {input_register2_value[15: 0], byte_2, byte_1};
    default:    store_half_word_write_data = {32{1'bX}};  // TODO: Misaligned access is currently invalid
    endcase

    case (subfunction_3)
    `SB_SUBFUN3:    word_to_write_to_block_memory = store_byte_write_data;
    `SH_SUBFUN3:    word_to_write_to_block_memory = store_half_word_write_data;
    `SW_SUBFUN3:    word_to_write_to_block_memory = input_register2_value;
    default:        word_to_write_to_block_memory = {32{1'bX}};
    endcase
end


always @(posedge clk) begin
    if (read_in_progress) begin
        clk_stall <= 0;
        read_in_progress <= 0;
        case(subfunction_3)
        `LB_SUBFUN3:    result_to_write_rd <= load_signed_byte_result;
        `LH_SUBFUN3:    result_to_write_rd <= load_signed_half_word_result;
        `LW_SUBFUN3:    result_to_write_rd <= load_word_result;
        `LBU_SUBFUN3:   result_to_write_rd <= load_unsigned_byte_result;
        `LHU_SUBFUN3:   result_to_write_rd <= load_unsigned_half_word_result;
        default:        result_to_write_rd <= {32{1'bX}};
        endcase
    end else if (opcode_is_load) begin
        clk_stall <= 1;
        read_in_progress <= 1;

`ifdef SIMULATION
        if($signed(effective_address) < $signed(32'h0) || $signed(effective_address) > $signed(32'h1000)) begin
            $error("Data read '%x' out of range", input_register1_value + immediate);
            $finish(1);
        end
`endif

    end

    if (write_in_progress) begin
        clk_stall <= 0;
        write_in_progress <= 0;

`ifdef SIMULATION
        if(^effective_address === 1'bX) begin
            $error("Attempt memory write to an undefined address: '%x'", effective_address);
            $finish(1);
        end
`endif

    end else if (opcode_is_store) begin
        if (effective_address == 32'h1000) begin
            memory_mapped_io <= input_register2_value[7: 0];
        end else begin
            clk_stall <= 1;
            write_in_progress <= 1;
        end
    end
end

endmodule


module program_memory #(
    parameter PROGRAM_PATH = ""
) (
    input wire clk,
    input [31: 0] address,

    output wire [31: 0] instruction,
    output reg [31: 0] instruction_address
);

wire[`PROGRAM_MEMORY_SIZE - 1: 0] truncated_address;
assign truncated_address = address[`PROGRAM_MEMORY_SIZE + 1 : 2];

block_memory #(
    .ADDRESS_SIZE(`PROGRAM_MEMORY_SIZE),
    .INITIALIZATION_LOCATION(PROGRAM_PATH)
) block_memory_instance (
    .clk(clk),
    .read_enable(1'b1),
    .write_enable(1'b0),
    .read_address(truncated_address),
    .write_address(`PROGRAM_MEMORY_SIZE'b0),
    .write_data(32'b0),

    .read_data(instruction)
);

always @(posedge clk) begin
    instruction_address <= address;
end

endmodule
