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
module altor32_alu
(
    input_a,
    input_b,
    carry_in,
    func,
    result,
    carry_out,
    carry_update
);

//-----------------------------------------------------------------
// I/O
//-----------------------------------------------------------------
input [31:0]    input_a     /*verilator public*/;
input [31:0]    input_b     /*verilator public*/;
input           carry_in    /*verilator public*/;
input [3:0]     func        /*verilator public*/;
output [31:0]   result      /*verilator public*/;
output          carry_out   /*verilator public*/;
output          carry_update/*verilator public*/;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [31:0]      result;
reg             carry_out;
reg             carry_update;

reg [31:16]     shift_right_fill;
reg [31:0]      shift_right_1;
reg [31:0]      shift_right_2;
reg [31:0]      shift_right_4;
reg [31:0]      shift_right_8;

reg [31:0]      shift_left_1;
reg [31:0]      shift_left_2;
reg [31:0]      shift_left_4;
reg [31:0]      shift_left_8;

//-----------------------------------------------------------------
// ALU
//-----------------------------------------------------------------
always @ (func or input_a or input_b or carry_in)
begin
   case (func)
       //----------------------------------------------
       // Shift Left
       //----------------------------------------------   
       `ALU_SHIFTL :
       begin
            if (input_b[0] == 1'b1)
                shift_left_1 = {input_a[30:0],1'b0};
            else
                shift_left_1 = input_a;

            if (input_b[1] == 1'b1)
                shift_left_2 = {shift_left_1[29:0],2'b00};
            else
                shift_left_2 = shift_left_1;

            if (input_b[2] == 1'b1)
                shift_left_4 = {shift_left_2[27:0],4'b0000};
            else
                shift_left_4 = shift_left_2;

            if (input_b[3] == 1'b1)
                shift_left_8 = {shift_left_4[23:0],8'b00000000};
            else
                shift_left_8 = shift_left_4;

            if (input_b[4] == 1'b1)
                result = {shift_left_8[15:0],16'b0000000000000000};
            else
                result = shift_left_8;
                
            carry_out    = 1'b0;
            carry_update = 1'b0;
       end
       //----------------------------------------------
       // Shift Right
       //----------------------------------------------
       `ALU_SHIFTR, `ALU_SHIRTR_ARITH:
       begin
            // Arithmetic shift? Fill with 1's if MSB set
            if (input_a[31] == 1'b1 && func == `ALU_SHIRTR_ARITH)
                shift_right_fill = 16'b1111111111111111;
            else
                shift_right_fill = 16'b0000000000000000;

            if (input_b[0] == 1'b1)
                shift_right_1 = {shift_right_fill[31], input_a[31:1]};
            else
                shift_right_1 = input_a;

            if (input_b[1] == 1'b1)
                shift_right_2 = {shift_right_fill[31:30], shift_right_1[31:2]};
            else
                shift_right_2 = shift_right_1;

            if (input_b[2] == 1'b1)
                shift_right_4 = {shift_right_fill[31:28], shift_right_2[31:4]};
            else
                shift_right_4 = shift_right_2;

            if (input_b[3] == 1'b1)
                shift_right_8 = {shift_right_fill[31:24], shift_right_4[31:8]};
            else
                shift_right_8 = shift_right_4;

            if (input_b[4] == 1'b1)
                result = {shift_right_fill[31:16], shift_right_8[31:16]};
            else
                result = shift_right_8;
                
            carry_out    = 1'b0;
            carry_update = 1'b0;
       end
       //----------------------------------------------
       // Arithmetic
       //----------------------------------------------
       `ALU_ADD : 
       begin
            {carry_out, result} = (input_a + input_b);
            carry_update    = 1'b1;
       end
       `ALU_ADDC : 
       begin
            {carry_out, result} = (input_a + input_b) + {31'h00000000, carry_in};
            carry_update    = 1'b1;
       end
       `ALU_SUB : 
       begin
            result          = (input_a - input_b);
            carry_out       = 1'b0;
            carry_update    = 1'b0;
       end
       //----------------------------------------------
       // Logical
       //----------------------------------------------       
       `ALU_AND : 
       begin
            result          = (input_a & input_b);
            carry_out       = 1'b0;
            carry_update    = 1'b0;
       end
       `ALU_OR  : 
       begin
            result          = (input_a | input_b);
            carry_out       = 1'b0;
            carry_update    = 1'b0;
       end
       `ALU_XOR : 
       begin
            result          = (input_a ^ input_b);
            carry_out       = 1'b0;
            carry_update    = 1'b0;
       end
       default  : 
       begin
            result          = 32'h00000000;
            carry_out       = 1'b0;
            carry_update    = 1'b0;
       end
   endcase
end

endmodule
