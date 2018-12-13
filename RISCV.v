`include "define.v"
module RISCV(
	input wire 				clk,
	input wire 				rst,
	input wire 				rdy,
	input wire[`byteBus]	ma_data_in,
	output wire[`regBus]	ma_addr_out,
	output wire[`byteBus]	ma_data_out,
	output wire				ma_rw_out,
	output wire 			ma_ce_out
);

wire[`stallBus]	stall;
wire 			mcu_if_stall_stall;
wire 			id_data_stall_stall;
wire 			mem_ma_stall_stall;
wire 			if_b_stall_stall;

STALL STALL0(
				.rst(rst),
				.rdy(rdy),
				.stall(stall),
				.if_mem_stall_in(mcu_if_stall_stall),
				.id_data_stall_in(id_data_stall_stall),
				.mem_ma_stall_in(mem_ma_stall_stall),
				.if_b_stall_in(if_b_stall_stall)
			);

wire[`regBus] 		if_addr_mcu;
wire 				if_ce_mcu;
wire 				id_br_if;

wire[`regBus]		if_inst_ifid;
wire[`regBus] 		if_addr_ifid;
wire[`regBus]		id_new_addr_if;

IF 		IF0(	.clk(clk),
				.rst(rst),
				.br_flag(id_br_if),
				.stall(stall),
				.new_addr(id_new_addr_if),
				.mem_data_in(ma_data_in),

				.if_inst_out(if_inst_ifid),
				.if_addr_out(if_addr_ifid),

				.if_mcu_addr(if_addr_mcu),
				.mcu_ce(if_ce_mcu),
				.if_b_stall_req(if_b_stall_stall)
			);

wire[`regBus]	ifid_addr_id;
wire[`regBus]	ifid_inst_id;

IFID 	IFID0(	.clk(clk),
				.rst(rst),
				.stall(stall),
				.if_inst_in(if_inst_ifid),
				.if_addr_in(if_addr_ifid),
				.ifid_addr_out(ifid_addr_id),
				.ifid_inst_out(ifid_inst_id)
			);

wire[`execBus]		id_exec_idex;
wire[`regBus]		id_rs1_idex;
wire[`regBus]		id_rs2_idex;
wire[`regBus]		id_imm_idex;
wire[`regBus]		id_addr_idex;
wire[`regAddrBus]	id_rdest_idex;
wire				id_we_idex;
wire				id_mux_idex;	

wire[`regBus]		memwb_res_reg;
wire[`regAddrBus]	memwb_rdest_reg;
wire				memwb_we_reg;

wire				ex_fw_we_id;
wire[`regAddrBus]	ex_fw_addr_id;
wire[`regBus]		ex_fw_data_id;
wire[`execBus]		ex_fw_exec_id;

wire				mem_fw_we_id;
wire[`regAddrBus]	mem_fw_addr_id;
wire[`regBus]		mem_fw_data_id;

ID 		ID0(	.rst(rst),
				.clk(clk),
				.stall(stall),

				.ifid_inst_in(ifid_inst_id),
				.ifid_addr_in(ifid_addr_id),

				.reg_we(memwb_we_reg),
				.reg_addr(memwb_rdest_reg),
				.reg_data(memwb_res_reg),

				.id_exec_out(id_exec_idex),
				.id_rs1_out(id_rs1_idex),
				.id_rs2_out(id_rs2_idex),
				.id_imm_out(id_imm_idex),
				.id_addr_out(id_addr_idex),
				.id_rdest_out(id_rdest_idex),
				.id_we_out(id_we_idex),
				.id_mux_out(id_mux_idex),

				.id_data_stall(id_data_stall_stall),
				.id_new_addr_out(id_new_addr_if),
				.branch_flag(id_br_if),

				.ex_we_in(ex_fw_we_id),
				.ex_addr_in(ex_fw_addr_id),
				.ex_data_in(ex_fw_data_id),
				.ex_exec_in(ex_fw_exec_id),

				.mem_we_in(mem_fw_we_id),
				.mem_addr_in(mem_fw_addr_id),
				.mem_data_in(mem_fw_data_id)
			);

wire[`execBus]		idex_exec_ex;
wire[`regAddrBus]	idex_rdest_ex;
wire[`regBus]		idex_rs1_ex;
wire[`regBus]		idex_rs2_ex;
wire[`regBus]		idex_imm_ex;
wire[`regBus]		idex_addr_ex;
wire				idex_mux_ex;
wire				idex_we_ex;

IDEX 	IDEX0(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.id_exec_in(id_exec_idex),
				.id_rdest_in(id_rdest_idex),
				.id_rs1_in(id_rs1_idex),
				.id_rs2_in(id_rs2_idex),
				.id_imm_in(id_imm_idex),
				.id_addr_in(id_addr_idex),
				.id_we_in(id_we_idex),
				.id_mux_in(id_mux_idex),

				.idex_exec_out(idex_exec_ex),
				.idex_rdest_out(idex_rdest_ex),
				.idex_rs1_out(idex_rs1_ex),
				.idex_rs2_out(idex_rs2_ex),
				.idex_imm_out(idex_imm_ex),
				.idex_addr_out(idex_addr_ex),
				.idex_mux_out(idex_mux_ex),
				.idex_we_out(idex_we_ex)
			);

wire[`regBus]		ex_alu_exmem;
wire[`regBus]		ex_rs1_exmem;
wire[`regBus]		ex_rs2_exmem;
wire[`execBus]		ex_exec_exmem;
wire[`regAddrBus]	ex_rdest_exmem;
wire				ex_we_exmem;

EX 		EX0(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.idex_exec_in(idex_exec_ex),
				.idex_rdest_in(idex_rdest_ex),
				.idex_rs1_in(idex_rs1_ex),
				.idex_rs2_in(idex_rs2_ex),
				.idex_imm_in(idex_imm_ex),
				.idex_addr_in(idex_addr_ex),
				.idex_mux_in(idex_mux_ex),
				.idex_we_in(idex_we_ex),

				.ex_alu_out(ex_alu_exmem),
				.ex_rs1_out(ex_rs1_exmem),
				.ex_rs2_out(ex_rs2_exmem),
				.ex_exec_out(ex_exec_exmem),
				.ex_rdest_out(ex_rdest_exmem),
				.ex_we_out(ex_we_exmem)
			);

wire[`regBus]		exmem_alu_mem;
wire[`regBus]		exmem_rs1_mem;
wire[`regBus]		exmem_rs2_mem;
wire[`execBus]		exmem_exec_mem;
wire[`regAddrBus]	exmem_rdest_mem;
wire				exmem_we_mem;

assign ex_fw_data_id 	= ex_alu_exmem;
assign ex_fw_addr_id 	= ex_rdest_exmem ;
assign ex_fw_we_id 		= ex_we_exmem;
assign ex_fw_exec_id	= ex_exec_exmem;

EXMEM	EXMEM(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.ex_alu_in(ex_alu_exmem),
				.ex_rs1_in(ex_rs1_exmem),
				.ex_rs2_in(ex_rs2_exmem),
				.ex_exec_in(ex_exec_exmem),
				.ex_rdest_in(ex_rdest_exmem),
				.ex_we_in(ex_we_exmem),

				.exmem_alu_out(exmem_alu_mem),
				.exmem_rs1_out(exmem_rs1_mem),
				.exmem_rs2_out(exmem_rs2_mem),
				.exmem_exec_out(exmem_exec_mem),
				.exmem_rdest_out(exmem_rdest_mem),
				.exmem_we_out(exmem_we_mem)
			);

wire[`regBus]		mem_res_memwb;
wire[`regAddrBus]	mem_rdest_memwb;
wire        		mem_we_memwb;

wire[`regBus]		mcu_data_mem;
wire 				mcu_busy_mem;

wire[`regBus]		mem_addr_mcu;
wire[`byteBus]		mem_data_mcu;
wire[`memDataType]	mem_type_mcu;
wire 				mem_rw_mcu;
wire 				mem_ce_mcu;

MEM		MEM(
				.rst(rst),
				.clk(clk),

				.exmem_alu_in(exmem_alu_mem),
				.exmem_rs1_in(exmem_rs1_mem),
				.exmem_rs2_in(exmem_rs2_mem),
				.exmem_exec_in(exmem_exec_mem),
				.exmem_rdest_in(exmem_rdest_mem),
				.exmem_we_in(exmem_we_mem),

				.ma_data_in(ma_data_in),

				.mem_res_out(mem_res_memwb),
				.mem_rdest_out(mem_rdest_memwb),
				.mem_we_out(mem_we_memwb),

				.ma_addr_out(mem_addr_mcu),
				.ma_data_out(mem_data_mcu),
				.ma_rw_flag(mem_rw_mcu),
				.ma_ce_flag(mem_ce_mcu)
			);


assign mem_fw_data_id = mem_res_memwb;
assign mem_fw_addr_id = mem_rdest_memwb;
assign mem_fw_we_id   = mem_we_memwb;

MEMWB 	MEMWB(
				.rst(rst),
				.clk(clk),
				.stall(stall),
				.exmem_res_in(mem_res_memwb),
				.exmem_rdest_in(mem_rdest_memwb),
				.exmem_we_in(mem_we_memwb),

				.memwb_res_out(memwb_res_reg),
				.memwb_rdest_out(memwb_rdest_reg),
				.memwb_we_out(memwb_we_reg)
			);

MCU MCU0(
				.clk(clk),
				.rst(rst),
				.rdy(rdy),
				
				.inst_ce(if_ce_mcu),
				.if_inst_addr_in(if_addr_mcu),

				.data_ce(mem_ce_mcu),
				.mem_data_in(mem_data_mcu),
				.mem_data_addr_in(mem_addr_mcu),
				.mem_rw_in(mem_rw_mcu),

				.ma_addr_out(ma_addr_out),
				.ma_data_out(ma_data_out),
				.ma_rw_out(ma_rw_out),

				.if_ma_stall(mcu_if_stall_stall),
				.mem_ma_stall(mem_ma_stall_stall)
		);

endmodule