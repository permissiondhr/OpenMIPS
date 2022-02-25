`include "defines.v"

module if_id(
    input   wire                clk,
    input   wire                rst,
    input   wire[`InstAddrBus]	if_pc,
    input   wire[`InstDataBus]  if_inst,
    output  reg [`InstAddrBus]  id_pc,
    output  reg [`InstDataBus]  id_inst
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord;         // When reset enable, pc sets to 0
        id_inst <= `ZeroWord;
    end 
    else begin
        id_pc <= if_pc;         
        id_inst <= if_inst;
    end
end

endmodule