`include "defines.v"
`timescale 1ns/1ps

module openmips_min_sopc_tb();

reg     CLOCK_50;
reg     rst;

initial begin
    $display("Start simulation");
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars; // dump all vars
end

initial begin
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
end
    
initial begin
    rst = `RstEnable;
    #195 rst= `RstDisable;
    #10000 $finish;
end
 
openmips_min_sopc openmips_min_sopc0(
    .clk(CLOCK_50),
	  .rst(rst)	
);

endmodule