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
			SRA	:	temp_result = (operand1 >> operand2[4:0]) + ({32{operand1[31]}} << temp);
			OR		:	temp_result = (operand1 | operand2);
			AND	:	temp_result = (operand1 & operand2);
			default	:	temp_result = 32'd0;
		endcase
	end
	assign alu_result = temp_result;
	
endmodule

/*module test;
	reg [3:0] ALUOP_CTRL;
	reg [31:0] OP1,OP2;
	wire [31:0] RESULT;
	
	alu_module a(ALUOP_CTRL, OP1, OP2, RESULT);
	initial
	begin
		$dumpfile("alu_wave.vcd");
		$dumpvars();
		#0 OP1 = 32'd20;
		#0 OP2 = -32'd32;
		#5 ALUOP_CTRL = 4'b0000;
		#5 ALUOP_CTRL = 4'b1000;
		#5 ALUOP_CTRL = 4'b0001;
		#5 ALUOP_CTRL = 4'b0010;
		#5 ALUOP_CTRL = 4'b0011;
		#5 ALUOP_CTRL = 4'b0100;
		#5 ALUOP_CTRL = 4'b0101;
		#5 ALUOP_CTRL = 4'b1101;
		#5 ALUOP_CTRL = 4'b0110;
		#5 ALUOP_CTRL = 4'b0111;
		#5 ALUOP_CTRL = 4'b0000;
		#5 $finish;
	end
endmodule*/
