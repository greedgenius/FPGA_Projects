//synthesizable ram module for xilinx

module ram (
	clk, we, waddr, raddr, din, dout
	);

parameter ADDR_WIDTH = 6;
parameter DATA_WIDTH = 4;

input				clk;
input				we;
input	[ADDR_WIDTH-1:0]	waddr;
input	[ADDR_WIDTH-1:0]	raddr;
input	[DATA_WIDTH-1:0]	din;
output	[DATA_WIDTH-1:0]	dout;

//synthesis attribute ram_style of mem is block
reg	[DATA_WIDTH-1:0]	mem	[(2**ADDR_WIDTH)-1:0]; //pragma attribute mem ram_block TRUE
reg	[ADDR_WIDTH-1:0]	raddr_reg;

always @ (posedge clk) begin
	raddr_reg <= raddr;

	if (we) begin
		mem[waddr] <= din;
	end

end

assign dout = mem[raddr_reg];
endmodule
