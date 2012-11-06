`timescale 1ns / 1ps
`include "async_transmitter_50MHz-parityodd.v"
`include "spi_recieve.v"
`include "spitouart_camp2.v"
module FPGA_Camp_v2(clk,rst,TxD,sdata1,sdata2,sclk,ncs
,data1,Pulse1_in,Pulse2_in
    );
input clk,rst;
input sdata1,sdata2;
input Pulse1_in,Pulse2_in;
output TxD;
output sclk;
output ncs;

output [11:0] data1;

wire [11:0] data1,data2;
wire done;
wire TxD_start;
wire [7:0] TxD_data;
wire start;
wire TxD_busy;

spitouart_camp2 Uspitouart(
.clk(clk),
.rst(rst),
.data1(data1),
.data2(data2),
.done(done),
.TxD_start(TxD_start),
.TxD_data(TxD_data),
.start(start),
.TxD_busy(TxD_busy),
.Pulse1_in(Pulse1_in),
.Pulse2_in(Pulse2_in)
    );
	 
async_transmitter Uasync_transmitter(
.clk(clk), 
.TxD_start(TxD_start), 
.TxD_data(TxD_data), 
.TxD(TxD), 
.TxD_busy(TxD_busy)
);

/*
async_receiver Uasync_receiver(
.clk(clk), 
.RxD(RxD), 
.RxD_data_ready(), 
.RxD_data(), 
.RxD_endofpacket(), 
.RxD_idle()
);
*/

spi_recieve Uspi_recieve(
//general usage
.clk(clk),
.rst(rst),
//Pmod interface signals
.sdata1(sdata1),
.sdata2(sdata2),
.sclk(sclk),
.ncs(ncs),
//user interface signals
.data1(data1),
.data2(data2),
.start(start),
.done(done)
    );
endmodule
