`include "defines.v"

module ex (
    input   wire                rst,
    // Inputs from id/ex module
    input   wire[`AluSelBus]    alusel_i,   
    input   wire[`AluOpBus]     aluop_i,    
    input   wire[`RegDataBus]   reg1_data_i,
    input   wire[`RegDataBus]   reg2_data_i,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                wreg_i,
    // Inputs from hilo_reg
    input   wire[`RegDataBus]   hi_i,
    input   wire[`RegDataBus]   lo_i,
    // Inputs from mem module to resolve data conflicts about hilo
    input   wire                mem_whilo_i,
    input   wire[`RegDataBus]   mem_hi_i,
    input   wire[`RegDataBus]   mem_lo_i,
    // Inputs from mem_wb module to resolve data conflicts about hilo
    input   wire                wb_whilo_i,
    input   wire[`RegDataBus]   wb_hi_i,
    input   wire[`RegDataBus]   wb_lo_i,
    // Outputs to ex/mem module
    output  reg                 wreg_o,
    output  reg [`RegAddrBus]   waddr_o,
    output  reg [`RegDataBus]   wdata_o,
    output  reg                 whilo_o,
    output  reg [`RegDataBus]   hi_o,
    output  reg [`RegDataBus]   lo_o
);

reg [`RegDataBus] logic_res;    // Store logic arithmetic result
reg [`RegDataBus] shift_res;    // Store shift arithmetic result
reg [`RegDataBus] move_res;     // Store move arithmetic result
reg [`RegDataBus] HI;           // Store HI value
reg [`RegDataBus] LO;           // Store LO value

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

// Get the latest HO/LO value, resolve data conflicts
always @(*) begin
    if (rst == `RstEnable) begin
        HI <= `ZeroWord;
        LO <= `ZeroWord;
    end
    else begin
        if (mem_whilo_i == `WriteEnable) begin      // Mem stage write HI/LO register
            HI <= mem_hi_i;
            LO <= mem_lo_i;
        end
        else begin
            if (wb_whilo_i == `WriteEnable) begin   // Wb stage write HI/LO register
                HI <= wb_hi_i;
                LO <= wb_lo_i;
            end
            else begin
                HI <= hi_i;
                LO <= lo_i;
            end
        end
    end
end

// Move operation
always @(*) begin
    if (rst == `RstEnable)
        move_res <= `ZeroWord;
    else begin
        case (aluop_i)
            `EXE_OP_MOVZ:move_res <= reg1_data_i;
            `EXE_OP_MOVN:move_res <= reg1_data_i;   // MOVZ and MOVN has the same operation
            `EXE_OP_MFHI:move_res <= HI;
            `EXE_OP_MFLO:move_res <= LO;
            default:     move_res <= `ZeroWord;
        endcase
    end
end

always @(*) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
    end
    else begin
        case (aluop_i)
            `EXE_OP_MTHI: begin         // Write HI reg, LO stays the same
                whilo_o <= `WriteEnable;
                hi_o    <= reg1_data_i;
                lo_o    <= LO;
            end
            `EXE_OP_MTLO: begin         // Write LO reg, HI stays the same
                whilo_o <= `WriteEnable;
                hi_o    <= HI;
                lo_o    <= reg1_data_i;
            end
            default: begin              // Write disable, HI/LO stays the same
                whilo_o <= `WriteDisable;
                hi_o    <= `ZeroWord;
                lo_o    <= `ZeroWord;
            end
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
        `EXE_RES_MOVE:  wdata_o <= move_res;
        default: wdata_o <= `ZeroWord;
    endcase
end

endmodule