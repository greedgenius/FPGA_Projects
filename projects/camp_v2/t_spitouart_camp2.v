`timescale 1ns / 1ps
module t_spitouart;
    
    parameter CLK_CYCLE=10;

	// Inputs
    reg clk,rst,done,TxD_busy;
    reg [11:0] data1,data2;
    reg Pulse1_in,Pulse2_in;

	// Outputs
    wire TxD_start,start;
    wire [7:0] TxD_data;

	// Instantiate the Unit Under Test (UUT)
    spitouart_camp2 spitouart_camp2(
        clk,
        rst,
        data1,
        data2,
        done,
        TxD_start,
        TxD_data,
        start,
        TxD_busy,
        Pulse1_in,
        Pulse2_in
    );
	
    task reset; begin
    #10; rst=1;
    #10; rst=0;
    end
    endtask


    task randin; begin
        @ (posedge clk); #1;
        done = $random%2;
        TxD_busy = $random%2;
        data1 = $random%100;
        data2 = $random%100;
        Pulse1_in = $random%2;
        Pulse2_in = $random%2;
    end
    endtask

    initial
     begin
     $dumpfile("spitouart_camp2.vcd");
     $dumpvars(0,spitouart_camp2);
     end


	initial begin
		// Initialize Inputs
		clk=0;
        
		// Add stimulus here
        reset;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        #10; $finish;


	end


    always #(CLK_CYCLE/2) clk=~clk;
    

      
endmodule

