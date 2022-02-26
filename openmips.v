`include "defines.v"

module openmips (
    input   wire                clk,
    input   wire                rst,
    input   wire[`InstDataBus]  rom_data_i,
    output  wire[`InstAddrBus]  rom_addr_o,
    output  wire                rom_ce_o
);

// IF/ID & ID
wire[`InstAddrBus]  pc;
wire[`InstAddrBus]  id_pc_i;
wire[`InstDataBus]  id_inst_i;
// ID & ID/EX
wire[`AluOpBus]     id_aluop_o;
wire[`AluSelBus]    id_alusel_o;
wire[`RegDataBus]   id_reg1_o;
wire[`RegDataBus]   id_reg2_o;
wire                id_wreg_o;
wire[`RegAddrBus]   id_wd_o;
// ID/EX & EX
wire[`AluOpBus]     ex_aluop_i;
wire[`AluSelBus]    ex_alusel_i;
wire[`RegDataBus]   ex_reg1_i;
wire[`RegDataBus]   ex_reg2_i;
wire                ex_wreg_i;
wire[`RegAddrBus]   ex_wd_i;
// EX & EX/MEM
wire                ex_wreg_o;
wire[`RegAddrBus]   ex_wd_o;
wire[`RegDataBus]   ex_wdata_o;
// EX/MEM & MEM
wire                mem_wreg_i;
wire[`RegAddrBus]   mem_wd_i;
wire[`RegDataBus]   mem_wdata_i;
// MEM & MEM/RB
wire                mem_wreg_o;
wire[`RegAddrBus]   mem_wd_o;
wire[`RegDataBus]   mem_wdata_o;
// MEM/RB & REGFILE
wire                wb_wreg_i;
wire[`RegAddrBus]   wb_wd_i;
wire[`RegDataBus]   wb_wdata_i;
// REGFILE & ID
wire                reg1_read;
wire                reg2_read;
wire[`RegDataBus]   reg1_data;
wire[`RegDataBus]   reg2_data;
wire[`RegAddrBus]   reg1_addr;
wire[`RegAddrBus]   reg2_addr;
  
pc_reg pc_reg0(
	.clk    (clk),
	.rst    (rst),
    // Outputs to ROM
	.pc     (pc),
	.ce     (rom_ce_o)		
);
	
assign rom_addr_o = pc;     // PC outputs to ROM

if_id if_id0(
	.clk    (clk),
	.rst    (rst),
    // Inputs from pc_reg
	.if_pc  (pc),
	.if_inst(rom_data_i),
    // Outputs to id
	.id_pc  (id_pc_i),
	.id_inst(id_inst_i)      	
);
	
id id0(
	.rst        (rst),
    // Inputs from if/id
	.pc_i       (id_pc_i),
	.inst_i     (id_inst_i),
    // Inputs from regfile
	.reg1_data_i(reg1_data),
	.reg2_data_i(reg2_data),
    // Outputs to regfile
	.reg1_read_o(reg1_read),
	.reg2_read_o(reg2_read), 	  
	.reg1_addr_o(reg1_addr),
	.reg2_addr_o(reg2_addr), 
    // Outputs to id_ex
	.aluop_o    (id_aluop_o),
	.alusel_o   (id_alusel_o),
	.reg1_data_o(id_reg1_o),
	.reg2_data_o(id_reg2_o),
	.wd_o       (id_wd_o),
	.wreg_o     (id_wreg_o)
);

regfile regfile1(
	.clk        (clk),
	.rst        (rst),
    // Inputs from wb(mem/wb)
	.we	        (wb_wreg_i),
	.waddr      (wb_wd_i),
	.wdata      (wb_wdata_i),
    // Inputs/Outputs from/to id
	.re1        (reg1_read),
	.raddr1     (reg1_addr),
	.rdata1     (reg1_data),
	.re2        (reg2_read),
	.raddr2     (reg2_addr),
	.rdata2     (reg2_data)
);

id_ex id_ex0(
	.clk        (clk),
	.rst        (rst),
	//Inputs from id
	.id_aluop   (id_aluop_o),
	.id_alusel  (id_alusel_o),
	.id_reg1_data(id_reg1_o),
	.id_reg2_data(id_reg2_o),
	.id_wd      (id_wd_o),
	.id_wreg    (id_wreg_o),
    // Outputs to ex
	.ex_aluop   (ex_aluop_i),
	.ex_alusel  (ex_alusel_i),
	.ex_reg1_data(ex_reg1_i),
	.ex_reg2_data(ex_reg2_i),
	.ex_wd      (ex_wd_i),
	.ex_wreg    (ex_wreg_i)
);		

ex ex0(
	.rst        (rst),
    // Inputs from id_ex
	.aluop_i    (ex_aluop_i),
	.alusel_i   (ex_alusel_i),
	.reg1_data_i     (ex_reg1_i),
	.reg2_data_i     (ex_reg2_i),
	.wd_i       (ex_wd_i),
	.wreg_i     (ex_wreg_i),
    // Outputs to ex_mem
	.wd_o       (ex_wd_o),
	.wreg_o     (ex_wreg_o),
	.wdata_o    (ex_wdata_o)
);

ex_mem ex_mem0(
	.clk        (clk),
	.rst        (rst),
    // Inputs from ex
	.ex_wd      (ex_wd_o),
	.ex_wreg    (ex_wreg_o),
	.ex_wdata   (ex_wdata_o),
    // Outputs to ex_mem
	.mem_wd     (mem_wd_i),
	.mem_wreg   (mem_wreg_i),
	.mem_wdata  (mem_wdata_i)				       	
);
	
mem mem0(
	.rst        (rst),
    // Inputs from ex_mem
	.wd_i       (mem_wd_i),
	.wreg_i     (mem_wreg_i),
	.wdata_i    (mem_wdata_i),
    // Outputs to mem_wb
	.wd_o       (mem_wd_o),
	.wreg_o     (mem_wreg_o),
	.wdata_o    (mem_wdata_o)
);

mem_wb mem_wb0(
	.clk        (clk),
	.rst        (rst),
    // Inputs from mem
	.mem_wd     (mem_wd_o),
	.mem_wreg   (mem_wreg_o),
	.mem_wdata  (mem_wdata_o),
    // Outputs to regfile
	.wb_wd      (wb_wd_i),
	.wb_wreg    (wb_wreg_i),
	.wb_wdata   (wb_wdata_i)
);

endmodule