module auipc(
    input wire clk,
    input wire [31: 0] program_counter_of_lui,
    input [31: 0] immediate,

    output wire error,
    output reg [31: 0] result_to_write_rd
);

assign error = 1'b0;

wire [31: 0] auipc_result;
assign auipc_result = program_counter_of_lui + immediate;

always @(posedge clk) begin
    result_to_write_rd <= auipc_result;
end

endmodule
