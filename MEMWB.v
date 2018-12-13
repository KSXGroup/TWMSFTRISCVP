`include "define.v"
module MEMWB(
	input wire 					rst,
	input wire 					clk,
	input wire[`stallBus]     	stall,
	input wire[`regBus]			exmem_res_in,
	input wire[`regAddrBus]		exmem_rdest_in,
	input wire					exmem_we_in,

	output reg[`regBus]			memwb_res_out,
	output reg[`regAddrBus]		memwb_rdest_out,
	output reg 					memwb_we_out
);

always @(posedge clk) begin
	if((stall[4] && !stall[5]) || rst) begin
		memwb_we_out	<= `bitFalse;
		memwb_rdest_out	<= `zero5;
		memwb_res_out	<= `zero32;
	end else if(!stall[4])begin
		memwb_res_out	<= exmem_res_in;
		memwb_rdest_out	<= exmem_rdest_in;
		memwb_we_out	<= exmem_we_in;
	end
end
endmodule