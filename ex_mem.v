`include "defines.v"

module ex_mem(
    input   wire			    clk,
    input   wire			    rst,
    // Inputs from ex module
    input   wire                ex_wreg,
    input   wire[`RegAddrBus]   ex_waddr,
    input   wire[`RegDataBus]	ex_wdata,
    input   wire                ex_whilo,
    input   wire[`RegDataBus]   ex_hi,
    input   wire[`RegDataBus]	ex_lo,
    // Outputs to mem module
    output  reg                 mem_wreg,
    output  reg [`RegAddrBus]   mem_waddr,
    output  reg [`RegDataBus]	mem_wdata,
    output  reg                 mem_whilo,
    output  reg [`RegDataBus]   mem_hi,
    output  reg [`RegDataBus]	mem_lo
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_waddr   <= `NOPRegAddr;
        mem_wreg    <= `WriteDisable;
        mem_wdata   <= `ZeroWord;
        mem_whilo   <= `WriteDisable;
        mem_hi      <= `ZeroWord;
        mem_lo      <= `ZeroWord;
    end 
    else begin
        mem_waddr   <= ex_waddr;
        mem_wreg    <= ex_wreg;
        mem_wdata   <= ex_wdata;
        mem_whilo   <= ex_whilo;
        mem_hi      <= ex_hi;
        mem_lo      <= ex_lo;
    end
end
            
endmodule