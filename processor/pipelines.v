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


module id_to_ex_pipeline(
    input wire clk,
    input wire [31: 0] id_pc_of_current_instruction,
    input wire [4: 0] id_destination_reg,
    input wire [2: 0] id_subfunction_3,
    input wire [6: 0] id_subfunction_7,
    input wire [31: 0] id_immediate,
    input wire [10: 0] id_opcode_selection,

    output reg [31: 0] ex_pc_of_current_instruction,
    output reg [4: 0] ex_destination_reg,
    output reg [2: 0] ex_subfunction_3,
    output reg [6: 0] ex_subfunction_7,
    output reg [31: 0] ex_immediate,
    output reg [10: 0] ex_opcode_selection
);

always @(posedge clk) begin
    ex_pc_of_current_instruction <= id_pc_of_current_instruction;
    ex_destination_reg <= id_destination_reg;
    ex_subfunction_3 <= id_subfunction_3;
    ex_subfunction_7 <= id_subfunction_7;
    ex_immediate <= id_immediate;
    ex_opcode_selection <= id_opcode_selection;
end
endmodule
