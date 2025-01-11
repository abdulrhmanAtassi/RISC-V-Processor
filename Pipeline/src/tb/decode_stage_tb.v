`timescale 1ns / 1ps

module decode_stage_tb;

    // Inputs to decode_stage
    reg clk;
    reg rst;
    reg [31:0] InstrD;       // Instruction fetched
    reg [63:0] PCD;          // Current PC
    reg [63:0] PCPlus4D;     // PC + 4 from fetch stage
    reg RegWriteEnW;         // Writeback enable signal
    reg [4:0] RDW;           // Destination register for writeback
    reg [63:0] ResultW;      // Writeback data
    reg MemReadEnBE;         // Memory read enable signal from execute
    reg [4:0] RdBE;          // Rd for memory stage hazard detection

    // Outputs from decode_stage
    wire RegWriteEnE;
    wire MemtoRegE;
    wire JALE;
    wire MemReadEnE;
    wire MemWriteEnE;
    wire [2:0] ALUOpE;
    wire ALUSrcE;
    wire [1:0] MemSizeE;
    wire [1:0] LoadSizeE;
    wire PCSF;
    wire [63:0] ImmE;
    wire [4:0] RdE;
    wire [4:0] Rs1E;
    wire [4:0] Rs2E;
    wire [63:0] PCPlus4E;
    wire [63:0] ReadData1E;
    wire [63:0] ReadData2E;
    wire [2:0] funct3E;
    wire [6:0] funct7E;
    wire [63:0] PCTargetD;
    wire PCWriteF;
    wire IF_IDWriteF;
    wire IF_IDFlushF;

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
        .MemReadEnBE(MemReadEnBE),
        .RdBE(RdBE),
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
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .PCPlus4E(PCPlus4E),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E),
        .funct3E(funct3E),
        .funct7E(funct7E),
        .PCTargetD(PCTargetD),
        .PCWriteF(PCWriteF),
        .IF_IDWriteF(IF_IDWriteF),
        .IF_IDFlushF(IF_IDFlushF)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period: 10ns
    end

    // Apply test vectors
    initial begin
        // Monitor outputs
        $monitor(
            "Time=%0t | InstrD=%h | RegWriteEnE=%b | MemtoRegE=%b | JALE=%b | MemReadEnE=%b | MemWriteEnE=%b | ALUOpE=%b | ALUSrcE=%b | RdE=%d | ImmE=%h | PCTargetD=%h | PCWriteF=%b | IF_IDWriteF=%b | IF_IDFlushF=%b",
            $time, InstrD, RegWriteEnE, MemtoRegE, JALE, MemReadEnE, MemWriteEnE, ALUOpE, ALUSrcE, RdE, ImmE, PCTargetD, PCWriteF, IF_IDWriteF, IF_IDFlushF
        );

        // Test Case 1: Reset
        rst = 1;
        InstrD = 32'd0;
        PCD = 64'd0;
        PCPlus4D = 64'd0;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        MemReadEnBE = 0;
        RdBE = 5'd0;
        #10;

        rst = 0;
        #10;

        // Test Case 2: ADDI (I-Type instruction)
        InstrD = 32'b000000000101_00001_000_00100_0010011; // addi x4, x1, 5
        PCD = 64'd8;
        PCPlus4D = 64'd12;
        RegWriteEnW = 1;
        RDW = 5'd1;
        ResultW = 64'd5; // Assume x1 = 5
        #10;

        // Test Case 3: BEQ (Branch instruction)
        InstrD = 32'b0000000_00001_00010_000_00001_1100011; // beq x1, x2, offset
        PCD = 64'd16;
        PCPlus4D = 64'd20;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        MemReadEnBE = 0;
        RdBE = 5'd0;
        #10;

        // Test Case 4: LW (I-Type Load instruction)
        InstrD = 32'b000000000100_00010_010_00101_0000011; // lw x5, 4(x2)
        PCD = 64'd24;
        PCPlus4D = 64'd28;
        RegWriteEnW = 1;
        RDW = 5'd2;
        ResultW = 64'd8; // Assume x2 = 8
        MemReadEnBE = 1;
        RdBE = 5'd2;
        #10;

        // Test Case 5: JALR (Jump and Link Register instruction)
        InstrD = 32'b000000000010_00001_000_00011_1100111; // jalr x3, x1, 2
        PCD = 64'd32;
        PCPlus4D = 64'd36;
        RegWriteEnW = 1;
        RDW = 5'd3;
        ResultW = 64'd10;
        MemReadEnBE = 0;
        RdBE = 5'd0;
        #10;

        // Test Case 6: SW (Store Word instruction)
        InstrD = 32'b0000000_00011_00010_010_00011_0100011; // sw x3, 4(x2)
        PCD = 64'd40;
        PCPlus4D = 64'd44;
        RegWriteEnW = 0;
        RDW = 5'd0;
        ResultW = 64'd0;
        MemReadEnBE = 0;
        RdBE = 5'd0;
        #10;

        // Test Case 7: SLT (Set Less Than, R-Type instruction)
        InstrD = 32'b0000000_00001_00010_010_00100_0110011; // slt x4, x2, x1
        PCD = 64'd48;
        PCPlus4D = 64'd52;
        RegWriteEnW = 1;
        RDW = 5'd4;
        ResultW = 64'd1; // Assume x4 = 1
        #10;

        // Finish simulation
        #20;
        $finish;
    end

endmodule
