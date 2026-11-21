// Simple UART transmitter: 8 data bits, no parity, 1 stop bit (8N1).
// CLKS_PER_BIT = clock_hz / baud, e.g. 50_000_000 / 115200 ~= 434.
`default_nettype none

module uart_tx #(
    parameter CLKS_PER_BIT = 434
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,   // pulse high for one clock to send `data`
    input  wire [7:0] data,
    output reg        tx,      // serial line, idles high
    output reg        busy     // high while a byte is being sent
);
    reg [9:0]  shreg;          // {stop, data[7:0], start}
    reg [3:0]  bitcnt;
    reg [15:0] clkcnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            tx     <= 1'b1;
            busy   <= 1'b0;
            bitcnt <= 4'd0;
            clkcnt <= 16'd0;
            shreg  <= 10'h3FF;
        end else if (!busy) begin
            if (start) begin
                shreg  <= {1'b1, data, 1'b0};
                busy   <= 1'b1;
                bitcnt <= 4'd0;
                clkcnt <= 16'd0;
                tx     <= 1'b0;            // start bit
            end
        end else if (clkcnt == CLKS_PER_BIT - 1) begin
            clkcnt <= 16'd0;
            if (bitcnt == 4'd9) begin
                busy <= 1'b0;              // stop bit finished
                tx   <= 1'b1;
            end else begin
                tx     <= shreg[bitcnt + 4'd1];
                bitcnt <= bitcnt + 4'd1;
            end
        end else begin
            clkcnt <= clkcnt + 16'd1;
        end
    end
endmodule
