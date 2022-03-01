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
reg [`RegDataBus] arithmetic_res;
reg [`RegDataBus] HI;           // Store HI value
reg [`RegDataBus] LO;           // Store LO value

wire[`RegDataBus] reg2_i_mux;   // 2's complement of oprand2
wire[`RegDataBus] reg1_i_not;   // 1's complement of oprand1
wire[`RegDataBus] result_sum;   // Add operation result
wire[`RegDataBus] opdata1_mult;
wire[`RegDataBus] opdata2_mult;
wire[`DoubleRegDataBus] hilo_temp;
reg [`DoubleRegDataBus] mul_res;
wire              ov_sum;       // Store overflow information
wire              reg1_eq_reg2; // Oprand1 equals oprand2
wire              reg1_lt_reg2; // Oprand1 less than oprand2


/******************** Do the computation according to aluop_i ********************/

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

// MTHI/MTLO instructions
always @(*) begin
    if (rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
    end
    else begin
        case (aluop_i)
            `EXE_OP_MULT, `EXE_OP_MULTU: begin
                whilo_o <= `WriteEnable;
                hi_o    <= mul_res[63:32];
                lo_o    <= mul_res[31: 0];
            end
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

// Arithmetic operation

// Phase 1, calculate internal signal
// Get 2's complement if SUB/SUBU/SLT(need sub to compare)
assign reg2_i_mux   = ((aluop_i == `EXE_OP_SUB) || (aluop_i == `EXE_OP_SUBU) || (aluop_i == `EXE_OP_SLT)) ? (~reg2_data_i + 1) : reg2_data_i;
// Get sum result
assign result_sum   = reg1_data_i + reg2_i_mux;
// Overflow accurs when 2 positive number gets negtive result or 2 negtive number gets positive result
assign ov_sum       = (((!reg1_data_i[31]) && (!reg2_i_mux[31])) && result_sum[31]) || ((reg1_data_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
// Data1 is smaller than data2: d1<0 && d2>0, d1d2>0 && sum<0, d1d2<0 && sum<0
assign reg1_lt_reg2 = (aluop_i == `EXE_OP_SLT) ? ((reg1_data_i[31] && !reg2_data_i[31]) || (!reg1_data_i[31] && !reg2_data_i[31] && result_sum[31]) || (reg1_data_i[31] && reg2_data_i[31] && result_sum[31])) : (reg1_data_i < reg2_data_i);
assign reg1_i_not   = ~reg1_data_i;

// Phase 2, generate arithmetic_res
always @(*) begin
    if (rst == `RstEnable)
        arithmetic_res <= `ZeroWord;
    else begin
        case (aluop_i)
            `EXE_OP_SLT, `EXE_OP_SLTU: arithmetic_res <= {31'd0, reg1_lt_reg2};
            `EXE_OP_ADD, `EXE_OP_ADDU: arithmetic_res <= result_sum;
            `EXE_OP_SUB, `EXE_OP_SUBU: arithmetic_res <= result_sum;
            `EXE_OP_CLZ: begin
                arithmetic_res <= reg1_data_i[31] ? 0  : reg1_data_i[30] ? 1  :
                                  reg1_data_i[29] ? 2  : reg1_data_i[28] ? 3  :
                                  reg1_data_i[27] ? 4  : reg1_data_i[26] ? 5  :
                                  reg1_data_i[25] ? 6  : reg1_data_i[24] ? 7  :
                                  reg1_data_i[23] ? 8  : reg1_data_i[22] ? 9  :
                                  reg1_data_i[21] ? 10 : reg1_data_i[20] ? 11 :
                                  reg1_data_i[19] ? 12 : reg1_data_i[18] ? 13 :
                                  reg1_data_i[17] ? 14 : reg1_data_i[16] ? 15 :
                                  reg1_data_i[15] ? 16 : reg1_data_i[14] ? 17 :
                                  reg1_data_i[13] ? 18 : reg1_data_i[12] ? 19 :
                                  reg1_data_i[11] ? 20 : reg1_data_i[10] ? 21 :
                                  reg1_data_i[9 ] ? 22 : reg1_data_i[8 ] ? 23 :
                                  reg1_data_i[7 ] ? 24 : reg1_data_i[6 ] ? 25 :
                                  reg1_data_i[5 ] ? 26 : reg1_data_i[4 ] ? 27 :
                                  reg1_data_i[3 ] ? 28 : reg1_data_i[2 ] ? 29 :
                                  reg1_data_i[1 ] ? 30 : reg1_data_i[0 ] ? 31 : 32;
            end
            `EXE_OP_CLO: begin
                arithmetic_res <= reg1_i_not[31] ? 0  : reg1_i_not[30] ? 1  :
                                  reg1_i_not[29] ? 2  : reg1_i_not[28] ? 3  :
                                  reg1_i_not[27] ? 4  : reg1_i_not[26] ? 5  :
                                  reg1_i_not[25] ? 6  : reg1_i_not[24] ? 7  :
                                  reg1_i_not[23] ? 8  : reg1_i_not[22] ? 9  :
                                  reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
                                  reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 :
                                  reg1_i_not[17] ? 14 : reg1_i_not[16] ? 15 :
                                  reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 :
                                  reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 :
                                  reg1_i_not[11] ? 20 : reg1_i_not[10] ? 21 :
                                  reg1_i_not[9 ] ? 22 : reg1_i_not[8 ] ? 23 :
                                  reg1_i_not[7 ] ? 24 : reg1_i_not[6 ] ? 25 :
                                  reg1_i_not[5 ] ? 26 : reg1_i_not[4 ] ? 27 :
                                  reg1_i_not[3 ] ? 28 : reg1_i_not[2 ] ? 29 :
                                  reg1_i_not[1 ] ? 30 : reg1_i_not[0 ] ? 31 : 32;
            end
            default: ;
        endcase
    end
end

// Phase 3, multiplication
// If signed multiplication and oprand is negtive, get it's 2's complement
assign opdata1_mult = (((aluop_i == `EXE_OP_MULT) || (aluop_i == `EXE_OP_MUL)) && (reg1_data_i[31])) ? (~reg1_data_i + 1) : reg1_data_i;
assign opdata2_mult = (((aluop_i == `EXE_OP_MULT) || (aluop_i == `EXE_OP_MUL)) && (reg2_data_i[31])) ? (~reg2_data_i + 1) : reg2_data_i;
// Get temporary result
assign hilo_temp    = opdata1_mult * opdata2_mult;
// Correction of temporary result
always @(*) begin
    if (rst == `RstEnable)
        mul_res <= {`ZeroWord, `ZeroWord};
    else begin
        if ((aluop_i == `EXE_OP_MULT) || (aluop_i == `EXE_OP_MUL)) begin
            if (reg1_data_i[31] ^ reg2_data_i[31])
                mul_res <= ~hilo_temp + 1;
            else
                mul_res <= hilo_temp;
        end
        else
            mul_res <= hilo_temp;
    end
end

/******************** Select output result according to alusel_i ********************/

always @(*) begin
    waddr_o <= waddr_i;
    if (((aluop_i == `EXE_OP_ADD) || (aluop_i == `EXE_OP_SUB)) && ov_sum) begin  // If overflow, no data is written
        wreg_o <= `WriteDisable;
    end
    else begin
        wreg_o <= wreg_i;                                                   // Normal write
    end
    case (alusel_i)
        `EXE_RES_LOGIC: wdata_o <= logic_res;
        `EXE_RES_SHIFT: wdata_o <= shift_res;
        `EXE_RES_MOVE:  wdata_o <= move_res;
        `EXE_RES_ARITHMETIC: wdata_o <= arithmetic_res;
        `EXE_RES_MUL:   wdata_o <= mul_res;
        default: wdata_o <= `ZeroWord;
    endcase
end

endmodule