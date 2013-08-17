`timescale 1ns / 1ps

/*
-------------------------------------------------------------------------
--Title         : AD1 Reference Component
--
--   Inputs         : 5
--   Outputs        : 5
--
--   Description: This is the AD1 Reference Component entity. The input
--                ports are a 50 MHz clock and an asynchronous reset 
--                button along with the data from the ADC7476 that 
--                is serially shifted in on each clock cycle(SDATA1 and
--                SDATA2). The outputs are the SCLK signal which clocks
--                the PMOD-AD1 board at 12.5 MHz and a chip select 
--                signal (nCS) that enables the ADC7476 chips on the
--                PMOD-AD1 board as well as two 12-bit output 
--                vectors labeled DATA1 and DATA2 which can be used by 
--                any external components. The START is used to tell
--                the component when to start a conversion. After a
--                conversion is done the component activates the DONE
--                signal.
--
--------------------------------------------------------------------------
*/

module spi_receive(
//general usage
clk,
rst,
//Pmod interface signals
sdata1,
sdata2,
sclk,
ncs,
//user interface signals
data1,
data2,
start,
done
    );

/*
--------------------------------------------------------------------------------
-- Title            : Local signal assignments
--
-- Description      : The following signals will be used to drive the  
--                    processes of this VHDL file.
--
--   current_state : This signal will be the pointer that will point at the
--                   current state of the Finite State Machine of the 
--                   controller.
--   next_state    : This signal will be the pointer that will point at the
--                   current state of the Finite State Machine of the 
--                   controller.
--   temp1         : This is a 16-bit vector that will store the 16-bits of data 
--                   that are serially shifted-in form the  first ADC7476 chip
--                   inside the PMOD-AD1 board.
--   temp2         : This is a 16-bit vector that will store the 16-bits of data 
--                   that are serially shifted-in form the second ADC7476 chip 
--                   inside the PMOD-AD1 board.
--   clk_div       : This will be the divided 12.5 MHz clock signal that will
--                   clock the PMOD-AD1 board
--   clk_counter   : This counter will be used to create a divided clock signal.
--
--   shiftCounter  : This counter will be used to count the shifted data from  
--                   the ADC7476 chip inside the PMOD-AD1 board.
--   enShiftCounter: This signal will be used to enable the counter for the  
--                   shifted data from the ADC7476 chip inside the PMOD-AD1.
--   enParalelLoad : This signal will be used to enable the load the shifted  
--                   data in a register.
--------------------------------------------------------------------------------
*/
parameter Idle=2'b00;
parameter ShiftIn=2'b01;
parameter SyncData=2'b11;

input         clk,rst,sdata1,sdata2,start;
output [11:0] data1;
output [11:0] data2;
output        sclk,ncs,done;

reg [11:0] data1;
reg [11:0] data2;
reg        sclk,sclk_tmp,ncs,done;

reg [1:0]  current_state,next_state;
reg [15:0] temp1,temp2;
reg        clk_div,clk_div_tmp;
reg [2:0]  clk_counter,clk_counter_tmp;
reg [3:0]  shiftCounter;
reg        enShiftCounter;
reg        enParalelLoad;

/*
--------------------------------------------------------------------------------
-- Title          :     clock divider process
--
-- Description    : This is the process that will divide the 50 MHz clock 
--                  down to a clock speed of 12.5 MHz to drive the ADC7476 chip. 
-------------------------------------------------------------------------------- 
*/
always @ (posedge clk or posedge rst)
begin
if (rst==1)
	clk_counter<=3'b000;
else
	clk_counter<=clk_counter_tmp;
end

always @ (clk_counter or clk_div or sclk)
begin
if (clk_counter==3'b001)
	begin
	clk_counter_tmp=3'b000;
	clk_div_tmp=~clk_div;
	sclk_tmp=~sclk;
	end
else
	begin
	clk_counter_tmp=clk_counter+1;
	clk_div_tmp=clk_div;
	sclk_tmp=sclk;
	end
end

always @ (posedge clk or posedge rst)
begin
if (rst)
	begin
	clk_div=0;
	sclk   =0;
	end
else
	begin
	clk_div=clk_div_tmp;
	sclk   =sclk_tmp;
	end
end

/*
-----------------------------------------------------------------------------------
--
-- Title      : counter
--
-- Description: This is the process were the converted data will be colected and
--              output.When the enShiftCounter is activated, the 16-bits of data  
--              from the ADC7476 chips will be shifted inside the temporary 
--              registers. A 4-bit counter is used to keep shifting the data 
--              inside temp1 and temp2 for 16 clock cycles. When the enParalelLoad
--              signal is generated inside the SyncData state, the converted data 
--              in the temporary shift registers will be placed on the outputs 
--              DATA1 and DATA2. 
--    
-----------------------------------------------------------------------------------    
*/

always @ (posedge clk_div)
begin
if(enShiftCounter==1)
	begin
	temp1<={temp1[14:0],sdata1};
	temp2<={temp2[14:0],sdata2};
	shiftCounter<=shiftCounter+1;
	data1<=data1;
	data2<=data2;

	end
else if (enParalelLoad==1)
	begin
	temp1<=temp1;
	temp2<=temp2;
	shiftCounter<=4'b0000;
	data1<=temp1[12:1];
	data2<=temp2[12:1];
	end
else
	begin
	temp1<=temp1;
	temp2<=temp2;
	shiftCounter<=4'b0000;
	data1<=data1;
	data2<=data2;
	end
end

/*
---------------------------------------------------------------------------------
--
-- Title      : Finite State Machine
--
-- Description: This 3 processes represent the FSM that contains three states.
--              The first state is the Idle state in which a temporary registers
--              are assigned the updated value of the input "DATA1" and "DATA2".
--              The next state is the ShiftIn state where the 16-bits of data
--              from each of the ADCS7476 chips are left shifted in the temp1
--              and temp2 shift registers. The third state, SyncData drives the
--              output signal nCS high for 1 clock period maintainig nCS high  
--              also in the Idle state telling the ADCS7476 to mark the end of
--              the conversion.
-- Notes:         The data will change on the lower edge of the clock signal. There 
--                     is also an asynchronous reset that will reset all signals to  
--                     their original state.
--
-----------------------------------------------------------------------------------        
        
-----------------------------------------------------------------------------------
--
-- Title      : SYNC_PROC
--
-- Description: This is the process were the states are changed synchronously. At 
--              reset the current state becomes Idle state.
--    
-----------------------------------------------------------------------------------   
*/

always @(posedge clk_div)
begin
if(rst)
	current_state<=Idle;
else
	current_state<=next_state;
end

/*
-----------------------------------------------------------------------------------
--
-- Title      : OUTPUT_DECODE
--
-- Description: This is the process were the output signals are generated
--              unsynchronously based on the state only (Moore State Machine).
--    
-----------------------------------------------------------------------------------      
*/

always @ (current_state)
begin
if(current_state==Idle)
	begin
	enShiftCounter=0;
	done=1;
	ncs=1;
	enParalelLoad=0;
	end
else if (current_state==ShiftIn)
	begin
	enShiftCounter=1;
	done=0;
	ncs=0;
	enParalelLoad=0;
	end
else
	begin
	enShiftCounter=0;
	done=0;
	ncs=1;
	enParalelLoad=1;
	end
end

/*
----------------------------------------------------------------------------------
--
-- Title      : NEXT_STATE_DECODE
--
-- Description: This is the process were the next state logic is generated 
--              depending on the current state and the input signals.
--    
-----------------------------------------------------------------------------------    
*/

always @ (current_state or start or shiftCounter)
begin
case (current_state)
	Idle:    begin if (start==1)              next_state=ShiftIn;  else next_state=current_state; end
	ShiftIn: begin if (shiftCounter==4'b1111) next_state=SyncData; else next_state=current_state; end
	SyncData:begin if (start==0)              next_state=Idle;     else next_state=current_state; end
	default: begin                                                       next_state=Idle; end
endcase
end


endmodule
