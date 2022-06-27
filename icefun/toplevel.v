module top(
    input wire clk,

    output wire [7: 0] led_rows,
    output wire [3: 0] led_columns
);
    wire error;
    wire opcode_decoding_error;
    wire [31: 0] program_counter;
    wire [31: 0] instruction;
    wire [10: 0] opcode_selection;
    wire [10: 0] instruction_errors;
    wire [7: 0] logical_io_output;
    processor #(.INITIAL_DELAY(50)) processor_instance (
        .clk(clk),

        .error(error),
        .opcode_decoding_error(opcode_decoding_error),
        .instruction(instruction),
        .program_counter(program_counter),
        .opcode_selection(opcode_selection),
        .instruction_errors(instruction_errors),
        .output_io(logical_io_output)
    );

    reg [7: 0] debug_display_column_1;
    reg [7: 0] debug_display_column_2;
    reg [7: 0] debug_display_column_3;
    reg [7: 0] debug_display_column_4;
    debug_display debug_display_instance (
        .clk(clk),
        .column_1(debug_display_column_1),
        .column_2(debug_display_column_2),
        .column_3(debug_display_column_3),
        .column_4(debug_display_column_4),

        .led_rows(led_rows),
        .led_columns(led_columns)
    );

    always @(*) begin
        if (error) begin
            debug_display_column_1 = {opcode_decoding_error, instruction[6: 0]};
            debug_display_column_2 = {{|program_counter[31: 8]}, program_counter[7: 1]};
            debug_display_column_3 = {{|opcode_selection[10: 8]}, opcode_selection[7: 1]};
            debug_display_column_4 = {{|instruction_errors[10: 8]}, instruction_errors[7: 1]};
        end else begin
            debug_display_column_1 = 8'b0;
            debug_display_column_2 = 8'b0;
            debug_display_column_3 = 8'b0;
            debug_display_column_4 = logical_io_output;
        end
    end
endmodule
