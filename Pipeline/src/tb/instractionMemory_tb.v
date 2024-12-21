`timescale 1ns/1ps
module instractionMemory_tb;

    // Declare testbench signals
    reg [7:0] address;
    reg clock;
    wire [31:0] q;

    // Instantiate the instruction memory module
    instractionMemory uut (
        .address(address),
        .clock(clock),
        .q(q)
    );

    // Clock generation
    always begin
        #5 clock = ~clock;  // Clock period of 10 units
    end

    // Initial block for test sequence
    initial begin
        // Initialize signals
        clock = 0;
        address = 8'b0;

        // Apply test vectors
        #10 address = 8'h00;  // Read from address 0x00
        #10 address = 8'h04;  // Read from address 0x04
        #10 address = 8'h08;  // Read from address 0x08
        #10 address = 8'h0C;  // Read from address 0x0C
        #10 address = 8'h10;  // Read from address 0x10
        #10 address = 8'h14;  // Read from address 0x14

        // Test with an address out of range (expect invalid data or unknown)
        #10 address = 8'hFF;  // Read from address 0xFF

        // End the simulation after a few cycles
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | address=%h | q=%h", $time, address, q);
    end

endmodule
