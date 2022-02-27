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

//CPU Instructions Encoding - MIPS IV Architecture

// Instructions encoded by OPCODE field
// 28:26    000     001     010     011     100     101     110     111
// 31:29
// 000      SPECIAL REGIMM  J       JAL     BEQ     BNE     BLEZ    BGTZ
// 001      ADDI    ADDIU   SLTI    SLTIU   ANDI    ORI     XORI    LUI
// 010
// 011
// 100      LB      LH      LWL     LW      LBU     LHU     LWR
// 101      SB      SH      SWL     SW                      SWR
// 110                              PREF
// 111

// Instructions encoded by FUNCTION field when OPCODE=SPECIAL
// 2:0      000     001     010     011     100     101     110     111
// 5:3
// 000      SLL             SRL     SRA     SLLV            SRLV    SRAV
// 001      JR      JALR                    SYSCALL BREAK           SYNC
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
// Defined by OPCODE
`define EXE_SPECIAL_INST    6'b000000
`define EXE_REGIMM_INST     6'b000001
`define EXE_ANDI            6'b001100
`define EXE_ORI             6'b001101
`define EXE_XORI            6'b001101
`define EXE_LUI             6'b001111
`define EXE_PREF            6'b110011
// Defined by FUNCTION   
`define EXE_NOP             6'b000000   // NOP:   32'h00000000 = sll $0, $0, 0
`define EXE_SSNOP           6'b000000   // SSNOP: 32'h00000040 = sll $0, $0, 1
`define EXE_SLL             6'b000000
`define EXE_SRL             6'b000010
`define EXE_SRA             6'b000011
`define EXE_SLLV            6'b000100 
`define EXE_SRLV            6'b000110 
`define EXE_SRAV            6'b000111
`define EXE_SYNC            6'b001111 
`define EXE_AND             6'b100100
`define EXE_OR              6'b100101
`define EXE_XOR             6'b100110
`define EXE_NOR             6'b100111

// AluSel
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
// AluOp
`define EXE_OP_NOP          8'b00000000
`define EXE_OP_SSNOP        8'b00000000
`define EXE_OP_SLL          8'b00000000
`define EXE_OP_SRL          8'b00000010
`define EXE_OP_SRA          8'b00000011
`define EXE_OP_SYNC         8'b00001111
`define EXE_OP_AND          8'b00100100
`define EXE_OP_OR           8'b00100101
`define EXE_OP_XOR          8'b00100110
`define EXE_OP_NOR          8'b00100111
