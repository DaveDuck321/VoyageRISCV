module top(
    input wire clk,

    output wire [7: 0] led_rows,
    output wire [3: 0] led_columns
);
    assign led_columns = 4'b1111;

    processor processor_instance (
        .clk(clk),
        .output_io(led_rows)
    );
endmodule
