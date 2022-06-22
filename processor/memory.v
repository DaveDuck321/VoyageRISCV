`include "define.vh"

module memory(
    input wire clk,
    input wire [2: 0] subfunction_3,
    input wire [31: 0] input_register1_value,
    input wire [31: 0] input_register2_value,
    input wire [31: 0] immediate,
    input wire request_write,
    input wire request_read,

    output reg clk_stall,
    output reg decoding_error,
    output reg [31: 0] result_to_write_rd,
    output reg [7: 0] memory_mapped_io
);

reg [7: 0] block_memory [0: 2**`BLOCK_MEMORY_SIZE - 1];

wire [31: 0] full_address;
assign full_address = input_register1_value + immediate;

wire [`BLOCK_MEMORY_SIZE - 1: 0] truncated_address;
assign truncated_address = full_address[`BLOCK_MEMORY_SIZE - 1: 0];

wire [`BLOCK_MEMORY_SIZE - 1: 0] addr_1;
wire [`BLOCK_MEMORY_SIZE - 1: 0] addr_2;
wire [`BLOCK_MEMORY_SIZE - 1: 0] addr_3;
wire [`BLOCK_MEMORY_SIZE - 1: 0] addr_4;

assign addr_1 = truncated_address;
assign addr_2 = truncated_address + 4;
assign addr_3 = truncated_address + 8;
assign addr_4 = truncated_address + 12;

reg currently_reading;
reg [7: 0] byte_1;
reg [7: 0] byte_2;
reg [7: 0] byte_3;
reg [7: 0] byte_4;


wire [31: 0] load_signed_byte_result;
wire [31: 0] load_unsigned_byte_result;
wire [31: 0] load_signed_half_word_result;
wire [31: 0] load_unsigned_half_word_result;
wire [31: 0] load_word_result;

assign load_signed_byte_result = {{24{byte_1[7]}}, byte_1};
assign load_unsigned_byte_result = {24'b0, byte_1};
assign load_signed_half_word_result = {{16{byte_2[7]}}, byte_2, byte_1};
assign load_unsigned_half_word_result = {16'b0, byte_2, byte_1};
assign load_word_result = {byte_4, byte_3, byte_2, byte_1};

initial begin
    clk_stall = 0;
    $readmemh("program/data.hex", block_memory);
end

always @(posedge clk) begin
    if (currently_reading) begin
        currently_reading <= 0;
        clk_stall <= 0;
        case(subfunction_3)
        `LB_SUBFUN3:    result_to_write_rd <= load_signed_byte_result;
        `LH_SUBFUN3:    result_to_write_rd <= load_signed_half_word_result;
        `LW_SUBFUN3:    result_to_write_rd <= load_word_result;
        `LBU_SUBFUN3:   result_to_write_rd <= load_unsigned_byte_result;
        `LHU_SUBFUN3:   result_to_write_rd <= load_unsigned_half_word_result;
        default: decoding_error <= 1;
        endcase
    end else if (request_read) begin
        currently_reading <= 1;
        clk_stall <= 1;
        byte_1 <= block_memory[addr_1];
        byte_2 <= block_memory[addr_2];
        byte_3 <= block_memory[addr_3];
        byte_4 <= block_memory[addr_4];
    end else if (request_write) begin
        case(subfunction_3)
        `SB_SUBFUN3: begin
            block_memory[addr_1] <= input_register2_value[7: 0];
        end
        `SH_SUBFUN3: begin
            block_memory[addr_1] <= input_register2_value[7: 0];
            block_memory[addr_2] <= input_register2_value[15: 8];
        end
        `SW_SUBFUN3: begin
            block_memory[addr_1] <= input_register2_value[7: 0];
            block_memory[addr_2] <= input_register2_value[15: 8];
            block_memory[addr_3] <= input_register2_value[23: 16];
            block_memory[addr_4] <= input_register2_value[31: 24];
        end
        default: decoding_error <= 1;
        endcase

        if (full_address == 32'h2000) begin
            memory_mapped_io <= input_register2_value[7: 0];
        end
    end
end
endmodule


module program_memory(
    input wire clk,
    input [31: 0] address,

    output reg [31: 0] instruction,
    output reg [31: 0] instruction_address
);

reg [31: 0] block_memory [0: 2**`PROGRAM_MEMORY_SIZE - 1];

wire[`PROGRAM_MEMORY_SIZE - 1: 0] truncated_address;
assign truncated_address = address[`PROGRAM_MEMORY_SIZE + 1 : 2];

initial begin
    $readmemh("program/program.hex", block_memory);
end

always @(posedge clk) begin
    instruction <= block_memory[truncated_address];
    instruction_address <= address;
end

endmodule
