module lui(
    input wire clk,
    input [31: 0] immediate,

    output reg [31: 0] result_to_write_rd
);

always @(posedge clk) begin
    result_to_write_rd <= immediate;
end

endmodule
