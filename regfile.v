`include "defines.v"

module regfile(
    input   wire	            clk,
    input   wire	            rst,
    // Write port
    input   wire				we,
    input   wire[`RegAddrBus]	waddr,
    input   wire[`RegDataBus]   wdata,
    // Read port 1
    input   wire				re1,
    input   wire[`RegAddrBus]	raddr1,
    output  reg [`RegDataBus]   rdata1,
    // Read port 2
    input   wire				re2,
    input   wire[`RegAddrBus]	raddr2,
    output  reg [`RegDataBus]   rdata2
);

reg [`RegDataBus] regs [`RegNum-1 : 0];                             // Defines RegNum(32) registers with width RegBus(32)

always @(posedge clk ) begin
    if (rst == `RstDisable)
        if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0))
            regs[waddr] <= wdata;                               // If write enable & write address !=0, write data to the corresponding address
end

always @(* ) begin                                              // Read circuit1 is combinational logic
    if (rst == `RstEnable)
        rdata1 <= `ZeroWord;
    else begin
        if (raddr1 == `RegNumLog2'h0)
            rdata1 <= `ZeroWord;                                // When read address1 is 0, read data1 always equals 0
        else begin
            if (re1 == `ReadEnable) begin
                if ((raddr1 == waddr) && (we == `WriteEnable))
                    rdata1 <= wdata;                            // When read address equals write address and write enable, read data1 equals write data
                else                                            // This method will solve the data conflict between wb & id stage
                    rdata1 <= regs[raddr1];                     // Normal read
            end
            else
                rdata1 <= `ZeroWord;                            // Otherwise, read data1 equals 0 
        end
    end
end

always @(* ) begin                                              // Read circuit2 is combinational logic and is the same as read circuit1
    if (rst == `RstEnable)
        rdata2 <= `ZeroWord;
    else begin
        if (raddr2 == `RegNumLog2'h0)
            rdata2 <= `ZeroWord;
        else begin
            if (re2 == `ReadEnable) begin
                if ((raddr2 == waddr) && (we == `WriteEnable))
                    rdata2 <= wdata;
                else
                    rdata2 <= regs[raddr2];
            end
            else
                rdata2 <= `ZeroWord;
        end
    end
end

endmodule