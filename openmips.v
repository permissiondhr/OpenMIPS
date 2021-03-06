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
wire[`RegAddrBus]   id_waddr_o;

// ID/EX & EX
wire[`AluOpBus]     ex_aluop_i;
wire[`AluSelBus]    ex_alusel_i;
wire[`RegDataBus]   ex_reg1_i;
wire[`RegDataBus]   ex_reg2_i;
wire                ex_wreg_i;
wire[`RegAddrBus]   ex_waddr_i;
// EX & EX/MEM
wire                ex_wreg_o;
wire[`RegAddrBus]   ex_waddr_o;
wire[`RegDataBus]   ex_wdata_o;
wire                ex_whilo_o;
wire[`RegDataBus]   ex_hi_o;
wire[`RegDataBus]   ex_lo_o;
wire[`DoubleRegDataBus] ex_hilo_i;
wire[1:0]               ex_cnt_i;
wire[`DoubleRegDataBus] ex_hilo_o;
wire[1:0]               ex_cnt_o;

// EX/MEM & MEM
wire                mem_wreg_i;
wire[`RegAddrBus]   mem_waddr_i;
wire[`RegDataBus]   mem_wdata_i;
wire                mem_whilo_i;
wire[`RegDataBus]   mem_hi_i;
wire[`RegDataBus]	mem_lo_i;
// MEM & MEM/WB
wire                mem_wreg_o;
wire[`RegAddrBus]   mem_waddr_o;
wire[`RegDataBus]   mem_wdata_o;
wire                mem_whilo_o;
wire[`RegDataBus]   mem_hi_o;
wire[`RegDataBus]	mem_lo_o;
// MEM/WB & REGFILE
wire                wb_wreg_i;
wire[`RegAddrBus]   wb_waddr_i;
wire[`RegDataBus]   wb_wdata_i;
wire                wb_whilo_i;
wire[`RegDataBus]   wb_hi_i;
wire[`RegDataBus]	wb_lo_i;
// REGFILE & ID
wire                reg1_read;
wire                reg2_read;
wire[`RegDataBus]   reg1_data;
wire[`RegDataBus]   reg2_data;
wire[`RegAddrBus]   reg1_addr;
wire[`RegAddrBus]   reg2_addr;
// HILO & EX
wire[`RegDataBus]   hi_data;
wire[`RegDataBus]   lo_data;
// Ctrl module
wire        stallreq_from_id;
wire        stallreq_from_ex;
wire [5:0]  stall;
// div module
wire                div_signed;
wire[`RegDataBus]   div_opdata1;
wire[`RegDataBus]   div_opdata2;
wire                div_start;
//wire                annul_i;
wire[`DoubleRegDataBus] div_result;
wire                div_ready;
// Branch signal
wire                branch_flag;
wire[`RegDataBus]   branch_target_address;
wire                id_is_in_delayslot_o;       
wire[`RegDataBus]   id_link_addr_o;             
wire                id_next_inst_in_delayslot_o;
wire                id_is_in_delayslot_i;
wire                ex_is_in_delayslot_i;
wire[`RegDataBus]   ex_link_address_i;

pc_reg pc_reg0(
    .clk    (clk),
    .rst    (rst),
    // Input from ctrl module
    .stall  (stall),
    // Branch signal
    .branch_flag_i          (branch_flag),
    .branch_target_address_i(branch_target_address),
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
    // Input from ctrl module
    .stall  (stall),
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
    // Added to resolve data conflict between id & ex/mem stage
    .ex_wdata_i	(ex_wdata_o),
    .ex_waddr_i	(ex_waddr_o),
    .ex_wreg_i	(ex_wreg_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_waddr_i(mem_waddr_o),
    .mem_wreg_i	(mem_wreg_o),
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
    .waddr_o    (id_waddr_o),
    .wreg_o     (id_wreg_o),
    .stallreq   (stallreq_from_id),
    // Branch signal
    .branch_flag_o              (branch_flag),
    .branch_target_address_o    (branch_target_address),
    .is_in_delayslot_o          (id_is_in_delayslot_o),
    .link_addr_o                (id_link_addr_o),
    .next_inst_in_delayslot_o   (id_next_inst_in_delayslot_o),
    .is_in_delayslot_i          (id_is_in_delayslot_i)
);

regfile regfile1(
    .clk        (clk),
    .rst        (rst),
    // Inputs from wb(mem/wb)
    .we	        (wb_wreg_i),
    .waddr      (wb_waddr_i),
    .wdata      (wb_wdata_i),
    // Inputs/Outputs from/to id
    .re1        (reg1_read),
    .raddr1     (reg1_addr),
    .rdata1     (reg1_data),
    .re2        (reg2_read),
    .raddr2     (reg2_addr),
    .rdata2     (reg2_data)
);

hilo_reg hilo_reg0(
    .clk        (clk),
    .rst        (rst),
    .we         (wb_whilo_i),
    .hi_i       (wb_hi_i),
    .lo_i       (wb_lo_i),
    .hi_o       (hi_data),
    .lo_o       (lo_data) 
);

id_ex id_ex0(
    .clk        (clk),
    .rst        (rst),
    //Inputs from id
    .id_aluop   (id_aluop_o),
    .id_alusel  (id_alusel_o),
    .id_reg1_data(id_reg1_o),
    .id_reg2_data(id_reg2_o),
    .id_waddr   (id_waddr_o),
    .id_wreg    (id_wreg_o),
    // Input from ctrl module
    .stall  (stall),
    // Outputs to ex
    .ex_aluop   (ex_aluop_i),
    .ex_alusel  (ex_alusel_i),
    .ex_reg1_data(ex_reg1_i),
    .ex_reg2_data(ex_reg2_i),
    .ex_waddr   (ex_waddr_i),
    .ex_wreg    (ex_wreg_i),
    // Branch signal
    .id_is_in_delayslot         (id_is_in_delayslot_o),
    .id_link_address            (id_link_addr_o),
    .next_inst_in_delayslot_i   (id_next_inst_in_delayslot_o),
    .ex_is_in_delayslot         (ex_is_in_delayslot_i),
    .ex_link_address            (ex_link_address_i),
    .is_in_delayslot_o          (id_is_in_delayslot_i)
);		

ex ex0(
    .rst        (rst),
    // Inputs from id_ex
    .aluop_i    (ex_aluop_i),
    .alusel_i   (ex_alusel_i),
    .reg1_data_i(ex_reg1_i),
    .reg2_data_i(ex_reg2_i),
    .waddr_i    (ex_waddr_i),
    .wreg_i     (ex_wreg_i),
    // Inputs from mem/wb
    .hi_i       (hi_data),
    .lo_i       (lo_data),
    .mem_whilo_i(mem_whilo_o),
    .mem_hi_i   (mem_hi_o),
    .mem_lo_i   (mem_lo_o),
    .wb_whilo_i (wb_whilo_i),
    .wb_hi_i    (wb_hi_i),
    .wb_lo_i    (wb_lo_i),
    // Outputs to ex_mem
    .waddr_o    (ex_waddr_o),
    .wreg_o     (ex_wreg_o),
    .wdata_o    (ex_wdata_o),
    .whilo_o    (ex_whilo_o),
    .hi_o       (ex_hi_o),
    .lo_o       (ex_lo_o),
    // MADD/MSUB instruction signal
    .hilo_temp_i(ex_hilo_i),
    .cnt_i      (ex_cnt_i),
    .hilo_temp_o(ex_hilo_o),
    .cnt_o      (ex_cnt_o),
    .stallreq   (stallreq_from_ex),
    // DIV module
    .div_signed_o   (div_signed),
    .div_opdata1_o  (div_opdata1),
    .div_opdata2_o  (div_opdata2),
    .div_start_o    (div_start),
    .div_result_i   (div_result),
    .div_ready_i    (div_ready),
    .link_addr_i        (ex_link_address_i),
    .is_in_delayslot_i  (ex_is_in_delayslot_i)
    
);

ex_mem ex_mem0(
    .clk        (clk),
    .rst        (rst),
    // Inputs from ex
    .ex_waddr   (ex_waddr_o),
    .ex_wreg    (ex_wreg_o),
    .ex_wdata   (ex_wdata_o),
    .ex_whilo   (ex_whilo_o),  
    .ex_hi      (ex_hi_o),
    .ex_lo      (ex_lo_o),
    // MADD/MSUB instruction signal
    .hilo_i     (ex_hilo_o),
    .cnt_i      (ex_cnt_o),
    .hilo_o     (ex_hilo_i),
    .cnt_o      (ex_cnt_i),
    // Input from ctrl module
    .stall      (stall),
    // Outputs to mem
    .mem_waddr  (mem_waddr_i),
    .mem_wreg   (mem_wreg_i),
    .mem_wdata  (mem_wdata_i),
    .mem_whilo  (mem_whilo_i),
    .mem_hi     (mem_hi_i),
    .mem_lo     (mem_lo_i)
);
    
mem mem0(
    .rst        (rst),
    // Inputs from ex_mem
    .waddr_i    (mem_waddr_i),
    .wreg_i     (mem_wreg_i),
    .wdata_i    (mem_wdata_i),
    .whilo_i    (mem_whilo_i),
    .hi_i       (mem_hi_i),
    .lo_i       (mem_lo_i),
    // Outputs to mem_wb
    .waddr_o    (mem_waddr_o),
    .wreg_o     (mem_wreg_o),
    .wdata_o    (mem_wdata_o),
    .whilo_o    (mem_whilo_o),
    .hi_o       (mem_hi_o),
    .lo_o       (mem_lo_o)
);

mem_wb mem_wb0(
    .clk        (clk),
    .rst        (rst),
    // Inputs from mem
    .mem_waddr  (mem_waddr_o),
    .mem_wreg   (mem_wreg_o),
    .mem_wdata  (mem_wdata_o),
    .mem_whilo  (mem_whilo_o),
    .mem_hi     (mem_hi_o),
    .mem_lo     (mem_lo_o),
    // Input from ctrl module
    .stall  (stall),
    // Outputs to regfile
    .wb_waddr   (wb_waddr_i),
    .wb_wreg    (wb_wreg_i),
    .wb_wdata   (wb_wdata_i),
    .wb_whilo   (wb_whilo_i),
    .wb_hi      (wb_hi_i),
    .wb_lo      (wb_lo_i)
);

ctrl ctrl0(
    .rst                (rst),
    .stallreq_from_id   (stallreq_from_id),
    .stallreq_from_ex   (stallreq_from_ex),
    .stall              (stall) 
);

div div0(
    .clk            (clk),
    .rst            (rst),
    .signed_div_i   (div_signed),
    .opdata1_i      (div_opdata1),
    .opdata2_i      (div_opdata2),
    .start_i        (div_start),
    .annul_i        (1'b0),
    .result_o       (div_result),
    .ready_o        (div_ready)
);

endmodule