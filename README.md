# UART-Echo-Verification
UART transceiver with echo loopback — built from scratch in SystemVerilog and verified in Vivado simulation.

A fully custom UART transceiver designed from scratch in SystemVerilog — no IP cores used. Implements baud generation, serial receive, serial transmit, and echo loopback. Verified using a bit-accurate testbench in Vivado simulation.

## Project Structure
UART-Echo-Verification/

├── baud_gen.v

├── uart_rx.v

├── uart_tx.v

├── uart_top.v

├── uart_top_tb.v

├── waveform_screenshot.png

└── README.md

## How It Works

| Module | Role |
|---|---|
| `baud_gen` | Parameterized clock divider — generates 115200 baud tick at 125 MHz |
| `uart_rx` | 4-state FSM receiver — captures 8-bit serial data, LSB first |
| `uart_tx` | 4-state FSM transmitter — serializes and sends with tx_busy handshake |
| `uart_top` | Echo loopback — received byte immediately retransmitted |

## Parameters

| Parameter | Value |
|---|---|
| Clock Frequency | 125 MHz |
| Baud Rate | 115200 |
| Data Bits | 8 |
| Stop Bits | 1 |
| Parity | None |

## Verification

Testbench sends ASCII `'A'` (0x41) and `'B'` (0x42) with bit-accurate timing at 115200 baud. Waveform confirms correct start bit, 8 data bits, stop bit, and echo response. Handshake signals (`rx_done`, `tx_start`, `tx_busy`) verified cycle-by-cycle using `$monitor`.

## Tools Used

- SystemVerilog (RTL + Testbench)
- Xilinx Vivado (Simulation)
- PYNQ-Z2 FPGA (Target board)

## What I Learned

Writing a UART from scratch forces you to think in **bit periods**, not clock cycles. Every FSM transition, every handshake signal, every tick alignment — it has to be reasoned from first principles. That time-domain thinking is the core skill this project built.
