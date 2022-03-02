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
    // Input from ctrl module
    input   wire[5:0]           stall,
    // Outputs to mem module
    output  reg                 mem_wreg,
    output  reg [`RegAddrBus]   mem_waddr,
    output  reg [`RegDataBus]	mem_wdata,
    output  reg                 mem_whilo,
    output  reg [`RegDataBus]   mem_hi,
    output  reg [`RegDataBus]	mem_lo,
    // Inputs/outputs for MADD/MSUB instructions
    input   wire[`DoubleRegDataBus] hilo_i,
    input   wire[1:0]               cnt_i,
    output  reg [`DoubleRegDataBus] hilo_o,
    output  reg [1:0]               cnt_o
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        mem_waddr   <= `NOPRegAddr;
        mem_wreg    <= `WriteDisable;
        mem_wdata   <= `ZeroWord;
        mem_whilo   <= `WriteDisable;
        mem_hi      <= `ZeroWord;
        mem_lo      <= `ZeroWord;
        hilo_o      <= {`ZeroWord, `ZeroWord};
        cnt_o       <= 2'b00;
    end 
    else begin
        if (stall[3] == `Stop && stall[4] == `NoStop) begin // When stall, do nothing
            mem_waddr   <= `NOPRegAddr;
            mem_wreg    <= `WriteDisable;
            mem_wdata   <= `ZeroWord;
            mem_whilo   <= `WriteDisable;                   // At first clock cycle of MADD/MSUB, pipline stall, whilo is *disabled*, so HI/LO has no data conflict and remain previous value
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
            hilo_o      <= hilo_i;
            cnt_o       <= cnt_i;
        end
        else begin
            if (stall[3] == `NoStop) begin                  // Normal
                mem_waddr   <= ex_waddr;
                mem_wreg    <= ex_wreg;
                mem_wdata   <= ex_wdata;
                mem_whilo   <= ex_whilo;
                mem_hi      <= ex_hi;
                mem_lo      <= ex_lo;
                hilo_o      <= {`ZeroWord, `ZeroWord};
                cnt_o       <= 2'b00;
            end                                             // Hold current value
            else begin
                hilo_o      <= hilo_i;
                cnt_o       <= cnt_i;
            end
        end                                                 
    end
end
            
endmodule