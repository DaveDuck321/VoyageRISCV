module lui(
    input wire clk,
    input [31: 0] immediate,

    output wire error,
    output reg [31: 0] result_to_write_rd
);

assign error = 1'b0;

always @(posedge clk) begin
    result_to_write_rd <= immediate;
end

endmodule
