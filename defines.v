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

// Defines in DIV module
`define DivFree             2'b00
`define DivByZero           2'b01
`define DivOn               2'b10
`define DivEnd              2'b11
`define DivResultNotReady   1'b0
`define DivResultReady      1'b1
`define DivStart            1'b1
`define DivStop             1'b0
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

//CPU Instructions Encoding - MIPS32 Architecture

// Instructions encoded by OPCODE field
// 28:26    000     001     010     011     100     101     110     111
// 31:29
// 000      SPECIAL REGIMM  J       JAL     BEQ     BNE     BLEZ    BGTZ
// 001      ADDI    ADDIU   SLTI    SLTIU   ANDI    ORI     XORI    LUI
// 010
// 011                                      SPECIAL2
// 100      LB      LH      LWL     LW      LBU     LHU     LWR
// 101      SB      SH      SWL     SW                      SWR
// 110                              PREF
// 111
`define EXE_SPECIAL_INST    6'b000000
`define EXE_REGIMM_INST     6'b000001
`define EXE_ADDI            6'b001000   // Arithmetic instructions
`define EXE_ADDIU           6'b001001
`define EXE_SLTI            6'b001010   // Set On Less Than
`define EXE_SLTIU           6'b001011
`define EXE_ANDI            6'b001100
`define EXE_ORI             6'b001101   // Logic instructions
`define EXE_XORI            6'b001110
`define EXE_LUI             6'b001111
`define EXE_SPECIAL2_INST   6'b011100
`define EXE_PREF            6'b110011

// Instructions encoded by FUNCTION field when OPCODE=SPECIAL
// 2:0      000     001     010     011     100     101     110     111
// 5:3
// 000      SLL             SRL     SRA     SLLV            SRLV    SRAV
// 001      JR      JALR    MOVZ    MOVN    SYSCALL BREAK           SYNC
// 010      MFHI    MTHI    MFLO    MTLO
// 011      MULT    MULTU   DIV     DIVU
// 100      ADD     ADDU    SUB     SUBU    AND     OR      XOR     NOR
// 101                      SLT     SLTU
// 110
// 111
`define EXE_NOP             6'b000000   // NOP:   32'h00000000 = sll $0, $0, 0
`define EXE_SSNOP           6'b000000   // SSNOP: 32'h00000040 = sll $0, $0, 1
`define EXE_SLL             6'b000000   // Shift instructions
`define EXE_SRL             6'b000010
`define EXE_SRA             6'b000011
`define EXE_SLLV            6'b000100 
`define EXE_SRLV            6'b000110 
`define EXE_SRAV            6'b000111
`define EXE_MOVZ            6'b001010   // Move instructions
`define EXE_MOVN            6'b001011
`define EXE_SYNC            6'b001111   // Sync instructions
`define EXE_MFHI            6'b010000   // HI/LO instructions
`define EXE_MTHI            6'b010001
`define EXE_MFLO            6'b010010
`define EXE_MTLO            6'b010011
`define EXE_MULT            6'b011000   // Multiply Word
`define EXE_MULTU           6'b011001   // Multiply Unsigned Word
`define EXE_DIV             6'b011010
`define EXE_DIVU            6'b011011
`define EXE_ADD             6'b100000   // Arithmetic instructions
`define EXE_ADDU            6'b100001
`define EXE_SUB             6'b100010
`define EXE_SUBU            6'b100011
`define EXE_AND             6'b100100   // Logic instructions
`define EXE_OR              6'b100101
`define EXE_XOR             6'b100110
`define EXE_NOR             6'b100111
`define EXE_SLT             6'b101010   // Set on Less Than
`define EXE_SLTU            6'b101011

// Instructions encoded by RT field when OPCODE=REGIMM
// 18:16    000     001     010     011     100     101     110     111
// 20:19
// 00      
// 01      
// 10

// Instructions encoded by FUNCTION field when OPCODE=SPECIAL2
// 2:0      000     001     010     011     100     101     110     111
// 5:3
// 000      MADD    MADDU   MUL             MSUB    MSUBU
// 001      
// 010      
// 011      
// 100      CLZ     CLO
// 101      
// 110
// 111
`define EXE_CLZ             6'b100000   // Count Leading Zeros
`define EXE_CLO             6'b100001   // Count Leading Ones
`define EXE_MUL             6'b000010   // Multiply Word to GPR
`define EXE_MADD            6'b000000   // Multiply and Add Word to Hi, Lo
`define EXE_MADDU           6'b000001
`define EXE_MSUB            6'b000100
`define EXE_MSUBU           6'b000101

// AluSel
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_ARITHMETIC  3'b100
`define EXE_RES_MUL         3'b101
`define EXE_RES_DIV         3'b110

// AluOp
`define EXE_OP_NOP          8'b00000000
`define EXE_OP_SSNOP        8'b00000000
`define EXE_OP_SLL          8'b00000000
`define EXE_OP_SRL          8'b00000010
`define EXE_OP_SRA          8'b00000011
`define EXE_OP_MOVZ         8'b00001010
`define EXE_OP_MOVN         8'b00001011
`define EXE_OP_SYNC         8'b00001111
`define EXE_OP_MFHI         8'b00010000
`define EXE_OP_MTHI         8'b00010001
`define EXE_OP_MFLO         8'b00010010
`define EXE_OP_MTLO         8'b00010011

`define EXE_OP_MULT         8'b00011000
`define EXE_OP_MULTU        8'b00011001
`define EXE_OP_DIV          8'b00011010
`define EXE_OP_DIVU         8'b00011011
`define EXE_OP_ADD          8'b00100000
`define EXE_OP_ADDU         8'b00100001
`define EXE_OP_SUB          8'b00100010
`define EXE_OP_SUBU         8'b00100011
`define EXE_OP_SLT          8'b00101010
`define EXE_OP_SLTU         8'b00101011

`define EXE_OP_AND          8'b00100100
`define EXE_OP_OR           8'b00100101
`define EXE_OP_XOR          8'b00100110
`define EXE_OP_NOR          8'b00100111

`define EXE_OP_CLZ          8'b11100000 // {2'b11, EXE_CLZ}
`define EXE_OP_CLO          8'b11100001 // {2'b11, EXE_CLO}
`define EXE_OP_MUL          8'b11000010 // {2'b11, EXE_MUL}
`define EXE_OP_MADD         8'b11000000
`define EXE_OP_MADDU        8'b11000001
`define EXE_OP_MSUB         8'b11000100
`define EXE_OP_MSUBU        8'b11000101