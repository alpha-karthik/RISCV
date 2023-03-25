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
