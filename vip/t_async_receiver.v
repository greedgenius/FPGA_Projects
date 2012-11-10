`timescale 1ns / 1ps

module t_async_receiver;

	parameter CLK_CYCLE=10;
	parameter UART_TX_WAIT = 500000000/19200;

	// Inputs
	reg clk, RxD, rst_n;

	// Outputs
	wire RxD_data_ready;  // onc clock pulse when RxD_data is valid
	wire [7:0] RxD_data;

	wire RxD_endofpacket;  // one clock pulse, when no more data is received (RxD_idle is going high)
	wire RxD_idle;  // no data is being received
        
	// Integers
	integer		i;
	
	
	// Instantiate the Unit Under Test (UUT)
	async_receiver async_receiver(clk, RxD, RxD_data_ready, RxD_data, RxD_endofpacket, RxD_idle, rst_n);


	task reset; begin
		#10; rst_n=0;
		#10; rst_n=1;
	end
	endtask
    
	task sendRx; 
		reg [7:0] data;
		begin
		data = $random;
		RxD = 1'b0;
		#UART_TX_WAIT;
		for ( i = 0; i < 8 ; i = i + 1 ) begin
			RxD = data[i];
			#UART_TX_WAIT;
		end        
		//uart_srx = 1'b0;
		//#UART_TX_WAIT;
		RxD = 1'b1;	    
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
		#UART_TX_WAIT;
	end
	endtask

	initial begin
		repeat(20) sendRx;
		$finish;
	end

	always #(CLK_CYCLE/2) clk=~clk;
	initial begin
		clk=0;
		reset;
	end

	initial begin
		$dumpfile("async_receiver.vcd");
		$dumpvars(0, async_receiver);
	end
endmodule
