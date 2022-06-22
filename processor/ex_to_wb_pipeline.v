module ex_to_wb_pipeline(
    input wire clk,
    input wire [10: 0] ex_opcode_selection,
    input wire [4: 0] ex_rd_index,

    output reg [10: 0] wb_opcode_selection,
    output reg [4: 0] wb_rd_index
);

always @(posedge clk) begin
    wb_opcode_selection <= ex_opcode_selection;
    wb_rd_index <= ex_rd_index;
end

endmodule
