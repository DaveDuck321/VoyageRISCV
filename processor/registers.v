module registers(
    input wire clk,
    input wire [4: 0] read_index_1,
    input wire [4: 0] read_index_2,

    input wire write_enabled,
    input wire [4: 0] write_index,
    input wire [31: 0] write_value,

    output reg [31: 0] read1_value,
    output reg [31: 0] read2_value
);

reg [31: 0] register_bank[2**5 - 1 : 0];

always @(posedge clk) begin
    // Avoid writing to the 'zero' register
    if (write_enabled && write_index != 5'b0) register_bank[write_index] <= write_value;

    read1_value <= register_bank[read_index_1];
    read2_value <= register_bank[read_index_2];
end


// Initialize register_bank with zeroes
integer index;
initial begin
    for (index = 0; index < 32; index = index + 1)
        register_bank[index] = 0;
end

endmodule
