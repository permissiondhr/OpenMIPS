`include "defines.v"

module ex (
    input   wire                rst,
    // Inputs from id/ex module
    input   wire [`AluSelBus]   alusel_i,   
    input   wire [`AluOpBus]    aluop_i,    
    input   wire [`RegDataBus]  reg1_data_i,
    input   wire [`RegDataBus]  reg2_data_i,
    input   wire [`RegAddrBus]  waddr_i,
    input   wire                wreg_i,
    // Outputs to mem module
    output  reg                 wreg_o,
    output  reg  [`RegAddrBus]  waddr_o,
    output  reg  [`RegDataBus]  wdata_o
);

reg [`RegDataBus] logic_res;    // Store logic arithmetic result
reg [`RegDataBus] shift_res;    // Store shift arithmetic result

/******************** Do the arithmetic computation according to aluop_i ********************/

// Logic operation
always @(*) begin
    if (rst == `RstEnable)
        logic_res <= `ZeroWord;
    else begin
        case (aluop_i)
            `EXE_OP_AND:logic_res <= reg1_data_i & reg2_data_i;
            `EXE_OP_OR: logic_res <= reg1_data_i | reg2_data_i;
            `EXE_OP_XOR:logic_res <= reg1_data_i ^ reg2_data_i;
            `EXE_OP_NOR:logic_res <= ~(reg1_data_i | reg2_data_i);
            default:    logic_res <= `ZeroWord;
        endcase
    end
end

// Shift operation
always @(*) begin
    if (rst == `RstEnable)
        shift_res <= `ZeroWord;
    else begin
        case (aluop_i)
            `EXE_OP_SLL:shift_res <= reg2_data_i << reg1_data_i[4:0];
            `EXE_OP_SRL:shift_res <= reg2_data_i >> reg1_data_i[4:0];
            `EXE_OP_SRA:shift_res <= ($signed(reg2_data_i)) >>> reg1_data_i[4:0];
                     // shift_res <= ({32{reg2_data_i[31]}} << (6'd32 - {1'b0, reg1_data_i[4:0]})) | (reg2_data_i >> reg1_data_i[4:0]);
            default:    shift_res <= `ZeroWord;
        endcase
    end
end

/******************** Select output result according to alusel_i ********************/

always @(*) begin
    waddr_o <= waddr_i;
    wreg_o  <= wreg_i;
    case (alusel_i)
        `EXE_RES_LOGIC: wdata_o <= logic_res;
        `EXE_RES_SHIFT: wdata_o <= shift_res;
        default: wdata_o <= `ZeroWord;
    endcase
end

endmodule