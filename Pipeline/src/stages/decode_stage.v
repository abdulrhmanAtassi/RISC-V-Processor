module decode_stage(clk, rst, InstrD, PCD, PCPlus4D, RegWriteEnW, RDW, ResultW,
                    RegWriteEnE,MemtoRegE, JALE, MemReadEnE,MemWriteEnE, ALUOpE, ALUSrcE, MemSizeE, LoadSizeE, PCSF, ImmE, RdE, PCPlus4E,ReadData1E, ReadData2E, PCTargetD);
	
    // Declaring I/O
    input clk, rst, RegWriteEnW;
    input [4:0] RDW;
    input [31:0] InstrD;
    input [63:0] ResultW, PCD, PCPlus4D;

    output RegWriteEnE,MemtoRegE, JALE, MemReadEnE,MemWriteEnE, PCSF, ALUSrcE;
    output [1:0]  MemSizeE, LoadSizeE;
    output [2:0]  ALUOpE;
    output [4:0]  RdE;
    output [63:0] ImmE, ReadData1E, ReadData2E, PCPlus4E, PCTargetD;

    // Declare Interim Wires
    wire IsBranch, BranchType, JALR, BranchResult;
    wire [1:0] ImmSrc;
    wire [63:0] AdderInput;

    // Declaration of Interim Register
    reg RegWriteEnD_R,MemtoRegD_R, JALD_R, MemReadEnD_R,MemWriteEnD_R, PCSD_R, ALUSrcD_R;
    reg [1:0]  MemSizeD_R, LoadSizeD_R;
    reg [2:0]  ALUOpD_R;
    reg [4:0]  RdD_R;
	reg [63:0] ImmD_R, ReadData1D_R, ReadData2D_R, PCPlus4D_R;

    // ---------------
    // SPLIT THE INSTRUCTION
    // ---------------
    wire [6:0] opcode = InstrD[6:0];
    wire [2:0] funct3 = InstrD[14:12];
    wire [6:0] funct7 = InstrD[31:25];
    wire [4:0] rs1    = InstrD[19:15];
    wire [4:0] rs2    = InstrD[24:20];
    wire [4:0] rd     = InstrD[11:7];

    // ---------------
    // CONTROL UNIT
    // ---------------
    ControlUnit dut (
        .op(opcode),
        .funct7(funct7),
        .funct3(funct3),

        .RegWriteEn(RegWriteEnE),
        .MemtoReg(MemtoRegE),
        .JAL(JALE),
        .MemReadEn(MemReadEnE),
        .MemWriteEn(MemWriteEnE),
        .IsBranch(IsBranch),
        .ALUSrc(ALUSrcE),
        .BranchType(BranchType),
        .JALR(JALR),
        .ImmSrc(ImmSrc),
        .alu_op(ALUOpE),
        .MemSize(MemSizeE),
        .LoadSize(LoadSizeE)
    );

    // ---------------
    // REGISTER FILE
    // ---------------
    RegisterFile RF(
        .clk(clk),
        .rst(rst),
        .ReadRegister1(rs1), 
        .ReadRegister2(rs2), 
        .WriteRegister(RDW),
        .WriteData(ResultW),
        .WriteEnable(RegWriteEnW),      // Control signal for enabling write
        .ReadData1(ReadData1E), 
        .ReadData2(ReadData2E)
);

    // ---------------
    // SIGN-EXTENSION
    // ---------------
	sign_extension SE (
        .instruction(InstrD),
        .imm_type(ImmSrc),
        .imm_out(ImmE)
    );

    // ---------------
    // BRANCH COMPARISON
    // ---------------
    EqReg EQ(
        .Data1(ReadData1E),       // 32-bit input data1
        .Data2(ReadData2E),       // 32-bit input data2
        .BranchType(BranchType),         // Branch type (1 for equality, 0 for inequality)
        .Branch(BranchResult)         // Output signal indicating branch decision
    );

    // ---------------
    // BRANCH DECISION
    // ---------------
    assign PCSF = IsBranch & BranchResult;
    
    // ---------------
    // SELECT ADDER INPUT FOR PC TARGET
    //    JALR => base is Register (ReadData1E)
    //    else => base is PC
    // ---------------
    Mux2x1 #(64) adderSrc (
        .a(PCD), 
        .b(ReadData1E), 
        .sel(JALR), 
        .y(AdderInput)
    );

    // ---------------
    // PC TARGET
    //    For JALR, ensure LSB is cleared
    // ---------------
    wire [63:0] raw_jalr_addr = ImmE + AdderInput;
    wire [63:0] jalr_addr     = {raw_jalr_addr[63:1], 1'b0}; // Clear LSB

    assign PCTargetD = (JALR) ? jalr_addr : (ImmE + AdderInput);

endmodule





