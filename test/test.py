import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

@cocotb.test()
async def test_vx1_structural_scan(dut):
    dut._log.info("Start VX-1 JSON Accelerator Test")

    # 1. Set a 50 MHz clock (20ns period) to match your info.yaml
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize inputs to 0 to prevent 'x' propagation
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # 3. Reset the Core
    dut._log.info("Applying Reset...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5) 
    dut.rst_n.value = 1
    
    # IMPORTANT: Wait for one rising edge so the reset values 
    # are actually latched into the registers, clearing 'x' bits.
    await RisingEdge(dut.clk)

    dut._log.info("Testing Voxel Core One behavior...")

    # TEST: Identify structural character '{' (Hex 0x7B)
    dut.ui_in.value = 0x7B
    
    # Wait 1 cycle for the data to be processed 
    await ClockCycles(dut.clk, 1)
    
    # We use .value.integer to ensure we aren't reading 'x' strings
    output_val = int(dut.uo_out.value)
    dut._log.info(f"Input: 0x7B | Output: {hex(output_val)}")

    # Check that all bits are 1 (input is replicated to 64-bit internally)
    assert output_val == 0xFF

    dut._log.info("✅ SUCCESS: VX-1 verified without 'x' errors!")
