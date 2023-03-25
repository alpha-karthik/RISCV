module control_logic (
	input [10:0] decode_bits, // {instruction[30], funct3, opcode};
	input [6:0] opcode,
	input branch_result,
	output jalr_pc_select, //ok
	output branch_select, //ok
	output [2:0] branch_op_control,	//ok
	output [3:0] alu_op_control,	//ok
	output [2:0] load_type_sel,	//ok
	output [1:0] store_type_sel,	//ok
	output write_enable_datamem, //ok
	output write_enable_regfile,	//ok
	output jalr_wd_selc,	//ok
	output mux3_sel, // it will select the write data between r type and load type instruction,  !ok
	output op_src,	//ok
	output [1:0]  mux5_sel // it will select different opreands depending on the instruction, !
);
	wire is_u_type;
	wire is_i_type;
	wire is_r_type;
	wire is_s_type;
	wire is_b_type;
	wire is_j_type;
	wire is_load_type;
	assign is_u_type = (opcode[6:2] == 5'b00101 || opcode[6:2] == 5'b01101);
	assign is_i_type = (opcode[6:5]==2'b00 || opcode[6:5] == 2'b11 )&(opcode[4:2] == 3'b000 || opcode[4:2] == 3'b001 || opcode[4:2] == 3'b100 || opcode[4:2] == 3'b110);
	assign is_r_type = (opcode[6:5]==2'b01 || opcode[6:5] == 2'b10)&( opcode[4:2] == 3'b011 || opcode[4:2] == 3'b100 || opcode[4:2] == 3'b110);
	assign is_s_type = (opcode[6:5]==2'b01)&(opcode[4:2] == 3'b000 || opcode[4:2] == 3'b001);
	assign is_b_type = (opcode[6:2] == 5'b11000);
	assign is_j_type = (opcode[6:2] == 5'b11011);
	assign is_load_type = (opcode[6:2] == 5'b00000);
	
	// ALU Operation control
	reg [3:0] operation;
	always @(*)
	begin
		case(opcode[6:2])
			5'b01100	:	operation = decode_bits[10:7];
			5'b00100	:	begin
								if (decode_bits[9:7] == 3'b101)
									operation = decode_bits[10:7];
								else
									operation = {1'b0,decode_bits[9:7]};
							end
			default		:	operation	=	4'b0000;
		endcase
	end
	assign alu_op_control = operation;
	
	//Branch Operation control
	assign branch_op_control	=	is_b_type ? decode_bits[9:7] : 3'b000;
	assign load_type_sel	= is_i_type ? decode_bits[9:7] : 3'b000;
	assign store_type_sel = is_s_type	? decode_bits[9:7] : 3'b000;
	
	//other control signals
	assign jalr_pc_select  = (opcode[6:2] == 5'b11001 );
	assign branch_select = branch_result & is_b_type ;
	assign write_enable_datamem = is_s_type;
	assign write_enable_regfile	 = ~(is_s_type | is_b_type);
	assign jalr_wd_selc = (is_j_type | jalr_pc_select);
	assign op_src = is_r_type;
	assign mux3_sel = is_load_type;

	//operand1 selection
	reg [1:0] select;
	always @(*)
	begin
		if (is_u_type)
			select = opcode[5] ? 2'b00 : 2'b01;
		else
			select = 2'b11;
	end
	assign mux5_sel = select;
	
	
endmodule
module alu_module(
	input [3:0] aluop_control,
	input [31:0] operand1,operand2,
	output [31:0] alu_result
);
	reg [31:0] temp_result;
	wire [31:0] temp;
	assign temp = 32'd32 - operand2; // This is for SRA Operation
	parameter ADD = 4'b0000, SUB = 4'b1000, SLL = 4'b0001 , SLT = 4'b0010 , SLTU = 4'b0011 , XOR = 4'b0100 , SRL = 4'b0101 , SRA = 4'b1101 , OR = 4'b0110 , AND = 4'b0111;
	always @(*)
	begin
		case(aluop_control)
			ADD	:	temp_result = operand1 + operand2 ;
			SUB	:	temp_result = operand1 - operand2 ;
			SLL	:	temp_result = (operand1 << operand2[4:0]);
			SLT	:	temp_result = (operand1[31] ^ operand2[31] )? (operand1[31]&~operand2[31]):(operand1 < operand2);
			SLTU	:	temp_result = (operand1 < operand2 ) ? 32'd1 : 32'd0;
			XOR	:	temp_result = (operand1 ^ operand2);
			SRL	:	temp_result = (operand1 >> operand2[4:0]);
			SRA	:	temp_result = (operand1 >> operand2[4:0]) + ({32{1'b1}} << temp);
			OR		:	temp_result = (operand1 | operand2);
			AND	:	temp_result = (operand1 & operand2);
			default	:	temp_result = 32'd0;
		endcase
	end
	
endmodule
module branch_mod(
	input [2:0] branch_control,
	input [31:0] rd1, rd2,
	output result
);
	reg temp;
	parameter BEQ =3'b000 , BNE = 3'b001 , BLT = 3'b100 , BGE = 3'b101 , BLTU = 3'b110 , BGEU =  3'b111;
	wire sign_bit = rd1[31] ^ rd2[31];
	wire result_equ;
	wire result_lessthan;
	wire result_lesstu;
	assign result_equ = (rd1 == rd2);
	assign result_lessthan = (rd1 < rd2);
	assign result_lesstu = (sign_bit)? (rd1[31]&~rd2[31]):(rd1 < rd2);
	always @(*)
	begin
		case(branch_control)
			BEQ	: temp = result_equ;
			BNE	: temp = ~(result_equ);
			BLT	: temp = result_lesstu;
			BGE	: temp = ~(result_lesstu);
			BLTU	: temp = result_lessthan;
			BGEU	: temp = ~(result_lessthan);
			default 	: temp = 1'b0;
		endcase
	end
	assign result = temp;
endmodule
module data_mem(
	input clk,
	input write_enable,
	input [31:0] addr,
	input [31:0] write_data,
	output [31:0] read_data
);
	reg [31:0] mem [0 : 31];
	always @(posedge clk)
	begin
		if (write_enable)
			mem[addr] <= write_data;
	end
	assign read_data = mem[addr];
endmodule
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
	
	wire rs2_valid,imm_valid,func3,rs1_valid,opcode;
	assign opcode = instruction[6:0];
	assign rs2 = instruction[24:20];
	assign rs1 = instruction[19:15];
	assign funct3 = instruction[14:12];
	assign rd = instruction[11:7];
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
module inst_mem(
	input [31:0] addr,
	output [31:0] read_data
);
	reg [31:0] mem [0 : 31];
	assign read_data = mem[addr];
endmodule
module load_mod(
	input [31:0] read_data,
	input [2:0] control,
	output [31:0]  out_data
);
	reg [31:0] temp;
	assign out_data = temp;
	parameter  LB = 3'b000, LH = 3'b001, LW = 3'b010, LBU = 3'b011, LHU = 3'b100;
	always @(*)
	begin
		case(control)
			LB 		: temp = {{25{read_data[7]}},read_data[6:0]};
			LH 		: temp = {{17{read_data[15]}},read_data[14:0]};
			LW 	: temp = read_data;
			LBU 	: temp = {{24{1'b0}},read_data[7:0]};
			LHU	: temp = {{16{1'b0}},read_data[15:0]};
			default	: temp = read_data;
		endcase
	end
endmodule

// implementation of program counter logic for the risc-v cpu
module pc_logic(
	input clk,
	input reset,
	input branch_taken,
	input jalr_branch,
	input [31:0] immediate_val,
	input [31:0] alu_result,
	output [31:0] pcounter,
	output [31:0] next_pc
);
	wire [31:0] next_branch_pc;
	assign next_pc = pc_ff + 32'd1;
	assign next_branch_pc = next_pc + immediate_val;
	
	reg [31:0] pc_ff ;
	always @(posedge clk)
	begin
		if (reset)
			pc_ff = 32'd0;
		else
			pc_ff = (jalr_branch)? alu_result : (branch_taken) ? next_branch_pc : next_pc ;
	end
	assign pcounter = pc_ff;
endmodule


module register_file(
	input clk,
	input write_enable,
	input [4:0] addr1,addr2,addr3,
	input [31:0] write_data,
	output [31:0] rd1,rd2
	
);
	reg [31:0] mem [0:31];
	always @(posedge clk)
	begin
		if (write_enable)
			mem[addr3] <= write_data;			
	end
	
	assign rd1 = mem[addr1];
	assign rd2 = mem[addr2];
endmodule
module store_mod(
	input [31:0] read_data2,
	input [1:0] control,
	output [31:0] out_data
);
	reg [31:0] temp;
	assign out_data = temp;
	always @(*)
	begin
		case (control)
			2'b00 	:	temp =  read_data2;
			2'b01	:	temp = {{17{read_data2[15]}},read_data2[14:0]};
			2'b10	:	temp = {{25{read_data2[7]}},read_data2[6:0]};
			default	:	temp = read_data2;
		endcase
	end
endmodule
module rv32i(
	input clk,
	input reset,
	output ALU_RESULT
);
	assign ALU_RESULT = alu_result;
	// differen wires
	wire [31:0] pc_val;
	wire [31:0] next_pc_val;
	wire [31:0] instruction_val;
	wire [4:0] rs1,rs2,rd;
	wire [31:0] immediate_val;
	wire [10:0] decode_bits;
	wire reg_write_enable;
	wire [31:0] read_d1, read_d2;
	wire [31:0] reg_write_data;
	wire [6:0] opcode;
	wire [2:0] branch_control;
	wire branch_result;
	wire jalr_pc_select;
	wire branch_select;
	wire [2:0] branch_op_control;
	wire [3:0] alu_op_control;
	wire [2:0] load_type_sel;
	wire [1:0] store_type_sel;
	wire write_enable_datamem;
	wire jalr_wd_selc;
	wire mux3_sel;
	wire op_src;
	wire [1:0]  mux5_sel;
	wire [31:0] operand1, operand2;
	wire [31:0] alu_result;
	wire [31:0] store_output_data;
	wire [31:0] read_datamem;
	wire [31:0] load_out_data;
	//different module instantiations
	pc_logic p(clk,reset,branch_taken,jalr_branch,immediate_val,alu_result,pc_val,next_pc_val);
	inst_mem m1(pc_val, instruction_val);
	decode id(instruction_val, rs1, rs2, rd, immediate_val, decode_bits);
	register_file rf(clk,reg_write_enable,rs1,rs2,rd,reg_write_data, read_d1, read_d2);
	control_logic c(decode_bits,opcode,branch_result,jalr_pc_select,branch_select,branch_op_control,alu_op_control,load_type_sel,store_type_sel,write_enable_datamem, reg_write_enable,jalr_wd_selc,mux3_sel, op_src, mux5_sel);
	branch_mod bm(branch_control, read_d1, read_d2,branch_result);
	alu_module alu(alu_op_control,operand1, operand2,alu_result);
	store_mod s(read_d2, store_type_sel, store_output_data);
	data_mem dm(clk,write_enable_datamem,alu_result, store_output_data, read_datamem);
	load_mod l(read_datamem, load_type_sel, load_out_data);
	
	
	//Adding multiplexers
	assign reg_write_data = jalr_wd_selc ? next_pc_val : (mux3_sel) ? load_out_data : alu_result ;
	 assign operand2 = op_src ? read_d2 : immediate_val;
	 assign operand1 = mux5_sel[1] ? read_d1 : (mux5_sel[0]) ? 32'd0 : next_pc_val;

endmodule
