module execution_stage (
    input  wire              clk,
    input  wire              rst,
    input  wire              RegWriteEnE,
    input  wire              MemtoRegE,
    input  wire              JALE,
    input  wire              MemReadEnE,
    input  wire              MemWriteEnE,
    input  wire              ALUSrcE,
    input  wire [1:0]        MemSizeE,
    input  wire [1:0]        LoadSizeE,
    input  wire [2:0]        ALUOpE,
    input  wire [2:0]        funct3E,
    input  wire [4:0]        RdE,
    input  wire [6:0]        funct7E,
    input  wire [63:0]       PCPlus4E,
    input  wire signed [63:0] ImmE,
    input  wire signed [63:0] ReadData1E,
    input  wire signed [63:0] ReadData2E,

    output wire              RegWriteEnM,
    output wire              MemtoRegM,
    output wire              JALM,
    output wire              MemReadEnM,
    output wire              MemWriteEnM,
    output wire [1:0]        MemSizeM,
    output wire [1:0]        LoadSizeM,
    output wire [4:0]        RdM,
    output wire [63:0]       PcPlus4M,
    output wire signed [63:0] ReadData2M,
    output wire signed [63:0] ALUResultM
);

    // Internal wires and regs
    wire        WordOp;
    wire [3:0]  ALUControl;
    wire signed [63:0] ALUResultE;

    // Pipeline registers
    reg                RegWriteEnE_R, MemtoRegE_R, JALE_R, MemReadEnE_R, MemWriteEnE_R;
    reg  [1:0]         MemSizeE_R, LoadSizeE_R;
    reg  [4:0]         RdE_R;
    reg  [63:0]        PcPlus4E_R;
    reg  signed [63:0] ReadData2E_R;
    reg  signed [63:0] ALUResultE_R;

    // Select ALU operand2 based on ALUSrcE
    wire signed [63:0] ALUOperand2 = ALUSrcE ? ImmE : ReadData2E;

    // ---------------
    // ALU Control Unit
    // ---------------
    ALU_Control alu_ctrl(
        .ALUOp     (ALUOpE),
        .funct3    (funct3E),
        .funct7    (funct7E),
        .ALUControl(ALUControl),
        .WordOp    (WordOp)
    );

    // ---------------
    // ALU
    // ---------------
    ALU alu_inst(
        .operand1   (ReadData1E),
        .operand2   (ALUOperand2),
        .ALUControl (ALUControl),
        .WordOp     (WordOp),  // 1 = 32-bit operation, 0 = 64-bit operation
        .ALUResult  (ALUResultE)
    );

    // ---------------
    // Pipeline Register Update
    // ---------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all pipeline registers
            RegWriteEnE_R  <= 0;
            MemtoRegE_R    <= 0;
            JALE_R         <= 0;
            MemReadEnE_R   <= 0;
            MemWriteEnE_R  <= 0;
            MemSizeE_R     <= 2'b00;
            LoadSizeE_R    <= 2'b00;
            RdE_R          <= 5'b00000;
            PcPlus4E_R     <= 64'b0;
            ReadData2E_R   <= 64'b0;
            ALUResultE_R   <= 64'b0;
        end else begin
            // Pipeline register updates
            RegWriteEnE_R  <= RegWriteEnE;
            MemtoRegE_R    <= MemtoRegE;
            JALE_R         <= JALE;
            MemReadEnE_R   <= MemReadEnE;
            MemWriteEnE_R  <= MemWriteEnE;
            MemSizeE_R     <= MemSizeE;
            LoadSizeE_R    <= LoadSizeE;
            RdE_R          <= RdE;
            PcPlus4E_R     <= PCPlus4E;
            ReadData2E_R   <= ReadData2E;
            ALUResultE_R   <= ALUResultE;
        end
    end

    // ---------------
    // Pipeline Register Outputs
    // ---------------
    assign RegWriteEnM  = RegWriteEnE_R;
    assign MemtoRegM    = MemtoRegE_R;
    assign JALM         = JALE_R;
    assign MemReadEnM   = MemReadEnE_R;
    assign MemWriteEnM  = MemWriteEnE_R;
    assign MemSizeM     = MemSizeE_R;
    assign LoadSizeM    = LoadSizeE_R;
    assign RdM          = RdE_R;
    assign PcPlus4M     = PcPlus4E_R;
    assign ReadData2M   = ReadData2E_R;
    assign ALUResultM   = ALUResultE_R;

endmodule
