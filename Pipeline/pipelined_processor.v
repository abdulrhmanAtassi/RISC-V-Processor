module pipelined_processor (
    input clk,
    input reset
);

    //-------------------------------------------------------------
    //  FETCH -> DECODE signals
    //-------------------------------------------------------------
    // Control signals from fetch stage
    wire PCSrcD;
    wire JalD;
    wire PCWriteD;
    wire IF_IDWriteD;
    wire IF_IDFlushD;

    // Data signals from fetch stage
    wire [63:0] PCTargetD;
    wire [31:0] InstrD;
    wire [63:0] PCD;
    wire [63:0] PCPlus4D;

    //-------------------------------------------------------------
    //  DECODE -> EXECUTE signals
    //-------------------------------------------------------------
    // These three signals are outputs from the writeback stage,
    // which we feed back to decode (the register file).
    wire RegWriteEnD;      // Write enable going *into* the register file
    wire [4:0] RDW;        // Writeback register address
    wire [63:0] ResultD;   // Data being written back into registers

    // Control signals going from decode to execute
    wire RegWriteEnE; 
    wire MemtoRegE;
    wire JALE;
    wire MemReadEnE;
    wire MemWriteEnE;
    wire [2:0] ALUOpE;
    wire ALUSrcE;
    wire [1:0] MemSizeE;   // <--- these were missing in your decode_stage instantiation
    wire [1:0] LoadSizeE;  // <--- these were missing in your decode_stage instantiation
    wire PCSF;             // Some PC-select or branch comparison flag

    // Data signals going from decode to execute
    wire signed [63:0] ImmE;
    wire [4:0]  RdE, Rs1E, Rs2E;
    wire [63:0] PCPlus4E;
    wire signed [63:0] ReadData1E;
    wire signed [63:0] ReadData2E;

    //-------------------------------------------------------------
    //  EXECUTE -> MEMORY signals
    //-------------------------------------------------------------
    wire [2:0]  funct3E;
    wire [6:0]  funct7E;
    wire [4:0]  RdM;
    wire [63:0] PcPlus4M;
    wire signed [63:0] ReadData2M;
    wire signed [63:0] ALUResultM;
    wire RegWriteEnM;
    wire MemtoRegM;
    wire JALM;
    wire MemReadEnM;
    wire MemWriteEnM;
    wire [1:0] MemSizeM;
    wire [1:0] LoadSizeM;

    //-------------------------------------------------------------
    //  MEMORY -> WRITEBACK signals
    //-------------------------------------------------------------
    wire RegWriteEnW;      // Pipeline reg from memory stage
    wire MemtoRegW;        // Pipeline reg from memory stage
    wire JALW;             // Pipeline reg from memory stage
    wire [63:0] PcPlus4W;  
    wire signed [63:0] ALUResultW;
    wire signed [63:0] ReadDataW;
    wire [4:0]  RdW;

    //-------------------------------------------------------------
    //  Forwarding unit signals
    //-------------------------------------------------------------
    wire [1:0] forwardA, forwardB;

    //-------------------------------------------------------------
    //  Fetch stage instantiation
    //-------------------------------------------------------------
    fetch_stage fetch_stage_inst (
        .clk         (clk),
        .rst         (reset),
        //input from Decode 
        .PCSrcD      (PCSF),
        .JalD        (JALE),
        .PCWriteF    (PCWriteD),
        .IF_IDWriteF (IF_IDWriteD),
        // .IF_IDFlushF (1'b0),
        .PCTargetD   (PCTargetD),
        //output to Decode
        .InstrD      (InstrD),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D)
    );

    //-------------------------------------------------------------
    //  Decode stage instantiation
    //-------------------------------------------------------------
    decode_stage decode_stage_inst (
        .clk         (clk),
        .rst         (reset),

        // Inputs from fetch
        .InstrD      (InstrD),
        .PCD         (PCD),
        .PCPlus4D    (PCPlus4D),

        // Writeback inputs (fed back from writeback stage outputs)
        .RegWriteEnW (RegWriteEnD),  // naming quirk: decode sees it as W, top calls it D
        .RDW         (RDW),
        .ResultW     (ResultD),

        // Input from execute stage for hazard detection
        .MemReadEnBE (MemReadEnE),
        .RdBE        (RdE),

        // Outputs to execution
        .RegWriteEnE (RegWriteEnE),
        .MemtoRegE   (MemtoRegE),
        .JALE        (JALE),
        .MemReadEnE  (MemReadEnE),
        .MemWriteEnE (MemWriteEnE),
        .ALUOpE      (ALUOpE),
        .ALUSrcE     (ALUSrcE),
        .MemSizeE    (MemSizeE),   // <--- now hooked up
        .LoadSizeE   (LoadSizeE),  // <--- now hooked up
        .ImmE        (ImmE),
        .RdE         (RdE),
        .Rs1E        (Rs1E),
        .Rs2E        (Rs2E),
        .PCPlus4E    (PCPlus4E),
        .ReadData1E  (ReadData1E),
        .ReadData2E  (ReadData2E),
        // (If decode also calculates PCTargetD or PCSrcD, those would go here too)
        .PCTargetD   (PCTargetD),
        .PCSF        (PCSF), // it shall be PCSD
        //hazard detection signals
        .PCWriteF    (PCWriteD),
        .IF_IDWriteF (IF_IDWriteD),
        .IF_IDFlushF (IF_IDFlushD),

        // ALU control bits
        .funct3E     (funct3E),
        .funct7E     (funct7E)
    );

    //-------------------------------------------------------------
    //  Execution stage instantiation
    //-------------------------------------------------------------
    execution_stage execution_stage_inst (
        .clk         (clk),
        .rst         (reset),

        // Control signals from decode
        .RegWriteEnE (RegWriteEnE),
        .MemtoRegE   (MemtoRegE),
        .JALE        (JALE),
        .MemReadEnE  (MemReadEnE),
        .MemWriteEnE (MemWriteEnE),
        .ALUSrcE     (ALUSrcE),
        .MemSizeE    (MemSizeE),
        .LoadSizeE   (LoadSizeE),
        .ALUOpE      (ALUOpE),
        .ALUResultW  (ResultD),
        // Data signals from decode
        .RdE         (RdE),
        .ImmE        (ImmE),
        .ReadData1E  (ReadData1E),
        .ReadData2E  (ReadData2E),
        .PCPlus4E    (PCPlus4E),

        // ALU control bits
        .funct3E     (funct3E),
        .funct7E     (funct7E),
        
        // forwarding signals
        .forwardA    (forwardA),
        .forwardB    (forwardB),
        
        // Outputs to memory
        .RdM         (RdM),
        .PcPlus4M    (PcPlus4M),
        .ReadData2M  (ReadData2M),
        .ALUResultM  (ALUResultM),
        .RegWriteEnM (RegWriteEnM),
        .MemtoRegM   (MemtoRegM),
        .JALM        (JALM),
        .MemReadEnM  (MemReadEnM),
        .MemWriteEnM (MemWriteEnM),
        .MemSizeM    (MemSizeM),
        .LoadSizeM   (LoadSizeM)
    );

    //-------------------------------------------------------------
    //  Memory stage instantiation
    //-------------------------------------------------------------
    memory_stage memory_stage_inst (
        .clk         (clk),
        .rst         (reset),

        // Inputs from execution
        .RegWriteEnM (RegWriteEnM),
        .MemtoRegM   (MemtoRegM),
        .JALM        (JALM),
        .MemReadEnM  (MemReadEnM),
        .MemWriteEnM (MemWriteEnM),
        .MemSizeM    (MemSizeM),
        .LoadSizeM   (LoadSizeM),
        .RdM         (RdM),
        .PcPlus4M    (PcPlus4M),
        .ReadData2M  (ReadData2M),
        .ALUResultM  (ALUResultM),

        // Outputs to writeback
        .RegWriteEnW (RegWriteEnD),
        .MemtoRegW   (MemtoRegW),
        .JALW        (JALW),
        .PcPlus4W    (PcPlus4W),
        .ALUResultW  (ALUResultW),
        .ReadDataW   (ReadDataW),
        .RdW         (RDW)
    );

    //-------------------------------------------------------------
    //  Writeback stage instantiation
    //-------------------------------------------------------------
    writeback_stage writeback_stage_inst (
        .clk          (clk),
        .rst          (reset),

        // Pipeline inputs from memory stage
        // .RDM          (RdW),
        // .RegWriteEnM  (RegWriteEnW),
        .MemtoRegM    (MemtoRegW),
        .JALM         (JALW),
        .PCPlus4W     (PcPlus4W),
        .ALU_ResultW  (ALUResultW),
        .ReadDataW    (ReadDataW),

        // Outputs that go back to decode stage’s register file
        // .RdD          (RDW),
        .ResultD      (ResultD)
        // .RegWriteEnD  (RegWriteEnD)
    );

    //-------------------------------------------------------------
    // Forwarding unit instantiation
    //-------------------------------------------------------------
    forwarding_unit forwarding_unit_inst (
        .EX_MEM_RegWriteEn (RegWriteEnM),
        .MEM_WB_RegWriteEn (RegWriteEnD),
        .EX_MEM_rd         (RdM),
        .MEM_WB_rd         (RDW),
        .ID_EX_rs1         (Rs1E),
        .ID_EX_rs2         (Rs2E),
        .forwardA          (forwardA),
        .forwardB          (forwardB)
    );

endmodule
