`timescale 1ns / 1ps

module tb_pipelined_processor;

    // Clock and Reset signals
    reg clk;
    reg reset;

    // Instantiate the top-level pipelined processor module
    pipelined_processor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    // Simulation control
    initial begin
        // Initialize signals
        reset = 1;

        // Apply reset for a few cycles
        #20;
        reset = 0;

        // Add additional test stimuli here if required

        // Run simulation for a specific duration
        #200;
        $stop; // End simulation
    end

    // Optional: Monitor signals for debugging
    initial begin
        $monitor("Time: %0t | Reset: %b | Clock: %b", $time, reset, clk);
    end

endmodule
