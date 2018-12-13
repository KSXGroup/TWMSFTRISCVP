//********************************OP CODE************************************
`define INST_OP_IMM  7'b0010011
`define INST_OP      7'b0110011
`define INST_LUI     7'b0110111
`define INST_AUIPC   7'b0010111
`define INST_JAL     7'b1101111
`define INST_JALR    7'b1100111
`define INST_BRANCH  7'b1100011
`define INST_LOAD    7'b0000011
`define INST_SAVE    7'b0100011

//********************************FUNCT3 CODE*******************************
`define FUNCT3_BEQ   3'b000
`define FUNCT3_BNE   3'b001
`define FUNCT3_BLT   3'b100
`define FUNCT3_BGE   3'b101
`define FUNCT3_BLTU  3'b110
`define FUNCT3_BGEU  3'b111

`define FUNCT3_LB    3'b000
`define FUNCT3_LH    3'b001
`define FUNCT3_LW    3'b010
`define FUNCT3_LBU   3'b100
`define FUNCT3_LHU   3'b101 

`define FUNCT3_SB    3'b000
`define FUNCT3_SH    3'b001
`define FUNCT3_SW    3'b010

`define FUNCT3_ADDI  3'b000
`define FUNCT3_SLTI  3'b010
`define FUNCT3_SLTIU 3'b011
`define FUNCT3_ANDI  3'b111
`define FUNCT3_ORI   3'b110
`define FUNCT3_XORI  3'b100
`define FUNCT3_SLLI  3'b001
`define FUNCT3_SRLI  3'b101
`define FUNCT3_SRAI  3'b101

`define FUNCT3_ADD   3'b000
`define FUNCT3_SLT   3'b010
`define FUNCT3_SLTU  3'b011
`define FUNCT3_AND   3'b111
`define FUNCT3_OR    3'b110
`define FUNCT3_XOR   3'b100
`define FUNCT3_SLL   3'b001
`define FUNCT3_SRL   3'b101
`define FUNCT3_SUB   3'b000
`define FUNCT3_SRA   3'b101

//********************************FUNCT7 CODE*******************************
`define FUNCT7_SRLI  7'b0000000
`define FUNCT7_SRAI  7'b0100000
`define FUNCT7_SRL   7'b0000000
`define FUNCT7_SRA   7'b0100000
`define FUNCT7_ADD   7'b0000000
`define FUNCT7_SUB   7'b0100000
//********************************* ALUOP **********************************
`define EXE_NOP_OP   5'b00000
`define EXE_AND_OP   5'b00001
`define EXE_OR_OP    5'b00010
`define EXE_XOR_OP   5'b00011

`define EXE_SLL_OP   5'b00100
`define EXE_SRL_OP   5'b00101
`define EXE_SRA_OP   5'b00110

`define EXE_ADD_OP   5'b00111
`define EXE_SLT_OP   5'b01000
`define EXE_SLTU_OP  5'b01001
`define EXE_SUB_OP   5'b01010

`define EXE_JAL_OP   5'b01011
`define EXE_JALR_OP  5'b01100
`define EXE_BEQ_OP   5'b01101
`define EXE_BNE_OP   5'b01110
`define EXE_BLT_OP   5'b01111
`define EXE_BGE_OP   5'b10000
`define EXE_BLTU_OP  5'b10001
`define EXE_BGEU_OP  5'b10010

`define EXE_LB_OP  	 5'b10011
`define EXE_LH_OP  	 5'b10100
`define EXE_LW_OP  	 5'b10101
`define EXE_LBU_OP 	 5'b10110
`define EXE_LHU_OP 	 5'b10111
`define EXE_SB_OP  	 5'b11000
`define EXE_SH_OP  	 5'b11001
`define EXE_SW_OP  	 5'b11010

`define EXE_LUI_OP   5'b11011
`define EXE_AUIPC_OP 5'b11100
//********************************GLOBAL************************************
`define onReset        1'b1
`define notOnReset     1'b0
`define canWrite       1'b1
`define canNotWrite    1'b0
`define canRead        1'b1
`define canNotRead     1'b0
`define aluOpBus       7:0
`define aluInstTypeBus 2:0
`define enabled        1'b1
`define disabled       1'b0
`define bitTrue        1'b1
`define bitFalse       1'b0
`define zero2 		   2'b00
`define zero3          3'b000
`define zero4		   4'b0000
`define zero5          5'b00000
`define zero7          7'b0000000
`define zero8 		   8'b00000000
`define zero9		   9'b000000000
`define zero14         14'b00000000000000
`define zero17		   17'b00000000000000000
`define zero32         32'h00000000
`define zero68		   {17{4'h0}}
`define zero125        {125{1'b0}}

`define max4		   4'hf
`define max32		   32'hffffffff

//Reg ctrl inst
`define regAddrBus     4:0
`define regBus         31:0
`define regCnt         32
`define regStatusCnt   2:0
`define regWidth       32
`define regNum         32
`define regBusWidth    5

`define execBus	   	   4:0
`define stallBus       6:0

`define opCodeBus      6:0
`define funct7Bus      6:0
`define funct3Bus      2:0
`define immNumBus      31:0

`define memAddrBus	   31:0
`define byteBus		   7:0
`define TrueAddrBus	   16:0
`define memDataType    2:0
`define MEM_BYTE	   3'b000
`define MEM_HALF	   3'b001
`define MEM_WORD	   3'b010
`define MEM_BU		   3'b100
`define MEM_HU		   3'b101

`define MEM_STAGE0 	   4'b0000
`define MEM_STAGE1	   4'b0001
`define MEM_STAGE2 	   4'b0010
`define MEM_STAGE3 	   4'b0011
`define MEM_STAGE4 	   4'b0100
`define MEM_STAGE5 	   4'b0101
`define MEM_STAGE6 	   4'b0110
`define MEM_STAGE7 	   4'b0111
`define MEM_STAGE8	   4'b1000
`define MEM_STAGE9	   4'b1001
`define MEM_STAGE10	   4'b1010
`define MEM_STAGE11	   4'b1011
`define MEM_STAGE12	   4'b1100

`define ICACHE_ADDR_WIDTH 		5
`define ICACHE_CNT				2**5
`define DCACHE_ADDR_WIDTH 		3
`define DCACHE_CNT 				2**3