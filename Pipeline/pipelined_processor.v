module pipelined_processor(
    input clk,
    input reset
);
    // Control signals
    wire PCSrcD;
    wire JalD;

    // Data signals
    wire [31:0] PCTargetD;
    wire [31:0] InstrD;
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;

    // Decode stage signals
    wire RegWriteEnW;
    wire [4:0] RDW;
    wire [31:0] ResultW;
    wire RegWriteEnE;
    wire MemtoRegE;
    wire JALE;
    wire MemReadEnE;
    wire MemWriteEnE;
    wire [2:0] ALUOpE;
    wire ALUSrcE;
    wire PCSF;
    wire [31:0] ImmE;
    wire [4:0] RdE;
    wire [31:0] PCPlus4E;
    wire [31:0] ReadData1E;
    wire [31:0] ReadData2E;

    // Instantiate fetch stage
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .rst(reset),
        .PCSrcD(PCSrcD),
        .JalD(JalD),
        .PCTargetD(PCTargetD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // Instantiate decode stage
    decode_stage decode_stage_inst (
        .clk(clk),
        .rst(reset),
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
        .PCSF(PCSF),
        .ImmE(ImmE),
        .RdE(RdE),
        .PCPlus4E(PCPlus4E),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E)
    );
endmodule
