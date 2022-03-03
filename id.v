`include "defines.v"

module id (
    input   wire                rst,
    // Input from if/id module
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstDataBus]  inst_i,
    // Input from regfile module
    input   wire[`RegDataBus]   reg1_data_i,
    input   wire[`RegDataBus]   reg2_data_i,

    // Added to resolve data conflict between id & ex stage
    input   wire[`RegDataBus]   ex_wdata_i,
    input   wire[`RegAddrBus]   ex_waddr_i,
    input   wire                ex_wreg_i,
    // Added to resolve data conflict between id & mem stage
    input   wire[`RegDataBus]   mem_wdata_i,
    input   wire[`RegAddrBus]   mem_waddr_i,
    input   wire                mem_wreg_i,

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
    output  reg [`RegAddrBus]   waddr_o,
    output  reg                 wreg_o,
    output  wire                stallreq
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

// Not stall the pipline
assign stallreq = 1'b0;
/******************** Instruction Decode ********************/

always @ (*) begin
    if (rst == `RstEnable) begin
        alusel_o    <= `EXE_RES_NOP;
        aluop_o     <= `EXE_OP_NOP;
        waddr_o     <= `NOPRegAddr;
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
        aluop_o     <= `EXE_OP_NOP;
        waddr_o     <=  op_rd;                  // Default: write to rd register
        wreg_o      <= `WriteDisable;           // Default: write disable
        inst_valid  <= `InstInvalid;            // Default: instruction invalid
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <=  op_rs;                  // Default: read rs from read port1
        reg2_addr_o <=  op_rt;                  // Default: read rt from read port2
        imm         <= `ZeroWord;

        case (op_opcode)
            `EXE_SPECIAL_INST: begin
                case (op_function)
                    `EXE_SLL: begin
                        if (op_rs == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SLL;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadEnable;
                            imm         <=  {27'h0, op_sa};
                        end
                    end
                    `EXE_SRL: begin
                        if (op_rs == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SRL;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadEnable;
                            imm         <=  {27'h0, op_sa};
                        end
                    end
                    `EXE_SRA: begin
                        if (op_rs == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SRA;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadEnable;
                            imm         <=  {27'h0, op_sa};
                        end
                    end
                    `EXE_SLLV: begin
                        if (op_sa == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SLL;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end 
                    `EXE_SRLV: begin
                        if (op_sa == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SRL;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end 
                    `EXE_SRAV: begin
                        if (op_sa == 5'b00000) begin
                            alusel_o    <= `EXE_RES_SHIFT;
                            aluop_o     <= `EXE_OP_SRA;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_MOVZ: begin
                        if (op_sa == 5'b00000) begin
                            alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MOVZ;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            if (reg2_data_o == `ZeroWord)                            
                                wreg_o  <= `WriteEnable;
                            else
                                wreg_o  <= `WriteDisable;
                        end
                    end
                    `EXE_MOVN: begin
                        if (op_sa == 5'b00000) begin
                            alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MOVN;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            if (reg2_data_o != `ZeroWord)                            
                                wreg_o  <= `WriteEnable;
                            else
                                wreg_o  <= `WriteDisable;
                        end
                    end
                    `EXE_SYNC: begin                                // Not used
                        if ({op_rs, op_rt, op_rd} == 15'h0000) begin
                            alusel_o    <= `EXE_RES_NOP;
                            aluop_o     <= `EXE_OP_NOP;
                            wreg_o      <= `WriteDisable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end 
                    `EXE_MFHI: begin
                        if ((op_sa == 5'b00000) && (op_rs == 5'b00000) && (op_rt == 5'b00000)) begin
                            alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MFHI;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadDisable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_MTHI: begin
                        if ((op_sa == 5'b00000) && (op_rd == 5'b00000) && (op_rt == 5'b00000)) begin
                            //alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MTHI;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadDisable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_MFLO: begin
                        if ((op_sa == 5'b00000) && (op_rs == 5'b00000) && (op_rt == 5'b00000)) begin
                            alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MFLO;
                            reg1_read_o <= `ReadDisable;
                            reg2_read_o <= `ReadDisable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_MTLO: begin
                        if ((op_sa == 5'b00000) && (op_rd == 5'b00000) && (op_rt == 5'b00000)) begin
                            //alusel_o    <= `EXE_RES_MOVE;
                            aluop_o     <= `EXE_OP_MTLO;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadDisable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_MULT: begin                                // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MULT;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_MULTU: begin                               // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MULTU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_DIV: begin                                 // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_DIV;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_DIVU: begin                                // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_DIVU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteDisable;
                        end
                    end
                    `EXE_ADD: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_ADD;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_ADDU: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_ADDU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_SUB: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_SUB;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_SUBU: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_SUBU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_SLT: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_SLT;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_SLTU: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_ARITHMETIC;
                            aluop_o     <= `EXE_OP_SLTU;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            inst_valid  <= `InstValid;
                            wreg_o      <= `WriteEnable;
                        end
                    end
                    `EXE_AND: begin
                        if (op_sa == 5'b0000) begin
                            alusel_o    <= `EXE_RES_LOGIC;
                            aluop_o     <= `EXE_OP_AND;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_OR: begin
                        if (op_sa == 5'b0000) begin
                            alusel_o    <= `EXE_RES_LOGIC;
                            aluop_o     <= `EXE_OP_OR;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_XOR: begin
                        if (op_sa == 5'b0000) begin
                            alusel_o    <= `EXE_RES_LOGIC;
                            aluop_o     <= `EXE_OP_XOR;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_NOR: begin
                        if (op_sa == 5'b0000) begin
                            alusel_o    <= `EXE_RES_LOGIC;
                            aluop_o     <= `EXE_OP_NOR;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end  
                    default: ;
                endcase
            end
            `EXE_ANDI: begin
                alusel_o    <= `EXE_RES_LOGIC;
                aluop_o     <= `EXE_OP_AND;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {16'h0, op_immediate};
            end
            `EXE_ORI: begin
                alusel_o    <= `EXE_RES_LOGIC;
                aluop_o     <= `EXE_OP_OR;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {16'h0, op_immediate};
            end
            `EXE_XORI: begin
                alusel_o    <= `EXE_RES_LOGIC;
                aluop_o     <= `EXE_OP_XOR;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {16'h0, op_immediate};
            end
            `EXE_LUI: begin
                if (op_rs == 5'b00000) begin            // For LUI instruction, rs must be 0
                    alusel_o    <= `EXE_RES_LOGIC;
                    aluop_o     <= `EXE_OP_OR;          // rs (which is '0') | (imm << 16)
                    waddr_o     <=  op_rt;
                    wreg_o      <= `WriteEnable;
                    inst_valid  <= `InstValid;
                    reg1_read_o <= `ReadEnable;
                    reg2_read_o <= `ReadDisable;
                    imm         <= {op_immediate, 16'h0}; 
                end
            end
            `EXE_ADDI: begin
                alusel_o    <= `EXE_RES_ARITHMETIC;
                aluop_o     <= `EXE_OP_ADD;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {{16{op_immediate[15]}}, op_immediate};
            end
            `EXE_ADDIU: begin
                alusel_o    <= `EXE_RES_ARITHMETIC;
                aluop_o     <= `EXE_OP_ADDU;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {{16{op_immediate[15]}}, op_immediate};
            end
            `EXE_SLTI: begin
                alusel_o    <= `EXE_RES_ARITHMETIC;
                aluop_o     <= `EXE_OP_SLT;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {{16{op_immediate[15]}}, op_immediate};
            end
            `EXE_SLTIU: begin
                alusel_o    <= `EXE_RES_ARITHMETIC;
                aluop_o     <= `EXE_OP_SLTU;
                waddr_o     <=  op_rt;
                wreg_o      <= `WriteEnable;
                inst_valid  <= `InstValid;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm         <= {{16{op_immediate[15]}}, op_immediate};
            end
            `EXE_SPECIAL2_INST: begin
                case (op_function)
                    `EXE_MADD: begin                            // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MADD;
                            wreg_o      <= `WriteDisable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_MADDU: begin                           // This instruction do not write GPR, so alusel=NOP
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MADDU;
                            wreg_o      <= `WriteDisable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_MUL: begin
                        if (op_sa == 5'h00) begin
                            alusel_o    <= `EXE_RES_MUL;
                            aluop_o     <= `EXE_OP_MUL;
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_MSUB: begin
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MSUB;
                            wreg_o      <= `WriteDisable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_MSUBU: begin
                        if ({op_rd, op_sa} == 10'h000) begin
                            aluop_o     <= `EXE_OP_MSUBU;
                            wreg_o      <= `WriteDisable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                        end
                    end
                    `EXE_CLZ: begin                             // CLZ has 2 versions: pre-release6, release6
                        if (op_sa == 5'h00) begin               // Pre-release6: 011100 rs rt     rd 00000 100000
                            alusel_o    <= `EXE_RES_ARITHMETIC; // Release6:     000000 rs 000000 rd 00001 010000
                            aluop_o     <= `EXE_OP_CLZ;         
                            wreg_o      <= `WriteEnable;        
                            inst_valid  <= `InstValid;          
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadDisable;
                        end
                    end
                    `EXE_CLO: begin                             // CLO has 2 versions: pre-release6, release6
                        if (op_sa == 5'h00) begin               // Pre-release6: 011100 rs rt     rd 00000 100001
                            alusel_o    <= `EXE_RES_ARITHMETIC; // Release6:     000000 rs 000000 rd 00001 010001
                            aluop_o     <= `EXE_OP_CLO;         
                            wreg_o      <= `WriteEnable;
                            inst_valid  <= `InstValid;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadDisable;
                        end
                    end
                    default: ;
                endcase
            end
            default: ;
        endcase
    end
end

/******************** Instruction Oprand 1 ********************/
always @(*) begin
    if (rst == `RstEnable)
        reg1_data_o <= `ZeroWord;
    else begin
        if (reg1_read_o == `ReadEnable) begin
            if ((reg1_addr_o == ex_waddr_i) && (ex_wreg_i == `WriteEnable))         // id & ex data conflict
                reg1_data_o <= ex_wdata_i;                                          // using data from ex stage
            else begin
                if ((reg1_addr_o == mem_waddr_i) && (mem_wreg_i == `WriteEnable))   // id & mem data conflict
                    reg1_data_o <= mem_wdata_i;                                     // using data from mem stage
                else
                    reg1_data_o <= reg1_data_i;                                     // normal read data out
            end
        end
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
        if (reg2_read_o == `ReadEnable) begin
            if ((reg2_addr_o == ex_waddr_i) && (ex_wreg_i == `WriteEnable))         // id & ex data conflict
                reg2_data_o <= ex_wdata_i;                                          // using data from ex stage
            else begin
                if ((reg2_addr_o == mem_waddr_i) && (mem_wreg_i == `WriteEnable))   // id & mem data conflict
                    reg2_data_o <= mem_wdata_i;                                     // using data from mem stage
                else
                    reg2_data_o <= reg2_data_i;                                     // normal read data out
            end
        end
        else begin
            if (reg2_read_o == `ReadDisable)
                reg2_data_o <= imm;
            else
                reg2_data_o <= `ZeroWord;
        end
    end
end

endmodule