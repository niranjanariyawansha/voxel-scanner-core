import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import random

@cocotb.test()
async def test_vx1_fuzzing(dut):
    clock = Clock(dut.clk, 0.5, units="ns") # 2 GHz
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.ena.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    for i in range(1000):
        char = random.choice('abcdef123456{"}[:],\\')
        dut.ui_in.value = ord(char)
        await ClockCycles(dut.clk, 1)
        
        # In this core, bit 7 of uo_out is the error flag [cite: 18]
        error_bit = (int(dut.uo_out.value) >> 7) & 1
        assert error_bit == 0, f"Unexpected error at cycle {i}"

    dut._log.info("✅ SUCCESS: VX-1 passed 1,000 randomized cycles!")
