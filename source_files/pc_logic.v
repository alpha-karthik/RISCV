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



