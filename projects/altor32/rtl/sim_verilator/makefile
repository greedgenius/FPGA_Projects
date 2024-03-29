
# Default binary to load & run
TEST_IMAGE  ?= test_image.bin  
SIMARGS     ?=

# Default core to simulate
RTL_CORE      ?= core_pipelined
CORE_FILENAME ?= altor32.v

# Waveform trace disabled by default
TRACE?= 1

# Enable debug output
DEBUG?= 0

# Enable instruction trace
INST_TRACE?= 0

# Top module (without .v extension)
TOP_MODULE = top

# Additional modules which can't be auto found
ADDITIONAL_MODULES = ../$(RTL_CORE)/$(CORE_FILENAME)

# CPP Source Files
SRC_CPP = main.cpp top.cpp inst_dump.cpp

# Source directories
INC_DIRS = -I../$(RTL_CORE) -I../soc -I../peripheral

# Build directory
BUILD_DIR = build

VERILATOR_OPTS = +define+CONF_MULT_HW+

ifeq ($(TRACE),1)
    VERILATOR_OPTS += --trace
endif

ifeq ($(DEBUG),1)
    VERILATOR_OPTS += +define+CONF_CORE_DEBUG+
endif

ifeq ($(INST_TRACE),1)
    VERILATOR_OPTS += -CFLAGS "-DINST_TRACE"
endif

all: run                                                                                      
 
compile: clean
	verilator --cc $(TOP_MODULE).v $(ADDITIONAL_MODULES) $(SRC_CPP) $(INC_DIRS) +define+CONF_TARGET_SIM+ --exe -Mdir $(BUILD_DIR) $(VERILATOR_OPTS)
	make -j -f V$(TOP_MODULE).mk -C $(BUILD_DIR)

run: compile
	./$(BUILD_DIR)/V$(TOP_MODULE) -f $(TEST_IMAGE) $(SIMARGS)
	
ifeq ($(TRACE),1)	
view:
	gtkwave wave_dump.vcd gtksettings.sav
endif
 
clean :                                                                                                  
	-rm -rf $(BUILD_DIR) *.vcd
