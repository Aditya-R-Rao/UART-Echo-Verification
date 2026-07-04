`timescale 1ns / 1ps // Define timescale for simulation

module uart_top_tb;

    // Clock and Reset parameters
    parameter CLK_PERIOD = 8; // 125 MHz clock -> 1/125MHz = 8ns period
    parameter RST_DELAY = 100; // Reset duration in ns

    // UART parameters (match with baud_gen parameters)
    parameter BAUD_RATE = 115200;
    localparam BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE; // 1 second in ns / baud rate
    localparam HALF_BIT_PERIOD_NS = BIT_PERIOD_NS / 2;

    // Testbench signals
    reg clk;
    reg rst;
    reg uart_rx_pin;
    wire uart_tx_pin;

    // Instantiate the top-level module
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .uart_rx_pin(uart_rx_pin),
        .uart_tx_pin(uart_tx_pin)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Reset Sequence
    initial begin
        rst = 1;
        uart_rx_pin = 1; // Keep RX idle high
        #(RST_DELAY);
        rst = 0;
        $display("Reset complete. Waiting for RX data...");
    end

    // Stimulus for uart_rx_pin (sending ASCII 'A' = 8'h41)
    initial begin
        @(negedge rst);
        #200; // Wait for some idle time after reset

        // --- Transmit character 'A' (8'h41 = 0100_0001) ---
        $display("Sending character 'A' (0x41)...");
        uart_rx_pin = 1; // Ensure idle high

        // Start bit
        #(HALF_BIT_PERIOD_NS); // Sync to middle of bit for simpler simulation
        uart_rx_pin = 0; // Start bit (low)
        #(BIT_PERIOD_NS);

        // Data bits (LSB first: 1,0,0,0,0,1,0,0)
        uart_rx_pin = 1; // D0 = 1
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D1 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D2 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D3 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D4 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 1; // D5 = 1
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D6 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D7 = 0
        #(BIT_PERIOD_NS);

        // Stop bit
        uart_rx_pin = 1; // Stop bit (high)
        #(BIT_PERIOD_NS * 2);

        $display("Finished sending 'A'. Waiting for echo...");

        // --- Transmit character 'B' (8'h42 = 0100_0010) -
        #50000; // Wait a bit before sending next char
        $display("Sending character 'B' (0x42)...");
        uart_rx_pin = 1; // Ensure idle high

        // Start bit
        #(HALF_BIT_PERIOD_NS);
        uart_rx_pin = 0; // Start bit (low)
        #(BIT_PERIOD_NS);

        // Data bits (LSB first: 0,1,0,0,0,0,1,0)
        uart_rx_pin = 0; // D0 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 1; // D1 = 1
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D2 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D3 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D4 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D5 = 0
        #(BIT_PERIOD_NS);
        uart_rx_pin = 1; // D6 = 1
        #(BIT_PERIOD_NS);
        uart_rx_pin = 0; // D7 = 0
        #(BIT_PERIOD_NS);

        // Stop bit
        uart_rx_pin = 1;
        #(BIT_PERIOD_NS * 2);

        $display("Simulation finished.");
        #1000;
       
    end

    // Monitor for debugging (optional)
    initial begin
        $monitor("Time: %0t, clk: %b, rst: %b, rx_pin: %b, tx_pin: %b, tick: %b, rx_data: %h, rx_done: %b, tx_start: %b, tx_busy: %b",
                 $time, clk, rst, uart_rx_pin, uart_tx_pin, uut.tick, uut.rx_data, uut.rx_done, uut.tx_start, uut.tx_busy);
    
    end

endmodule

