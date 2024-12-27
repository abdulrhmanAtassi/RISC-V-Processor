module pipelined_processor (
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
    wire RegWriteEnD;
    wire [4:0] RDW;
    wire [31:0] ResultD;
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

    // Execution stage signals
    wire [2:0] funct3E;
    wire [6:0] funct7E;
    wire [4:0] RdM;
    wire [31:0] PcPlus4M;
    wire [31:0] ReadData2M;
    wire [31:0] ALUResultM;
    wire RegWriteEnM;
    wire MemtoRegM;
    wire JALM;
    wire MemReadEnM;
    wire MemWriteEnM;
    wire [1:0] MemSizeE;
    wire [1:0] LoadSizeE;
    wire [1:0] MemSizeM;
    wire [1:0] LoadSizeM;

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
        .RegWriteEnW(RegWriteEnD),
        .RDW(RDW),
        .ResultW(ResultD),
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

    // Instantiate execution stage
    execution_stage execution_stage_inst (
        .clk(clk),
        .rst(reset),
        .RegWriteEnE(RegWriteEnE),
        .MemtoRegE(MemtoRegE),
        .JALE(JALE),
        .MemReadEnE(MemReadEnE),
        .MemWriteEnE(MemWriteEnE),
        .ALUSrcE(ALUSrcE),
        .MemSizeE(MemSizeE),
        .LoadSizeE(LoadSizeE),
        .ALUOpE(ALUOpE),
        .RdE(RdE),
        .ImmE(ImmE),
        .ReadData1E(ReadData1E),
        .ReadData2E(ReadData2E),
        .PCPlus4E(PCPlus4E),
        .funct3E(funct3E),
        .funct7E(funct7E),
        .RdM(RdM),
        .PcPlus4M(PcPlus4M),
        .ReadData2M(ReadData2M),
        .ALUResultM(ALUResultM),
        .RegWriteEnM(RegWriteEnM),
        .MemtoRegM(MemtoRegM),
        .JALM(JALM),
        .MemReadEnM(MemReadEnM),
        .MemWriteEnM(MemWriteEnM),
        .MemSizeM(MemSizeM),
        .LoadSizeM(LoadSizeM)
    );

    // Instantiate writeback stage
    writeback_stage writeback_stage_inst (
        .clk(clk),
        .rst(reset),
        .RDM(RdM),
        .RegWriteEnM(RegWriteEnM),
        .MemtoRegM(MemtoRegM),
        .JALM(JALM),
        .PCPlus4W(PcPlus4M),
        .ALU_ResultW(ALUResultM),
        .ReadDataW(ReadData2M),
        .RdD(RDW),
        .ResultD(ResultD),
        .RegWriteEnD(RegWriteEnD)
    );

endmodule
