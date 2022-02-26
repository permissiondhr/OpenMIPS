`include "defines.v"

module inst_rom (
    input   wire                ce,
    input   wire[`InstAddrBus] addr,
    output  wire[`InstDataBus] inst
);

// Define an array with size=InstMemNum, width=8bit
reg[7:0]    inst_mem[`InstMemNum-1:0];

// use file inst_rom.data to initialize instruction memeory
initial $readmemh ("./AsmTest/inst_rom.data", inst_mem);

//assign inst = (ce == `ChipDisable) ? `ZeroWord : {inst_mem[addr[`InstMemNumLog2-1:0]], inst_mem[addr[`InstMemNumLog2-1:0]+17'h00001], inst_mem[addr[`InstMemNumLog2-1:0]+17'h00002], inst_mem[addr[`InstMemNumLog2-1:0]]+17'h00003};

assign inst[31:24] = (ce == `ChipDisable) ? 8'h00 : inst_mem[addr[`InstMemNumLog2-1:0]];
assign inst[23:16] = (ce == `ChipDisable) ? 8'h00 : inst_mem[addr[`InstMemNumLog2-1:0]+1];
assign inst[15: 8] = (ce == `ChipDisable) ? 8'h00 : inst_mem[addr[`InstMemNumLog2-1:0]+2];
assign inst[7 : 0] = (ce == `ChipDisable) ? 8'h00 : inst_mem[addr[`InstMemNumLog2-1:0]+3];
endmodule