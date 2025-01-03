`timescale 1ns / 1ps

module memory_stage_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg RegWriteEnM;
    reg MemtoRegM;
    reg JALM;
    reg MemReadEnM;
    reg MemWriteEnM;
    reg [1:0] MemSizeM;
    reg [1:0] LoadSizeM;
    reg [4:0] RdM;
    reg [63:0] PcPlus4M;
    reg [63:0] ReadData2M;
    reg [63:0] ALUResultM;

    wire RegWriteEnW;
    wire MemtoRegW;
    wire JALW;
    wire [63:0] PcPlus4W;
    wire [63:0] ALUResultW;
    wire [63:0] ReadDataW;
    wire [4:0] RdW;

    // Instantiate the DUT (Device Under Test)
    memory_stage dut (
        .clk(clk),
        .rst(rst),
        .RegWriteEnM(RegWriteEnM),
        .MemtoRegM(MemtoRegM),
        .JALM(JALM),
        .MemReadEnM(MemReadEnM),
        .MemWriteEnM(MemWriteEnM),
        .MemSizeM(MemSizeM),
        .LoadSizeM(LoadSizeM),
        .RdM(RdM),
        .PcPlus4M(PcPlus4M),
        .ReadData2M(ReadData2M),
        .ALUResultM(ALUResultM),
        .RegWriteEnW(RegWriteEnW),
        .MemtoRegW(MemtoRegW),
        .JALW(JALW),
        .PcPlus4W(PcPlus4W),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        RegWriteEnM = 0;
        MemtoRegM = 0;
        JALM = 0;
        MemReadEnM = 0;
        MemWriteEnM = 0;
        MemSizeM = 2'b00;
        LoadSizeM = 2'b00;
        RdM = 5'b00000;
        PcPlus4M = 64'b0;
        ReadData2M = 64'b0;
        ALUResultM = 64'b0;

        // Apply reset
        #20 rst = 0;

        // Test case 1: Write 1 byte (SB)
        MemWriteEnM = 1;
        MemSizeM = 2'b00; // SB
        ALUResultM = 64'h0000000000000010; // Address
        ReadData2M = 64'h00000000000000AA; // Data to write
        #20;

        // Test case 2: Write 2 bytes (SH)
        MemSizeM = 2'b01; // SH
        ALUResultM = 64'h0000000000000020; // Address
        ReadData2M = 64'h000000000000AABB; // Data to write
        #20;

        // Test case 3: Write 4 bytes (SW)
        MemSizeM = 2'b10; // SW
        ALUResultM = 64'h0000000000000030; // Address
        ReadData2M = 64'h00000000AABBCCDD; // Data to write
        #20;

        // Test case 4: Read 1 byte (LB)
        MemWriteEnM = 0;
        MemReadEnM = 1;
        LoadSizeM = 2'b00; // LB
        ALUResultM = 64'h0000000000000010; // Address
        #20;

        // Test case 5: Read 2 bytes (LH)
        LoadSizeM = 2'b01; // LH
        ALUResultM = 64'h0000000000000020; // Address
        #20;

        // Test case 6: Read 4 bytes (LW)
            LoadSizeM = 2'b10; // LW
            ALUResultM = 64'h0000000000000030; // Address
        #20;
        #20
        // End simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0dns, RegWriteEnW=%b, MemtoRegW=%b, JALW=%b, PcPlus4W=%h, ALUResultW=%h, ReadDataW=%h, RdW=%b",
            $time, RegWriteEnW, MemtoRegW, JALW, PcPlus4W, ALUResultW, ReadDataW, RdW);
    end

endmodule
