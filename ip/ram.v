//synthesizable ram module for xilinx

module ram #( 
	parameter ADDR_WIDTH = 10, 
	parameter DATA_WIDTH = 8
	)(
	clk, we, waddr, raddr, din, dout
	);

input				clk;
input				we;
input	[ADDR_WIDTH-1:0]	waddr;
input	[ADDR_WIDTH-1:0]	raddr;
input	[DATA_WIDTH-1:0]	din;
output	[DATA_WIDTH-1:0]	dout;

//synthesis attribute ram_style of mem is block
reg	[DATA_WIDTH-1:0]	mem	[(2**ADDR_WIDTH)-1:0]; //pragma attribute mem ram_block TRUE
reg	[ADDR_WIDTH-1:0]	raddr_reg;
//reg	[DATA_WIDTH-1:0]	dout;

always @ (posedge clk) begin
	raddr_reg <= raddr;

	if (we) begin
		mem[waddr] <= din;
	end

	//dout <= mem[raddr_reg]; //registered read
end

assign dout = mem[raddr_reg]; //unregistered read
endmodule
