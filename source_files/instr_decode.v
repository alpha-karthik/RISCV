module decode(
	input [31:0] instruction,
	output [4:0] rs1,
	output [4:0]rs2,
	output [4:0] rd,
	output [31:0] imm,
	output [10:0] dec_bits
);
	wire [31:0] imm;
	wire is_u_type;
	wire is_i_type;
	wire is_r_type;
	wire is_s_type;
	wire is_b_type;
	wire is_j_type;
	assign is_u_type = (instruction[6:2] == 5'b00101 || instruction[6:2] == 5'b01101);
	assign is_i_type = (instruction[6:5]==2'b00 || instruction[6:5] == 2'b11 )&(instruction[4:2] == 3'b000 || instruction[4:2] == 3'b001 || instruction[4:2] == 3'b100 || instruction[4:2] == 3'b110);
	assign is_r_type = (instruction[6:5]==2'b01 || instruction[6:5] == 2'b10)&( instruction[4:2] == 3'b011 || instruction[4:2] == 3'b100 || instruction[4:2] == 3'b110);
	assign is_s_type = (instruction[6:5]==2'b01)&(instruction[4:2] == 3'b000 || instruction[4:2] == 3'b001);
	assign is_b_type = (instruction[6:2] == 5'b11000);
	assign is_j_type = (instruction[6:2] == 5'b11011);
	
	wire rs2_valid,imm_valid,rs1_valid;
	wire [2:0] func3;
	wire [6:0] opcode;
	assign opcode = instruction[6:0];
	assign rs2 = instruction[24:20];
	assign rs1 = instruction[19:15];
	assign funct3 = instruction[14:12];
	assign rd = (instruction[11:7]==5'd0) ? 5'dx : instruction[11:7];
	assign rs2_valid = is_u_type || is_s_type || is_b_type;
	assign imm_valid = ~(is_r_type);
	assign rs1_valid = is_r_type || is_s_type || is_b_type || is_i_type;
	assign imm = is_i_type ? {{21{instruction[31]}},instruction[30:20]}:
		     is_s_type ? {{21{instruction[31]}},instruction[30:25],instruction[11:7]}:
		     is_b_type ? {{20{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0}:
		     is_u_type ? {instruction[31],instruction[30:20],instruction[19:12],{12{1'b0}}}:
		     is_j_type ? {{12{instruction[31]}},instruction[19:12],instruction[20],instruction[30:25],instruction[24:21],1'b0} : 31'd0;
		    
	assign dec_bits[10:0] = {instruction[30],funct3,opcode};
	
	
endmodule
