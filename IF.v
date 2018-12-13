`include "define.v"
module IF(
	input wire                 	clk,
	input wire                 	rst,
	input wire 					br_flag,
	input wire[`stallBus] 		stall, 
	input wire[`regBus]			new_addr,
	input wire[`byteBus]		mem_data_in,

	output reg[`regBus]       	if_inst_out,
	output reg[`regBus]   		if_addr_out,
	output reg[`regBus]   		if_mcu_addr,
	output reg 					if_b_stall_req,
	output reg					mcu_ce
);

reg[`regBus] 	pc;
reg[`regBus] 	ibuffer;
reg[3:0] 		stage;

wire[`opCodeBus]  	opCode;
assign opCode  = ibuffer[6:0];

always @(posedge clk) begin
	if(rst) begin
		if_inst_out		<= `zero32;
		if_addr_out		<= `zero32;
		if_mcu_addr		<= `zero32;
		mcu_ce			<= `bitFalse;
		if_b_stall_req	<= `bitFalse;
		pc				<= `zero32;
		ibuffer			<= `zero32;
		stage 			<= `MEM_STAGE0;
	end else if(br_flag && !stall[1]) begin
		pc 				<= new_addr;
		stage			<= `MEM_STAGE0;
		mcu_ce 			<= `bitFalse;
		if_b_stall_req 	<= `bitFalse;
		if_addr_out		<= `zero32;
		if_inst_out		<= `zero32;
	end else begin
		case(stage)
			`MEM_STAGE0:begin
				if(!stall[1] && !stall[2]) begin
					mcu_ce			<= `bitTrue;
					if_mcu_addr		<= pc;
					stage 			<= `MEM_STAGE1;
				end
			end
			`MEM_STAGE1:begin
				stage 			<= `MEM_STAGE2;
				if_mcu_addr		<= pc + 1;
			end
			`MEM_STAGE2:begin
				ibuffer[7:0]	<= mem_data_in;
				if_mcu_addr		<= pc + 2;
				stage 			<= `MEM_STAGE3;
			end
			`MEM_STAGE3:begin
				if(stall[6]) begin
					stage 		<= `MEM_STAGE6;
				end else begin
					ibuffer[15:8]	<= mem_data_in;
					if_mcu_addr	<= pc + 3;
					stage 		<= `MEM_STAGE4;
				end
			end
			`MEM_STAGE4:begin
				if(stall[6]) begin
					stage 		<= `MEM_STAGE8;
				end else begin
					ibuffer[23:16]	<= mem_data_in;
					stage 			<= `MEM_STAGE5;
				end
			end
			`MEM_STAGE5:begin
				if_inst_out		<= {mem_data_in, ibuffer[23:0]};
				if_addr_out		<= pc;
				mcu_ce			<= `bitFalse;
				stage 			<= `MEM_STAGE0;
				case(opCode)
					`INST_JAL ,`INST_JALR, `INST_BRANCH :begin
						if_b_stall_req	<= `bitTrue;
					end
					default:begin
						if_b_stall_req	<= `bitFalse;
						pc				<= pc + 4;
					end
				endcase
			end

			`MEM_STAGE6:begin
				if(!stall[6]) begin
					stage 		<= `MEM_STAGE7;
					if_mcu_addr	<= pc + 1;
				end
			end
			`MEM_STAGE7:begin
				if_mcu_addr		<= pc + 2;
				stage 			<= `MEM_STAGE3;
			end

			`MEM_STAGE8:begin
				if(!stall[6]) begin
					stage 		<= `MEM_STAGE9;
					if_mcu_addr	<= pc + 2;
				end
			end
			`MEM_STAGE9:begin
				if_mcu_addr	<= pc + 3;
				stage 		<= `MEM_STAGE4;
			end
		endcase
	end
end


endmodule
