`timescale 1ns / 1ps

module t_uart;

	parameter CLK_CYCLE=20;
	parameter UART_TX_WAIT = 1000000000/115200;

	// Inputs
        reg		clk,tx_send, rst_n;
	reg	[7:0]	tx_data;
	reg 		rx;
	// Outputs
        wire		tx, tx_busy;
        wire	[7:0]	rx_data;
	wire		rx_ok;
	// Integers
	integer		i;
	
	
	// Instantiate the Unit Under Test (UUT)
	uart uart(clk, rst_n, tx_data, tx_send, tx, tx_busy, rx, rx_data, rx_ok);
	
	task sendTx; begin
        	tx_data=$random;
		@ (posedge clk); tx_send = 1;
		@ (posedge clk); tx_send = 0;
		uart_decoder(tx_data);
	end
	endtask
	
	
	task sendRx; 
		reg [7:0] send_rx_data;
		begin
		send_rx_data = $random;
		rx = 1'b0;
		#UART_TX_WAIT;
		for ( i = 0; i < 8 ; i = i + 1 ) begin
			rx = send_rx_data[i];
			#UART_TX_WAIT;
		end        
		rx = 1'b1;	    
    		rx_output_decode(send_rx_data);
		
	end
	endtask


	task reset; begin
		#10; rst_n=0;
		#10; rst_n=1;
	end
	endtask
    
    

	task uart_decoder;
	input	[7:0]	expected_tx_data;
	integer i;
	reg [7:0] tx_byte;
	//reg tx_parity;
	begin
	        // Wait for start bit
	        while (tx == 1'b1)
			@(tx);
		#(UART_TX_WAIT + (UART_TX_WAIT/2));
	
	        for ( i = 0; i < 8 ; i = i + 1 ) begin
	        	tx_byte[i] = tx;
	        	#UART_TX_WAIT;
	        end
		
		//tx_parity=tx;
		//#UART_TX_WAIT;
	
	        //Check for stop bit
	        if (tx == 1'b0) begin
	        	//$display("* WARNING: user stop bit not received when expected at time %d__", $time);
	        	// Wait for return to idle
	        	while (tx == 1'b0)
	        	@(tx);
	        	//$display("* USER UART returned to idle at time %d",$time);
	        end
	        // display the char
	        $write("TX:\texpected byte = %h\treceived byte = %h\n", expected_tx_data, tx_byte);
	end
	endtask
 	

	
	task rx_output_decode;
	input	[7:0]	expected_rx_data;
	integer i;
	reg [7:0] rx_byte;
	//reg tx_parity;
	begin
	        // Wait for start bit
	        @ (posedge rx_ok);
		@(negedge clk);
	        $write("RX:\texpected byte = %h\treceived byte = %h\n", expected_rx_data, rx_data);
	end	
	endtask


	initial begin
		$dumpfile("uart.vcd");
		$dumpvars(0, uart);
	end


	//initial begin
	//	sendTx;
        //#10; $finish;
	//end
	initial begin
		@(posedge rst_n);
		@(posedge clk);
		repeat(20) sendTx;
		$finish;
	end
	
	initial begin
		@(posedge rst_n);
		@(posedge clk);
		repeat(20) sendRx;
		$finish;
	end

	always #(CLK_CYCLE/2) clk=~clk;
	initial begin
		clk=0;
		rx=1;
		reset;
	end
endmodule

