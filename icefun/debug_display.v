module debug_display #(
    parameter DUTY_CYCLE = 1
) (
    input wire clk,
    input wire [7: 0] column_1,
    input wire [7: 0] column_2,
    input wire [7: 0] column_3,
    input wire [7: 0] column_4,

    output reg [7: 0] led_rows,
    output reg [3: 0] led_columns
);

// We can't strobe the LEDs at 12MHz :-( -- use a divider instead
integer counter = 0;
wire [1: 0] current_column = counter[10: 9];
wire duty_cycle_active = !(|counter[DUTY_CYCLE: 0]);

always @(posedge clk) begin
    counter <= counter + 1;

    if (duty_cycle_active) begin
        case(current_column)
        2'd0: begin
            led_rows <= ~column_1;
            led_columns <= ~4'b0001;
        end
        2'd1: begin
            led_rows <= ~column_2;
            led_columns <= ~4'b0010;
        end
        2'd2: begin
            led_rows <= ~column_3;
            led_columns <= ~4'b0100;
        end
        2'd3: begin
            led_rows <= ~column_4;
            led_columns <= ~4'b1000;
        end
        endcase
    end else begin
        led_rows <= ~8'b0;
        led_columns <= ~4'b0;
    end
end
endmodule
