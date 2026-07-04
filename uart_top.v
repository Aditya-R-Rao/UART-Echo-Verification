module uart_top (
    input wire clk,
    input wire rst,
    input wire uart_rx_pin,
    output wire uart_tx_pin
);
    wire tick;
    wire [7:0] rx_data;
    wire rx_done;
    reg [7:0] tx_data;
    reg tx_start = 0;
    wire tx_busy;

    baud_gen #(
        .CLK_FREQ(125_000_000),
        .BAUD_RATE(115200)
    ) baud_inst (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );
    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(uart_rx_pin),
        .tick(tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tick(tick),
        .tx(uart_tx_pin),
        .tx_busy(tx_busy)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 0;
            tx_data <= 0;
        end else begin
            if (rx_done && !tx_busy) begin
                tx_data <= rx_data;
                tx_start <= 1;
            end else begin
                tx_start <= 0;
            end
        end
    end
endmodule
