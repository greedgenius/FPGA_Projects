//Depp_mem module
//Developed by F.M.Zhu
//this module that converts depp interface to memory interface

module depp_mem (
	clk		//clock

	//depp interface
	, a_astb	//depp address strobe, active low
	, a_dstb	//depp data strobe, active low
	, a_write	//depp write signal, active low
	, a_db		//bi directional data bus
	, a_wait	//indicate peripheral is ready to accept data or has data available

	//memory interface
	, we		//write enable, active high
	, addr		//memory address
	, din		//memory write data
	, dout		//memory read data
	);

input 		clk;

//DEPP ports (a stands for async)
input 		a_astb, a_dstb, a_write;
inout	[7:0]	a_db;
output		a_wait;

//MEM ports
output		we;
output	[7:0]	addr;
output	[7:0]	din;
input	[7:0]	dout;

//registers and wires
reg	[7:0]	din;
reg	[7:0]	addr, addr_reg;
reg	[2:0]	a_astb_sr, a_dstb_sr;
reg		we;

wire a_wait = ~a_astb | ~a_dstb;
wire a_db = (a_write) ? dout : 8'bZZZZ_ZZZZ;  

//stb signal will hold low for more than 80 ns
//data will is stable during this period
always @ (posedge clk) begin
	a_astb_sr <= {a_astb_sr[1:0], a_astb};
	a_dstb_sr <= {a_dstb_sr[1:0], a_dstb};
end

always @ (posedge clk)
	if (~a_write && a_astb_sr == 3'b100) begin
		addr_reg <= a_db;
	end

always @ (posedge clk)
	if (~a_write && a_dstb_sr == 3'b100) begin
		din <= a_db;
		addr <= addr_reg;
		we <= 1;
	end
	else begin
		din <= 0;
		addr <= addr_reg;
		we <= 0;
	end

endmodule
		
