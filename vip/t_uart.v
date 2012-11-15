`timescale 1ns / 1ps

`include "uart_global.v"

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
wire		rx_error;


//Unit Under Test 
uart uart (clk, rst_n
	, tx_data, tx_send, tx, tx_busy
	, rx, rx_data, rx_ok
`ifdef PARITY_ODD
	, rx_error
`elsif PARITY_EVEN
	, rx_error
`endif
	);


//Main Testbench
always #(CLK_CYCLE/2) clk=~clk;

initial begin
	clk=0;
	rx=1;
	reset;
end

initial begin
	@(posedge rst_n);
	@(posedge clk);
	repeat(20) test_tx($random);
	$finish;
end

initial begin
	@(posedge rst_n);
	@(posedge clk);
	repeat(20) test_rx($random);
	$finish;
end

initial begin
	$dumpfile("uart.vcd");
	$dumpvars(0, uart);
end


//Tasks
task reset; begin
	#10; rst_n=0;
	#10; rst_n=1;
end
endtask

//verify uart receive function
task test_rx; 
input	[7:0]	rx_data_sim; //simulated UART signal for rx
integer		i;

begin
	rx = 1'b0;
	#UART_TX_WAIT;
	for ( i = 0; i < 8 ; i = i + 1 ) begin
		rx = rx_data_sim[i];
		#UART_TX_WAIT;
	end        

`ifdef PARITY_ODD
	rx = ~^rx_data_sim;
	#UART_TX_WAIT;
`elsif PARITY_EVEN
	rx = ^rx_data_sim;
	#UART_TX_WAIT;
`endif

	rx = 1'b1;	    
	rx_compare_module_result(rx_data_sim);
	
end
endtask

task rx_compare_module_result;
input	[7:0]	rx_data_sim;
integer i;

begin
	@ (posedge rx_ok);
	@ (negedge clk);
	if (rx_data_sim != rx_data) 
		$display ("RX MISMATCH:\texpected = %h\tmodule got = %h", rx_data_sim, rx_data);
`ifdef PARITY_ODD
	else if (rx_error == 1)
		$display ("RX ERROR:\tparity fail");
`elsif PARITY_EVEN
	else if (rx_error == 1)
		$display ("RX ERROR:\tparity fail");
`endif
	else
		$display ("RX PASS: byte = %h", rx_data_sim);
	#UART_TX_WAIT;
end	
endtask


//verify uart transmit function
task test_tx;
input	[7:0]	tx_data_set;
begin
	tx_data = tx_data_set;
	@ (posedge clk); tx_send = 1;
	@ (posedge clk); tx_send = 0;

	tx_compare_module_result(tx_data_set);
end
endtask

task tx_compare_module_result;
input	[7:0]	tx_data_set;
integer i;
reg	[7:0]	tx_data_decoded; //module tx output decoded by testbench
reg		tx_parity;
begin
        while (tx == 1'b1)
		@(tx);
		#(UART_TX_WAIT + (UART_TX_WAIT/2));

        for ( i = 0; i < 8 ; i = i + 1 ) begin
        	tx_data_decoded[i] = tx;
        	#UART_TX_WAIT;
        end
	
`ifdef PARITY_ODD
	tx_parity=tx;
	#UART_TX_WAIT;
`elsif PARITY_EVEN
	tx_parity=tx;
	#UART_TX_WAIT;
`endif
	
        if (tx == 1'b0) begin
        	$display("* TX ERROR:\tstop bit not at time %d ns", $time);
        	while (tx == 1'b0)
        	@(tx);
        end



        if (tx_data_set!=tx_data_decoded) 
		$display ("TX MISMATCH:\texpected = %h\tmodule gen = %h at time %d ns", tx_data_set, tx_data_decoded, $time);
`ifdef PARITY_ODD
	else if (tx_parity!= ~^tx_data_decoded)
		$display ("TX ERROR:\todd parity fail at time %d ns", $time);
`elsif PARITY_EVEN
	else if (tx_parity!= ^tx_data_decoded)
		$display ("TX ERROR:\teven parity fail at time %d ns", $time);
`endif
	else
		$display("TX PASS: byte = %h", tx_data_decoded);
		
end
endtask

endmodule
