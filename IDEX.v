`include "define.v"
module IDEX(
	input rst,
	input clk,

	input wire[`stallBus]	stall,
	
	input wire[`execBus]	id_exec_in,
	input wire[`regAddrBus]	id_rdest_in,
	input wire[`regBus]		id_rs1_in,
	input wire[`regBus]		id_rs2_in,
	input wire[`regBus]		id_imm_in,
	input wire[`regBus]		id_addr_in,
	input wire 				id_we_in,
	input wire				id_mux_in,

	output reg[`execBus]	idex_exec_out,
	output reg[`regAddrBus]	idex_rdest_out,
	output reg[`regBus]		idex_rs1_out,
	output reg[`regBus]		idex_rs2_out,
	output reg[`regBus]		idex_imm_out,
	output reg[`regBus]		idex_addr_out,
	output reg				idex_mux_out,
	output reg 				idex_we_out
);

always @(posedge clk) begin
	if(rst || (stall[2] && !stall[3])) begin
		idex_exec_out	<= `zero5;
		idex_rs2_out 	<= `zero32;
		idex_rs1_out 	<= `zero32;
		idex_imm_out	<= `zero32;
		idex_addr_out	<= `zero32;
		idex_mux_out	<= `bitFalse;
		idex_rdest_out	<= `zero5;
		idex_we_out		<= `bitFalse;
	end else if(!stall[2]) begin
		idex_exec_out 	<= id_exec_in;
		idex_mux_out	<= id_mux_in;
		idex_rs1_out 	<= id_rs1_in;
		idex_rs2_out 	<= id_rs2_in;
		idex_imm_out	<= id_imm_in;
		idex_addr_out	<= id_addr_in;
		idex_rdest_out	<= id_rdest_in;
		idex_we_out		<= id_we_in;
	end
end

endmodule