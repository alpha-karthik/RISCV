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

/*module top();
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] bc;
	wire result;
	branch_mod m(bc,A,B,result);
	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars();
		#0 A = -32'd100;
		#0 B = -32'd200;
		
		#5 bc = 3'd0;
		#5 bc = 3'd1;
		#5 bc = 3'd2;
		#5 bc = 3'd3;
		#5 bc = 3'd4;
		#5 bc = 3'd5;
		#10 $finish;
	end
endmodule*/
