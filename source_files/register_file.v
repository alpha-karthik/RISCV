module register_file(
	input clk,
	input clr,
	input write_enable,
	input [4:0] addr1,addr2,addr3,
	input [31:0] write_data,
	output [31:0] rd1,rd2
);
	integer i; 
	reg [31:0] mem [0:31];
	always @(posedge clk)
	begin
		if (clr)
			begin
			for ( i = 0; i < 32; i= i+1)
				mem[i] <= 32'd0;
			end
		else if (write_enable)
			mem[addr3] <= write_data;
		else
			begin
				for (i =0; i <32; i= i +1)
					mem[i] <= mem[i];
			end
	
	end
	
	assign rd1 = mem[addr1];
	assign rd2 = mem[addr2];
endmodule


/*module tb;
	reg clk;
	reg we;
	reg [4:0] addr1,addr2,addr3;
	reg [31:0] wdata;
	wire [31:0] r1,r2;
	reg rst;
	register_file rf(clk,rst,we,addr1,addr2,addr3,wdata,r1,r2);
	always #5 clk = ~clk;
	initial
	begin	
		$dumpfile("register.vcd");
		$dumpvars();
		#0 we = 1'b1;
		#0 rst = 1'b1;
		#0 clk = 1'b0;
		#0 addr1 = 5'b0;
		#6 we = 1'b1; rst = 1'b0;
		#5 addr3 = 5'd4;
		wdata = 32'd7;
		#10 addr1 = 5'd4;
		#50 $finish;
		
	end
endmodule*/
