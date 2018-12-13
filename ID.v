`include "define.v"
module ID(
	input rst,
    input clk,
	input wire[`stallBus]		stall,

	input wire[`regBus]      	ifid_inst_in,
	input wire[`regBus]  	    ifid_addr_in,

	input wire					reg_we,
	input wire[`regAddrBus]		reg_addr,
	input wire[`regBus]			reg_data,

	output reg[`regBus]			id_addr_out,
	output reg[`execBus]		id_exec_out,
	output reg[`regBus]			id_rs1_out,
	output reg[`regBus]			id_rs2_out,
	output reg[`regBus]			id_imm_out,
	output reg[`regAddrBus]		id_rdest_out,
	output reg 					id_we_out,	
	output reg 					id_mux_out,

	output reg 					id_data_stall,

	output reg[`regBus]			id_new_addr_out,
	output reg 					branch_flag,

	//------------------forwarding------------------
	input wire 					ex_we_in,
	input wire[`regAddrBus] 	ex_addr_in,
	input wire[`regBus]			ex_data_in,
	input wire[`execBus] 		ex_exec_in,

	input wire 					mem_we_in,
	input wire[`regAddrBus] 	mem_addr_in,
	input wire[`regBus] 		mem_data_in
);

integer i;
reg[`regBus] 		register[0:`regCnt - 1];
reg 				reg1_re;
reg 				reg2_re;

reg 				id_data1_stall;
reg 				id_data2_stall;

wire[`opCodeBus]  	opCode;
wire[`regAddrBus] 	regDest;
wire[`funct3Bus]  	funct3;
wire[`funct7Bus]  	funct7;
wire[`regAddrBus] 	regSrc1;
wire[`regAddrBus] 	regSrc2;
wire[`regBus]  		immI;
wire[`regBus]  		immJ;
wire[`regBus]  		immS;
wire[`regBus]  		immB;
wire[`regBus]  		immU;
assign opCode  = ifid_inst_in[6:0];
assign regDest = ifid_inst_in[11:7];
assign funct7  = ifid_inst_in[31:25];
assign funct3  = ifid_inst_in[14:12];
assign regSrc1 = ifid_inst_in[19:15];
assign regSrc2 = ifid_inst_in[24:20];

//signed extend to 32bit
assign immI    = {{20{ifid_inst_in[31]}}, ifid_inst_in[31:20]};
assign immJ    = {{12{ifid_inst_in[31]}}, ifid_inst_in[19:12], ifid_inst_in[20],ifid_inst_in[30:21],1'h0};
assign immS    = {{20{ifid_inst_in[31]}}, ifid_inst_in[31:25], ifid_inst_in[11:7]};
assign immB    = {{20{ifid_inst_in[31]}}, ifid_inst_in[7], ifid_inst_in[30:25], ifid_inst_in[11:8], 1'h0};
assign immU    = {ifid_inst_in[31:12], 12'h000};


wire pload; 
assign pload = (ex_exec_in == `EXE_LB_OP || ex_exec_in == `EXE_LH_OP ||  ex_exec_in == `EXE_LW_OP ||  ex_exec_in == `EXE_LBU_OP ||  ex_exec_in == `EXE_LHU_OP);

always @(posedge clk) begin
	if(rst) begin
		for(i = 0; i < `regCnt; i = i + 1) begin
			register[i] 	<= `zero32;
		end
	end else if(!rst && reg_we && reg_addr) begin
		register[reg_addr] 	<= reg_data;
	end
end

always @(*) begin
	if(rst) begin
		id_rs1_out		<= `zero32;
		id_data1_stall	<= `bitFalse;
	end else begin
		if(reg1_re) begin
			if(ex_we_in && ex_addr_in == regSrc1) begin
				if(pload) begin
					id_data1_stall	<= `bitTrue;
					id_rs1_out		<= `zero32;
				end else begin
					id_data1_stall	<= `bitFalse;
					id_rs1_out		<= ex_data_in;
				end
			end else if(mem_we_in && mem_addr_in == regSrc1) begin
				id_data1_stall	<= `bitFalse;
				id_rs1_out		<= ex_data_in;
			end else if(regSrc1 == reg_addr && reg_we) begin
				id_data1_stall	<= `bitFalse;
				id_rs1_out		<= reg_data;
			end else begin
				id_data1_stall	<= `bitFalse;
				id_rs1_out	<= register[regSrc1];
			end
		end else begin
			id_rs1_out		<= `zero32;
			id_data1_stall	<= `bitFalse;
		end
	end
end

always @(*) begin
	if(rst) begin
		id_rs2_out		<= `zero32;
		id_data2_stall	<= `bitFalse;
	end else begin
		if(reg2_re) begin
			if(ex_we_in && ex_addr_in == regSrc2) begin
				if(pload) begin
					id_data2_stall	<= `bitTrue;
					id_rs2_out		<= `zero32;
				end else begin
					id_data2_stall	<= `bitFalse;
					id_rs2_out		<= ex_data_in;
				end
			end else if(mem_we_in && mem_addr_in == regSrc2) begin
				id_data2_stall	<= `bitFalse;
				id_rs2_out		<= ex_data_in;
			end else if(regSrc2 == reg_addr && reg_we) begin
				id_data2_stall	<= `bitFalse;
				id_rs2_out		<= reg_data;
			end else begin
				id_data2_stall	<= `bitFalse;
				id_rs2_out	<= register[regSrc2];
			end
		end else begin
			id_rs2_out		<= `zero32;
			id_data2_stall	<= `bitFalse;
		end
	end
end

always @(*) begin
	if(rst) begin
		id_data_stall	<= `bitFalse;
	end else  begin
		id_data_stall  	<= (id_data1_stall || id_data2_stall);
	end
end

always @(*) begin
	if(rst) begin
	    id_exec_out  	<= `zero32;
		id_imm_out      <= `zero32;
		id_rdest_out 	<= `zero5;
		id_we_out       <= `bitFalse;
		id_mux_out      <= `bitFalse;
		id_new_addr_out	<= `max32;
		id_addr_out 	<= `zero32;
		reg1_re			<= `bitFalse;
		reg2_re 		<= `bitFalse;
		branch_flag		<= `zero32;
	end else begin
		case(opCode)
			`INST_OP_IMM :begin
				reg1_re				<= `bitTrue;
				reg2_re				<= `bitFalse;
				id_mux_out			<= `bitTrue;
				id_rdest_out 		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= `zero32;
				branch_flag			<= `bitFalse;
				case(funct3) 
					`FUNCT3_ADDI: begin
						id_exec_out			<= `EXE_ADD_OP;
						id_imm_out			<= immI;
					end
					`FUNCT3_SLTI: begin
						id_exec_out			<= `EXE_SLT_OP;
						id_imm_out			<= immI;
					end
					`FUNCT3_SLTIU: begin
						id_exec_out			<= `EXE_SLTU_OP;
						id_imm_out			<= immI;
					end
					`FUNCT3_ANDI: begin
						id_exec_out			<= `EXE_AND_OP;
						id_imm_out			<= {20'h0,immI[11:0]};
					end
					`FUNCT3_ORI:  begin
						id_exec_out			<= `EXE_OR_OP;
						id_imm_out			<= {20'h0,immI[11:0]};
					end
					`FUNCT3_XORI:  begin
						id_exec_out			<= `EXE_XOR_OP;
						id_imm_out			<= {20'h0,immI[11:0]};
					end
					`FUNCT3_SLLI: begin
						id_exec_out			<= `EXE_SLL_OP;
						id_imm_out			<= {27'h0,immI[4:0]};
					end
					`FUNCT3_SRLI: begin
						case(funct7)
							`FUNCT7_SRAI : begin
								id_exec_out			<= `EXE_SRA_OP;
								id_imm_out			<= {27'h0,immI[4:0]};
							end
							`FUNCT7_SRLI : begin
								id_exec_out			<= `EXE_SRL_OP;
								id_imm_out			<= {27'h0,immI[4:0]};
							end
							default      :begin
							    id_exec_out  	<= `zero32;
								reg1_re			<= `bitTrue;
								reg2_re			<= `bitFalse;
								id_imm_out      <= `zero32;
								id_rdest_out 	<= `zero5;
								id_we_out       <= `bitFalse;
								id_mux_out      <= `bitFalse;
								id_new_addr_out	<= `max32;
								id_addr_out 	<= `zero32;
								branch_flag		<= `bitFalse;
							end
						endcase
					end
					default     :begin
					    id_exec_out  	<= `zero32;
						reg1_re			<= `bitTrue;
						reg2_re			<= `bitFalse;
						id_imm_out      <= `zero32;
						id_rdest_out 	<= `zero5;
						id_we_out       <= `bitFalse;
						id_mux_out      <= `bitFalse;
						id_new_addr_out	<= `max32;
						id_addr_out 	<= `zero32;
						branch_flag		<= `bitFalse;
					end
				endcase
			end
			`INST_OP     :begin
				id_imm_out			<= `zero32;
				reg1_re				<= `bitTrue;
				reg2_re				<= `bitTrue;
				id_mux_out			<= `bitFalse;
				id_rdest_out 		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= `zero32; 
				branch_flag			<= `bitFalse;
				case(funct3)
					`FUNCT3_ADD : begin
						case(funct7)
						`FUNCT7_ADD : begin
							id_exec_out			<= `EXE_ADD_OP;
						end
						`FUNCT7_SUB : begin
							id_exec_out			<= `EXE_SUB_OP;
						end
						default      :begin
						    id_exec_out  	<= `zero32;
							reg1_re			<= `bitFalse;
							reg2_re			<= `bitFalse;
							id_imm_out      <= `zero32;
							id_rdest_out 	<= `zero5;
							id_we_out       <= `bitFalse;
							id_mux_out      <= `bitFalse;
							id_new_addr_out	<= `max32;
							id_addr_out 	<= `zero32;
							branch_flag		<= `bitFalse;
						end
					endcase
					end
					`FUNCT3_SLL : begin
						id_exec_out			<= `EXE_SLL_OP;
					end
					`FUNCT3_SLT : begin
						id_exec_out			<= `EXE_SLT_OP;
					end
					`FUNCT3_SLTU: begin
						id_exec_out			<= `EXE_SLTU_OP;
					end
					`FUNCT3_XOR: begin
						id_exec_out			<= `EXE_XOR_OP;
					end
					`FUNCT3_SRA: begin
						case(funct7)
							`FUNCT7_SRA: begin
								id_exec_out			<= `EXE_SRA_OP;
							end
							`FUNCT7_SRL: begin
								id_exec_out			<= `EXE_SRL_OP;
							end
							default      :begin
							    id_exec_out  	<= `zero32;
								reg1_re			<= `bitFalse;
								reg2_re			<= `bitFalse;
								id_imm_out      <= `zero32;
								id_rdest_out 	<= `zero5;
								id_we_out       <= `bitFalse;
								id_mux_out      <= `bitFalse;
								id_new_addr_out	<= `max32;
								id_addr_out 	<= `zero32;
								branch_flag		<= `bitFalse;
							end
						endcase
					end
					`FUNCT3_OR: begin
						id_exec_out			<= `EXE_OR_OP;
					end
					`FUNCT3_AND: begin
						id_exec_out			<= `EXE_AND_OP;
					end
					default      :begin
					    id_exec_out  	<= `zero32;
						reg1_re			<= `bitFalse;
						reg2_re			<= `bitFalse;
						id_imm_out      <= `zero32;
						id_rdest_out 	<= `zero5;
						id_we_out       <= `bitFalse;
						id_mux_out      <= `bitFalse;
						id_new_addr_out	<= `max32;
						id_addr_out 	<= `zero32;
						branch_flag		<= `bitFalse;
					end
				endcase
			end
			`INST_LUI    :begin
				id_exec_out			<= `EXE_LUI_OP;
				id_imm_out			<= immU;
				reg1_re				<= `bitFalse;
				reg2_re				<= `bitFalse;	
				id_mux_out			<= `bitFalse;
				id_rdest_out 		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= `zero32;
				branch_flag			<= `bitFalse;
			end
			`INST_AUIPC  :begin
				id_exec_out			<= `EXE_AUIPC_OP;
				id_imm_out			<= immU;
				reg1_re				<= `bitFalse;
				reg2_re				<= `bitFalse;
				id_mux_out			<= `bitTrue; 
				id_rdest_out 		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= `bitFalse;
			end
			`INST_JAL    :begin
			   	//$display("ID JAL DETECTED");
				id_exec_out			<= `EXE_JAL_OP;
				id_imm_out			<=	32'b0100;
				reg1_re				<= `bitFalse;
				reg2_re				<= `bitFalse;
				id_mux_out			<= `bitTrue;
				id_rdest_out		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= ifid_addr_in + immJ;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= `bitTrue;
			end
			`INST_JALR   :begin
				//$display("ID JALR DETECTED");
				id_exec_out			<= `EXE_JALR_OP;
				id_imm_out			<= 32'b0100;
				reg1_re				<= `bitTrue;
				reg2_re				<= `bitFalse;
				id_mux_out			<= `bitTrue;
				id_rdest_out		<= regDest;
				id_we_out			<= `bitTrue;
				id_new_addr_out		<= id_rs1_out + immI;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= `bitTrue;
			end
			`INST_BRANCH :begin
				id_exec_out			<= `EXE_BLT_OP;
				reg1_re				<= `bitTrue;
				reg2_re				<= `bitTrue;
				id_imm_out			<= `zero32;
				id_mux_out			<= `bitFalse;
				id_rdest_out		<= `zero5;
				id_we_out			<= `bitFalse;
				id_addr_out 		<= `zero32;
				case(funct3)
					`FUNCT3_BLT : begin
						id_new_addr_out	<= ($signed(id_rs1_out) < $signed(id_rs2_out)) ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
					`FUNCT3_BGE	: begin
						id_new_addr_out	<= ($signed(id_rs1_out) >= $signed(id_rs2_out)) ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
					`FUNCT3_BNE	: begin
						id_new_addr_out	<= id_rs1_out != id_rs2_out ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
					`FUNCT3_BEQ	: begin
						id_new_addr_out	<= id_rs1_out == id_rs2_out ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
					`FUNCT3_BLTU: begin
						id_new_addr_out	<= (id_rs1_out < id_rs2_out) ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
					`FUNCT3_BGEU: begin
						id_new_addr_out	<= (id_rs1_out >= id_rs2_out) ? ifid_addr_in + immB : ifid_addr_in + 4;
					end
				endcase
				branch_flag			<= `bitTrue;
			end
			`INST_LOAD   :begin

					case(funct3)
						`FUNCT3_LW : begin
							id_exec_out			<= `EXE_LW_OP;
						end
						`FUNCT3_LH : begin
							id_exec_out			<= `EXE_LH_OP;
						end
						`FUNCT3_LB : begin
							id_exec_out			<= `EXE_LB_OP;
						end
						`FUNCT3_LBU : begin
							id_exec_out			<= `EXE_LBU_OP;
						end
						`FUNCT3_LHU : begin
							id_exec_out			<= `EXE_LHU_OP;
						end
					endcase
					id_imm_out			<= immI;
					reg1_re				<= `bitTrue;
					reg2_re 			<= `bitFalse;
					id_mux_out			<= `bitTrue;
					id_rdest_out 		<= regDest;
					id_we_out			<= `bitTrue;
					id_new_addr_out		<= `max32;
					id_addr_out 		<= ifid_addr_in;
					branch_flag			<= `bitFalse;
			end
			`INST_SAVE   :begin
				id_imm_out			<= immS;
				reg1_re				<= `bitTrue;
				reg2_re				<= `bitTrue;
				id_mux_out			<= `bitTrue;
				id_rdest_out 		<= `zero32;
				id_we_out			<= `bitFalse;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= ifid_addr_in;
				case(funct3)
					`FUNCT3_SW : begin
						id_exec_out			<= `EXE_SW_OP;
					end
					`FUNCT3_SH : begin
						id_exec_out			<= `EXE_SH_OP;
					end
					`FUNCT3_SB : begin
						id_exec_out			<= `EXE_SB_OP;
					end
				endcase
				branch_flag			<= `bitFalse;
			end
			default      :begin
			    id_exec_out  	<= `zero32;
				reg1_re			<= `bitFalse;
				reg2_re 		<= `bitFalse;
				id_imm_out      <= `zero32;
				id_rdest_out 	<= `zero5;
				id_we_out       <= `bitFalse;
				id_mux_out      <= `bitFalse;
				id_new_addr_out	<= `max32;
				id_addr_out 	<= `zero32;
				branch_flag		<= `bitFalse;
			end
		endcase
	end
end

endmodule