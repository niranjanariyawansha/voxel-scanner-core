import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import random

@cocotb.test()
async def test_vx1_fuzzing(dut):
    dut._log.info("🚀 Starting VX-1 Randomized Fuzzing Test")

    # 1. Setup 2 GHz Clock (0.5ns) for 16nm simulation
    clock = Clock(dut.clk, 0.5, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.ena.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # 3. Randomized Stress Test Loop
    # Target: 10,000 cycles of chaotic JSON data
    for i in range(10000):
        # Weighted random selection:
        # 30% Structural characters, 10% Escapes, 60% Random Noise/Data
        choice = random.random()
        if choice < 0.30:
            char = random.choice(['{', '}', '[', ']', ':', ',', '"'])
        elif choice < 0.40:
            char = '\\'
        else:
            char = random.choice("abcdefghijklmnopqrstuvwxyz0123456789")

        dut.ui_in.value = ord(char)
        await ClockCycles(dut.clk, 1)

        # Monitor internal state stability
        # Ensure the error_flag doesn't trip on valid (though messy) streams
        if dut.user_project.core_logic.error_flag.value == 1:
            dut._log.error(f"❌ Logic Error at cycle {i} with input: {char}")
            assert False

    dut._log.info("✅ SUCCESS: VX-1 survived 10,000 cycles of randomized stress!")
