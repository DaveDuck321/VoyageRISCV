module top;
    reg clk = 0;
    wire [7: 0] output_io;

    always #1 clk = !clk;

    processor processor_instance (
        .clk(clk),
        .output_io(output_io)
    );

    initial begin
        $dumpfile("riscv_dump.vcd");
        $dumpvars(0, processor_instance);
    end
endmodule
