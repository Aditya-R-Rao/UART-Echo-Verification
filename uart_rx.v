module uart_rx (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire tick,
    output reg [7:0] rx_data,
    output reg rx_done
);
    localparam IDLE = 0,
               START_BIT = 1,
               DATA_BITS = 2,
               STOP_BIT = 3;

    reg [1:0] current_state, next_state;
    reg [3:0] bit_counter;
    reg [7:0] rx_shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            rx_data <= 0;
            rx_done <= 0;
            bit_counter <= 0;
            rx_shift_reg <= 0;
        end else begin
            current_state <= next_state;
            if (rx_done) rx_done <= 0;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (rx == 0 && tick)
                    next_state = START_BIT;
            end
            START_BIT: begin
                if (tick)
                    next_state = DATA_BITS;
            end
            DATA_BITS: begin
                if (tick) begin
                    if (bit_counter < 8) begin
                        rx_shift_reg[bit_counter] = rx;
                        if (bit_counter == 7)
                            next_state = STOP_BIT;
                    end
                end
            end
            STOP_BIT: begin
                if (tick) begin
                    if (rx == 1) begin
                        rx_data = rx_shift_reg;
                        rx_done = 1;
                        next_state = IDLE;
                    end else begin
                        next_state = IDLE;
                    end
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_counter <= 0;
        end else begin
            if (tick) begin
                if (current_state == START_BIT) begin
                    bit_counter <= 0;
                end else if (current_state == DATA_BITS && bit_counter < 8) begin
                    bit_counter <= bit_counter + 1;
                end
            end
        end
    end
endmodule
