module uart_tx (
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,
    input wire tick,
    output reg tx,
    output reg tx_busy
);
    localparam IDLE = 0,
               START_BIT = 1,
               DATA_BITS = 2,
               STOP_BIT = 3;

    reg [1:0] current_state, next_state;
    reg [3:0] bit_counter;
    reg [7:0] tx_shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            tx <= 1;
            tx_busy <= 0;
            bit_counter <= 0;
            tx_shift_reg <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                tx = 1;
                tx_busy = 0;
                if (tx_start) begin
                    tx_shift_reg = tx_data;
                    next_state = START_BIT;
                end
            end
            START_BIT: begin
                tx = 0;
                tx_busy = 1;
                if (tick) begin
                    next_state = DATA_BITS;
                    bit_counter = 0;
                end
            end
            DATA_BITS: begin
                tx = tx_shift_reg[bit_counter];
                if (tick) begin
                    if (bit_counter == 7) begin
                        next_state = STOP_BIT;
                    end else begin
                        bit_counter = bit_counter + 1;
                    end
                end
            end
            STOP_BIT: begin
                tx = 1;
                if (tick) begin
                    next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
