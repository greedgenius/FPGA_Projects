
###############################################################################
# USER CONFIG PARAMETERS 
###############################################################################

TOPMODULE = top
TOPFILE = top.v
TOPBIT = top.bit
TOPMCS = top.mcs

TESTBENCH = t_top.v
TBOUTPUT = top.vcd

DEVICE = Basys2
PACKAGE = xc3s100e-cp132-4
PROM = xcf02s

C_TARGET = DeppDemo
#C_TARGET = depp_throughput

###############################################################################
# XILINX MAKEFILE 
###############################################################################

genbit: $(TOPBIT)

genmcs: $(TOPMCS)

%.v: %.vpp
	vpp $< > $@

%.xst:
	echo "time short" > $@
	echo "run -glob_opt max_delay" >> $@
	echo "-ifn $*.v" >> $@
	echo "-ifmt Verilog" >> $@
	echo "-ofn $*.ngc" >> $@
	echo "-p $(PACKAGE)" >> $@
	echo "-write_timing_constraints yes" >> $@
	echo "-opt_mode Speed" >> $@
	echo "-opt_level 1" >> $@
	echo "-top $(TOPMODULE)" >> $@

%.ngc: %.xst %.v
	xst -ifn $<

%.ngd: %.ngc
	ngdbuild -aul $* -uc depp.ucf

%.ncd: %.ngd
	map -pr b -timing -detail $*

%_par.ncd: %.ncd
	par -w $* $*_par

%.bit: %_par.ncd
	#bitgen -g startupClk:jtagClk -w $*_par $*.bit
	bitgen -g startupClk:Cclk -w $*_par $*.bit

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

%.mcs: %.bit 
#	promgen -w -p mcs -c FF -o $(TOPMCS) -s 16384 -u 00000000 $(TOPBIT) -i 0 -x $(PROM) -z
	promgen -u 0 $(TOPBIT) -p mcs -w -x $(PROM)

do-not-clean:
# This is to make sure xilinx-clean is not the default target
	@echo "Meep! Define your default target before including 'xilinx.mk'."

xilinx-clean:
	rm -rf *.lst *.ngc *.ngd *.ncd *.bld *.mrp *.ngm *.pcf *.srp *.bgn \
	       *.dly *.drc *.pad *.xpi *.par *.nav *.imp *.csv *.twr *.twx \
               *.txt *.dsn _impact* *.ut *_par.xst xst *.map *.xrpt *.ptwx \
               *.xml *.unroutes *.xwbt *.html *.log xlnx_auto_0_xdb _xmsgs \
	       *.cfi *.prm

verilog-clean:
	rm -rf *.trn *.vdc verilog.log *.out *.vcd

very-clean: xilinx-clean verilog-clean cclean
	rm -rf *.ace *.bit *.mcs 

###############################################################################
# DIGILENT DOWNLOAD MAKEFILE
###############################################################################

enum:
	djtgcfg enum
init:
	djtgcfg init -d $(DEVICE)
progbit: genbit
	djtgcfg prog -d $(DEVICE) -i 0 -f $(TOPBIT) 
progmcs: genmcs
	djtgcfg prog -d $(DEVICE) -i 1 -f $(TOPMCS) 


###############################################################################
# ICARUS VERILOG & GTKWAVE MAKEFILE
###############################################################################

COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

COFLAGS = -v -o
SFLAGS = -v
SOUTPUT = -vcd 
COUTPUT = compiler.out			
###############################################################################

#MAKE DIRECTIVES
check : $(TESTBENCH) $(TOPFILE)
	$(COMPILER) -v $(TOPFILE)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

display: $(TBOUTPUT)
	$(VIEWER) $(TBOUTPUT) &

#MAKE DEPENDANCIES
$(TBOUTPUT): $(COUTPUT)
	$(SIMULATOR) $(SOPTIONS) $(COUTPUT) $(SOUTPUT)

$(COUTPUT): $(TESTBENCH) $(TOPFILE)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(TOPFILE)



###############################################################################
# Adept SDK GCC MAKEFILE
###############################################################################

CC = gcc
INC = /usr/local/include/digilent/adept
LIBDIR = /usr/local/lib/digilent/adept
CFLAGS = -I $(INC) -L $(LIBDIR) 
###############################################################################

compile: $(C_TARGET)

$(C_TARGET):
	$(CC) $(CFLAGS) -o $(C_TARGET) $(C_TARGET).cpp -ldepp -ldmgr
	
cclean:
	rm -f $(C_TARGET)

deppwrite: compile
	./DeppDemo -p 123 -c 1 -b 73 -d $(DEVICE)

deppread: compile
	./DeppDemo -g 123 -c 1 -d $(DEVICE)
