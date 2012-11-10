module uart (clk, rst_n, tx_data, tx_send, tx, tx_busy, rx, rx_data, rx_ok);

input		clk, rst_n;

input	[7:0]	tx_data;
input		tx_send;
output		tx;
output		tx_busy;

input		rx;
output	[7:0]	rx_data;
output		rx_ok;

//parameters
parameter CLK_FREQ	=	32'd50000000;
parameter BAUD		=	115200;
parameter CNT_PER_BAUD	=	(CLK_FREQ+(BAUD/2))/BAUD;

parameter CNT_SIZE	=	32;
parameter BITS_PER_PACK	=	1+8+1; //1 start 8 data 1 stop
parameter TX_START_BIT	=	4'd0;
parameter TX_STOP_BIT	=	4'd9;
 

//tx counter
reg	[14:0]	tx_cnt;
reg		tx_cnt_en;
wire		tx_en;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt <= 0;
	else if (tx_cnt_en && (tx_cnt < CNT_PER_BAUD))
		tx_cnt <= tx_cnt + 1; 
	else
		tx_cnt <= 0;
end

assign tx_en = (tx_cnt == CNT_PER_BAUD);
//


//rx counter
reg	[14:0]	rx_cnt;
reg		rx_cnt_en;
wire		rx_en;

always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n) 
		rx_cnt <= 0;
	else if (rx_cnt_en && (rx_cnt < CNT_PER_BAUD))
		rx_cnt <= rx_cnt + 1; 
	else
		rx_cnt <= 0;
end

assign rx_en = ~(tx_cnt < CLK_FREQ);
//


//tx input flopping
reg	[7:0]	tx_data_reg;
always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n)
		tx_data_reg <=0;
	else if (tx_send & ~tx_cnt_en)
		tx_data_reg <= tx_data;
end
//


reg	[3:0]	bits_sent;
//counter control
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt_en<=1'b0;
	else if ((bits_sent == BITS_PER_PACK-1) & tx_en )
		tx_cnt_en<=1'b0;
	else if (tx_send)
		tx_cnt_en<=1'b1;
end
//


reg tx_data_bit;
reg start_stop_parity;
//determine sending bit
always @ (bits_sent) begin
	case (bits_sent)
		TX_START_BIT: 	begin tx_data_bit=0; start_stop_parity=0; end
		TX_STOP_BIT: 	begin tx_data_bit=0; start_stop_parity=1; end
		default: 	begin tx_data_bit=1; end
	endcase
end



reg tx;
//tx output select
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n |((bits_sent==BITS_PER_PACK-1) & tx_en) ) begin
		tx<=1;
		bits_sent <= 0;
	end
	else if (tx_en) begin
		tx <= tx_data_bit ? (tx_data_reg[bits_sent-3'd1]) : start_stop_parity;
		bits_sent <= bits_sent + 1;
	end
end

//wire [2:0] data_sel;
//assign data_sel = bits_sent[2:0]-3'd1;
assign tx_busy = tx_cnt_en;

endmodule
