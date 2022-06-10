// TODO: I'm not sure if this is a good idea:
//      the register reading is NOT clocked... but this allows single cycle instruction decoding
//      I don't think they need to go in block ram... but what about races?


module registers(
    input wire clk,
    input wire [4: 0] read_index_1,
    input wire [4: 0] read_index_2,

    input wire [4: 0] write_index,
    input wire [31: 0] write_value,

    output wire [31: 0] read1_value,
    output wire [31: 0] read2_value
);

reg [31: 0] register_bank[2**5 - 1 : 0];

assign read1_value = register_bank[read_index_1];
assign read2_value = register_bank[read_index_2];

always @(posedge clk) begin
    // Avoid writing to the 'zero' register
    if (write_index != 5'b0) register_bank[write_index] <= write_value;
end


// Initialize register_bank with zeroes
integer index;
initial begin
    for (index = 0; index < 32; index = index + 1)
        register_bank[index] = 0;
end

endmodule
