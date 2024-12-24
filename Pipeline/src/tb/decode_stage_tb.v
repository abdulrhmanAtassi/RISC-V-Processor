`timescale 1ns / 1ps

module decode_stage_tb;

    // Inputs to decode_stage
    reg clk;
    reg rst;
    reg RegWriteEnW;
    reg [4:0] RDW;
    reg [31:0] InstrD;
    reg signed [63:0] ResultW;
    reg [63:0] PCD;
    reg [63:0] PCPlus4D;

    // Outputs from decode_stage
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
    wire signed [63:0] ImmE;
    wire signed [63:0] ReadData1E;
    wire signed [63:0] ReadData2E;
    wire [63:0] PCPlus4E;
    wire [63:0] PCTargetD;

    // Instantiate the decode_stage
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
        forever #5 clk = ~clk; // 10ns period
    end

    // Initialize and apply test vectors
    initial begin
    
        // Initialize Inputs
        rst = 1;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        PCD = 64'd0;
        PCPlus4D = 64'd4;
        InstrD = 32'd0;

        // Initialize Dump for Waveform Viewing
        // $dumpfile("decode_stage_tb.vcd");
        // $dumpvars(0, decode_stage_tb);
        
        // // Apply reset
        #10;
        rst = 0;
        repeat (5) @(posedge clk);
        // Wait for a clock edge
        // @(posedge clk);

        // Test Case 1: ADD instruction
        // Encoding for ADD (R-type): opcode=0110011, funct3=000, funct7=0000000
        //InstrD = 32'b0000001_00010_00001_000_00011_0110011; // add x3, x1, x2
        InstrD = 32'b000000000101_00001_000_00100_0010011; // addi x4, x1, 5
        PCD = 64'h0000000000000000;
        PCPlus4D = 64'h0000000000000004;
        RegWriteEnW = 1;
        RDW = 5'd3;
        ResultW = 64'd15; // Assume x3 = 15
        @(posedge clk);

        // Test Case 2: ADDI instruction
        // Encoding for ADDI (I-type): opcode=0010011, funct3=000
        InstrD = 32'b000000000101_00001_000_00100_0010011; // addi x4, x1, 5
        PCD = 64'h0000000000000004;
        PCPlus4D = 64'h0000000000000008;
        RegWriteEnW = 1;
        RDW = 5'd4;
        ResultW = 64'd20; // Assume x4 = 20
        #10;

        // Test Case 3: AND instruction
        // Encoding for AND (R-type): opcode=0110011, funct3=111, funct7=0000000
        InstrD = 32'b0000000_00011_00010_111_00101_0110011; // and x5, x2, x3
        PCD = 64'h0000000000000008;
        PCPlus4D = 64'h000000000000000C;
        RegWriteEnW = 1;
        RDW = 5'd5;
        ResultW = 64'd10; // Assume x5 = 10
        #10;

        // Test Case 4: ANDI instruction
        // Encoding for ANDI (I-type): opcode=0010011, funct3=111
        InstrD = 32'b000000000011_00010_111_00110_0010011; // andi x6, x2, 3
        PCD = 64'h000000000000000C;
        PCPlus4D = 64'h0000000000000010;
        RegWriteEnW = 1;
        RDW = 5'd6;
        ResultW = 64'd2; // Assume x6 = 2
        #10;

        // Test Case 5: BEQ instruction
        // Encoding for BEQ (SB-type): opcode=1100011, funct3=000
        InstrD = 32'b0000000_00010_00011_000_00010_1100011; // beq x2, x3, offset
        PCD = 64'h0000000000000010;
        PCPlus4D = 64'h0000000000000014;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        #10;

        // Test Case 6: BNE instruction
        // Encoding for BNE (SB-type): opcode=1100011, funct3=001
        InstrD = 32'b0000000_00100_00011_001_00001_1100011; // bne x4, x3, offset
        PCD = 64'h0000000000000014;
        PCPlus4D = 64'h0000000000000018;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        #10;

        // Test Case 7: JAL instruction
        // Encoding for JAL (UJ-type): opcode=1101111
        InstrD = 32'b000000000001_00010_00000_000000000000_1101111; // jal x0, offset
        PCD = 64'h0000000000000018;
        PCPlus4D = 64'h000000000000001C;
        RegWriteEnW = 1;
        RDW = 5'd0;
        ResultW = 64'd24; // Assume PC+4 = 24
        #10;

        // Test Case 8: JALR instruction
        // Encoding for JALR (I-type): opcode=1100111, funct3=000
        InstrD = 32'b000000000010_00001_000_00011_1100111; // jalr x3, x1, 2
        PCD = 64'h000000000000001C;
        PCPlus4D = 64'h0000000000000020;
        RegWriteEnW = 1;
        RDW = 5'd3;
        ResultW = 64'd28; // Assume PC+4 = 28
        #10;

        // Test Case 9: LH instruction
        // Encoding for LH (I-type): opcode=0000011, funct3=001
        InstrD = 32'b000000000011_00001_001_00100_0000011; // lh x4, 3(x1)
        PCD = 64'h0000000000000020;
        PCPlus4D = 64'h0000000000000024;
        RegWriteEnW = 1;
        RDW = 5'd4;
        ResultW = 64'd50; // Assume x4 = 50
        #10;

        // Test Case 10: LUI instruction
        // Encoding for LUI (U-type): opcode=0110111
        InstrD = 32'b00000000000000000001_0110111; // lui x1, imm
        PCD = 64'h0000000000000024;
        PCPlus4D = 64'h0000000000000028;
        RegWriteEnW = 1;
        RDW = 5'd1;
        ResultW = 64'h0000000000010000; // Assume imm shifted
        #10;

        // Test Case 11: LW instruction
        // Encoding for LW (I-type): opcode=0000011, funct3=010
        InstrD = 32'b000000000100_00010_010_00101_0000011; // lw x5, 4(x2)
        PCD = 64'h0000000000000028;
        PCPlus4D = 64'h000000000000002C;
        RegWriteEnW = 1;
        RDW = 5'd5;
        ResultW = 64'd100; // Assume x5 = 100
        #10;

        // Test Case 12: XOR instruction
        // Encoding for XOR (R-type): opcode=0110011, funct3=100, funct7=0000000
        InstrD = 32'b0000000_00101_00010_100_00110_0110011; // xor x6, x2, x5
        PCD = 64'h000000000000002C;
        PCPlus4D = 64'h0000000000000030;
        RegWriteEnW = 1;
        RDW = 5'd6;
        ResultW = 64'd15; // Assume x6 = 15
        #10;

        // Test Case 13: OR instruction
        // Encoding for OR (R-type): opcode=0110011, funct3=110, funct7=0000000
        InstrD = 32'b0000000_00110_00010_110_00111_0110011; // or x7, x2, x6
        PCD = 64'h0000000000000030;
        PCPlus4D = 64'h0000000000000034;
        RegWriteEnW = 1;
        RDW = 5'd7;
        ResultW = 64'd15; // Assume x7 = 15
        #10;

        // Test Case 14: ORI instruction
        // Encoding for ORI (I-type): opcode=0010011, funct3=110
        InstrD = 32'b000000000111_00010_110_01000_0010011; // ori x8, x2, 7
        PCD = 64'h0000000000000034;
        PCPlus4D = 64'h0000000000000038;
        RegWriteEnW = 1;
        RDW = 5'd8;
        ResultW = 64'd7; // Assume x8 = 7
        #10;

        // Test Case 15: SLT instruction
        // Encoding for SLT (R-type): opcode=0110011, funct3=010, funct7=0000000
        InstrD = 32'b0000000_00111_00010_010_01000_0110011; // slt x8, x2, x7
        PCD = 64'h0000000000000038;
        PCPlus4D = 64'h000000000000003C;
        RegWriteEnW = 1;
        RDW = 5'd8;
        ResultW = 64'd1; // Assume x8 = 1
        #10;

        // Test Case 16: SLL instruction
        // Encoding for SLL (R-type): opcode=0110011, funct3=001, funct7=0000000
        InstrD = 32'b0000000_01000_00010_001_01001_0110011; // sll x9, x2, x8
        PCD = 64'h000000000000003C;
        PCPlus4D = 64'h0000000000000040;
        RegWriteEnW = 1;
        RDW = 5'd9;
        ResultW = 64'd256; // Assume x9 = x2 << x8
        #10;

        // Test Case 17: SRL instruction
        // Encoding for SRL (R-type): opcode=0110011, funct3=101, funct7=0000000
        InstrD = 32'b0000000_01001_00010_101_01010_0110011; // srl x10, x2, x9
        PCD = 64'h0000000000000040;
        PCPlus4D = 64'h0000000000000044;
        RegWriteEnW = 1;
        RDW = 5'd10;
        ResultW = 64'd1; // Assume x10 = x2 >> x9
        #10;

        // Test Case 18: SB instruction
        // Encoding for SB (S-type): opcode=0100011, funct3=000
        InstrD = 32'b0000000_01010_00010_000_01011_0100011; // sb x10, 0(x2)
        PCD = 64'h0000000000000044;
        PCPlus4D = 64'h0000000000000048;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        #10;

        // Test Case 19: SW instruction
        // Encoding for SW (S-type): opcode=0100011, funct3=010
        InstrD = 32'b0000000_01011_00010_010_01100_0100011; // sw x11, 0(x2)
        PCD = 64'h0000000000000048;
        PCPlus4D = 64'h000000000000004C;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        #10;

        // Test Case 20: SUB instruction
        // Encoding for SUB (R-type): opcode=0110011, funct3=000, funct7=0100000
        InstrD = 32'b0100000_01100_00010_000_01101_0110011; // sub x13, x2, x12
        PCD = 64'h000000000000004C;
        PCPlus4D = 64'h0000000000000050;
        RegWriteEnW = 1;
        RDW = 5'd13;
        ResultW = 64'd5; // Assume x13 = x2 - x12
        #10;

        // Finish simulation
        #20;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | InstrD=%h | RegWriteEnE=%b | MemtoRegE=%b | JALE=%b | MemReadEnE=%b | MemWriteEnE=%b | ALUOpE=%b | ALUSrcE=%b | RdE=%d | ImmD=%h | ImmE=%h | PCTargetD=%h",
                $time, InstrD, RegWriteEnE, MemtoRegE, JALE, MemReadEnE, MemWriteEnE, ALUOpE, ALUSrcE, RdE,uut.dut.ImmSrc ,  ImmE, PCTargetD);
    end

endmodule
