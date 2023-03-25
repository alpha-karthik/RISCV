`include "alu_module.v"
`include "branch_mod.v"
`include "control_logic.v"
`include "data_mem.v"
`include "instr_decode.v"
`include "instruction_mem.v"
`include "load_mod.v"
`include "store_mod.v"
`include "pc_logic.v"
`include "register_file.v"


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
	assign branch_taken = branch_select;
	assign jalr_branch = jalr_pc_select;
	//different module instantiations
	pc_logic p(clk,reset,branch_taken,jalr_branch,immediate_val,alu_result,pc_val,next_pc_val);
	inst_mem m1(clk,pc_val, instruction_val);
	decode id(instruction_val, rs1, rs2, rd, immediate_val, decode_bits);
	register_file rf(clk,reset,reg_write_enable,rs1,rs2,rd,reg_write_data, read_d1, read_d2);
	control_logic c(decode_bits,branch_result,jalr_pc_select,branch_select,branch_op_control,alu_op_control,load_type_sel,store_type_sel,write_enable_datamem, reg_write_enable,jalr_wd_selc,mux3_sel, op_src, mux5_sel);
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

module tb;
	reg clk;
	reg reset;
	wire res;
	rv32i r (clk,reset,res);
	always #5 clk = ~clk;
	initial
		begin
		$dumpfile("main.vcd");
		$dumpvars();
		#0 reset = 1'b1;
		#0 clk = 1'b0;
		#6 reset = 1'b0;
		#60 $finish;
		end
endmodule
