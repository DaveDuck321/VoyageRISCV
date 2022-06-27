module error_propagation(
    input wire clk,
    input wire id_opcode_decoding_error,
    input wire [10: 0] ex_errors,
    input wire [10: 0] ex_opcode_selection,
    input wire [1: 0] current_pipeline_stage,

    output reg error = 0
);


wire multiple_selected_opcodes = | ((ex_opcode_selection - 1) & ex_opcode_selection);
wire execute_error = | (ex_errors & ex_opcode_selection);

always @(posedge clk) begin
    case (current_pipeline_stage)
    2'd2: begin
        if (id_opcode_decoding_error)   error <= 1;
    end
    2'd3: begin
        if (multiple_selected_opcodes)  error <= 1;
        if (execute_error)              error <= 1;
    end
    default: ;
    endcase
end


endmodule
