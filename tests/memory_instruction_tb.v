`define WAIT_UNTIL_CPU_IS_NOT_STALLED while(clk_stall) #2;

`define ASSERT_LEGAL_WRITE \
    if (^store_error === 1'bX)  $error("Store_error is undefined"); \
    if (store_error)            $error("Store_error is true (expected false)"); \
    if (memory_mapped_io != 8'h00)  $error("Incorrect IO write"); \
    if (^memory_mapped_io === 1'bX) $error("Undefined IO write")

`define ASSERT_LEGAL_READ \
    if (^load_error === 1'bX)   $error("Load_error is undefined"); \
    if (load_error)             $error("Load_error is true (expected false)")

`define COMMIT_WRITE_AND_ASSERT_VALID \
    #2 `ASSERT_LEGAL_WRITE; \
    `WAIT_UNTIL_CPU_IS_NOT_STALLED; \
    `ASSERT_LEGAL_WRITE

`define COMMIT_READ_AND_ASSERT_VALID \
    #2 `ASSERT_LEGAL_READ; \
    `WAIT_UNTIL_CPU_IS_NOT_STALLED; \
    `ASSERT_LEGAL_READ


module memory_instruction_tb;

reg clk = 1;
reg [2: 0] subfunction_3;
reg [31: 0] input_register1_value;
reg [31: 0] input_register2_value;
reg [31: 0] immediate;
reg opcode_is_store;
reg opcode_is_load;

wire clk_stall;
wire load_error;
wire store_error;
wire [31: 0] read_result;
wire [7: 0] memory_mapped_io;


task ASSERT_LOAD_VALUE(input [31: 0] target_value);
    begin
        if (^read_result === 1'bX)
            $error("Load gives undefined value: '%h'", read_result);

        if (read_result != target_value)
            $error("Load gives unexpected value, expected: '%h', actual: '%h'", target_value, read_result);
    end
endtask

memory_instruction memory_instruction_instance(
    .clk(clk),
    .subfunction_3(subfunction_3),
    .input_register1_value(input_register1_value),
    .input_register2_value(input_register2_value),
    .immediate(immediate),
    .opcode_is_store(opcode_is_store),
    .opcode_is_load(opcode_is_load),

    .clk_stall(clk_stall),
    .load_error(load_error),
    .store_error(store_error),
    .result_to_write_rd(read_result),
    .memory_mapped_io(memory_mapped_io)
);

always  #1 clk = ~clk;

initial begin
    `WAIT_UNTIL_CPU_IS_NOT_STALLED;

    begin  // Test write 1 (little endian MSB)
        //    Write word 'FE DC BA 98' to address '00 00 00 FC'
        opcode_is_store = 1'b1;
        opcode_is_load = 1'b0;
        subfunction_3 = 3'b010;  // SW
        input_register1_value = 32'hEC;
        immediate = 32'h10;  // EC + 10 = FC
        input_register2_value = 32'hFEDCBA98;
        `COMMIT_WRITE_AND_ASSERT_VALID;
        
        //    Write half word '76 54' to address '00 00 00 FE'
        subfunction_3 = 3'b001;  // SH
        input_register1_value = 32'hDE;
        immediate = 32'h20;  // DE + 20 = FE
        input_register2_value = 32'h7654;
        `COMMIT_WRITE_AND_ASSERT_VALID;

        //    Write bytes '32' to address '00 00 00 FF'
        subfunction_3 = 3'b000;  // SB
        input_register1_value = 32'hFF;
        immediate = 32'h0;
        input_register2_value = 32'h32;
        `COMMIT_WRITE_AND_ASSERT_VALID;

        // Now verify the data is valid
        opcode_is_store = 1'b0;
        opcode_is_load = 1'b1;
        subfunction_3 = 3'b010;  // LW
        input_register1_value = 32'hFB;
        immediate = 32'h01;  // FB + 1 = FC
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'h3254ba98);
    end

    begin  // Test write 2 (little endian LSB)
        //    Write word 'FE DC BA 98' to address '00 00 00 FC'
        opcode_is_store = 1'b1;
        opcode_is_load = 1'b0;
        subfunction_3 = 3'b010;  // SW
        input_register1_value = 32'hFC;
        immediate = 32'h00;
        input_register2_value = 32'hFEDCBA98;
        `COMMIT_WRITE_AND_ASSERT_VALID;
        
        //    Write half word '76 54' to address '00 00 00 FC'
        subfunction_3 = 3'b001;  // SH
        input_register2_value = 32'h7654;
        `COMMIT_WRITE_AND_ASSERT_VALID;

        //    Write bytes '32' to address '00 00 00 FF'
        subfunction_3 = 3'b000;  // SB
        input_register2_value = 32'h32;
        `COMMIT_WRITE_AND_ASSERT_VALID;

        // Now verify the data is valid
        opcode_is_store = 1'b0;
        opcode_is_load = 1'b1;
        subfunction_3 = 3'b010;  // LW
        input_register1_value = 32'hFC;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hFEDC7632);
    end


    begin  // Test partial reads
        //    Write word 'FE DC BA 98' to address '00 00 00 FC'
        opcode_is_store = 1'b1;
        opcode_is_load = 1'b0;
        subfunction_3 = 3'b010;  // SW
        input_register1_value = 32'hFC;
        immediate = 32'h00;
        input_register2_value = 32'hFEDCBA10;
        `COMMIT_WRITE_AND_ASSERT_VALID;

        // Check each byte
        opcode_is_store = 1'b0;
        opcode_is_load = 1'b1;
        subfunction_3 = 3'b100;  // LBU

        immediate = 32'b00;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'h10);

        immediate = 32'b01;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hBA);

        immediate = 32'b10;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hDC);

        immediate = 32'b11;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hFE);

        // Check each half world
        subfunction_3 = 3'b101;  // LHU

        immediate = 32'b00;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hBA10);

        immediate = 32'b10;
        `COMMIT_READ_AND_ASSERT_VALID;
        ASSERT_LOAD_VALUE(32'hFEDC);
    end

    begin  // Test IO write
        //    Write byte 'd1' to IO address '00 00 20 00'
        opcode_is_store = 1'b1;
        opcode_is_load = 1'b0;
        subfunction_3 = 3'b000;  // SW
        input_register1_value = 32'h1000;
        immediate = 32'h1000;  // 1000 + 1000 = 2000
        input_register2_value = 32'hD1;
        #2 `WAIT_UNTIL_CPU_IS_NOT_STALLED;

        if (^memory_mapped_io === 1'bX) $error("Undefined IO write");
        if (memory_mapped_io != 8'hD1)  $error("Incorrect IO write");
    end

    $finish();
end

endmodule
