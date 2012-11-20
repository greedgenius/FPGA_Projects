//Depp_mem module
//Developed by F.M.Zhu

module depp_mem (clk
	, a_astb, a_dstb, a_write, a_db, a_wait
	, we, addr, din, dout
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
		
