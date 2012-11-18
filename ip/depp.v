//Depp module
//Developed by F.M.Zhu

module depp (clk, rst_n
	, a_astb, a_dstb, a_write, a_db, a_wait
	, a_addr_reg 
	);

input 		clk, rst_n;

//DEPP ports
input 		a_astb, a_dstb, a_write;
inout	[7:0]	a_db;
output		a_wait;

output	[7:0]	a_addr_reg;

//registers and wires
reg	[7:0]	a_data_reg;
reg	[7:0]	a_addr_reg;

wire a_wait = ~a_astb | ~a_dstb;
wire a_db = (a_write) ? a_data_reg : 8'bZZZZ_ZZZZ;  

always @ (posedge a_astb)
	if (~a_write)
		a_addr_reg <= a_db;

always @ (posedge a_dstb)
	if (~a_write)
		a_data_reg <= a_db;

endmodule
		
