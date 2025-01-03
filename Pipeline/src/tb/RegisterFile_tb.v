`timescale 1ns / 1ps

module RegisterFile_tb;

    // Testbench signals
    reg clk;
    reg rst;                // Reset signal
    reg [4:0] ReadRegister1;
    reg [4:0] ReadRegister2;
    reg [4:0] WriteRegister;
    reg [63:0] WriteData;
    reg WriteEnable;
    wire signed [63:0] ReadData1;
    wire signed [63:0] ReadData2;

    // Instantiate the RegisterFile module
    RegisterFile uut (
        .clk(clk),
        .rst(rst),          // Connect reset
        .ReadRegister1(ReadRegister1),
        .ReadRegister2(ReadRegister2),
        .WriteRegister(WriteRegister),
        .WriteData(WriteData),
        .WriteEnable(WriteEnable),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Generate clock signal
    initial clk = 0;
    always #5 clk = ~clk; // 10 time units clock period

    // Test procedure
    initial begin
        // Apply reset
        rst = 1;  // Activate reset
        #10;      // Wait for a few clock cycles
        rst = 0;  // Deactivate reset

        // Initialize inputs
        ReadRegister1 = 5'b0;
        ReadRegister2 = 5'b0;
        WriteRegister = 5'b0;
        WriteData = 64'b0;
        WriteEnable = 1'b0;

        // Wait for global reset
        #10;

        // Test write to register 1
        WriteRegister = 5'd1;    // Write to register 1
        WriteData = 64'd42;      // Data to write
        WriteEnable = 1'b1;      // Enable write
        #10;                     // Wait for clock edge

        // Test read from registers
        WriteEnable = 1'b0;      // Disable write
        ReadRegister1 = 5'd1;    // Read register 1
        ReadRegister2 = 5'd0;    // Read register 0 (should be 0)
        #10;

        // Check another write
        WriteRegister = 5'd2;    // Write to register 2
        WriteData = -64'd15;     // Negative data
        WriteEnable = 1'b1;
        #10;

        // Test read from multiple registers
        WriteEnable = 1'b0;
        ReadRegister1 = 5'd1;    // Register 1
        ReadRegister2 = 5'd2;    // Register 2
        #10;

        // Attempt to write to register 0 (should not write)
        WriteRegister = 5'd0;    // Register 0
        WriteData = 64'd100;     // Data
        WriteEnable = 1'b1;
        #10;

        // Test reading register 0 (should still be 0)
        WriteEnable = 1'b0;
        ReadRegister1 = 5'd0;
        #10;

        // Test WriteEnable = 0 (should not write)
        WriteRegister = 5'd3;
        WriteData = 64'd99;
        WriteEnable = 1'b0;     // Disable writing
        #10;

        // Check if register 3 has not been written (should be 0)
        ReadRegister1 = 5'd3;    // Register 3 (should be 0)
        #10;

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | ReadRegister1: %0d | ReadData1: %0d | ReadRegister2: %0d | ReadData2: %0d | WriteRegister: %0d | WriteData: %0d | WriteEnable: %b",
                $time, ReadRegister1, ReadData1, ReadRegister2, ReadData2, WriteRegister, WriteData, WriteEnable);
    end

endmodule
