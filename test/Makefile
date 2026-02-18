SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

# PROJECT_SOURCES: All monitoring pillars are now included in the simulation path
PROJECT_SOURCES = tt_um_niranjanariyawansha_voxel_scanner_core.v vx1_pmu.v vx1_sensors.v vx1_dfd.v

SIM_BUILD = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb
MODULE = test_fuzzer

include $(shell cocotb-config --makefiles)/Makefile.sim
