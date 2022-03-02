`include "defines.v"

module if_id(
    input   wire                clk,
    input   wire                rst,
    input   wire[`InstAddrBus]	if_pc,
    input   wire[`InstDataBus]  if_inst,
    input   wire[5:0]           stall,
    output  reg [`InstAddrBus]  id_pc,
    output  reg [`InstDataBus]  id_inst
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        id_pc <= `ZeroWord;                                 // When reset enable, pc sets to 0
        id_inst <= `ZeroWord;
    end 
    else begin
        if (stall[1] == `Stop && stall[2] == `NoStop) begin // If stage stop & id stage not stop, pass NOP instructions to id stage
            id_pc   <= `ZeroWord;    
            id_inst <= `ZeroWord;
        end
        else begin
            if (stall[1] == `NoStop) begin                  // If stage not stop, pass normal instructions to id stage
                id_pc <= if_pc;
                id_inst <= if_inst;
            end
        end                                                 // If & id stages both stop, hold current instructions        
    end
end

endmodule