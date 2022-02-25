`include "defines.v"

module pc_reg (
    input   wire                clk,
    input   wire                rst,
    output  reg [`InstAddrBus]  pc,
    output  reg                 ce
);

always @(posedge clk ) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;         // When reset, disable ROM
    end
    else begin
        ce <= `ChipEnable;
    end
end

always @(posedge clk ) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h00000000;         // When ROM disabled, pc resets to 0
    end
    else begin
        pc <= pc + 32'h00000004;    // pc accumulates by 4 every clock cycle
    end
end

endmodule