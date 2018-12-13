`include "define.v"
module IFID(
	input clk,
	input rst,
	input wire[`stallBus]	stall,
	input wire[`regBus]		if_inst_in,
	input wire[`regBus] 	if_addr_in,
	output reg[`regBus]		ifid_addr_out,
	output reg[`regBus]		ifid_inst_out
);

always @(posedge clk) begin
	if(rst) begin
		ifid_inst_out	<= `zero32;
        ifid_addr_out 	<= `zero32;
    end else if(!stall[1]) begin
    	ifid_inst_out	<= if_inst_in;
        ifid_addr_out 	<= if_addr_in;
    end else if(stall[1] && !stall[2]) begin
    	ifid_inst_out   <= `zero32;
        ifid_addr_out   <= `zero32;
    end
end
endmodule