/*
 * fc_ctrl_rom generated by KCAsm at Sat May 26 15:39:05 EDT 2007
 */

module fc_ctrl_rom(address, instruction, clk);
input [9:0] address;
output [17:0] instruction;
input clk;
RAMB16_S18 ram_1024_x_18(
	.DI (16'b0),
	.DIP (2'b0),
	.EN (1'b1),
	.WE (1'b0),
	.SSR (1'b0),
	.CLK (clk),
	.ADDR (address),
	.DO (instruction[15:0]),
	.DOP (instruction[17:16])
);
// synthesis translate_off
/*	synthesis
	init_00 = "052B00E60213052100D30213051001B501B501B500C002130510C001000001FD"
	init_01 = "0000013F541AC001E180C108010000FF020E01B501B501B501B501B500F50213"
	init_02 = "0F00010054314F014024015D542CAF0F4F004F8002130521C0015C20C101F010"
	init_03 = "014E4024015D503F4F0840410F020130543B4F0440410F01011454364F024041"
	init_04 = "0E200FFF4024004E0619021305100094C0016503640263016200C000CF080F03"
	init_05 = "052040610E4D01D3052E505F4FFF008C00886517008C00886518008C00886519"
	init_06 = "01D3052E50724FFF50724E4D008C00886514008C00886515008C0088651601D3"
	init_07 = "15E001D3052001D385306511008C00886512008C0088651301D3052040740E4B"
	init_08 = "01D3853050914FFFA0000F00B0004500A00001D3052001D3057A01D3054801D3"
	init_09 = "1D501C401B301A20A0005496CE018F01F1F0009C0F110E0AA00001D30520A000"
	init_0A = "40B5020758B0FD90FC80FB70DA60001D06000700080009A00500040003000200"
	init_0B = "A00011A054A9C001060807080808090E0500040003000206BD90BC80BB709A60"
	init_0C = "01D3057A01D3056101D3056C01D3054201D3056F01D3056301D3056901D30550"
	init_0D = "056E01D3056501D3057501D3057101D3056501D3057201D30546A00001D30565"
	init_0E = "01D3057401D3056E01D3057501D3056F01D30543A00001D3057901D3056301D3"
	init_0F = "A00001D3053001D3053001D3052E01D3053101D30576A00001D3057201D30565"
	init_10 = "01D3057501D3057001D3056E01D3056901D3052001D3054101D3054D01D30553"
	init_11 = "01D3052001D3057A01D3054801D3054D01D3053001D3053541570F0601D30574"
	init_12 = "41570F0201D3056C01D3056101D3057401D3057301D3057901D3057201D30543"
	init_13 = "01D3056901D3056301D3057301D3054F01D3052001D3054D01D3054301D30544"
	init_14 = "01D30552A00001D3052001D3057201D3056F01D3057401D3056101D301D3056C"
	init_15 = "0552021305104157CF0101D30520B0004F00413601D3056701D3056E01D30569"
	init_16 = "052001D3054D01D3054301D3054401D3052001D3056701D3056E01D3056901D3"
	init_17 = "052001D3054101D3054D01D3055301D3052001D3054D01D3053001D3053501D3"
	init_18 = "053201D3055701D3055301D3052001D3053301D3055701D3055301D305200213"
	init_19 = "053001D3055701D3055301D3052001D3053101D3055701D3055301D3052001D3"
	init_1A = "A00055ACC20101A60219A00055A7C10101A20128A00055A3C001000BA00001D3"
	init_1B = "A000C404E40101A2C404E401A00055B6C40101B00432A00055B1C30101AB0314"
	init_1C = "01A601C00406040604060407145001A201C0C408A4F01450A00001BAC404A4F8"
	init_1D = "01BAC4040406040604070407145001A201BAC404C40CA4F01450A000C40404F0"
	init_1E = "01A2C404E40101A2C404E401450901A2C404E401C404040EA000C40404F001A6"
	init_1F = "01C0043001B0A00001A6C4040404D500000E000E000E000EA5F0C404E4014009"
	init_20 = "01C4050101C4050C01C4050601C4052801A601C0042001A601C001AB01C001B0"
	init_21 = "E232E131E030A00001C4C5C0A50FA00001C4C580A50F52192510A00001AB01AB"
	init_22 = "523C40046004EF3FEE3EED3DEC3CEB3BEA3AE939E838E737E636E535E434E333"
	init_23 = "00F05248201040804256C0020000C002000242380001523720104080E0048001"
	init_24 = "C00200024F704E604D504C40C001000F4250C00200014F304E204D104C00C001"
	init_25 = "66366737683869396A3A6B3B6C3C6D3D6E3E6F3FEF03EE02ED01EC00C0020000"
	init_26 = "0000000000000000000000000000000000008001603061316232633364346535"
	init_27 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_28 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_29 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2A = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2B = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2C = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2D = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2E = "0000000000000000000000000000000000000000000000000000000000000000"
	init_2F = "0000000000000000000000000000000000000000000000000000000000000000"
	init_30 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_31 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_32 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_33 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_34 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_35 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_36 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_37 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_38 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_39 = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3A = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3B = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3C = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3D = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3E = "0000000000000000000000000000000000000000000000000000000000000000"
	init_3F = "421D000000000000000000000000000000000000000000000000000000000000"
	initp_00 = "334F3CCCCDDF3CF33337CF3C0F33C038FF73DCF73DFC4CF60D20FFFF3CF3FF23"
	initp_01 = "B33332CCCCCCCB333333332CCCCCCCCC8DAAAA55ED54000000B5B0B2DD89B333"
	initp_02 = "333333333333333333727CCCCB33333CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
	initp_03 = "CEE0AA20E38388A3EAA3E028FAA3C0B8A38B72DCB72DCB4B3333333333333333"
	initp_04 = "000000000000300000000AA88008E00234E23349D2AAAAAAAAC2C36FCCCCF3FF"
	initp_05 = "0000000000000000000000000000000000000000000000000000000000000000"
	initp_06 = "0000000000000000000000000000000000000000000000000000000000000000"
	initp_07 = "C000000000000000000000000000000000000000000000000000000000000000"
*/
// synthesis translate_off
defparam ram_1024_x_18.INIT_00 = 256'h052B00E60213052100D30213051001B501B501B500C002130510C001000001FD;
defparam ram_1024_x_18.INIT_01 = 256'h0000013F541AC001E180C108010000FF020E01B501B501B501B501B500F50213;
defparam ram_1024_x_18.INIT_02 = 256'h0F00010054314F014024015D542CAF0F4F004F8002130521C0015C20C101F010;
defparam ram_1024_x_18.INIT_03 = 256'h014E4024015D503F4F0840410F020130543B4F0440410F01011454364F024041;
defparam ram_1024_x_18.INIT_04 = 256'h0E200FFF4024004E0619021305100094C0016503640263016200C000CF080F03;
defparam ram_1024_x_18.INIT_05 = 256'h052040610E4D01D3052E505F4FFF008C00886517008C00886518008C00886519;
defparam ram_1024_x_18.INIT_06 = 256'h01D3052E50724FFF50724E4D008C00886514008C00886515008C0088651601D3;
defparam ram_1024_x_18.INIT_07 = 256'h15E001D3052001D385306511008C00886512008C0088651301D3052040740E4B;
defparam ram_1024_x_18.INIT_08 = 256'h01D3853050914FFFA0000F00B0004500A00001D3052001D3057A01D3054801D3;
defparam ram_1024_x_18.INIT_09 = 256'h1D501C401B301A20A0005496CE018F01F1F0009C0F110E0AA00001D30520A000;
defparam ram_1024_x_18.INIT_0A = 256'h40B5020758B0FD90FC80FB70DA60001D06000700080009A00500040003000200;
defparam ram_1024_x_18.INIT_0B = 256'hA00011A054A9C001060807080808090E0500040003000206BD90BC80BB709A60;
defparam ram_1024_x_18.INIT_0C = 256'h01D3057A01D3056101D3056C01D3054201D3056F01D3056301D3056901D30550;
defparam ram_1024_x_18.INIT_0D = 256'h056E01D3056501D3057501D3057101D3056501D3057201D30546A00001D30565;
defparam ram_1024_x_18.INIT_0E = 256'h01D3057401D3056E01D3057501D3056F01D30543A00001D3057901D3056301D3;
defparam ram_1024_x_18.INIT_0F = 256'hA00001D3053001D3053001D3052E01D3053101D30576A00001D3057201D30565;
defparam ram_1024_x_18.INIT_10 = 256'h01D3057501D3057001D3056E01D3056901D3052001D3054101D3054D01D30553;
defparam ram_1024_x_18.INIT_11 = 256'h01D3052001D3057A01D3054801D3054D01D3053001D3053541570F0601D30574;
defparam ram_1024_x_18.INIT_12 = 256'h41570F0201D3056C01D3056101D3057401D3057301D3057901D3057201D30543;
defparam ram_1024_x_18.INIT_13 = 256'h01D3056901D3056301D3057301D3054F01D3052001D3054D01D3054301D30544;
defparam ram_1024_x_18.INIT_14 = 256'h01D30552A00001D3052001D3057201D3056F01D3057401D3056101D301D3056C;
defparam ram_1024_x_18.INIT_15 = 256'h0552021305104157CF0101D30520B0004F00413601D3056701D3056E01D30569;
defparam ram_1024_x_18.INIT_16 = 256'h052001D3054D01D3054301D3054401D3052001D3056701D3056E01D3056901D3;
defparam ram_1024_x_18.INIT_17 = 256'h052001D3054101D3054D01D3055301D3052001D3054D01D3053001D3053501D3;
defparam ram_1024_x_18.INIT_18 = 256'h053201D3055701D3055301D3052001D3053301D3055701D3055301D305200213;
defparam ram_1024_x_18.INIT_19 = 256'h053001D3055701D3055301D3052001D3053101D3055701D3055301D3052001D3;
defparam ram_1024_x_18.INIT_1A = 256'hA00055ACC20101A60219A00055A7C10101A20128A00055A3C001000BA00001D3;
defparam ram_1024_x_18.INIT_1B = 256'hA000C404E40101A2C404E401A00055B6C40101B00432A00055B1C30101AB0314;
defparam ram_1024_x_18.INIT_1C = 256'h01A601C00406040604060407145001A201C0C408A4F01450A00001BAC404A4F8;
defparam ram_1024_x_18.INIT_1D = 256'h01BAC4040406040604070407145001A201BAC404C40CA4F01450A000C40404F0;
defparam ram_1024_x_18.INIT_1E = 256'h01A2C404E40101A2C404E401450901A2C404E401C404040EA000C40404F001A6;
defparam ram_1024_x_18.INIT_1F = 256'h01C0043001B0A00001A6C4040404D500000E000E000E000EA5F0C404E4014009;
defparam ram_1024_x_18.INIT_20 = 256'h01C4050101C4050C01C4050601C4052801A601C0042001A601C001AB01C001B0;
defparam ram_1024_x_18.INIT_21 = 256'hE232E131E030A00001C4C5C0A50FA00001C4C580A50F52192510A00001AB01AB;
defparam ram_1024_x_18.INIT_22 = 256'h523C40046004EF3FEE3EED3DEC3CEB3BEA3AE939E838E737E636E535E434E333;
defparam ram_1024_x_18.INIT_23 = 256'h00F05248201040804256C0020000C002000242380001523720104080E0048001;
defparam ram_1024_x_18.INIT_24 = 256'hC00200024F704E604D504C40C001000F4250C00200014F304E204D104C00C001;
defparam ram_1024_x_18.INIT_25 = 256'h66366737683869396A3A6B3B6C3C6D3D6E3E6F3FEF03EE02ED01EC00C0020000;
defparam ram_1024_x_18.INIT_26 = 256'h0000000000000000000000000000000000008001603061316232633364346535;
defparam ram_1024_x_18.INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INIT_3F = 256'h421D000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INITP_00 = 256'h334F3CCCCDDF3CF33337CF3C0F33C038FF73DCF73DFC4CF60D20FFFF3CF3FF23;
defparam ram_1024_x_18.INITP_01 = 256'hB33332CCCCCCCB333333332CCCCCCCCC8DAAAA55ED54000000B5B0B2DD89B333;
defparam ram_1024_x_18.INITP_02 = 256'h333333333333333333727CCCCB33333CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC;
defparam ram_1024_x_18.INITP_03 = 256'hCEE0AA20E38388A3EAA3E028FAA3C0B8A38B72DCB72DCB4B3333333333333333;
defparam ram_1024_x_18.INITP_04 = 256'h000000000000300000000AA88008E00234E23349D2AAAAAAAAC2C36FCCCCF3FF;
defparam ram_1024_x_18.INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam ram_1024_x_18.INITP_07 = 256'hC000000000000000000000000000000000000000000000000000000000000000;
// synthesis translate_on
// synthesis attribute INIT_00 of ram_1024_x_18 is "052B00E60213052100D30213051001B501B501B500C002130510C001000001FD"
// synthesis attribute INIT_01 of ram_1024_x_18 is "0000013F541AC001E180C108010000FF020E01B501B501B501B501B500F50213"
// synthesis attribute INIT_02 of ram_1024_x_18 is "0F00010054314F014024015D542CAF0F4F004F8002130521C0015C20C101F010"
// synthesis attribute INIT_03 of ram_1024_x_18 is "014E4024015D503F4F0840410F020130543B4F0440410F01011454364F024041"
// synthesis attribute INIT_04 of ram_1024_x_18 is "0E200FFF4024004E0619021305100094C0016503640263016200C000CF080F03"
// synthesis attribute INIT_05 of ram_1024_x_18 is "052040610E4D01D3052E505F4FFF008C00886517008C00886518008C00886519"
// synthesis attribute INIT_06 of ram_1024_x_18 is "01D3052E50724FFF50724E4D008C00886514008C00886515008C0088651601D3"
// synthesis attribute INIT_07 of ram_1024_x_18 is "15E001D3052001D385306511008C00886512008C0088651301D3052040740E4B"
// synthesis attribute INIT_08 of ram_1024_x_18 is "01D3853050914FFFA0000F00B0004500A00001D3052001D3057A01D3054801D3"
// synthesis attribute INIT_09 of ram_1024_x_18 is "1D501C401B301A20A0005496CE018F01F1F0009C0F110E0AA00001D30520A000"
// synthesis attribute INIT_0A of ram_1024_x_18 is "40B5020758B0FD90FC80FB70DA60001D06000700080009A00500040003000200"
// synthesis attribute INIT_0B of ram_1024_x_18 is "A00011A054A9C001060807080808090E0500040003000206BD90BC80BB709A60"
// synthesis attribute INIT_0C of ram_1024_x_18 is "01D3057A01D3056101D3056C01D3054201D3056F01D3056301D3056901D30550"
// synthesis attribute INIT_0D of ram_1024_x_18 is "056E01D3056501D3057501D3057101D3056501D3057201D30546A00001D30565"
// synthesis attribute INIT_0E of ram_1024_x_18 is "01D3057401D3056E01D3057501D3056F01D30543A00001D3057901D3056301D3"
// synthesis attribute INIT_0F of ram_1024_x_18 is "A00001D3053001D3053001D3052E01D3053101D30576A00001D3057201D30565"
// synthesis attribute INIT_10 of ram_1024_x_18 is "01D3057501D3057001D3056E01D3056901D3052001D3054101D3054D01D30553"
// synthesis attribute INIT_11 of ram_1024_x_18 is "01D3052001D3057A01D3054801D3054D01D3053001D3053541570F0601D30574"
// synthesis attribute INIT_12 of ram_1024_x_18 is "41570F0201D3056C01D3056101D3057401D3057301D3057901D3057201D30543"
// synthesis attribute INIT_13 of ram_1024_x_18 is "01D3056901D3056301D3057301D3054F01D3052001D3054D01D3054301D30544"
// synthesis attribute INIT_14 of ram_1024_x_18 is "01D30552A00001D3052001D3057201D3056F01D3057401D3056101D301D3056C"
// synthesis attribute INIT_15 of ram_1024_x_18 is "0552021305104157CF0101D30520B0004F00413601D3056701D3056E01D30569"
// synthesis attribute INIT_16 of ram_1024_x_18 is "052001D3054D01D3054301D3054401D3052001D3056701D3056E01D3056901D3"
// synthesis attribute INIT_17 of ram_1024_x_18 is "052001D3054101D3054D01D3055301D3052001D3054D01D3053001D3053501D3"
// synthesis attribute INIT_18 of ram_1024_x_18 is "053201D3055701D3055301D3052001D3053301D3055701D3055301D305200213"
// synthesis attribute INIT_19 of ram_1024_x_18 is "053001D3055701D3055301D3052001D3053101D3055701D3055301D3052001D3"
// synthesis attribute INIT_1A of ram_1024_x_18 is "A00055ACC20101A60219A00055A7C10101A20128A00055A3C001000BA00001D3"
// synthesis attribute INIT_1B of ram_1024_x_18 is "A000C404E40101A2C404E401A00055B6C40101B00432A00055B1C30101AB0314"
// synthesis attribute INIT_1C of ram_1024_x_18 is "01A601C00406040604060407145001A201C0C408A4F01450A00001BAC404A4F8"
// synthesis attribute INIT_1D of ram_1024_x_18 is "01BAC4040406040604070407145001A201BAC404C40CA4F01450A000C40404F0"
// synthesis attribute INIT_1E of ram_1024_x_18 is "01A2C404E40101A2C404E401450901A2C404E401C404040EA000C40404F001A6"
// synthesis attribute INIT_1F of ram_1024_x_18 is "01C0043001B0A00001A6C4040404D500000E000E000E000EA5F0C404E4014009"
// synthesis attribute INIT_20 of ram_1024_x_18 is "01C4050101C4050C01C4050601C4052801A601C0042001A601C001AB01C001B0"
// synthesis attribute INIT_21 of ram_1024_x_18 is "E232E131E030A00001C4C5C0A50FA00001C4C580A50F52192510A00001AB01AB"
// synthesis attribute INIT_22 of ram_1024_x_18 is "523C40046004EF3FEE3EED3DEC3CEB3BEA3AE939E838E737E636E535E434E333"
// synthesis attribute INIT_23 of ram_1024_x_18 is "00F05248201040804256C0020000C002000242380001523720104080E0048001"
// synthesis attribute INIT_24 of ram_1024_x_18 is "C00200024F704E604D504C40C001000F4250C00200014F304E204D104C00C001"
// synthesis attribute INIT_25 of ram_1024_x_18 is "66366737683869396A3A6B3B6C3C6D3D6E3E6F3FEF03EE02ED01EC00C0020000"
// synthesis attribute INIT_26 of ram_1024_x_18 is "0000000000000000000000000000000000008001603061316232633364346535"
// synthesis attribute INIT_27 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_28 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_29 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2A of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2B of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2C of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2D of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2E of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2F of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_30 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_31 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_32 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_33 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_34 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_35 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_36 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_37 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_38 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_39 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3A of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3B of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3C of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3D of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3E of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3F of ram_1024_x_18 is "421D000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INITP_00 of ram_1024_x_18 is "334F3CCCCDDF3CF33337CF3C0F33C038FF73DCF73DFC4CF60D20FFFF3CF3FF23"
// synthesis attribute INITP_01 of ram_1024_x_18 is "B33332CCCCCCCB333333332CCCCCCCCC8DAAAA55ED54000000B5B0B2DD89B333"
// synthesis attribute INITP_02 of ram_1024_x_18 is "333333333333333333727CCCCB33333CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"
// synthesis attribute INITP_03 of ram_1024_x_18 is "CEE0AA20E38388A3EAA3E028FAA3C0B8A38B72DCB72DCB4B3333333333333333"
// synthesis attribute INITP_04 of ram_1024_x_18 is "000000000000300000000AA88008E00234E23349D2AAAAAAAAC2C36FCCCCF3FF"
// synthesis attribute INITP_05 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INITP_06 of ram_1024_x_18 is "0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INITP_07 of ram_1024_x_18 is "C000000000000000000000000000000000000000000000000000000000000000"
endmodule
