`include "define.v"
module EX(
	input rst,
	input clk,
	
	input wire[`stallBus]	stall,

	input wire[`regAddrBus]	idex_rdest_in,
	input wire[`execBus]	idex_exec_in,
	input wire[`regBus]		idex_rs1_in,
	input wire[`regBus]		idex_rs2_in,
	input wire[`regBus]		idex_imm_in,
	input wire[`regBus] 	idex_addr_in,
	input wire				idex_mux_in,
	input wire				idex_we_in,

	output reg[`regBus]		ex_alu_out,
	output reg[`regBus]		ex_rs1_out,
	output reg[`regBus]		ex_rs2_out,
	output reg[`execBus]	ex_exec_out,
	output reg[`regAddrBus]	ex_rdest_out,
	output reg 				ex_we_out
);


reg[`regBus] res;

always @(*) begin
	if(rst) begin
		res <= `zero32;
	end else begin
		case(idex_exec_in)
			`EXE_ADD_OP : begin
				if(idex_mux_in) begin
					res <= idex_rs1_in + idex_imm_in;
				end else begin
					res <= idex_rs1_in + idex_rs2_in;
				end
			end
			`EXE_SUB_OP : begin
				res <= idex_rs1_in - idex_rs2_in;
			end
			`EXE_SLL_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in	<< idex_imm_in[4:0];
				end
				1'b0 : begin
					res <= idex_rs1_in	<< idex_rs2_in[4:0];
				end
				endcase
			end
			`EXE_SLT_OP: begin
				case(idex_mux_in)
				1'b1 : begin
					res <= ($signed(idex_rs1_in)) < ($signed(idex_imm_in)) ? {{31{1'b0}}, 1'b1} : {32{1'b0}};
				end
				1'b0 : begin
					res <= ($signed(idex_rs1_in)) < ($signed(idex_rs2_in)) ? {{31{1'b0}}, 1'b1} : {32{1'b0}};
				end
				endcase
			end
			`EXE_SLTU_OP: begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in < idex_imm_in ? {{31{1'b0}}, 1'b1} : {32{1'b0}};
				end
				1'b0 : begin
					res <= idex_rs1_in < idex_rs2_in ? {{31{1'b0}}, 1'b1} : {32{1'b0}};
				end
				endcase
			end
			`EXE_XOR_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in	^ idex_imm_in;
				end
				1'b0 : begin
					res <= idex_rs1_in	^ idex_rs2_in;
				end
				endcase
			end
			`EXE_SRL_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in	>> idex_imm_in[4:0];
				end
				1'b0 : begin
					res <= idex_rs1_in	>> idex_rs2_in[4:0];
				end
				endcase
			end
			`EXE_SRA_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= ($signed(idex_rs1_in)) >>> (idex_imm_in[4:0]);
				end
				1'b0 : begin
					res <= ($signed(idex_rs1_in)) >>> (idex_rs2_in[4:0]);
				end
				endcase
			end
			`EXE_AND_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in	& idex_imm_in;
				end
				1'b0 : begin
					res <= idex_rs1_in	& idex_rs2_in;
				end
				endcase
			end
			`EXE_OR_OP : begin
				case(idex_mux_in)
				1'b1 : begin
					res <= idex_rs1_in	| idex_imm_in;
				end
				1'b0 : begin
					res <= idex_rs1_in	| idex_rs2_in;
				end
				endcase
			end
			`EXE_LW_OP, `EXE_LH_OP, `EXE_LB_OP, `EXE_SW_OP, `EXE_SH_OP, `EXE_SB_OP, `EXE_LBU_OP, `EXE_LHU_OP: begin
			    res <= idex_imm_in + idex_rs1_in;
			end
			`EXE_JAL_OP, `EXE_JALR_OP, `EXE_AUIPC_OP: begin
				res <= idex_imm_in + idex_addr_in;
			end
			`EXE_LUI_OP: begin
				res <= idex_imm_in;
			end
			default: begin
				res <= `zero32;
			end
		endcase
	end
end

always @(*) begin
	if(!rst && !stall[3]) begin
		ex_exec_out		<= idex_exec_in;
		ex_alu_out		<= res;
		ex_rs1_out		<= idex_rs1_in;
		ex_rs2_out		<= idex_rs2_in;
		ex_rdest_out	<= idex_rdest_in;
		ex_we_out		<= idex_we_in;
	end else begin
		ex_exec_out		<= `zero5;
		ex_alu_out		<= `zero32;
		ex_rs1_out		<= `zero32;
		ex_rs2_out		<= `zero32;
		ex_rdest_out	<= `zero5;
		ex_we_out		<= `bitFalse;
	end
end

endmodule