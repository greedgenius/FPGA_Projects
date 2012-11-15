all: uart.bit

%.v: %.vpp
	vpp $< > $@

%.xst:
	echo "time short" > $@
	echo "run -glob_opt max_delay" >> $@
	echo "-ifn $*.v" >> $@
	echo "-ifmt Verilog" >> $@
	echo "-ofn $*.ngc" >> $@
#	echo "-p xc2v6000-bf957-4" >> $@
	echo "-p xc3s100e-cp132-4" >> $@
	echo "-write_timing_constraints yes" >> $@
	echo "-opt_mode Speed" >> $@
	echo "-opt_level 1" >> $@
	echo "-top uart" >> $@

%.ngc: %.xst %.v
	xst -ifn $<

%.ngd: %.ngc
	ngdbuild -aul $* -uc uart.ucf
#	ngdbuild -aul $* -uc starter_board.ucf

%.ncd: %.ngd
	map -pr b -timing -detail $*

%_par.ncd: %.ncd
	par -w $* $*_par

%.bit: %_par.ncd
	bitgen -g startupClk:jtagClk -w $*_par $*.bit

%.imp:
	echo "setMode -cf" > $@
	echo "addConfigDevice -size 0 -name systemace -path ." >> $@
	echo "addCollection -name sa_temp" >> $@
	echo "addDesign -version 0 -name sa_temp" >> $@
	echo "addDeviceChain -index 0" >> $@
	echo "addDevice -p 1 -file $*.bit" >> $@
	echo "generate -active sa_temp" >> $@
	echo "quit" >> $@

%.ace: %.bit %.imp
	impact -batch $*.imp
	mv sa_temp/sa_temp/sa_temp.ace $*.ace
	rm -rf sa_temp
	rm xilinx.sys

do-not-clean:
# This is to make sure xilinx-clean is not the default target
	@echo "Meep! Define your default target before including 'xilinx.mk'."

xilinx-clean:
	rm -rf *.lst *.ngc *.ngd *.ncd *.bld *.mrp *.ngm *.pcf *.srp *.bgn \
	       *.dly *.drc *.pad *.xpi *.par *.nav *.imp *.csv *.twr *.twx \
               *.txt *.dsn _impact* *.ut *_par.xst xst *.map *.xrpt *.ptwx \
               *.xml *.unroutes *.xwbt *.html *.log xlnx_auto_0_xdb _xmsgs  

verilog-clean:
	rm -rf *.trn *.vdc verilog.log *.out *.vcd

very-clean: xilinx-clean verilog-clean
	rm -rf *.ace *.bit

###############################################################################
#
# ICARUS VERILOG & GTKWAVE MAKEFILE
# MADE BY WILLIAM GIBB FOR HACDC
# williamgibb@gmail.com
# 
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make simulate" - compiles your design+TB & simulates your design
#	"make display" - compiles, simulates and displays waveforms
# 
###############################################################################
#
# CHANGE THESE THREE LINES FOR YOUR DESIGN
#
#TOOL INPUT
SRC = spi_receive.v
TESTBENCH = t_spi_receive.v
TBOUTPUT = spi_receive.vcd#waves.lxt	#THIS NEEDS TO MATCH THE OUTPUT FILE
#SRC = uart.v
#TESTBENCH = t_uart.v
#TBOUTPUT = uart.vcd	#THIS NEEDS TO MATCH THE OUTPUT FILE
			#FROM YOUR TESTBENCH
###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v
SOUTPUT = -vcd #-lxt		#SIMULATOR OUTPUT TYPE
#TOOL OUTPUT
COUTPUT = compiler.out			#COMPILER OUTPUT
###############################################################################
#MAKE DIRECTIVES
check : $(TESTBENCH) $(SRC)
	$(COMPILER) -v $(SRC)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

display: $(TBOUTPUT)
	$(VIEWER) $(TBOUTPUT) &
#MAKE DEPENDANCIES
$(TBOUTPUT): $(COUTPUT)
	$(SIMULATOR) $(SOPTIONS) $(COUTPUT) $(SOUTPUT)

$(COUTPUT): $(TESTBENCH) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(SRC)
