`timescale 1ns/1ps

module decode_stage_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] InstrD;
    reg [63:0] PCD;
    reg [63:0] PCPlus4D;
    reg RegWriteEnW;
    reg [4:0] RDW;
    reg [63:0] ResultW;

    // Outputs
    wire RegWriteEnE;
    wire MemtoRegE;
    wire JALE;
    wire MemReadEnE;
    wire MemWriteEnE;
    wire PCSF;
    wire ALUSrcE;
    wire [1:0] MemSizeE;
    wire [1:0] LoadSizeE;
    wire [2:0] ALUOpE;
    wire [4:0] RdE;
    wire [63:0] ImmE;
    wire [63:0] ReadData1E;
    wire [63:0] ReadData2E;
    wire [63:0] PCPlus4E;
    wire [63:0] PCTargetD;

    // Instantiate the decode_stage module
    decode_stage uut (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteEnW(RegWriteEnW),
        .RDW(RDW),
        .ResultW(ResultW),
        .RegWriteEnE(RegWriteEnE),
        .MemtoRegE(MemtoRegE),
        .JALE(JALE),
        .MemReadEnE(MemReadEnE),
        .MemWriteEnE(MemWriteEnE),
        .ALUOpE(ALUOpE),
        .ALUSrcE(ALUSrcE),
        .MemSizeE(MemSizeE),
        .LoadSizeE(LoadSizeE),
        .PCSF(PCSF),
        .ImmE(ImmE),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E),
        .PCTargetD(PCTargetD)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        rst = 1;
        InstrD = 32'b0;
        PCD = 64'b0;
        PCPlus4D = 64'b0;
        RegWriteEnW = 0;
        RDW = 5'b0;
        ResultW = 64'b0;

        // Reset the module
        #10 rst = 0;

        // Test case 1: Load instruction
        InstrD = 32'b00000000000100000000000010000011; // Example load instruction
        PCD = 64'h0000000000000040;
        PCPlus4D = 64'h0000000000000044;
        RegWriteEnW = 1;
        RDW = 5'b00001;
        ResultW = 64'h0000000000001234;
        #10;

        // Display output after test case 1
        $display("Test case 1: Load instruction");
        $display("RegWriteEnE = %b, MemtoRegE = %b, JALE = %b, MemReadEnE = %b", 
                 RegWriteEnE, MemtoRegE, JALE, MemReadEnE);
        $display("PC = %h, ImmE = %h, ReadData1E = %h", PCD, ImmE, ReadData1E);
        $display("----------------------------");

        // Test case 2: Branch instruction
        InstrD = 32'b00000000010000010000001101100011; // Example branch instruction
        #10;

        // Display output after test case 2
        $display("Test case 2: Branch instruction");
        $display("RegWriteEnE = %b, MemtoRegE = %b, JALE = %b, MemReadEnE = %b", 
                 RegWriteEnE, MemtoRegE, JALE, MemReadEnE);
        $display("PC = %h, ImmE = %h, ReadData1E = %h", PCD, ImmE, ReadData1E);
        $display("----------------------------");

        // Test case 3: JAL instruction
        InstrD = 32'b00000000000100000000000011101111; // Example JAL instruction
        #10;

        // Display output after test case 3
        $display("Test case 3: JAL instruction");
        $display("RegWriteEnE = %b, MemtoRegE = %b, JALE = %b, MemReadEnE = %b", 
                 RegWriteEnE, MemtoRegE, JALE, MemReadEnE);
        $display("PC = %h, ImmE = %h, ReadData1E = %h", PCD, ImmE, ReadData1E);
        $display("----------------------------");

        // Test case 4: Reset signal
        rst = 1;
        #10 rst = 0;

        // Test case 5: Random instruction
        InstrD = 32'b11111111111111111111111111111111; // Example random instruction
        #10;

        // Display output after test case 5
        $display("Test case 5: Random instruction");
        $display("RegWriteEnE = %b, MemtoRegE = %b, JALE = %b, MemReadEnE = %b", 
                 RegWriteEnE, MemtoRegE, JALE, MemReadEnE);
        $display("PC = %h, ImmE = %h, ReadData1E = %h", PCD, ImmE, ReadData1E);
        $display("----------------------------");

        // End simulation
        $stop;
    end

endmodule
