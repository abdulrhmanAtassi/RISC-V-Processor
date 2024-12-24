module decode_stage(clk, rst, InstrD, PCD, PCPlus4D, RegWriteEnW, RDW, ResultW,
                    RegWriteEnE,MemtoRegE, JALE, MemReadEnE, MemWriteEnE, ALUOpE,
                    ALUSrcE, MemSizeE, LoadSizeE, PCSF, ImmE, RdE, PCPlus4E,ReadData1E,
                    ReadData2E, PCTargetD);
	
    // Declaring I/O
    input clk, rst, RegWriteEnW;
    input [4:0] RDW;
    input [31:0] InstrD;
    input [63:0] PCD, PCPlus4D;
    input signed [63:0] ResultW;

    output RegWriteEnE,MemtoRegE, JALE, MemReadEnE, MemWriteEnE, PCSF, ALUSrcE;
    output [1:0]  MemSizeE, LoadSizeE;
    output [2:0]  ALUOpE;
    output [4:0]  RdE;
    output [63:0] PCPlus4E, PCTargetD;
    output signed [63:0] ImmE, ReadData1E, ReadData2E;

    // Declare Interim Wires
    wire RegWriteEnD, MemtoRegD, JALD, MemReadEnD, MemWriteEnD, PCSD, ALUSrcD;
    wire [1:0] MemSizeD, LoadSizeD;
    wire [2:0] ALUOpD;
    wire [4:0] RdD;
	wire signed [63:0] ImmD, ReadData1D, ReadData2D;
    wire IsBranch, BranchType, JALR, BranchResult;
    wire [2:0] ImmSrc;
    wire [63:0] AdderInput;

    // Declaration of Interim Register
    reg RegWriteEnD_R,MemtoRegD_R, JALD_R, MemReadEnD_R,MemWriteEnD_R, PCSD_R, ALUSrcD_R;
    reg [1:0]  MemSizeD_R, LoadSizeD_R;
    reg [2:0]  ALUOpD_R;
    reg [4:0]  RdD_R;
    reg signed [63:0] ImmD_R, ReadData1D_R, ReadData2D_R;
    reg [63:0] PCPlus4D_R;

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
        .RegWriteEn(RegWriteEnD),
        .MemtoReg(MemtoRegD),
        .JAL(JALD),
        .MemReadEn(MemReadEnD),
        .MemWriteEn(MemWriteEnD),
        .IsBranch(IsBranch),
        .ALUSrc(ALUSrcD),
        .BranchType(BranchType),
        .JALR(JALR),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOpD),
        .MemSize(MemSizeD),
        .LoadSize(LoadSizeD)
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
        .ReadData1(ReadData1D), 
        .ReadData2(ReadData2D)
);

    // ---------------
    // SIGN-EXTENSION
    // ---------------
	sign_extension SE (
        .instruction(InstrD),
        .imm_type(ImmSrc),
        .imm_out(ImmD)
    );

    // ---------------
    // BRANCH COMPARISON
    // ---------------
    EqReg EQ(
        .Data1(ReadData1D),       // 32-bit input data1
        .Data2(ReadData2D),       // 32-bit input data2
        .BranchType(BranchType),         // Branch type (1 for equality, 0 for inequality)
        .Branch(BranchResult)         // Output signal indicating branch decision
    );

    // ---------------
    // BRANCH DECISION
    // ---------------
    assign PCSD = IsBranch & BranchResult;
    
    // ---------------
    // SELECT ADDER INPUT FOR PC TARGET
    //    JALR => base is Register (ReadData1E)
    //    else => base is PC
    // ---------------
    Mux2x1 #(64) adderSrc (
        .a(PCD), 
        .b(ReadData1D), 
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
    //assign RdD = rd;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        RegWriteEnD_R <= 0;
        MemtoRegD_R <= 0;
        JALD_R <= 0;
        MemReadEnD_R <= 0;
        MemWriteEnD_R <= 0;
        PCSD_R <= 0;
        ALUSrcD_R <= 0;
        MemSizeD_R <= 2'b0;
        LoadSizeD_R <= 2'b0;
        ALUOpD_R <= 3'b0;
        RdD_R <= 5'b0;
        ImmD_R <= 64'b0;
        ReadData1D_R <= 64'b0;
        ReadData2D_R <= 64'b0;
        PCPlus4D_R <= 64'b0;
    end else begin
        RegWriteEnD_R <= RegWriteEnD;
        MemtoRegD_R <= MemtoRegD;
        JALD_R <= JALD;
        MemReadEnD_R <= MemReadEnD;
        MemWriteEnD_R <= MemWriteEnD;
        PCSD_R <= PCSD;
        ALUSrcD_R <= ALUSrcD;
        MemSizeD_R <= MemSizeD;
        LoadSizeD_R <= LoadSizeD;
        ALUOpD_R <= ALUOpD;
        RdD_R <= rd;
        ImmD_R <= ImmD;
        ReadData1D_R <= ReadData1D;
        ReadData2D_R <= ReadData2D;
        PCPlus4D_R <= PCPlus4D;
    end
end

		// Assign statements
		assign RegWriteEnE = RegWriteEnD_R;
		assign MemtoRegE = MemtoRegD_R;
		assign JALE = JALD_R;
		assign MemReadEnE = MemReadEnD_R;
		assign MemWriteEnE = MemWriteEnD_R;
		assign PCSF = PCSD_R;
		assign ALUSrcE = ALUSrcD_R;
		assign MemSizeE = MemSizeD_R;
		assign LoadSizeE = LoadSizeD_R;
		assign ALUOpE = ALUOpD_R;
		assign RdE = RdD_R;
		assign ImmE = ImmD_R;
		assign ReadData1E = ReadData1D_R;
		assign ReadData2E = ReadData2D_R;
		assign PCPlus4E = PCPlus4D_R;


endmodule
