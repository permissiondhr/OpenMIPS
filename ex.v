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

// reg store logic arithmetic result
reg [`RegDataBus] logicout;

/******************** Do the arithmetic computation according to aluop_i ********************/

always @(*) begin
    if (rst == `RstEnable)
        logicout <= `ZeroWord;
    else begin
        case (aluop_i)
            `EXE_OR_OP: logicout <= reg1_data_i | reg2_data_i; 
            default: logicout <= `ZeroWord;
        endcase
    end
end

/******************** Select output result according to alusel_i ********************/

always @(*) begin
    waddr_o <= waddr_i;
    wreg_o  <= wreg_i;
    case (alusel_i)
        `EXE_RES_LOGIC: wdata_o <= logicout;
        default: wdata_o <= `ZeroWord;
    endcase
end

endmodule