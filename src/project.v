/*
 * Copyright (c) 2026 Blake Porteous
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_blakeporteous_protocol_emulator (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Stage 1 scaffolding: a hard-wired UART that sends the letter "A"
  // whenever ui_in[0] (SEND) is high and the transmitter is idle.
  wire tx;
  wire busy;

  uart_tx #(
      .CLKS_PER_BIT(434)  // 50 MHz / 115200 baud
  ) u_uart_tx (
      .clk  (clk),
      .rst_n(rst_n),
      .start(ui_in[0]),
      .data (8'h41),
      .tx   (tx),
      .busy (busy)
  );

  assign uo_out  = {6'b000000, busy, tx};  // uo[0] = TX, uo[1] = BUSY
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule
