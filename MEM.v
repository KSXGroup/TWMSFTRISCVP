`include "define.v"
module MEM(
	input wire					rst,
	input wire					clk,

	input wire[`regBus]			exmem_alu_in,
	input wire[`regBus]			exmem_rs1_in,
	input wire[`regBus]			exmem_rs2_in,
	input wire[`execBus]		exmem_exec_in,
	input wire[`regAddrBus]		exmem_rdest_in,
	input wire					exmem_we_in,

	input wire[`byteBus]		ma_data_in,

	output reg[`regBus]			mem_res_out,
	output reg[`regAddrBus]		mem_rdest_out,
	output reg					mem_we_out,

	output reg[`regBus]			ma_addr_out,
	output reg[`byteBus]		ma_data_out,
	output reg 					ma_rw_flag,
	output reg 					ma_ce_flag
);

reg 			ma_done;
reg[3:0] 		stage;
reg[`regBus] 	ma_res;

always @(posedge clk) begin
	if(rst) begin
		stage		<= `zero4;
		ma_res		<= `zero32;
		ma_done 	<= `bitFalse;
		ma_addr_out	<= `zero32;
		ma_data_out	<= `zero8;
		ma_rw_flag	<= `bitFalse;
	end else if(ma_ce_flag) begin
		case(stage)
			`MEM_STAGE0:begin
				ma_addr_out <= exmem_alu_in;
				ma_done		<= `bitFalse;
				case(exmem_exec_in)
					`EXE_SW_OP,`EXE_SH_OP,`EXE_SB_OP:begin
						ma_rw_flag	<= `bitTrue;
						ma_data_out	<= exmem_rs2_in[7:0];
						stage 		<= `MEM_STAGE1;
					end
					`EXE_LW_OP,`EXE_LH_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LHU_OP:begin
						ma_rw_flag	<= `bitFalse;
						stage 		<= `MEM_STAGE1;
					end
				endcase
			end
			`MEM_STAGE1:begin
				case(exmem_exec_in)
					`EXE_SB_OP:begin
						ma_rw_flag	<= `bitFalse;
						ma_done		<= `bitTrue;
						stage 		<= `MEM_STAGE0;
						ma_addr_out	<= `zero32;
					end
					`EXE_SH_OP,`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[15:8];
						ma_addr_out	<= exmem_alu_in + 1;
						stage 		<= `MEM_STAGE2;
					end
					default:begin
						stage 		<= `MEM_STAGE2;
					end
				endcase
			end
			`MEM_STAGE2:begin
				case(exmem_exec_in)
					`EXE_SH_OP:begin
						ma_rw_flag	<= `bitFalse;
						ma_done		<= `bitTrue;
						stage 		<= `MEM_STAGE0;
						ma_addr_out	<= `zero32;
					end
					`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[23:16];
						ma_addr_out	<= exmem_alu_in + 2;
						stage 		<= `MEM_STAGE3;
					end
					`EXE_LB_OP:begin
						ma_res		<= {{24{ma_data_in[7]}}, ma_data_in};
						ma_done		<= `bitTrue;
						stage 		<= `MEM_STAGE0;
					end
					`EXE_LBU_OP:begin
						ma_res		<= {{24{1'b0}}, ma_data_in};
						ma_done		<= `bitTrue;
						stage 		<= `MEM_STAGE0;
					end
					`EXE_LW_OP,`EXE_LH_OP,`EXE_LHU_OP:begin
						ma_res[7:0]	<= ma_data_in;
						ma_addr_out	<= exmem_alu_in + 1;
						stage 		<= `MEM_STAGE3;
					end
				endcase
			end
			`MEM_STAGE3:begin
				case(exmem_exec_in)
					`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[31:24];
						ma_addr_out	<= exmem_alu_in + 3;
						stage 		<= `MEM_STAGE4;
					end
					default:begin
						stage 		<= `MEM_STAGE4;
					end
				endcase
			end
			`MEM_STAGE4:begin
				case(exmem_exec_in)
					`EXE_SW_OP:begin
						ma_done		<= `bitTrue;
						stage 		<= `MEM_STAGE0;
						ma_rw_flag	<= `bitFalse;
						ma_addr_out	<= `zero32;
					end
					`EXE_LH_OP:begin
						ma_res[31:8] 	<= {{16{ma_data_in[7]}}, ma_data_in};
						ma_done			<= `bitTrue;
						stage 			<= `MEM_STAGE0;
					end
					`EXE_LHU_OP:begin
						ma_res[31:8] 	<= {{16{1'b0}}, ma_data_in};
						ma_done			<= `bitTrue;
						stage 			<= `MEM_STAGE0;
					end
					`EXE_LW_OP:begin
						ma_res[15:8]	<= ma_data_in;
						ma_addr_out		<= exmem_alu_in + 2;
						stage 			<= `MEM_STAGE5;
					end
				endcase
			end
			`MEM_STAGE5:begin
				stage 	<= `MEM_STAGE6;
			end
			`MEM_STAGE6:begin
				ma_res[23:16]	<= ma_data_in;
				ma_addr_out		<= exmem_alu_in + 3;
				stage 			<= `MEM_STAGE7;
			end
			`MEM_STAGE7:begin
				stage 	<= `MEM_STAGE8;
			end
			`MEM_STAGE8:begin
				ma_res[31:24]	<= ma_data_in;
				stage 			<= `MEM_STAGE0;
				ma_done			<= `bitTrue;
			end
		endcase
	end else begin
		ma_done	<= `bitFalse;
	end
end

always @(*) begin
	if(rst) begin
		ma_ce_flag	<= `bitFalse;
	end else begin
		if(ma_done)begin
			ma_ce_flag	<= `bitFalse;
		end else if(!ma_done) begin
			case(exmem_exec_in) 
				`EXE_LW_OP,`EXE_LH_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LHU_OP,`EXE_SW_OP,`EXE_SH_OP,`EXE_SB_OP:begin
					ma_ce_flag	<= `bitTrue;
				end
				default:begin
					ma_ce_flag	<= `bitFalse;
				end
			endcase 
		end
	end
end

always @(*) begin
	if(rst) begin
		mem_res_out 	<= 	`zero32;
		mem_rdest_out 	<= 	`zero5;
		mem_we_out		<=  `bitFalse;
	end else begin
		case(exmem_exec_in)
			`EXE_LW_OP, `EXE_LH_OP, `EXE_LB_OP,`EXE_LBU_OP, `EXE_LHU_OP:begin
				mem_res_out 	<= ma_res;
			end
			default: begin
				mem_res_out 	<= exmem_alu_in;
			end
		endcase
		mem_rdest_out	<= exmem_rdest_in;
		mem_we_out		<= exmem_we_in;
	end
end

endmodule