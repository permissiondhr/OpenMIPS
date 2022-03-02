`include "defines.v"

module ctrl (
    input   wire        rst,
    input   wire        stallreq_from_id,
    input   wire        stallreq_from_ex,
    output  reg [5:0]   stall               // pc:0, if/id:1, id/ex:2, ex/mem:3, mem/wb:4
);

always @(*) begin
    if (rst == `RstEnable)
        stall <= 6'b000000;
    else begin
        if (stallreq_from_ex == `Stop)
            stall <= 6'b001111;
        else begin
            if (stallreq_from_id == `Stop)
                stall <= 6'b000111;
            else
                stall <= 6'b000000;
        end
    end
end

endmodule