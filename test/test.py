import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_vx1_structural_scan(dut):
    # Set up 100MHz clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the VX-1 Core
    dut.rst_n.value = 0
    dut.ena.value = 1
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Test identifying a structural character: '{' (Hex 0x7B)
    dut.ui_in.value = 0x7B
    await ClockCycles(dut.clk, 1)
    
    # Your logic replicates 8-bits to 64-bits, so all 8 output bits should go HIGH
    assert dut.uo_out.value == 0xFF
    dut._log.info("Successfully identified structural character '{'")
