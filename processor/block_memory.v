module block_memory #(
    parameter ADDRESS_SIZE = 10,
    parameter WORD_SIZE = 32
) (
    input wire clk,
    input wire read_enable,
    input wire write_enable,
    input wire [ADDRESS_SIZE - 1: 0] read_address,
    input wire [ADDRESS_SIZE - 1: 0] write_address,
    input wire [WORD_SIZE - 1: 0] write_data,

    output reg [WORD_SIZE - 1: 0] read_data
);

reg [WORD_SIZE - 1: 0] memory [0: 2**ADDRESS_SIZE - 1];


always @(posedge clk) begin
    if (read_enable)    read_data <= memory[read_address];
    if (write_enable)   memory[write_address] <= write_data;
end

endmodule
