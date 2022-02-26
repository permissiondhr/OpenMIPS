`include "defines.v"

module ex_mem(
    input   wire			    clk,
    input   wire			    rst,
    // Inputs from ex module
    input   wire                ex_wreg,
    input   wire[`RegAddrBus]   ex_wd,
    input   wire[`RegDataBus]	ex_wdata,
    // Outputs to mem module
    output  reg                 mem_wreg,
    output  reg [`RegAddrBus]   mem_wd,
    output  reg [`RegDataBus]	mem_wdata
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_wd      <= `NOPRegAddr;
        mem_wreg    <= `WriteDisable;
        mem_wdata   <= `ZeroWord;	
    end 
    else begin
        mem_wd      <= ex_wd;
        mem_wreg    <= ex_wreg;
        mem_wdata   <= ex_wdata;
    end
end
            
endmodule