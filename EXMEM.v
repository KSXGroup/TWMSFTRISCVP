`include "define.v"
module EXMEM(
	input wire				rst,
	input wire				clk,
	input wire[`stallBus] 	stall,
	input wire[`regBus]		ex_alu_in,
	input wire[`regBus]		ex_rs1_in,
	input wire[`regBus]		ex_rs2_in,
	input wire[`execBus]	ex_exec_in,
	input wire[`regAddrBus]	ex_rdest_in,
	input wire				ex_we_in,

	output reg[`regBus]		exmem_alu_out,
	output reg[`regBus]		exmem_rs1_out,
	output reg[`regBus]		exmem_rs2_out,
	output reg[`execBus]	exmem_exec_out,
	output reg[`regAddrBus]	exmem_rdest_out,
	output reg 				exmem_we_out
);

always @(posedge clk) begin
	if(rst || (stall[3] && !stall[4])) begin
		exmem_alu_out	<= `zero32;
		exmem_rs1_out	<= `zero32;
		exmem_rs2_out	<= `zero32;
		exmem_exec_out	<= `zero5;
		exmem_rdest_out	<= `zero5;
		exmem_we_out	<= `bitFalse;
	end	else if(!stall[3]) begin
		exmem_alu_out	<= ex_alu_in;
		exmem_rs1_out	<= ex_rs1_in;
		exmem_rs2_out	<= ex_rs2_in;
		exmem_exec_out	<= ex_exec_in;
		exmem_rdest_out	<= ex_rdest_in;
		exmem_we_out	<= ex_we_in;
	end
end
endmodule
