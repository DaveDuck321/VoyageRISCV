module top(
    input wire clk,

    output wire [7: 0] led_rows,
    output wire [3: 0] led_columns
);
    wire [7: 0] logical_io_output;

    processor processor_instance (
        .clk(clk),
        .output_io(logical_io_output)
    );

    assign led_columns = 4'b1110;
    assign led_rows = ~logical_io_output;  // Convert to a common anode format
endmodule
