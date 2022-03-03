`include "defines.v"

module div (
    input   wire                clk,
    input   wire                rst,
    // Inputs from ex module
    input   wire                signed_div_i,
    input   wire[`RegDataBus]   opdata1_i,
    input   wire[`RegDataBus]   opdata2_i,
    input   wire                start_i,
    input   wire                annul_i,        // Cancel division operation
    // Outputs to ex module
    output  reg [`DoubleRegDataBus] result_o,
    output  reg                 ready_o
);

// Assume m[k:0] / n = s
// k from 31 -> 0
// minuend = m[k], subtrahend = n
//                          minuend - n >= 0 ?
//      no                                          yes
//      s[k] = 0                                    s[k] = 1
//      k == 0 ?    yes->       end     <- yes      k == 0 ?
//      no                                          no
//      minuend = {minuend, m[k-1]}                 minuend = {minuend-n, m[k-1]}
//                              k = k - 1

wire[32:0]  div_temp;
reg [5 :0]  cnt;        // Counts how many cycle is going on, when equals 32, division ends
reg [63:0]  dividend;   // {[63:32], [31:], [31-k:0]} = {minuend, m[31-k:0], s}
reg [ 1:0]  state;
reg [31:0]  divisor;
reg [31:0]  temp_op1;
reg [31:0]  temp_op2;

assign div_temp = {1'b0, dividend[62:31]} - {1'b0, divisor}; // minuend - n >= 0, LSB of dividend is at [31], so first clock cycle has 1 bit

always @(posedge clk ) begin
    if (rst == `RstEnable) begin
        state   <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o<= {`ZeroWord, `ZeroWord};
    end
    else begin
        case (state)
            `DivFree: begin
                if (start_i == `DivStart && annul_i == 1'b0) begin
                    if (opdata2_i == `ZeroWord)
                        state   <= `DivByZero;
                    else begin
                        state   <= `DivOn;
                        cnt     <= 6'b000000;
                        if (signed_div_i && opdata1_i[31])  // When negtive, get 2's complement
                            temp_op1 = ~opdata1_i + 1;
                        else
                            temp_op1 = opdata1_i;
                        if (signed_div_i && opdata2_i[31])  // When negtive, get 2's complement
                            temp_op2 = ~opdata2_i + 1;
                        else
                            temp_op2 = opdata2_i;
                        dividend[63:32] <= `ZeroWord;
                        dividend[31: 0] <= temp_op1;        // Put MSB of dividend at [31], so first clock cycle will only have 1 bit of dividend
                        divisor         <= temp_op2;
                    end
                end
                else begin
                    ready_o <= `DivResultNotReady;
                    result_o <= {`ZeroWord, `ZeroWord};
                end
            end 
            `DivByZero: begin
                dividend <= {`ZeroWord, `ZeroWord};
                state    <= `DivEnd;
            end
            `DivOn: begin
                if (annul_i == 1'b0) begin
                    if (cnt != 6'b100000) begin     // Division not end
                        if (div_temp[32])           // Minuend - n < 0
                            dividend <= {dividend[62:0], 1'b0};
                        else
                            dividend <= {div_temp[31:0], dividend[30:0], 1'b1};
                        cnt <= cnt + 1;
                    end
                    else begin                      // Division end
                        if (signed_div_i && (opdata1_i[31] ^ opdata2_i[31]))
                            dividend[31:0] <= ~dividend[31:0] + 1;
                        if (signed_div_i && (opdata1_i[31] ^ dividend[63]))
                            dividend[63:32] <= ~dividend[63:32] + 1;
                        state <= `DivEnd;
                        cnt <= 6'b000000;
                    end
                end
                else
                    state <= `DivFree;
            end
            `DivEnd: begin
                result_o <= {dividend[63:32], dividend[31:0]};
                ready_o  <= `DivResultReady;
                if (start_i == `DivStop) begin
                    state   <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o<= {`ZeroWord, `ZeroWord};
                end
            end
            default: ;
        endcase
    end
end

endmodule