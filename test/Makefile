CWD=$(shell pwd)

SIM ?= icarus
TOPLEVEL_LANG ?=verilog

VERILOG_SOURCES =$(CWD)/../hdl/*.v

TOPLEVEL = riscv
MODULE := riscv_test
COCOTB_HDL_TIMEUNIT=1us
COCOTB_HDL_TIMEPRECISION=1us

include $(shell cocotb-config --makefiles)/Makefile.sim