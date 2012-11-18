`timescale 1ns / 1ps
module t_spi_receive;
    
    parameter CLK_CYCLE=20;

	// Inputs
        reg         clk,rst,sdata1,sdata2,start;

	// Outputs
        wire [11:0] data1;
        wire [11:0] data2;
        wire        sclk,ncs,done;

        
        reg [15:0] d1;
        reg [15:0] d2;

        reg [6:0] i;
        
	// Instantiate the Unit Under Test (UUT)
        spi_receive spi_receive(
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

	initial start=0;
	task randin; begin
		d1=16'hf05a;
		d2=$random;
		#100;
		@ (posedge clk); start = 1;
		for (i=0;i<16;i=i+1)
		begin
		@ (posedge clk); @ (posedge clk); @ (posedge clk); 
			@ (posedge clk); #1; start = 0;
			sdata1 = d1>>i;
			sdata2 = d2>>i; 
		end
	end
	endtask

	initial
	begin
	$dumpfile("spi_receive.vcd");
	$dumpvars(0,t_spi_receive.d1,t_spi_receive.d2,spi_receive);
	end


	initial begin
		// Initialize Inputs
		clk=0;
        
		// Add stimulus here
        reset;
        #10;
        randin; randin; randin; randin; randin; randin; randin; randin; randin; randin; randin;
        #10; $finish;


	end


	always #(CLK_CYCLE/2) clk=~clk;
    

      
endmodule

