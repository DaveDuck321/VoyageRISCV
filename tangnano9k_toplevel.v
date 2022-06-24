module top(
    input wire clk,

    output wire [5: 0] leds
);
    wire [7: 0] logical_io_output;

    processor processor_instance (
        .clk(clk),
        .output_io(logical_io_output)
    );

    assign leds = logical_io_output[5: 0];
endmodule
