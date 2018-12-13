`include "define.v"
module MCU(
	input wire rst, 
	input wire clk,
	input wire rdy,

	input wire 					inst_ce,
	input wire[`regBus]			if_inst_addr_in,

	input wire 					data_ce,
	input wire[`byteBus]		mem_data_in,
	input wire[`regBus]			mem_data_addr_in,
	input wire					mem_rw_in, //1 for write, 0 for read
//---------------------------------------------------
	output reg[`regBus] 		ma_addr_out,
	output reg[`byteBus]		ma_data_out,
	output reg 					ma_rw_out,
//----------------------------------------------------
	output reg 					if_ma_stall,
	output reg 					mem_ma_stall
);

always @(*) begin
	if(rst) begin
		ma_addr_out	 	<= `zero32;
		ma_data_out     <= `zero8;
		ma_rw_out 		<= `bitFalse;
		if_ma_stall		<= `bitFalse;
		mem_ma_stall 	<= `bitFalse;
	end else if(rdy) begin
		if(data_ce) begin
			if(inst_ce) begin
				if_ma_stall	<=	`bitTrue;
			end else begin
				if_ma_stall	<=	`bitFalse;
			end
			mem_ma_stall	<=	`bitTrue;
			ma_addr_out		<= 	mem_data_addr_in;
			ma_rw_out 		<= 	mem_rw_in;
			ma_data_out		<= 	mem_data_in;
		end else if(inst_ce) begin
			mem_ma_stall	<=	`bitFalse;
			if_ma_stall		<= 	`bitTrue;
			ma_addr_out		<= 	if_inst_addr_in;
			ma_rw_out 		<= 	`bitFalse;
		end else begin
			if_ma_stall		<= `bitFalse;
			mem_ma_stall 	<= `bitFalse;
		end
	end
end

endmodule