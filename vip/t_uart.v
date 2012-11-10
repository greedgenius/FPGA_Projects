`timescale 1ns / 1ps

module t_uart;

	parameter CLK_CYCLE=10;
	parameter UART_TX_WAIT = 500000000/115200;

	// Inputs
        reg		clk,tx_send, rst_n;
	reg	[7:0]	tx_data;

	// Outputs
        wire		tx, tx_busy;
        
	// Integers
	integer		i;
	
	
	// Instantiate the Unit Under Test (UUT)
	uart uart(clk, rst_n, tx_data, tx_send, tx, tx_busy, rx, rx_data, rx_ok);
	
	task sendTx; begin
        	tx_data=$random;
		@ (posedge clk); tx_send = 1;
		@ (posedge clk); tx_send = 0;

		for (i=0;i<50000000/1500;i=i+1)
		begin
			@ (posedge clk); 
		end
	end
	endtask

	task reset; begin
		#10; rst_n=0;
		#10; rst_n=1;
	end
	endtask
    
    
	always @ (posedge tx_send)
		uart_decoder;
    

	task uart_decoder;
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
	        $write("receive byte =%h", tx_byte);
	        //$write("receive byte =%h\tparity=%d\texpected=%d", tx_byte,tx_parity,~^tx_byte);
		//if (tx_parity!= ~^tx_byte) $write("\t parity error!!!!!!\n");
		//else $write("\n");
		$write("\n");
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
		repeat(20) sendTx;
		$finish;
	end


	always #(CLK_CYCLE/2) clk=~clk;
	initial begin
		clk=0;
		reset;
	end
endmodule

