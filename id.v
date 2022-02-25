`include "defines.v"

module id (
    input   wire                rst,
    // Input from if/id module
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstDataBus]  inst_i,
    // Input from regfile module
    input   wire[`RegDataBus]   reg1_data_i,
    input   wire[`RegDataBus]   reg2_data_i,
    // Output to regfile module
    output  reg                 reg1_read_o,
    output  reg                 reg2_read_o,     
    output  reg [`RegAddrBus]   reg1_addr_o,
    output  reg [`RegAddrBus]   reg2_addr_o,
    // Output to id/ex module
    output  reg [`AluSelBus]    alusel_o,       // The operation type ALU will do
    output  reg [`AluOpBus]     aluop_o,        // The operation sub_type ALU will do
    output  reg [`RegDataBus]   reg1_data_o,
    output  reg [`RegDataBus]   reg2_data_o,
    output  reg [`RegAddrBus]   wd_o,
    output  reg                 wreg_o
);

// Instruction decode wires
wire [5 :0] op_opcode      = inst_i[`OPCODE];
wire [4 :0] op_rs          = inst_i[`RS];
wire [4 :0] op_rt          = inst_i[`RT];
wire [15:0] op_immediate   = inst_i[`IMMEDIATE];
wire [25:0] op_instr_index = inst_i[`INSTR_INDEX];
wire [4 :0] op_rd          = inst_i[`RD];
wire [4 :0] op_sa          = inst_i[`SA];
wire [5 :0] op_function    = inst_i[`FUNCTION];

// Store the immediate in imm
reg [`RegDataBus]   imm;

// Show the instruction is valid or not
reg                 inst_valid;

/******************** Instruction Decode ********************/

always @ (*) begin
    if (rst == `RstEnable) begin
        alusel_o    <= `EXE_RES_NOP;
        aluop_o     <= `EXE_NOP_OP;
        wd_o        <= `NOPRegAddr;
        wreg_o      <= `WriteDisable;
        inst_valid  <= `InstValid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm         <= `ZeroWord;
    end
    else begin
        alusel_o    <= `EXE_RES_NOP;
        aluop_o     <= `EXE_NOP_OP;
        wd_o        <= op_rd;
        wreg_o      <= `WriteDisable;
        inst_valid  <= `InstInvalid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= op_rs;                   // Default: read rs from read port1
        reg2_addr_o <= op_rt;                   // Default: read rt from read port2
        imm         <= `ZeroWord;

        case (op_opcode)                        // ORI instruction
            `EXE_ORI: begin
                alusel_o    <= `EXE_RES_LOGIC;  // Logic operation
                aluop_o     <= `EXE_OR_OP;      // "OR" operation
                wd_o        <= op_rt;           // Writes the result to rt
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;     // rs read enable
                reg2_read_o <= `ReadDisable;
                imm         <= {16'h0, op_immediate};
            end
            default: begin
            end
        endcase
    end
end

/******************** Instruction Oprand 1 ********************/
always @(*) begin
    if (rst == `RstEnable)
        reg1_data_o <= `ZeroWord;
    else begin
        if (reg1_read_o == `ReadEnable)
            reg1_data_o <= reg1_data_i;
        else begin
            if (reg1_read_o == `ReadDisable)
                reg1_data_o <= imm;
            else
                reg1_data_o <= `ZeroWord;
        end
    end
end

/******************** Instruction Oprand 2 ********************/
always @(*) begin
    if (rst == `RstEnable)
        reg2_data_o <= `ZeroWord;
    else begin
        if (reg2_read_o == `ReadEnable)
            reg2_data_o <= reg2_data_i;
        else begin
            if (reg2_read_o == `ReadDisable)
                reg2_data_o <= imm;
            else
                reg2_data_o <= `ZeroWord;
        end
    end
end

endmodule