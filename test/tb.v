# SPDX-FileCopyrightText: © 2024 Niranjan Ariyawansha
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start VX-1 JSON Accelerator Test")

    # 1. Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # 2. Reset the Core
    dut._log.info("Resetting the chip...")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Testing Voxel Core One behavior...")

    # TEST 1: Identify structural character '{' (Hex 0x7B)
    # The VX-1 replicates this 8-bit input to all 64 bits of the internal bus.
    dut.ui_in.value = 0x7B
    await ClockCycles(dut.clk, 1)
    
    # Since '{' is a structural element, the bitmap should flag all 8 bytes.
    # Expected output: 11111111 in binary (0xFF in Hex).
    dut._log.info(f"Input: {{ (0x7B) | Output: {hex(int(dut.uo_out.value))}")
    assert dut.uo_out.value == 0xFF

    # TEST 2: Identify structural character ':' (Hex 0x3A)
    dut.ui_in.value = 0x3A
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0xFF

    # TEST 3: Ignore non-structural character 'A' (Hex 0x41)
    dut.ui_in.value = 0x41
    await ClockCycles(dut.clk, 1)
    
    # 'A' is not structural, so the output bitmap should be empty.
    # Expected output: 0x00.
    dut._log.info(f"Input: A (0x41) | Output: {hex(int(dut.uo_out.value))}")
    assert dut.uo_out.value == 0x00

    dut._log.info("✅ All VX-1 core tests passed!")
