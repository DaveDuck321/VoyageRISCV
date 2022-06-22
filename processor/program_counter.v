module program_counter(
    input wire clk,
    input wire [31: 0] current_program_counter,

    output reg [31: 0] new_program_counter
);

wire [31: 0] normally_next_program_counter;
assign normally_next_program_counter = current_program_counter + 4;

always @(posedge clk) begin
    new_program_counter <= normally_next_program_counter;
end

endmodule
