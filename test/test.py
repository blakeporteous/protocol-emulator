# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

CLKS_PER_BIT = 434  # must match the parameter in src/project.v


def tx_bit(dut):
    return int(dut.uo_out.value) & 1


async def reset(dut):
    clock = Clock(dut.clk, 20, unit="ns")  # 50 MHz
    cocotb.start_soon(clock.start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


@cocotb.test()
async def test_uart_sends_A(dut):
    await reset(dut)

    # Line idles high
    assert tx_bit(dut) == 1, "TX should idle high"

    # Pulse SEND for one clock cycle
    await RisingEdge(dut.clk)
    dut.ui_in.value = 1
    await RisingEdge(dut.clk)  # design sees SEND here; start bit begins
    dut.ui_in.value = 0

    # Sample in the middle of each bit
    await ClockCycles(dut.clk, CLKS_PER_BIT // 2)
    assert tx_bit(dut) == 0, "start bit should be 0"

    value = 0
    for i in range(8):
        await ClockCycles(dut.clk, CLKS_PER_BIT)
        value |= tx_bit(dut) << i  # least significant bit first
    assert value == 0x41, f"expected 0x41 ('A'), got {value:#04x}"

    await ClockCycles(dut.clk, CLKS_PER_BIT)
    assert tx_bit(dut) == 1, "stop bit should be 1"

    # Back to idle afterwards
    await ClockCycles(dut.clk, CLKS_PER_BIT)
    assert tx_bit(dut) == 1, "TX should return to idle high"
    assert (int(dut.uo_out.value) >> 1) & 1 == 0, "BUSY should be low when idle"
