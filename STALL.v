`include "define.v"
module STALL(
	input wire rst,
	input wire rdy,
	input wire if_mem_stall_in,
	input wire if_b_stall_in,
	input wire id_data_stall_in,
	input wire mem_ma_stall_in,

	output reg[`stallBus] 	stall
	//0-interrupt from ma, 1-if, 2-id, 3-ex, 4-mem, 5-wb, 6-interrupt_if
);

always @(*) begin
	if(rst) begin
		stall 			= 7'b0000000;
	end else if(!rdy) begin
		stall 			= 7'b0111110;
	end else if(mem_ma_stall_in) begin
		stall 			= 7'b1011111;
	end else if(id_data_stall_in) begin
		stall 			= 7'b0000110;	
	end else if(if_b_stall_in) begin
		stall 			= 7'b0000100;
	end else if(if_mem_stall_in) begin
		stall 			= 7'b0000010;
	end else begin
		stall 			= `zero7;
	end
end
endmodule