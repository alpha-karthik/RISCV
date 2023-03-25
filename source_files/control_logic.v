module control_logic (
	input [10:0] decode_bits, // {instruction[30], funct3, opcode};
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
	wire [6:0] opcode;
	assign opcode = decode_bits[6:0] ;
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


/*module tb;
	reg [10:0] DECODE_BITS;
	reg Branch_result;
	wire Jalr_pc_select;
	wire Branch_select; 
	wire [2:0] Branch_op_control;
	wire [3:0] Alu_op_control;
	wire [2:0] Load_type_sel;	
	wire [1:0] Store_type_sel;	
	wire Write_enable_datamem; 
	wire Write_enable_regfile;
	wire Jalr_wd_selc;
	wire Mux3_sel; 
	wire Op_src;	
	wire [1:0]  Mux5_sel;
	
	control_logic c(DECODE_BITS, Branch_result,Jalr_pc_select, Branch_select, Branch_op_control, Alu_op_control, Load_type_sel, Store_type_sel, Write_enable_datamem, Write_enable_regfile, Jalr_wd_selc, Mux3_sel, Op_src, Mux5_sel);
	
	initial
	begin
		$dumpfile("controlunit_waveform.vcd");
		$dumpvars();
		// R-type Instruction
		#0 DECODE_BITS = 11'b00000110011;
		#5 DECODE_BITS = 11'b10000110011;
		#5 DECODE_BITS = 11'b00010110011;
		#5 DECODE_BITS = 11'b00100110011;
		#5 DECODE_BITS = 11'b00110110011;
		#5 DECODE_BITS = 11'b01000110011;
		#5 DECODE_BITS = 11'b01010110011;
		#5 DECODE_BITS = 11'b11010110011;
		#5 DECODE_BITS = 11'b01100110011;
		#5 DECODE_BITS = 11'b01110110011;
		// Immediate type Instruction
		#5 DECODE_BITS = 11'b00000010011;
		#5 DECODE_BITS = 11'b00010010011;
		#5 DECODE_BITS = 11'b00100010011;
		#5 DECODE_BITS = 11'b00110010011;
		#5 DECODE_BITS = 11'b01000010011;
		#5 DECODE_BITS = 11'b01010010011;
		#5 DECODE_BITS = 11'b11010010011;
		#5 DECODE_BITS = 11'b01100010011;
		#5 DECODE_BITS = 11'b01110010011;
		//Store Type Instruction
		#5 DECODE_BITS = 11'b00000100011;
		#5 DECODE_BITS = 11'b00010100011;
		#5 DECODE_BITS = 11'b00100100011;
		//Load Type Instruction
		#5 DECODE_BITS = 11'b00000000011;
		#5 DECODE_BITS = 11'b00010000011;
		#5 DECODE_BITS = 11'b00100000011;
		#5 DECODE_BITS = 11'b01000000011;
		#5 DECODE_BITS = 11'b01010000011;
		//Branch Type Instruction
		#5 DECODE_BITS = 11'b00001100011;
		#5 DECODE_BITS = 11'b00011100011;
		#5 DECODE_BITS = 11'b01001100011;
		#5 DECODE_BITS = 11'b01011100011;
		#5 DECODE_BITS = 11'b01101100011;
		#5 DECODE_BITS = 11'b01111100011;
		//Specific Instructions
		#5 DECODE_BITS = 11'b00000110111;
		#5 DECODE_BITS = 11'b00000010111;
		#5 DECODE_BITS = 11'b00001101111;
		#5 DECODE_BITS = 11'b00001100111;
		#5 $finish;
	end

	
endmodule*/
