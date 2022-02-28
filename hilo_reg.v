`include "defines.v"

module hilo_reg (
    input   wire                clk,
    input   wire                rst,
    input   wire                we,
    input   wire[`RegDataBus]   hi_i,
    input   wire[`RegDataBus]   lo_i,
    output  reg [`RegDataBus]   hi_o,
    output  reg [`RegDataBus]   lo_o
);

always @(posedge clk ) begin
    if (rst == `RstEnable) begin
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end
    else begin
        if (we == `WriteEnable) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end
end
endmodule