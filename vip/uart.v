//UART module
//Developed by F.M.Zhu
module uart (clk, rst_n, tx_data, tx_send, tx, tx_busy, rx, rx_data, rx_ok);

input		clk, rst_n;

input	[7:0]	tx_data;
input		tx_send;
output		tx;
output		tx_busy;

input		rx;
output	[7:0]	rx_data;
output		rx_ok;

//registers and wires
reg	[14:0]	tx_cnt, rx_cnt;
reg		tx_cnt_en, rx_cnt_en;
reg	[7:0]	tx_data_reg;
reg	[3:0]	bits_sent;
reg		tx_data_bit;
reg		start_stop_parity;
reg		tx;
wire		tx_en, rx_en;


//parameters
parameter CLK_FREQ	=	32'd50000000;
parameter BAUD		=	115200;
parameter CNT_PER_BAUD	=	(CLK_FREQ+(BAUD/2))/BAUD;

parameter BITS_PER_PACK	=	1+8+1; //1 start 8 data 1 stop
parameter TX_START_BIT	=	4'd0;
parameter TX_STOP_BIT	=	4'd9;
 

//tx counter
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt <= 0;
	else if (tx_cnt_en && (tx_cnt < CNT_PER_BAUD))
		tx_cnt <= tx_cnt + 1; 
	else
		tx_cnt <= 0;
end

assign tx_en = (tx_cnt == CNT_PER_BAUD);


//rx counter
always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n) 
		rx_cnt <= 0;
	else if (rx_cnt_en && (rx_cnt < CNT_PER_BAUD))
		rx_cnt <= rx_cnt + 1; 
	else
		rx_cnt <= 0;
end

assign rx_en =  (rx_cnt == CNT_PER_BAUD);

//tx input flopping
always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n)
		tx_data_reg <=0;
	else if (tx_send & ~tx_cnt_en)
		tx_data_reg <= tx_data;
end

//counter control
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt_en<=1'b0;
	else if ((bits_sent == BITS_PER_PACK-1) & tx_en )
		tx_cnt_en<=1'b0;
	else if (tx_send)
		tx_cnt_en<=1'b1;
end

//determine sending bit
always @ (posedge clk) begin
	case (bits_sent)
		TX_START_BIT: 	begin tx_data_bit=0; start_stop_parity=0; end
		TX_STOP_BIT: 	begin tx_data_bit=0; start_stop_parity=1; end
		default: 	begin tx_data_bit=1; end
	endcase
end

//tx output select
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		tx<=1;
		bits_sent <= 0;
	end
	else if ((bits_sent==BITS_PER_PACK-1) & tx_en) begin
		tx<=1;
		bits_sent <= 0;
	end
	else if (tx_en) begin
		tx <= tx_data_bit ? (tx_data_reg[bits_sent-3'd1]) : start_stop_parity;
		bits_sent <= bits_sent + 1;
	end
end

assign tx_busy = tx_cnt_en;

endmodule
