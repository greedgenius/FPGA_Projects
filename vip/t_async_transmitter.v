`timescale 1ns / 1ps

module t_async_transmitter;

	parameter CLK_CYCLE=10;
	parameter UART_TX_WAIT = 500000000/19200;

	// Inputs
        reg		clk,TxD_start, rst_n;
	reg	[7:0]	TxD_data;

	// Outputs
        wire		TxD, TxD_busy;
        
	// Integers
	integer		i;
	
	
	// Instantiate the Unit Under Test (UUT)
	async_transmitter async_transmitter(clk, TxD_start, TxD_data, TxD, TxD_busy, rst_n);
	
	task sendTx; begin
        	TxD_data=$random;
		@ (posedge clk); TxD_start = 1;
		@ (posedge clk); TxD_start = 0;

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
    
    
	always @ (posedge TxD_start)
		uart_decoder;
    

	task uart_decoder;
	integer i;
	reg [7:0] tx_byte;
	reg tx_parity;
	begin
	        // Wait for start bit
	        while (TxD == 1'b1)
			@(TxD);
			#(UART_TX_WAIT + (UART_TX_WAIT/2));
	
	        for ( i = 0; i < 8 ; i = i + 1 ) begin
	        	tx_byte[i] = TxD;
	        	#UART_TX_WAIT;
	        end
		
		tx_parity=TxD;
		#UART_TX_WAIT;
	
	        //Check for stop bit
	        if (TxD == 1'b0) begin
	        	//$display("* WARNING: user stop bit not received when expected at time %d__", $time);
	        	// Wait for return to idle
	        	while (TxD == 1'b0)
	        	@(TxD);
	        	//$display("* USER UART returned to idle at time %d",$time);
	        end
	        // display the char
	        $write("receive byte =%h\tparity=%d\texpected=%d", tx_byte,tx_parity,~^tx_byte);
		if (tx_parity!= ~^tx_byte) $write("\t parity error!!!!!!\n");
		else $write("\n");
	end
	endtask
    
	initial begin
		$dumpfile("async_transmitter.vcd");
		$dumpvars(0, async_transmitter);
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

