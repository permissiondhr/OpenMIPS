`include "defines.v"

module mem_wb (
    input   wire                clk,
    input   wire                rst,
    // Inputs from mem module
    input   wire                mem_wreg,
    input   wire[`RegAddrBus]   mem_waddr,
    input   wire[`RegDataBus]   mem_wdata,
    input   wire                mem_whilo,
    input   wire[`RegDataBus]   mem_hi,
    input   wire[`RegDataBus]	mem_lo,
    // Outputs to wb module
    output  reg                 wb_wreg,
    output  reg [`RegAddrBus]   wb_waddr,
    output  reg [`RegDataBus]   wb_wdata,
    output  reg                 wb_whilo,
    output  reg [`RegDataBus]   wb_hi,
    output  reg [`RegDataBus]	wb_lo
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        wb_waddr   <= `NOPRegAddr;
        wb_wreg    <= `WriteDisable;
        wb_wdata   <= `ZeroWord;
        wb_whilo   <= `WriteDisable;
        wb_hi      <= `ZeroWord;
        wb_lo      <= `ZeroWord;	
    end 
    else begin
        wb_waddr   <= mem_waddr;
        wb_wreg    <= mem_wreg;
        wb_wdata   <= mem_wdata;
        wb_whilo   <= mem_whilo;
        wb_hi      <= mem_hi;
        wb_lo      <= mem_lo;
    end
end

endmodule