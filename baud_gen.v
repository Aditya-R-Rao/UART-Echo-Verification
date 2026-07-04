module baud_gen #(
    parameter CLK_FREQ = 125_000_000, // Clock frequency in Hz
    parameter BAUD_RATE = 115200    // Baud rate in bps
) (
    input wire clk,
    input wire rst,
    output reg tick
);
    localparam BAUD_CNT_MAX = (CLK_FREQ / BAUD_RATE) - 1;
    localparam CNT_WIDTH = $clog2(BAUD_CNT_MAX + 1);

    reg [CNT_WIDTH-1:0] baud_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
            tick <= 0;
        end else begin
            if (baud_counter == BAUD_CNT_MAX) begin
                baud_counter <= 0;
                tick <= 1;
            end else begin
                baud_counter <= baud_counter + 1;
                tick <= 0;
            end
        end
    end
endmodule

