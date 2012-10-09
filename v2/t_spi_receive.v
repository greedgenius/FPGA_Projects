`timescale 1ns / 1ps
module t_spi_receive;
    
    parameter CLK_CYCLE=10;

	// Inputs
        reg         clk,rst,sdata1,sdata2,start;

	// Outputs
        wire [11:0] data1;
        wire [11:0] data2;
        wire        sclk,ncs,done;

	// Instantiate the Unit Under Test (UUT)
        spi_recieve dut(
        //general usage
        clk,
        rst,
        //Pmod interface signals
        sdata1,
        sdata2,
        sclk,
        ncs,
        //user interface signals
        data1,
        data2,
        start,
        done
        );
	
    task reset; begin
    #10; rst=1;
    #10; rst=0;
    end
    endtask


    task randin; begin
        @ (posedge clk); #1;
        sdata1 = $random%100;
        sdata2 = $random%100;
        start = $random%2;
    end
    endtask

    initial
     begin
     $dumpfile("test.vcd");
     $dumpvars(0,dut);
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
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
        randin;
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

