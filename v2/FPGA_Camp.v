`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:55:50 08/07/2011 
// Design Name: 
// Module Name:    FPGA_Camp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FPGA_Camp(clk,rst,TxD,sdata1,RxD,sclk,ncs
,data1
    );
input clk,rst;
input sdata1;
output TxD;
input RxD;
output sclk;
output ncs;

output [11:0] data1;

wire [11:0] data1;
wire done;
wire TxD_start;
wire [7:0] TxD_data;
wire RxD_data_ready;
wire start;
wire TxD_busy;

spitouart_camp2 Uspitouart(
.clk(clk),
.rst(rst),
.data1(data1),
.done(done),
.TxD_start(TxD_start),
.TxD_data(TxD_data),
.RxD_data_ready(RxD_data_ready),
.start(start),
.TxD_busy(TxD_busy)
    );
	 
async_transmitter Uasync_transmitter(
.clk(clk), 
.TxD_start(TxD_start), 
.TxD_data(TxD_data), 
.TxD(TxD), 
.TxD_busy(TxD_busy)
);

async_receiver Uasync_receiver(
.clk(clk), 
.RxD(RxD), 
.RxD_data_ready(RxD_data_ready), 
.RxD_data(), 
.RxD_endofpacket(), 
.RxD_idle()
);

spi_recieve Uspi_recieve(
//general usage
.clk(clk),
.rst(rst),
//Pmod interface signals
.sdata1(sdata1),
.sdata2(),
.sclk(sclk),
.ncs(ncs),
//user interface signals
.data1(data1),
.data2(),
.start(start),
.done(done)
    );
endmodule
