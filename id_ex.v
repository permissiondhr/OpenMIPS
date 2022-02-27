`include "defines.v"

module id_ex (
    input   wire                clk,
    input   wire                rst,
    // Inputs from id module
    input   wire [`AluSelBus]   id_alusel,       // The operation type ALU will do
    input   wire [`AluOpBus]    id_aluop,        // The operation sub_type ALU will do
    input   wire [`RegDataBus]  id_reg1_data,
    input   wire [`RegDataBus]  id_reg2_data,
    input   wire [`RegAddrBus]  id_waddr,
    input   wire                id_wreg,

    // Outputs to ex module
    output  reg [`AluSelBus]    ex_alusel,   
    output  reg [`AluOpBus]     ex_aluop,    
    output  reg [`RegDataBus]   ex_reg1_data,
    output  reg [`RegDataBus]   ex_reg2_data,
    output  reg [`RegAddrBus]   ex_waddr,
    output  reg                 ex_wreg
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        ex_alusel       <= `EXE_RES_NOP;
        ex_aluop        <= `EXE_NOP_OP;
        ex_reg1_data    <= `ZeroWord;
        ex_reg2_data    <= `ZeroWord;
        ex_waddr        <= `NOPRegAddr;
        ex_wreg         <= `WriteDisable;
    end 
    else begin		
        ex_alusel       <= id_alusel;
        ex_aluop        <= id_aluop;
        ex_reg1_data    <= id_reg1_data;
        ex_reg2_data    <= id_reg2_data;
        ex_waddr        <= id_waddr;
        ex_wreg         <= id_wreg;		
    end
end

endmodule