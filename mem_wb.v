`include "defines.v"

module mem_wb (
    input   wire                clk,
    input   wire                rst,
    // Inputs from mem module
    input   wire                mem_wreg,
    input   wire[`RegAddrBus]   mem_wd,
    input   wire[`RegDataBus]   mem_wdata,
    // Outputs to wb module
    output  reg                 wb_wreg,
    output  reg [`RegAddrBus]   wb_wd,
    output  reg [`RegDataBus]   wb_wdata
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        wb_wd      <= `NOPRegAddr;
        wb_wreg    <= `WriteDisable;
        wb_wdata   <= `ZeroWord;	
    end 
    else begin
        wb_wd      <= mem_wd;
        wb_wreg    <= mem_wreg;
        wb_wdata   <= mem_wdata;
    end
end

endmodule