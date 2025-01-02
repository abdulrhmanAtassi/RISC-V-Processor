`timescale 1ns/1ps

module fetch_stage_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg PCSrcD;
    reg JalD;
    reg [63:0] PCTargetD;
    wire [31:0] InstrD;
    wire [63:0] PCD;
    wire [63:0] PCPlus4D;
    wire [31:0] InstrF;




    // Instantiate the fetch_stage module
    fetch_stage uut (
        .clk(clk),
        .rst(rst),
        .PCSrcD(PCSrcD),
        .JalD(JalD),
        .PCTargetD(PCTargetD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 ns
    end

    // Initial block for simulation setup
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;  // Start with reset active
        PCSrcD = 0;
        JalD = 0;
        PCTargetD = 64'h00000000;

        // Release reset after some time
        #30 rst = 0;

        // Test a simple PC increment (PC + 4)
        #10 PCSrcD = 0; JalD = 0; PCTargetD = 64'h00000004;  // PC should increment by 4
        #10 PCSrcD = 0; JalD = 0; PCTargetD = 64'h00000004;  // Continue incrementing

        // Test a jump (JalD = 1)
        #10 PCSrcD = 0; JalD = 1; PCTargetD = 64'h00000020;  // Jump to address 0x20
        #10 PCSrcD = 0; JalD = 1; PCTargetD = 64'h00000020;  // Continue jump

        // Test a branch (PCSrcD = 1)
        #10 PCSrcD = 1; JalD = 0; PCTargetD = 64'h00000010;  // Branch to address 0x10

        // End simulation
        #20 $finish;
    end

    // Monitoring output (optional, for debugging)
    initial begin
        $monitor("Time=%t | clk=%b | rst=%b | PCSrcD=%b | JalD=%b | PCTargetD=%h | InstrD=%h | PCD=%h | PCPlus4D=%h",
                    $time, clk, rst, PCSrcD, JalD, PCTargetD, InstrD, PCD, PCPlus4D);
    end

endmodule