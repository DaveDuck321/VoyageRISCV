`include "define.vh"

module rd_mux(
    input wire [10: 0] opcode_selection,
    input wire [31: 0] lui_write,
    input wire [31: 0] auipc_write,
    input wire [31: 0] jal_write,
    input wire [31: 0] jalr_write,
    input wire [31: 0] load_write,
    input wire [31: 0] itype_alu_write,
    input wire [31: 0] rtype_alu_write,

    output reg write_enabled,
    output reg [31: 0] write_value
);

always @(*) begin
    case(opcode_selection)
    (11'b1 << `ONEHOT_LUI_INDEX): begin
        write_enabled = 1;
        write_value = lui_write;
    end
    (11'b1 << `ONEHOT_AUIPI_INDEX): begin
        write_enabled = 1;
        write_value = auipc_write;
    end
    (11'b1 << `ONEHOT_JAL_INDEX): begin
        write_enabled = 1;
        write_value = jal_write;
    end
    (11'b1 << `ONEHOT_JALR_INDEX): begin
        write_enabled = 1;
        write_value = jalr_write;
    end
    (11'b1 << `ONEHOT_LOAD_INDEX): begin
        write_enabled = 1;
        write_value = load_write;
    end
    (11'b1 << `ONEHOT_ITYPE_ALU_INDEX): begin
        write_enabled = 1;
        write_value = itype_alu_write;
    end
    (11'b1 << `ONEHOT_RTYPE_ALU_INDEX): begin
        write_enabled = 1;
        write_value = rtype_alu_write;
    end
    default: begin
        write_enabled = 0;
        write_value = {32{1'bX}};
    end
    endcase
end
endmodule


module pc_mux(
    input wire [10: 0] opcode_selection,
    input wire [31: 0] jal_pc_write,
    input wire [31: 0] jalr_pc_write,
    input wire [31: 0] branching_pc_write,
    input wire [31: 0] default_pc_write,

    output reg [31: 0] new_pc
);

always @(*) begin
    case(opcode_selection)
    (11'b1 << `ONEHOT_JAL_INDEX):       new_pc = jal_pc_write;
    (11'b1 << `ONEHOT_JALR_INDEX):      new_pc = jalr_pc_write;
    (11'b1 << `ONEHOT_BRANCH_INDEX):    new_pc = branching_pc_write;
    default:    new_pc = default_pc_write;
    endcase
end
endmodule
