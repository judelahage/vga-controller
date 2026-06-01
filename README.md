<h1 align="center">VGA Display Controller</h1>

<p align="center">
  A <b>640 × 480 @ 60 Hz VGA controller</b> written in Verilog for the
  <b>Digilent Basys 3</b> (AMD/Xilinx Artix-7 FPGA).
</p>

---

## Overview

This design generates standard **VGA timing** and drives a monitor at **640 × 480, 60 Hz** from the Basys 3's 100 MHz system clock. Inside the visible area it outputs a solid color chosen by the board's **12 slide switches** — 4 bits each for red, green, and blue, matching the Basys 3's 12-bit VGA DAC.

## How it works

- **Pixel clock** — the 100 MHz input is divided by 4 to produce the **25 MHz** pixel tick that 640 × 480 VGA expects.
- **Counters** — horizontal and vertical counters sweep an **800 × 525** pixel field (visible area + porches + sync) and generate `hsync` / `vsync`.
- **Video-on** — RGB is driven only inside the 640 × 480 visible region and blanked everywhere else.

| | Visible | Front porch | Sync pulse | Back porch | Total |
|---|---|---|---|---|---|
| **Horizontal** | 640 | 16 | 96 | 48 | 800 |
| **Vertical** | 480 | 10 | 2 | 33 | 525 |

## Files

| File | Purpose |
|---|---|
| `vga_controller.v` | Timing generator — counters, `hsync`/`vsync`, pixel tick, and `(x, y)` pixel coordinates |
| `vga_top.v` | Top module — maps the 12 switches to 12-bit RGB within the active area |
| `const_vga.xdc` | Basys 3 pin constraints (clock, switches, VGA connector, reset) |

## Build & run (Vivado)

1. Create a Vivado project targeting the Basys 3 — part `xc7a35tcpg236-1`.
2. Add `vga_controller.v`, `vga_top.v`, and `const_vga.xdc`.
3. Set **`vga_top`** as the top module, generate the bitstream, and program the board.
4. Connect a monitor to the VGA port and flip the switches to change the on-screen color. The **center button** is reset.

## Pinout (Basys 3)

- **Clock** — `clk_100MHz` → `W5` (100 MHz)
- **Switches** — `sw[11:0]` → the 12 slide switches (selects the RGB color)
- **VGA** — `rgb[11:0]` → VGA connector, `hsync` → `P19`, `vsync` → `R19`
- **Reset** — center button → `U18`

## Reference

The VGA timing approach follows Pong P. Chu's *FPGA Prototyping by Verilog Examples*, adapted to the Basys 3.
