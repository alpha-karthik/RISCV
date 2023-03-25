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

/*module top();
	reg [31:0] data;
	reg [2:0] ctrl;
	wire [31:0] out;
	load_mod m (data,ctrl,out);
	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars();
		#0 data <= 32'h12345678;
		#5 ctrl = 3'b000;
		#5 ctrl = 3'b001;
		#5 ctrl = 3'b010;
		#5 ctrl = 3'b011;
		#5 ctrl = 3'b100;
		#10 $finish;
	end
endmodule*/
