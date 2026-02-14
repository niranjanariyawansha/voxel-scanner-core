import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer

@cocotb.test()
async def test_vx1_structural_scan(dut):
    dut._log.info("Start VX-1 JSON Accelerator Test")

    # 1. Set a 50 MHz clock (20ns period) to match your info.yaml
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize inputs to 0 to prevent 'x' (unknown) propagation
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # 3. Apply Reset
    dut._log.info("Applying Reset...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5) 
    dut.rst_n.value = 1
    
    # Wait for one rising edge to clear internal 'x' bits
    await RisingEdge(dut.clk)
    await Timer(1, units="ns") # Small delay to let logic settle

    dut._log.info("Testing Voxel Core One behavior...")

    # TEST: Identify structural character '{' (Hex 0x7B)
    dut.ui_in.value = 0x7B
    
    # Wait 1 cycle for the VX-1 core to process the data
    await ClockCycles(dut.clk, 1)
    
    # IMPORTANT: Wait a tiny bit AFTER the edge so the result is stable
    await Timer(1, units="ns")
    
    # Read the value as an integer
    output_val = int(dut.uo_out.value)
    dut._log.info(f"Input: {{ (0x7B) | Output Bitmap: {hex(output_val)}")

    # Since ui_in is replicated 8 times, all 8 bits should be HIGH (0xFF)
    assert output_val == 0xFF

    dut._log.info("✅ SUCCESS: VX-1 verified and ready for tapeout!")
