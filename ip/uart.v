//UART module
//Developed by F.M.Zhu

`include "uart_global.v"

module uart (clk, rst_n
	, tx_data, tx_send, tx, tx_busy
	, rx, rx_data, rx_ok
`ifdef PARITY_ODD
	, rx_error
`elsif PARITY_EVEN
	, rx_error
`endif
	);

input		clk, rst_n;

input	[7:0]	tx_data;
input		tx_send;
output		tx;
output		tx_busy;

input		rx;
output	[7:0]	rx_data;
output		rx_ok;
`ifdef PARITY_ODD
output		rx_error;
`elsif PARITY_EVEN
output		rx_error;
`endif

//registers and wires
reg	[14:0]	tx_cnt, rx_cnt;
reg		tx_cnt_en, rx_cnt_en;
reg	[7:0]	tx_data_reg;
reg	[3:0]	bits_sent;
reg		tx_data_bit;
reg		start_stop_parity;
reg		tx;
wire		tx_en, rx_en;


//user configure parameters
parameter CLK_FREQ		=	32'd50000000;
parameter BAUD			=	115200;
parameter NUM_DATA_BITS		=	8;
parameter NUM_STOP_BITS		=	1;

//generated parameter
`ifdef PARITY_ODD
parameter NUM_PARITY_BIT	=	1;
`elsif PARITY_EVEN
parameter NUM_PARITY_BIT	=	1;
`else
parameter NUM_PARITY_BIT	=	0;
`endif

parameter CNT_PER_BAUD		=	(CLK_FREQ+(BAUD/2))/BAUD;
parameter DELAY_READ		=	CNT_PER_BAUD*3/2;	
parameter BITS_PER_PACK		=	1 + NUM_DATA_BITS + NUM_PARITY_BIT + NUM_STOP_BITS;	//1 is start bit 
parameter TX_START_BIT		=	0;
parameter TX_STOP_BIT		=	1 + NUM_DATA_BITS + NUM_PARITY_BIT;
parameter TX_PARITY_BIT		=	1 + NUM_DATA_BITS;
 
//////////////////////////////////////////////////////////
//UART TRANSMITTER LOGIC

//tx input flopping
always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n)
		tx_data_reg <=0;
	else if (tx_send & ~tx_cnt_en)
		tx_data_reg <= tx_data;
end

//tx baud counter
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt <= 0;
	else if (tx_cnt_en && (tx_cnt < CNT_PER_BAUD))
		tx_cnt <= tx_cnt + 1; 
	else
		tx_cnt <= 0;
end

assign tx_en = (tx_cnt == CNT_PER_BAUD);


//tx buad counter control
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n)
		tx_cnt_en <= 1'b0;
	else if ((bits_sent == BITS_PER_PACK-1) & tx_en )
		tx_cnt_en <= 1'b0;
	else if (tx_send)
		tx_cnt_en <= 1'b1;
end

//tx determine sending bit
always @ (posedge clk) begin
	case (bits_sent)
		TX_START_BIT: 	begin tx_data_bit<=0; start_stop_parity<=0; end
		TX_STOP_BIT: 	begin tx_data_bit<=0; start_stop_parity<=1; end

`ifdef PARITY_ODD
		TX_PARITY_BIT:	begin tx_data_bit<=0; start_stop_parity<=~^tx_data_reg; end
`elsif PARITY_EVEN
		TX_PARITY_BIT:	begin tx_data_bit<=0; start_stop_parity<=^tx_data_reg; end
`endif

		default: 	begin tx_data_bit<=1; end
	endcase
end

//tx output select
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		tx<=1;
		bits_sent <= 0;
	end
	else if ((bits_sent == BITS_PER_PACK-1) & tx_en) begin
		tx<=1;
		bits_sent <= 0;
	end
	else if (tx_en) begin
		tx <= tx_data_bit ? (tx_data_reg[bits_sent-1]) : start_stop_parity;
		bits_sent <= bits_sent + 1;
	end
end

assign tx_busy = tx_cnt_en;
//////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////
//UART RECEIVER LOGIC

reg	[3:0]	rx_sr;
//rx start bit detect
always @ (posedge clk) begin
	rx_sr <= {rx_sr[2:0],rx};
end

reg	[3:0]	bits_received;
//rx baud counter
always @ (posedge clk or negedge rst_n) begin 
	if (~rst_n) 
		rx_cnt <= 0;
	else if (rx_cnt_en && (rx_cnt < DELAY_READ) && bits_received ==1)
		rx_cnt <= rx_cnt + 1; 
	else if (rx_cnt_en && (rx_cnt < CNT_PER_BAUD))
		rx_cnt <= rx_cnt + 1; 
	else
		rx_cnt <= 0;
end

assign rx_en = (bits_received == 1) ? (rx_cnt == DELAY_READ) : (rx_cnt == CNT_PER_BAUD) ;

//rx buad counter control
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx_cnt_en <= 1'b0;
		bits_received <= 0;
	end
	else if ((bits_received == BITS_PER_PACK-1) && rx_en==1) begin
		rx_cnt_en <= 1'b0;
		bits_received <= 0;
	end
	else if ((rx_sr == 4'b1100 && (bits_received == 0)) || rx_en==1) begin
		rx_cnt_en <= 1'b1;
		bits_received <= bits_received + 1;
	end
end

reg	[7:0]	rx_data_reg;
reg		rx_error_reg;
//rx decode input 
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx_data_reg <= 0;
		rx_error_reg <= 0;
	end
	else if (bits_received > 0 && bits_received < 1+NUM_DATA_BITS && rx_en) begin
		rx_data_reg[bits_received-1] <= rx; 
		rx_error_reg <= 0;
	end
`ifdef PARITY_ODD	
	else if (bits_received == 1+NUM_DATA_BITS && rx != ~^rx_data_reg && rx_en)
		rx_error_reg <= 1;
`elsif PARITY_EVEN
	else if (bits_received == 1+NUM_DATA_BITS && rx != ^rx_data_reg && rx_en)
		rx_error_reg <= 1;
`endif
end

reg	[7:0]	rx_data;
reg		rx_ok;
reg		rx_error;
//rx data output
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx_data <= 0;
		rx_error <= 0;
		rx_ok <= 0;
	end
	else if ((bits_received == BITS_PER_PACK-1) & rx_en) begin
		rx_data <= rx_data_reg;
		rx_error <= rx_error_reg;
		rx_ok <= 1;
	end
	else begin
		rx_ok <= 0;
		rx_error <= 0;
	end

end
//////////////////////////////////////////////////////////

endmodule
