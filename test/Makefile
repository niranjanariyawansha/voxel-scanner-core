# Makefile
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Ensure the path to your combined source file is correct
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_niranjanariyawansha_voxel_scanner_core.v

# RTL simulation:
SIM_BUILD = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS += -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# Set the default test module
MODULE = test_fuzzer

include $(shell cocotb-config --makefiles)/Makefile.sim
