`include "defines.v"

module mem(
	input   wire				rst,
	input   wire                wreg_i,
    input   wire[`RegAddrBus]   waddr_i,
	input   wire[`RegDataBus]	wdata_i,
	input	wire                whilo_i,
    input	wire[`RegDataBus]   hi_i,
    input	wire[`RegDataBus]   lo_i,
	output  reg                 wreg_o,
    output  reg [`RegAddrBus]   waddr_o,
	output  reg [`RegDataBus]	wdata_o,
	output  reg                 whilo_o,
    output  reg [`RegDataBus]   hi_o,
    output  reg [`RegDataBus]   lo_o
	
);

always @ (*) begin
	if(rst == `RstEnable) begin
		waddr_o <= `NOPRegAddr;
		wreg_o  <= `WriteDisable;
	    wdata_o <= `ZeroWord;
		whilo_o <= `WriteDisable;
        hi_o    <= `ZeroWord;
        lo_o    <= `ZeroWord;
	end 
    else begin
	    waddr_o <= waddr_i;
		wreg_o  <= wreg_i;
		wdata_o <= wdata_i;
		whilo_o <= whilo_i;
		hi_o    <= hi_i;
		lo_o    <= lo_i;
	end
end
			
endmodule