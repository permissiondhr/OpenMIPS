`include "defines.v"

module pc_reg (
    input   wire                clk,
    input   wire                rst,
    input   wire[5:0]           stall,  // From ctrl module, pipline stall signal
    output  reg [`InstAddrBus]  pc,
    output  reg                 ce
);

always @(posedge clk ) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;         // When reset, disable ROM
    end
    else begin
        ce <= `ChipEnable;          // Otherwise, enable ROM
    end
end

always @(posedge clk ) begin
    if (ce == `ChipDisable) begin
        pc <= 32'h00000000;         // When ROM disabled, pc resets to 0
    end
    else begin
        if (stall[0] == `NoStop)    // Pc continue
            pc <= pc + 32'h00000004;// pc accumulates by 4 every clock cycle
    end
end

endmodule