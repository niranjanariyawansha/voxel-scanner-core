import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_vx1_structural_scan(dut):
    dut._log.info("Start VX-1 JSON Accelerator Test")

    # 1. Set a 50 MHz clock (20ns period) to match your real specs
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize inputs to 0 to avoid 'x' propagation
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # 3. Reset the Core
    dut._log.info("Applying Reset...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5) # Hold reset for 5 cycles
    dut.rst_n.value = 1
    
    # IMPORTANT: Wait for one rising edge so the reset values 
    # (0s) are actually latched into the registers.
    await RisingEdge(dut.clk)

    dut._log.info("Testing Voxel Core One behavior...")

    # TEST: Identify structural character '{' (Hex 0x7B)
    dut.ui_in.value = 0x7B
    
    # Wait 1 cycle for the data to be processed and latched into the output reg
    await ClockCycles(dut.clk, 1)
    
    # Read the value. We use .value.integer to handle the comparison properly.
    output_val = dut.uo_out.value
    dut._log.info(f"Input: 0x7B | Output: {output_val}")

    # Check that all bits are 1 (since the 8-bit input is replicated to 64-bit)
    assert output_val == 0xFF

    dut._log.info("✅ SUCCESS: VX-1 identified structural token without 'x' errors!")
