`include "defines.v"

module mem_wb (
    input   wire                clk,
    input   wire                rst,
    // Inputs from mem module
    input   wire                mem_wreg,
    input   wire[`RegAddrBus]   mem_waddr,
    input   wire[`RegDataBus]   mem_wdata,
    // Outputs to wb module
    output  reg                 wb_wreg,
    output  reg [`RegAddrBus]   wb_waddr,
    output  reg [`RegDataBus]   wb_wdata
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        wb_waddr   <= `NOPRegAddr;
        wb_wreg    <= `WriteDisable;
        wb_wdata   <= `ZeroWord;	
    end 
    else begin
        wb_waddr   <= mem_waddr;
        wb_wreg    <= mem_wreg;
        wb_wdata   <= mem_wdata;
    end
end

endmodule