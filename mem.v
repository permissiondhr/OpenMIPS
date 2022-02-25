`include "defines.v"

module mem(
	input   wire				rst,
	input   wire                wreg_i,
    input   wire[`RegAddrBus]   wd_i,
	input   wire[`RegDataBus]	wdata_i,
	output  reg                 wreg_o,
    output  reg [`RegAddrBus]   wd_o,
	output  reg [`RegDataBus]	wdata_o
	
);

always @ (*) begin
	if(rst == `RstEnable) begin
		wd_o    <= `NOPRegAddr;
		wreg_o  <= `WriteDisable;
	    wdata_o <= `ZeroWord;
	end 
    else begin
	    wd_o    <= wd_i;
		wreg_o  <= wreg_i;
		wdata_o <= wdata_i;
	end
end
			
endmodule