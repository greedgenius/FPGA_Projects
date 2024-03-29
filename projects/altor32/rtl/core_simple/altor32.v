//-----------------------------------------------------------------
//                           AltOR32 
//              Alternative Lightweight OpenRisc 
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//
// If you would like a version with a different license for use 
// in commercial projects please contact the above email address 
// for more details.
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.                                               
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.                                                     
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"

//-----------------------------------------------------------------
// Module
//-----------------------------------------------------------------
module cpu 
( 
	// General
	clk_i,
	rst_i, 
	en_i, 
	intr_i, 
	fault_o, 
	break_o,

	// Memory Interface
	mem_addr_o, 
	mem_data_out_o, 
	mem_data_in_i, 
	mem_wr_o, 
	mem_rd_o, 
	mem_pause_i
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter [31:0]	BOOT_VECTOR		= 32'h00000000;
parameter [31:0]	ISR_VECTOR		= 32'h00000000;
parameter		REGISTER_FILE_TYPE 	= "SIMULATION";

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
// General
input			clk_i /*verilator public*/;
input			rst_i /*verilator public*/;
input			en_i /*verilator public*/;
input			intr_i /*verilator public*/;
output			fault_o /*verilator public*/;
output			break_o /*verilator public*/;

// Memory Interface
output [31:0]		mem_addr_o /*verilator public*/;
output [31:0]		mem_data_out_o /*verilator public*/;
input [31:0]		mem_data_in_i /*verilator public*/;
output [3:0]		mem_wr_o /*verilator public*/;
output			mem_rd_o /*verilator public*/;
input			mem_pause_i /*verilator public*/;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
  
// Current program counter
reg [31:0] r_pc;

// Next program counter
reg [31:0] r_pc_next;

// Exception saved program counter
reg [31:0] r_epc;

// Supervisor register
reg [31:0] r_sr;

// Exception saved supervisor register
reg [31:0] r_esr;

// Register number (rA)
reg [4:0] r_ra;

// Register number (rB)
reg [4:0] r_rb;

// Destination register number (pre execute stage)
reg [4:0] r_rd;

// Destination register number (post execute stage)
reg [4:0] r_rd_wb;

// Register value (rA)
wire [31:0] r_reg_ra;

// Register value (rB)
wire [31:0] r_reg_rb;

// Current opcode
reg [31:0] r_opcode;

// Execute result output (non-ALU)
reg [31:0] r_reg_result;

// Register writeback value
reg [31:0] r_reg_rd;

// Register writeback enable
reg r_writeback;

// Memory operation address (data only)
reg [31:0] mem_addr;

// Memory operation write data
reg [31:0] mem_data_out;

// Memory operation write mask
reg [3:0] mem_wr;

// Memory read operation
reg mem_rd;

// Memory operation byte/word select
reg [1:0] mem_offset;

// Memory operation occurring
reg r_mem_access;

// ALU input A
reg [31:0] alu_a;

// ALU input B
reg [31:0] alu_b;

// ALU output
wire [31:0] alu_result;

// ALU operation selection
reg [3:0] alu_func;

// Current state
parameter STATE_RESET	   = 3'b000;
parameter STATE_FETCH	   = 3'b001;
parameter STATE_EXECUTE	 = 3'b010;
parameter STATE_MEMORY	  = 3'b011;
parameter STATE_WRITEBACK   = 3'b100;
reg [2:0] r_state;

// Fault output
reg fault_o;

// Break/Trap output
reg break_o;

// Memory output signals
wire [31:0] mem_addr_o;
wire [31:0] mem_data_out_o;
wire [3:0] mem_wr_o;
wire mem_rd_o;

//-----------------------------------------------------------------
// Instantiation
//-----------------------------------------------------------------

// ALU
altor32_alu alu
(
	.input_a(alu_a), 
	.input_b(alu_b), 
	.func(alu_func), 
	.result(alu_result)
);

// Register file
generate
if (REGISTER_FILE_TYPE == "XILINX")
begin
	altor32_regfile_xil
	reg_bank
	(
		// Clocking
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.en_i(1'b1), 
		.wr_i(r_writeback), 
		
		// Tri-port
		.rs_i(r_ra), 
		.rt_i(r_rb), 
		.rd_i(r_rd_wb), 
		.reg_rs_o(r_reg_ra), 
		.reg_rt_o(r_reg_rb), 
		.reg_rd_i(r_reg_rd)
	);
end
else if (REGISTER_FILE_TYPE == "ALTERA")
begin
	altor32_regfile_alt
	reg_bank
	(
		// Clocking
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.en_i(1'b1), 
		.wr_i(r_writeback), 
		
		// Tri-port
		.rs_i(r_ra), 
		.rt_i(r_rb), 
		.rd_i(r_rd_wb), 
		.reg_rs_o(r_reg_ra), 
		.reg_rt_o(r_reg_rb), 
		.reg_rd_i(r_reg_rd)
	);
end   
else
begin
	altor32_regfile_sim
	reg_bank
	(
		// Clocking
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.en_i(1'b1), 
		.wr_i(r_writeback), 
		
		// Tri-port
		.rs_i(r_ra), 
		.rt_i(r_rb), 
		.rd_i(r_rd_wb), 
		.reg_rs_o(r_reg_ra), 
		.reg_rt_o(r_reg_rb), 
		.reg_rd_i(r_reg_rd)
	);
end
endgenerate
	
//-------------------------------------------------------------------
// Decode: Decode instruction
//-------------------------------------------------------------------	   
always @ (posedge clk_i or posedge rst_i) 
begin 
	if (rst_i) 
	begin 
		r_opcode	<= 32'h00000000;
		r_rd		<= 5'b00000;
		r_ra		<= 5'b00000;
		r_rb		<= 5'b00000;
	end
	// Instruction fetch cycle
	else if ((en_i == 1'b1) && (r_state == STATE_FETCH))
	begin 
		// Decode opcode in-order to perform register accesses  
		r_opcode 	<= mem_data_in_i;
		r_rd		<= mem_data_in_i[25:21];
		r_ra		<= mem_data_in_i[20:16];
		r_rb		<= mem_data_in_i[15:11];
		
`ifdef CONF_CORE_DEBUG			
		$display("%08x: Fetch 0x%08x", r_pc, mem_data_in_i);
`endif				 
	end 
end

//-------------------------------------------------------------------
// Execute: Execute opcode
//-------------------------------------------------------------------

// Execute stage blocking assignment vars
reg [7:0] v_inst;
reg [4:0] v_ra;
reg [4:0] v_rb;
reg [4:0] v_rd;
reg [7:0] v_alu_op;
reg [1:0] v_shift_op;
reg [15:0] v_sfxx_op;
reg [15:0] v_imm;
reg [31:0] v_imm_uint32;
reg [31:0] v_imm_int32;
reg [31:0] v_store_imm;
reg [15:0] v_mxspr_imm;
reg [31:0] v_target;
reg [31:0] v_reg_ra;
reg [31:0] v_reg_rb;
reg [31:0] v_pc;
reg [31:0] v_pc_next;
reg [31:0] v_reg_result;
reg [31:0] v_offset;
reg [31:0] v_shift_val;
reg [31:0] v_shift_imm;
reg [31:0] v_vector;
reg [31:0] v_sr;
reg [31:0] v_mem_addr;
reg [31:0] v_mem_data_in;
reg v_exception;
reg v_branch;
reg v_jmp;
reg v_write_rd;
reg v_mem_access;

always @ (posedge clk_i or posedge rst_i) 
begin 
	if (rst_i == 1'b1) 
	begin 
		r_pc				<= BOOT_VECTOR + `VECTOR_RESET;
		r_pc_next			<= BOOT_VECTOR + `VECTOR_RESET;
	
		r_epc				<= 32'h00000000;
		r_sr				<= 32'h00000000;
		r_esr				<= 32'h00000000;		
		r_rd_wb				<= 5'b00000;
		
		// Default to no ALU operation
		alu_func			<= `ALU_NONE;		
	
		mem_addr			<= 32'h00000000;
		mem_data_out			<= 32'h00000000;
		mem_rd				<= 1'b0;
		mem_wr				<= 4'b0000;
		mem_offset			<= 2'b00;
		
		fault_o				<= 1'b0;
		break_o				<= 1'b0;
		r_mem_access			<= 1'b0;
	end
	// Enabled
	else if (en_i == 1'b1)
	begin 
	
	r_mem_access				<= 1'b0;
	mem_rd					<= 1'b0;
	mem_wr					<= 4'b0000;
	break_o					<= 1'b0;
	
	// Memory stalls are not supported by this version of the core
	if (mem_pause_i == 1'b1)
	begin
		fault_o <= 1'b1;
`ifdef CONF_CORE_DEBUG
			$display("Memory pause not supported on this implementation!");
`endif		 
	end

	// Execute stage?			
	if (r_state == STATE_EXECUTE)
	begin

`ifdef CONF_CORE_DEBUG
		// This opcode is valid (l.j same_location) but not usual and
		// can sometimes indicate an error occurred in the execution/fetch
		if (r_opcode == 32'h00000000)
			fault_o <= 1'b1;
		else
			$display("%08x: Execute 0x%08x", r_pc, r_opcode);
`endif			

			v_exception 			= 1'b0;
			v_vector    			= 32'h00000000;
			v_branch    			= 1'b0;
			v_jmp	    			= 1'b0;
			v_write_rd  			= 1'b0;
			v_sr	    			= r_sr;
			v_mem_access			= 1'b0;
			
			// Decode opcode
			v_mem_data_in			= r_opcode;
			v_inst				= {2'b00,v_mem_data_in[31:26]};
			v_rd				= v_mem_data_in[25:21];
			v_ra				= v_mem_data_in[20:16];
			v_rb				= v_mem_data_in[15:11];
			v_alu_op			= {v_mem_data_in[9:6],v_mem_data_in[3:0]};
			v_sfxx_op			= {5'b00,v_mem_data_in[31:21]};
			v_shift_op			= v_mem_data_in[7:6];
			v_target			= sign_extend_imm26(v_mem_data_in[25:0]);
			v_store_imm			= sign_extend_imm16({v_mem_data_in[25:21],v_mem_data_in[10:0]});
			
			// Signed & unsigned imm -> 32-bits
			v_imm				= v_mem_data_in[15:0];
			v_imm_int32			= sign_extend_imm16(v_imm);
			v_imm_uint32			= extend_imm16(v_imm);
			
			// Load register[ra]
			v_reg_ra			= r_reg_ra;
			
			// Load register[rb]
			v_reg_rb			= r_reg_rb;
			
			// Shift ammount (from register[rb])
			v_shift_val			= {26'b00,v_reg_rb[5:0]};

			// Shift ammount (from immediate)
			v_shift_imm			= {26'b00,v_imm[5:0]};
			
			// MTSPR/MFSPR operand
			v_mxspr_imm			=  (v_reg_ra[15:0] | {5'b000000,v_mem_data_in[10:0]});
			
			// Zero result
			v_reg_result			= 32'h00000000;
			
			// Update PC to next value
			v_pc				= r_pc_next;
			
			// Increment next PC value (might be overriden by branch)
			v_pc_next			= r_pc_next + 4;		
			
			// Default target is r_rd
			r_rd_wb			<= r_rd;		
			
			// Default to no ALU operation
			alu_func			<= `ALU_NONE;	  
			
			// Execute instruction
			case (v_inst)
				`INST_OR32_ALU : 
				begin
					case (v_alu_op)
						`INST_OR32_ADD: // l.add
						begin 
							alu_func <= `ALU_ADD;
							alu_a <= v_reg_ra;
							alu_b <= v_reg_rb;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_AND: // l.and
						begin 
							alu_func <= `ALU_AND;
							alu_a <= v_reg_ra;
							alu_b <= v_reg_rb;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_OR: // l.or
						begin 
							alu_func <= `ALU_OR;
							alu_a <= v_reg_ra;
							alu_b <= v_reg_rb;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SLL: // l.sll
						begin 
							alu_func <= `ALU_SHIFTL;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_val;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SRA: // l.sra
						begin 
							alu_func <= `ALU_SHIRTR_ARITH;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_val;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SRL: // l.srl
						begin 
							alu_func <= `ALU_SHIFTR;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_val;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SUB: // l.sub
						begin 
							alu_func <= `ALU_SUB;
							alu_a <= v_reg_ra;
							alu_b <= v_reg_rb;
							v_write_rd = 1'b1;
						end						
						
						`INST_OR32_XOR: // l.xor
						begin 
							alu_func <= `ALU_XOR;
							alu_a <= v_reg_ra;
							alu_b <= v_reg_rb;
							v_write_rd = 1'b1;
						end
						
						default:
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase
				end
				
				`INST_OR32_ADDI: // l.addi
				begin 
					alu_func <= `ALU_ADD;
					alu_a <= v_reg_ra;
					alu_b <= v_imm_int32;
					v_write_rd = 1'b1;
				end
				
				`INST_OR32_ANDI: // l.andi
				begin 
					alu_func <= `ALU_AND;
					alu_a <= v_reg_ra;
					alu_b <= v_imm_uint32;
					v_write_rd = 1'b1;
				end			
				
				`INST_OR32_BF: // l.bf
				begin
					if (v_sr[`OR32_SR_F] == 1'b1)
						v_branch = 1'b1;
				end
				
				`INST_OR32_BNF: // l.bnf
				begin
					if (v_sr[`OR32_SR_F] == 1'b0)
						v_branch = 1'b1;
				end
				
				`INST_OR32_J: // l.j
				begin
					v_branch = 1'b1;
				end			
				
				`INST_OR32_JAL: // l.jal
				begin 
					v_reg_result = v_pc_next;
					v_write_rd = 1'b1;
					r_rd_wb <= 5'b01001; // Write to REG_9_LR
					
					v_branch = 1'b1;
				end
			  
			  `INST_OR32_JALR: // l.jalr
				begin 
					v_reg_result = v_pc_next;
					v_write_rd = 1'b1;
					r_rd_wb <= 5'b01001; // Write to REG_9_LR
					
					v_pc_next = v_reg_rb;
					v_jmp = 1;
				end
		
			  `INST_OR32_JR: // l.jr
				begin 
					v_pc_next = v_reg_rb;
					v_jmp = 1;
				end		  
			  
				// l.lbs l.lhs l.lws l.lbz l.lhz l.lwz		  
				`INST_OR32_LBS, `INST_OR32_LHS, `INST_OR32_LWS, `INST_OR32_LBZ, `INST_OR32_LHZ, `INST_OR32_LWZ :
				begin 
					v_mem_addr = (v_reg_ra + v_imm_int32);
					mem_addr <= {v_mem_addr[31:2],2'b00};
					mem_data_out <= 32'h00000000;
					mem_rd <= 1'b1;
					mem_offset <= v_mem_addr[1:0];
					v_write_rd = 1'b1;
					v_mem_access = 1'b1;
				end		  
			  
			  `INST_OR32_MFSPR: // l.mfspr
			  begin 
					case (v_mxspr_imm)
						// SR - Supervision register
						`SPR_REG_SR:
						begin 
							v_reg_result = v_sr;
							v_write_rd = 1'b1;
						end
						
						// EPCR - EPC Exception saved PC
						`SPR_REG_EPCR:
						begin 
							v_reg_result = r_epc;
							v_write_rd = 1'b1;
						end
						
						// ESR - Exception saved SR
						`SPR_REG_ESR:
						begin 
							v_reg_result = r_esr;
							v_write_rd = 1'b1;
						end
						
						default:
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase		  
				end			  
					 
			  `INST_OR32_MTSPR: // l.mtspr
			  begin 
					case (v_mxspr_imm)
						// SR - Supervision register
						`SPR_REG_SR:
						begin 
							v_sr = v_reg_rb;
						end
						
						// EPCR - EPC Exception saved PC
						`SPR_REG_EPCR:
						begin 
							r_epc <= v_reg_rb;
						end
						
						// ESR - Exception saved SR
						`SPR_REG_ESR:
						begin 
							r_esr <= v_reg_rb;
						end
						
						default:
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase		  
				end				 
			  
				`INST_OR32_MOVHI: // l.movhi 
				begin 
					v_reg_result = {v_imm,16'h0000};
					v_write_rd = 1'b1;
				end		  
			  
				`INST_OR32_NOP: // l.nop
				begin 
				  
				end			  
			  
				`INST_OR32_ORI: // l.ori
				begin 
					alu_func <= `ALU_OR;
					alu_a <= v_reg_ra;
					alu_b <= v_imm_uint32;
					v_write_rd = 1'b1;
				end		  
			  
				`INST_OR32_RFE: // l.rfe
				begin
					// TODO: This instruction should not have a delay slot
					// but does in this implementation...
					v_pc_next = r_epc;
					v_sr	  = r_esr;
					v_jmp	 = 1;
				end				 
			  
			  `INST_OR32_SHIFTI :
			  begin 
					case (v_shift_op)
						`INST_OR32_SLLI: // l.slli
						begin 
							alu_func <= `ALU_SHIFTL;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_imm;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SRAI: // l.srai
						begin 
							alu_func <= `ALU_SHIRTR_ARITH;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_imm;
							v_write_rd = 1'b1;
						end
						
						`INST_OR32_SRLI: // l.srli
						 begin 
							alu_func <= `ALU_SHIFTR;
							alu_a <= v_reg_ra;
							alu_b <= v_shift_imm;
							v_write_rd = 1'b1;
						end
						
						default:
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase		  
				end
				
				`INST_OR32_SB: 
				begin 
					v_mem_addr = (v_reg_ra + v_store_imm);
					mem_addr <= {v_mem_addr[31:2],2'b00};
					case (v_mem_addr[1:0])
						2'b00 : 
						begin 
							mem_data_out <= {v_reg_rb[7:0],24'h000000};
							mem_wr <= 4'b1000;
							v_mem_access = 1'b1;
						end
						2'b01 : 
						begin 
							mem_data_out <= {{8'h00,v_reg_rb[7:0]},16'h0000};
							mem_wr <= 4'b0100;
							v_mem_access = 1'b1;
						end
						2'b10 : 
						begin 
							mem_data_out <= {{16'h0000,v_reg_rb[7:0]},8'h00};
							mem_wr <= 4'b0010;
							v_mem_access = 1'b1;
						end
						2'b11 : 
						begin 
							mem_data_out <= {24'h000000,v_reg_rb[7:0]};
							mem_wr <= 4'b0001;
							v_mem_access = 1'b1;
						end
						default : 
						begin 
							mem_data_out <= 32'h00000000;
							mem_wr <= 4'b0000;
						end
					endcase
				end		  
			  
			  `INST_OR32_SFXX, `INST_OR32_SFXXI:
			  begin
					case (v_sfxx_op)
						`INST_OR32_SFEQ: // l.sfeq
						begin 
							if (v_reg_ra == v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;
						end
						
						`INST_OR32_SFEQI: // l.sfeqi
						begin 
							if (v_reg_ra == v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;
						end
						
						`INST_OR32_SFGES: // l.sfges
						begin 
							if (greater_than_equal_signed(v_reg_ra, v_reg_rb) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGESI: // l.sfgesi
						begin 
							if (greater_than_equal_signed(v_reg_ra, v_imm_int32) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGEU: // l.sfgeu
						begin 
							if (v_reg_ra >= v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;						
						end
						
						`INST_OR32_SFGEUI: // l.sfgeui
						begin 
							if (v_reg_ra >= v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGTS: // l.sfgts
						begin 
							if (greater_than_signed(v_reg_ra, v_reg_rb) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGTSI: // l.sfgtsi
						begin 
							if (greater_than_signed(v_reg_ra, v_imm_int32) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGTU: // l.sfgtu
						begin 
							if (v_reg_ra > v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFGTUI: // l.sfgtui
						begin 
							if (v_reg_ra > v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLES: // l.sfles
						begin 
							if (less_than_equal_signed(v_reg_ra, v_reg_rb) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLESI: // l.sflesi
						begin 
							if (less_than_equal_signed(v_reg_ra, v_imm_int32) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLEU: // l.sfleu
						begin 
							if (v_reg_ra <= v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLEUI: // l.sfleui
						begin 
							if (v_reg_ra <= v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLTS: // l.sflts
						begin 
							if (less_than_signed(v_reg_ra, v_reg_rb) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;							 
						end
						
						`INST_OR32_SFLTSI: // l.sfltsi
						begin 
							if (less_than_signed(v_reg_ra, v_imm_int32) == 1'b1)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLTU: // l.sfltu
						begin 
							if (v_reg_ra < v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFLTUI: // l.sfltui
						begin 
							if (v_reg_ra < v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0; 
						end
						
						`INST_OR32_SFNE: // l.sfne
						begin 
							if (v_reg_ra != v_reg_rb)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;
						end
						
						`INST_OR32_SFNEI: // l.sfnei
						begin 
							if (v_reg_ra != v_imm_int32)
								v_sr[`OR32_SR_F] = 1'b1;
							else
								v_sr[`OR32_SR_F] = 1'b0;
						end																	 
						
						default:
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase		  
				end
				
				`INST_OR32_SH: // l.sh
				begin 
					v_mem_addr = (v_reg_ra + v_store_imm);
					mem_addr <= {v_mem_addr[31:2],2'b00};
					case (v_mem_addr[1:0])
						2'b00 : 
						begin 
							mem_data_out <= {v_reg_rb[15:0],16'h0000};
							mem_wr <= 4'b1100;
							v_mem_access = 1'b1;
						end
						2'b10 : 
						begin 
							mem_data_out <= {16'h0000,v_reg_rb[15:0]};
							mem_wr <= 4'b0011;
							v_mem_access = 1'b1;
						end
						default : 
						begin 
							mem_data_out <= 32'h00000000;
							mem_wr <= 4'b0000;
						end
					endcase
				end
				
				`INST_OR32_SW: // l.sw
				begin 
					v_mem_addr = (v_reg_ra + v_store_imm);
					mem_addr <= {v_mem_addr[31:2],2'b00};
					mem_data_out <= v_reg_rb;
					mem_wr <= 4'b1111;
					v_mem_access = 1'b1;
				end			
				
			  `INST_OR32_MISC:
			  begin
					case (v_mem_data_in[31:24])
						`INST_OR32_SYS: // l.sys
						begin 
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_SYSCALL;
						end
						
						`INST_OR32_TRAP: // l.trap
						begin 
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_TRAP;
							break_o <= 1'b1;
						end
						
						default : 
						begin 
							fault_o <= 1'b1;
							v_exception = 1'b1;
							v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
						end
					endcase			 
				end
				
				`INST_OR32_XORI: // l.xori
				begin 
					alu_func <= `ALU_XOR;
					alu_a <= v_reg_ra;
					alu_b <= v_imm_int32;
					v_write_rd = 1'b1;
				end
				
				default : 
				begin 
					fault_o <= 1'b1;
					v_exception = 1'b1;
					v_vector = ISR_VECTOR + `VECTOR_ILLEGAL_INST;
				end
			endcase
			
			// Handle branches
			if (v_branch == 1'b1) 
			begin 
				v_offset		 = {v_target[29:0],2'b00};
				v_pc_next		= (r_pc + v_offset);
			end
			// If not branching, handle interrupts / exceptions
			else if (v_jmp == 1'b0)
			begin 
			
				// Exception (Fault/Syscall/Break)
				if (v_exception == 1'b1) 
				begin 
				
					// Save PC & SR
					r_epc <= v_pc;
					r_esr <= v_sr;

					// Jump to exception vector
					v_pc = v_vector;
					v_pc_next = v_pc + 4;

					// Disable further interrupts
					v_sr = 0;
				end
				// External interrupt (and not handling an exception or branch)?
				else if ((intr_i == 1'b1) && (v_sr[`OR32_SR_IEE] == 1'b1)) 
				begin 
					// Save PC & SR
					r_epc <= v_pc;
					r_esr <= v_sr;

					// Jump to exception vector
					v_pc = `VECTOR_EXTINT;
					v_pc_next = v_pc + 4;

					// Disable further interrupts
					v_sr = 0;
				end
			end 

			// Update registers with variable values
			r_pc		 <= v_pc;
			r_pc_next	<= v_pc_next;
			r_sr		 <= v_sr;
			r_reg_result <= v_reg_result;
			r_mem_access <= v_mem_access;
			
			// No writeback required?
			if (v_write_rd == 1'b0)
			begin
				// Target register is R0 which is read-only
				r_rd_wb <= 5'b00000;
			end				
		end
	end
end

//-------------------------------------------------------------------
// Writeback
//-------------------------------------------------------------------	
reg [31:0] wb_v_reg_result;
reg [7:0] wb_v_inst;

always @ (posedge clk_i or posedge rst_i)
begin 
	if (rst_i == 1'b1)
	begin
		r_writeback <= 1'b1;
	end
	// Enabled
	else if (en_i == 1'b1)
	begin 
		r_writeback <= 1'b0;
		
		// Writeback stage?
		if (r_state == STATE_WRITEBACK)
		begin 
		
			wb_v_reg_result = r_reg_result;
			
			// Handle delayed result instructions
			wb_v_inst = {2'b00,r_opcode[31:26]};
			case (wb_v_inst)
				`INST_OR32_LBS: // l.lbs
				begin 
					case (mem_offset)
						2'b00 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[31:24]};
						2'b01 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[23:16]};
						2'b10 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[15:8]};
						2'b11 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[7:0]};
						default : 
							wb_v_reg_result = 32'h00000000;
					endcase
					
					// Sign extend LB
					if (wb_v_reg_result[7] == 1'b1)
						wb_v_reg_result = {24'hFFFFFF,wb_v_reg_result[7:0]};
				end
				
				`INST_OR32_LBZ: // l.lbz
					case (mem_offset)
						2'b00 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[31:24]};
						2'b01 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[23:16]};
						2'b10 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[15:8]};
						2'b11 : 
							wb_v_reg_result = {24'h000000,mem_data_in_i[7:0]};
						default : 
							wb_v_reg_result = 32'h00000000;
					endcase
					
				`INST_OR32_LHS: // l.lhs
				begin 
					case (mem_offset)
						2'b00 : 
							wb_v_reg_result = {16'h0000,mem_data_in_i[31:16]};
						2'b10 : 
							wb_v_reg_result = {16'h0000,mem_data_in_i[15:0]};
						default : 
							wb_v_reg_result = 32'h00000000;
					endcase
					
					// Sign extend LH
					if (wb_v_reg_result[15] == 1'b1)
						wb_v_reg_result = {16'hFFFF,wb_v_reg_result[15:0]};
				end
				
				`INST_OR32_LHZ: // l.lhz
					case (mem_offset)
						2'b00 : 
							wb_v_reg_result = {16'h0000,mem_data_in_i[31:16]};
						2'b10 : 
							wb_v_reg_result = {16'h0000,mem_data_in_i[15:0]};
						default : 
							wb_v_reg_result = 32'h00000000;
					endcase
									
				`INST_OR32_LWZ, `INST_OR32_LWS: // l.lwz l.lws
					wb_v_reg_result = mem_data_in_i;
					
				default : 
					wb_v_reg_result = r_reg_result;
			endcase
			
			// Result from memory / other
			if (alu_func == `ALU_NONE)
			begin
				r_reg_rd <= wb_v_reg_result;
			end
			// Result from ALU
			else 
			begin
				r_reg_rd <= alu_result;
			end
			
			// Register writeback required?
			if (r_rd_wb != 5'b00000)
			begin
				r_writeback <= 1'b1;
				
`ifdef CONF_CORE_DEBUG				
			if (alu_func == `ALU_NONE)
				$display("%08x: Writeback R%d = 0x%08x", r_pc, r_rd_wb, wb_v_reg_result);
			else
				$display("%08x: Writeback R%d = 0x%08x", r_pc, r_rd_wb, alu_result);
`endif
			end
		end
	end
end 

//-------------------------------------------------------------------
// Cycle Control
//-------------------------------------------------------------------		
always @ (posedge clk_i or posedge rst_i)
begin 
	if (rst_i) 
	begin
		r_state <= STATE_RESET;
	end
	else if (en_i == 1'b1) 
	begin 
		case (r_state)
			STATE_RESET :
			begin
				r_state <= STATE_WRITEBACK;
			end
			STATE_FETCH : 
			begin
				r_state <= STATE_EXECUTE;					
			end
			STATE_EXECUTE : 
			begin
				r_state <= STATE_MEMORY;
			end
			STATE_MEMORY:
			begin
				r_state <= STATE_WRITEBACK;
			end			
			STATE_WRITEBACK : 
			begin
				r_state <= STATE_FETCH;
			end
			default : 
			begin
				r_state <= STATE_RESET;
			end
		endcase
	end 
end 
	
//-------------------------------------------------------------------
// Combinatorial
//------------------------------------------------------------------- 
	
// Memory access mux
assign mem_addr_o	= (r_mem_access == 1'b1) ? mem_addr : r_pc;
assign mem_data_out_o	= (r_mem_access == 1'b1) ? mem_data_out : 32'h00000000;
assign mem_rd_o		= (r_mem_access == 1'b1) ? mem_rd : 1'b1;
assign mem_wr_o		= mem_wr;

`include "altor32_funcs.v"	
	
endmodule
