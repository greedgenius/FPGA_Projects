`timescale 1ns / 1ps
module spitouart_camp2(
clk,
rst,
data1,
data2,
done,
TxD_start,
TxD_data,
start,
TxD_busy,
Pulse1_in,
Pulse2_in
    );
	
input clk,rst,done,TxD_busy;
input [11:0] data1,data2;
input Pulse1_in,Pulse2_in;
output TxD_start,start;
output [7:0] TxD_data;

parameter CAMPDATALENGTH = 8192;
parameter SPIFSMSIZE = 2;
parameter SPIIDLE      = 2'b00; 
parameter SPISTART     = 2'b01;
parameter SPISTARTWAIT = 2'b10;
parameter GETSPI       = 2'b11;

parameter CAMPBELLFSMSIZE = 3;
parameter CAMPIDLE =    3'b000;
parameter GETDATA =     3'b001;  
parameter SUBANDMULT =  3'b011;  
parameter ADDTORESULT = 3'b010;
parameter SENDUART =    3'b110;    

parameter UARTFSMSIZE = 5;
parameter UARTIDLE  = 5'd0;
parameter UARTAIM   = 5'd1;
parameter SENDUART1 = 5'd2;
parameter WAITUART1 = 5'd3;
parameter SENDUART2 = 5'd4;
parameter WAITUART2 = 5'd5;
parameter SENDUART3 = 5'd6;
parameter WAITUART3 = 5'd7;
parameter SENDUART4 = 5'd8;
parameter WAITUART4 = 5'd9;
parameter SENDUART5 = 5'd10;
parameter WAITUART5 = 5'd11;
parameter SENDUART6 = 5'd12;
parameter WAITUART6 = 5'd13;
parameter SENDUART7 = 5'd14;
parameter WAITUART7 = 5'd15;
parameter SENDUART8 = 5'd16;
parameter WAITUART8 = 5'd17;
parameter SENDUART9 = 5'd18;
parameter WAITUART9 = 5'd19;
parameter SENDUART10 = 5'd20;
parameter WAITUART10 = 5'd21;
parameter SENDUART11 = 5'd22;
parameter WAITUART11 = 5'd23;

parameter UCOUNTDIGITS = 18;
parameter UCOUNTCYCLE= 18'd40000;//18'd166665; //300Hz  a little bit smaller than 300Hz to allow some margion on SCOUNTCYCLE, can't exceed 400Hz or UART transmitter will fail (4800 baud)

parameter SCOUNTDIGITS = 7;  //to count 103
parameter SCOUNTCYCLE= 7'd100; // because (50 000 000 / 103) / (2^13) = 59.2574333 and 103-1=102, 1 cycle SPISTART, -2 based on calibration with function generator

parameter PCOUNTDIGITS = 16; //same as counter/transmitter
		                                                                                                            
reg [SPIFSMSIZE-1:0]       spi_current_state,  spi_next_state;
reg [CAMPBELLFSMSIZE-1:0]  camp_current_state, camp_next_state;
reg [UARTFSMSIZE-1:0]      uart_current_state, uart_next_state;
reg dataReady;
reg [1:0] dataReady_sr;
reg [11:0] dataCount;
reg [11:0] data1_reg,data2_reg;
reg signed [12:0] s_data1_reg,s_data2_reg;
reg signed [12:0] mean;
reg signed [12:0] submean1,submean2;
reg signed [25:0] meanSqrData1,meanSqrData2;
wire signed [25:0] meanSqrData1_comb,meanSqrData2_comb;

reg [36:0] addMeanSqrData1,addMeanSqrData1_lock,addMeanSqrData2,addMeanSqrData2_lock; //24bit * 2^13 data, 24+13=37
reg uartok;
reg TxD_start,start;
reg [7:0] TxD_data;
reg [1:0] TxD_busy_sr;

reg [UCOUNTDIGITS-1:0] ucount,ucount_next;
reg ucount_start;

reg [SCOUNTDIGITS-1:0] scount,scount_next;
reg scount_start;

//reg [19:0] test_count,test_count_next;

reg [23:0] powerdata1,powerdata2,powerdata1_lock,powerdata2_lock;
reg [15:0] powerdata3,powerdata3_lock,powerdata4,powerdata4_lock;
reg [7:0]  systemstate;

reg [PCOUNTDIGITS-1:0] p1count,p1count_next,p2count,p2count_next;
reg pcount_rst;

wire Cin_buf1,Cin_buf2,Cin_buf3;
wire Pulse1_in_buf ,Pulse2_in_buf,pcount_rst_buf ,uartok_buf;

always @ (posedge clk)
begin
dataReady_sr = {dataReady_sr[0], dataReady};
TxD_busy_sr={TxD_busy_sr[0],TxD_busy};
end

//-------------------------------------------------------------SPI_Trigger
always @ (posedge clk or posedge rst)
begin
if(rst)
	spi_current_state<=SPIIDLE;
else
	spi_current_state<=spi_next_state;
end

always @ (spi_current_state or scount_next)
begin
case (spi_current_state)
SPIIDLE       : spi_next_state=SPISTART;
SPISTART      : spi_next_state=SPISTARTWAIT;
SPISTARTWAIT  : if (scount_next == 7'd3) spi_next_state=GETSPI; else spi_next_state=SPISTARTWAIT;
GETSPI        : if (scount_next == SCOUNTCYCLE) spi_next_state=SPISTART; else spi_next_state=GETSPI;
default       : spi_next_state = SPIIDLE;
endcase
end

always @ ( posedge clk)
begin
case (spi_current_state)
SPIIDLE        : begin start <= 0  ; dataReady<= 0; scount_start <= 0; end
SPISTART       : begin start <= 1  ; dataReady<= 0; data1_reg <= data1 ;data2_reg <= data2 ; scount_start <= 0; end
SPISTARTWAIT   : begin start <= 1  ; dataReady<= 1; scount_start <= 1; end
GETSPI         : begin start <= 0  ; dataReady<= 1; scount_start <= 1; end
default        : begin start <= 0  ;  scount_start <= 0; end
endcase
end
//-------------------------------------------------------------Counter for SPI_Trigger
always @ (posedge clk)
begin
scount<=scount_next; 
end

always @ (scount or scount_start)
begin
if (scount_start==0)
	scount_next=0;
else
	scount_next=scount+1;
end

//-------------------------------------------------------------Camp2
always @ (posedge clk or posedge rst)
begin
if(rst)
	camp_current_state<=CAMPIDLE;
else
	camp_current_state<=camp_next_state;
end

always @ (data1_reg or s_data1_reg or data2_reg or s_data2_reg or mean)
begin
mean = 13'b0100000000000;
s_data1_reg = {1'b0,data1_reg}; s_data2_reg = {1'b0,data2_reg};
submean1 = s_data1_reg-mean;    submean2 = s_data2_reg-mean;
end

//mult13sign mult1(
//	.clk(clk),
//	.a(submean1), // Bus [12 : 0] 
//	.b(submean1), // Bus [12 : 0] 
//	.p(meanSqrData1_comb)); // Bus [25 : 0] 
	
//mult13sign mult2(
//	.clk(clk),
//	.a(submean2), // Bus [12 : 0] 
//	.b(submean2), // Bus [12 : 0] 
//	.p(meanSqrData2_comb)); // Bus [25 : 0] 

assign meanSqrData1_comb=submean1*submean1;
assign meanSqrData2_comb=submean2*submean2;


always @ (camp_current_state or dataReady_sr or dataCount)
begin
case (camp_current_state)
CAMPIDLE    : if (dataReady_sr==2'b10) camp_next_state=GETDATA; else camp_next_state=CAMPIDLE;
GETDATA     : camp_next_state =SUBANDMULT;
SUBANDMULT  : camp_next_state = ADDTORESULT;
ADDTORESULT : if (dataCount==13'd0) camp_next_state=SENDUART  ; else camp_next_state=CAMPIDLE;
SENDUART    : camp_next_state = CAMPIDLE;
default    : camp_next_state = CAMPIDLE;
endcase
end	
	
always @ (posedge clk)
begin
case (camp_current_state)
CAMPIDLE    : begin uartok    <= 0; end
GETDATA     : begin dataCount<= dataCount+1; end   //may be necessary to isolate this code to a new always block, and add rst value.
SUBANDMULT  : begin meanSqrData1 <= meanSqrData1_comb ;meanSqrData2 <= meanSqrData2_comb ;  end
ADDTORESULT : begin addMeanSqrData1 <= addMeanSqrData1 + {13'd0,meanSqrData1[23:0]} ;addMeanSqrData2 <= addMeanSqrData2 + {13'd0,meanSqrData2[23:0]} ; end
SENDUART    : begin uartok    <= 1;  powerdata1<= addMeanSqrData1[35:12];powerdata2<= addMeanSqrData2[35:12]; addMeanSqrData1<=37'd0; addMeanSqrData2<=37'd0; end  //addMeanSqrData's data choose should be tuned later
default     : begin uartok    <= 0;  end
endcase
end



//-------------------------------------------------------------UART_Trigger test codes
/*
always @ (posedge clk)
begin
	test_count<=test_count_next;
end

always @ (test_count)
if (test_count==20'd833334)
	begin
	test_count_next=0;
	uartok=1;
	end
else
	begin
	test_count_next=test_count+1;
	uartok=0;
	end
*/

//-------------------------------------------------------------UART_Trigger


always @ (posedge clk or posedge rst)
begin
if(rst)
	uart_current_state<=UARTIDLE;
else
	uart_current_state<=uart_next_state;
end

always @ (uart_current_state or uartok or TxD_busy_sr or ucount_next)
begin
case (uart_current_state)
UARTIDLE   : if (uartok==1)                    uart_next_state=UARTAIM; else uart_next_state=UARTIDLE;
UARTAIM    : uart_next_state=SENDUART1;
SENDUART1  : uart_next_state=WAITUART1;
WAITUART1  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART2;  else uart_next_state=WAITUART1;
SENDUART2  : uart_next_state=WAITUART2;
WAITUART2  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART3;  else uart_next_state=WAITUART2;
SENDUART3  : uart_next_state=WAITUART3;
WAITUART3  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART4;  else uart_next_state=WAITUART3;
SENDUART4  : uart_next_state=WAITUART4;
WAITUART4  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART5;  else uart_next_state=WAITUART4;
SENDUART5  : uart_next_state=WAITUART5;
WAITUART5  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART6;  else uart_next_state=WAITUART5;
SENDUART6  : uart_next_state=WAITUART6;                      
WAITUART6  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART7;  else uart_next_state=WAITUART6;
SENDUART7  : uart_next_state=WAITUART7;                      
WAITUART7  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART8;  else uart_next_state=WAITUART7;
SENDUART8  : uart_next_state=WAITUART8;                      
WAITUART8  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART9;  else uart_next_state=WAITUART8;
SENDUART9  : uart_next_state=WAITUART9;                      
WAITUART9  : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART10; else uart_next_state=WAITUART9;
SENDUART10 : uart_next_state=WAITUART10;                      
WAITUART10 : if (ucount_next == UCOUNTCYCLE) uart_next_state=SENDUART11; else uart_next_state=WAITUART10;
SENDUART11 : uart_next_state=WAITUART11;
WAITUART11 : if (ucount_next == UCOUNTCYCLE) uart_next_state=UARTIDLE;   else uart_next_state=WAITUART11;
default    : uart_next_state = UARTIDLE;
endcase
end


always @ ( posedge clk)
begin
case (uart_current_state) 
UARTAIM   : begin 
			TxD_start <= 0 ; 
			powerdata1_lock <= powerdata1; 
			powerdata2_lock <= powerdata2;
			powerdata3_lock <= powerdata3;
			powerdata4_lock <= powerdata4;
			pcount_rst<=1; 
			end
SENDUART1 : begin TxD_start <= 1 ; TxD_data  <= powerdata1_lock[23:16];ucount_start <= 0; pcount_rst<=0; end
WAITUART1 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART2 : begin TxD_start <= 1 ; TxD_data  <= powerdata1_lock[15:8]; ucount_start <= 0; pcount_rst<=0; end
WAITUART2 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART3 : begin TxD_start <= 1 ; TxD_data  <= powerdata1_lock[7:0] ; ucount_start <= 0; pcount_rst<=0; end
WAITUART3 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART4 : begin TxD_start <= 1 ; TxD_data  <= powerdata2_lock[23:16];ucount_start <= 0; pcount_rst<=0; end
WAITUART4 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART5 : begin TxD_start <= 1 ; TxD_data  <= powerdata2_lock[15:8]; ucount_start <= 0; pcount_rst<=0; end
WAITUART5 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART6 : begin TxD_start <= 1 ; TxD_data  <= powerdata2_lock[7:0] ; ucount_start <= 0; pcount_rst<=0; end
WAITUART6 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART7 : begin TxD_start <= 1 ; TxD_data  <= powerdata3_lock[15:8]; ucount_start <= 0; pcount_rst<=0; end
WAITUART7 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART8 : begin TxD_start <= 1 ; TxD_data  <= powerdata3_lock[7:0] ; ucount_start <= 0; pcount_rst<=0; end
WAITUART8 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART9 : begin TxD_start <= 1 ; TxD_data  <= powerdata4_lock[15:8]; ucount_start <= 0; pcount_rst<=0; end
WAITUART9 : begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART10: begin TxD_start <= 1 ; TxD_data  <= powerdata4_lock[7:0] ; ucount_start <= 0; pcount_rst<=0; end
WAITUART10: begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
SENDUART11: begin TxD_start <= 1 ; TxD_data  <= 8'b1111_1111;          ucount_start <= 0; pcount_rst<=0; end
WAITUART11: begin TxD_start <= 0 ;                                     ucount_start <= 1; pcount_rst<=0; end
default  :  begin TxD_start <= 0 ;                                     ucount_start <= 0; pcount_rst<=0; end
endcase
end

//-------------------------------------------------------------Counter for UART_Trigger
always @ (posedge clk)
begin
ucount<=ucount_next; 
end

always @ (ucount or ucount_start)
begin
if (ucount_start==0)
	ucount_next=0;
else
	ucount_next=ucount+1;
end


//-------------------------------------------------------------Pulse1_Counter


//IBUFG buf_1 ( .O(Cin_buf1 ),.I (Pulse1_in) );
//BUFG buf_2 ( .O (Pulse1_in_buf ), .I (Cin_buf1 ));//For best clock quality 
//BUFG buf_3 ( .O (uartok_buf ), .I (uartok));//For best clock quality 

always @ (posedge Pulse1_in_buf or posedge pcount_rst)
begin
	if (pcount_rst) p1count<=0;
	else p1count<=p1count_next;
end

always @ (p1count)
begin
	p1count_next=p1count+1;
end

always @ (posedge uartok_buf)
begin
	powerdata3<=p1count;
end

//-------------------------------------------------------------Pulse2_Counter
//IBUFG buf_4 ( .O(Cin_buf2 ),.I (Pulse2_in) );
//BUFG buf_5 ( .O (Pulse2_in_buf ), .I (Cin_buf2 ));//For best clock quality

always @ (posedge Pulse2_in_buf or posedge pcount_rst)
begin
	if (pcount_rst) p2count<=0;
	else p2count<=p2count_next;
end

always @ (p2count)
begin
	p2count_next=p2count+1;
end

always @ (posedge uartok_buf)
begin
	powerdata4<=p2count;
end

endmodule
