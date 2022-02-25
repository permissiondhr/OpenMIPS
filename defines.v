// Global defines
`define RstEnable           1'b1
`define RstDisable          1'b0
`define ZeroWord            32'h00000000
`define WriteEnable         1'b1
`define WriteDisable        1'b0
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define AluOpBus            7:0         // ALU Operation Bus
`define AluSelBus           2:0         // ALU Selection Bus
`define InstValid           1'b0
`define InstInvalid         1'b1
`define Stop                1'b1
`define NoStop              1'b0
`define InDelaySlot         1'b1
`define NotInDelaySlot      1'b0
`define Branch              1'b1
`define NotBranch           1'b0
`define InterruptAssert     1'b1
`define InterruptNotAssert  1'b0
`define TrapAssert          1'b1
`define TrapNotAssert       1'b0
`define True_v              1'b1
`define False_v             1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0

// Defines for ROM
`define InstAddrBus         31:0        // ROM address bus
`define InstDataBus         31:0        // ROM data bus
`define InstMemNum          131071      // Total ROM is 128KB
`define InstMemNumLog2      17          // Actual address bus width used for addressing

// Defines for GPR
`define RegAddrBus          4:0
`define RegDataBus          31:0
`define RegDataWidth        32
`define DoubleRegDAtaWidth  64
`define DoubleRegDataBus    63:0
`define RegNum              32
`define RegNumLog2          5
`define NOPRegAddr          5'b00000    // If no need for read regfile in id stage, output address is NOPRegAddr

// CPU Instrction Formats

// I-type (Immediate)
`define OPCODE              31:26       // 6-bit primary operation code
`define RS                  25:21       // 5-bit source register specifier
`define RT                  20:16       // 5-bit target register specifier or used to specify functions within the primary opcode value REGIMM
`define IMMEDIATE           15:0        // 16-bit signed immediate used for: logical operands, arithmetic aigned operands, load/store address byte offsets, PC-relative branch signed instruction displacement

// J-type (Jump)
// `define OPCODE           31:26       // already defined in I-type
`define INSTR_INDEX         25:0        // 26-bit index shifted left two bits to supply the lower-order 28 bits of the jump target address

// R-type (Register)
// `define OPCODE           31:26       // already defined in I-type
// `define RS               25:21       // already defined in I-type
// `define RT               20:16       // already defined in I-type
`define RD                  15:11       // 5-bit destination register specifier
`define SA                  10:6        // 5-bit shift amount
`define FUNCTION            5:0         // 6-bit function used to specify functions within the primary operation code value SPECIAL

// Instructions encoded by OPCODE field
// 28:26    000     001     010     011     100     101     110     111
// 31:29
// 000      SPECIAL REGIMM  J       JAL     BEQ     BNE     BLEZ    BGTZ
// 001      ADDI    ADDIU   SLTI    SLTIU   ANDI    ORI     XORI    LUI
// 010
// 011
// 100      LB      LH      LWL     LW      LBU     LHU     LWR
// 101      SB      SH      SWL     SW                      SWR
// 110
// 111

// Instructions encoded by FUNCTION field when OPCODE=SPECIAL
// 2:0      000     001     010     011     100     101     110     111
// 5:3
// 000      SLL             SRL     SRA     SLLV            SRLV    SRAV
// 001      JR      JALR    MFLO    MTLO    
// 010      MFHI    MTHI    MFLO    MTLO
// 011      MULT    MULTU   DIV     DIVU
// 100      ADD     ADDU    SUB     SUBU    AND     OR      XOR     NOR
// 101                      SLT     SLTU
// 110
// 111

// Instructions encoded by RT field when OPCODE=REGIMM
// 18:16    000     001     010     011     100     101     110     111
// 20:19
// 00      
// 01      
// 10

// Defines for specific instruction
`define EXE_ORI             6'b001101   // OPCODE
`define EXE_NOP             6'b000000

// AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_NOP         3'b000

// AluOp
`define EXE_OR_OP           8'b00100101
`define EXE_NOP_OP          8'b00000000

