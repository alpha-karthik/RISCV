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
			begin
			mem[addr] <= write_data;
			mem[1] <= 32'd4;
			mem[2] <= 32'd3;
			end
		else
			begin
			mem[1] <= 32'd4;
			mem[2] <= 32'd3;
			end
		
	end
	assign read_data = mem[addr];
endmodule


