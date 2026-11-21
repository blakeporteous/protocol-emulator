## How it works

A UART transmitter: when SEND (ui[0]) goes high it sends the letter "A" on TX (uo[0]) at 115200 baud (8N1, 50 MHz clock).

## How to test

Pulse SEND (ui[0]) high for one clock after reset and read TX (uo[0]).

## External hardware

None.
