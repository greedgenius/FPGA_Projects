`include "ram.v"
`include "depp_mem.v"

//This module is a memory connected with depp interface
module top (clk
	, a_astb, a_dstb, a_write, a_db, a_wait
	);

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
defparam ram.ADDR_WIDTH = ADDR_WIDTH;
defparam ram.DATA_WIDTH = DATA_WIDTH;

input		clk;

//DEPP ports (a stands for async)
input 		a_astb, a_dstb, a_write;
inout	[7:0]	a_db;
output		a_wait;

wire				we;
wire	[ADDR_WIDTH-1:0]	addr;
wire	[DATA_WIDTH-1:0]	din;
wire	[DATA_WIDTH-1:0]	dout;

depp_mem depp_mem (.clk(clk)
	, .a_astb(a_astb), .a_dstb(a_dstb), .a_write(a_write), .a_db(a_db), .a_wait(a_wait)
	, .we(we), .addr(addr), .din(din), .dout(dout)
	);

ram ram (.clk(clk)
	, .we(we), .waddr(addr), .raddr(addr), .din(din), .dout(dout)
	);


endmodule

