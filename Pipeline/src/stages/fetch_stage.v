module fetch_stage (
    input clk,                  // Clock signal
    input rst,                  // Reset signal
    input PCSrcD,               // PC Source control (for branches/jumps)
    input JalD,                 // Jump signal (for jump link)
    input [31:0] PCTargetD,     // Target address for branching/jumping
    output [31:0] InstrD,       // Instruction at current PC
    output [31:0] PCD,          // Current PC value
    output [31:0] PCPlus4D      // PC + 4 value
);

    // Declaring internal wires
    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Registers for pipeline stage
    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;

    // PC Mux: Select either PC + 4 or PCTargetD based on branch/jump control signals
    Mux2x1 pc_mux (
        .a(PCPlus4F),           // Next sequential PC (PC + 4)
        .b(PCTargetD),          // Target PC for branch/jump
        .sel(PCSrcD | JalD),    // Select signal for branch/jump
        .y(PC_F)                // Output PC (either next PC or jump target)
    );

    // Debug: Assign the PC_F value for debugging purposes (optional)
    // assign debug_PC_F = PC_F;  // Uncomment if you want a debug output

    // Program Counter: Update PC based on the output of the PC mux
    PC Program_Counter (
        .clk(clk),              // Clock signal
        .rst(rst),              // Reset signal
        .pc_in(PC_F),           // Next PC (either PC + 4 or jump/branch target)
        .pc_out(PCF)            // Current PC
    );

    // Instruction Memory: Fetch instruction at the current PC
    instractionMemory IMEM (
        .address(PCF),          // Address input (current PC)
        .clock(clk),            // Clock signal
        .q(InstrF)              // Instruction output
    );

    // PC Adder: Calculate PC + 4 (for sequential PC)
    PC_Adder pc_add (
        .in(PCF),               // Current PC
        .out(PCPlus4F)          // PC + 4 (next instruction address)
    );

    // Pipeline registers for fetch stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the pipeline registers
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
        end else begin
            // Update pipeline registers with the current values
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F_reg <= PCPlus4F;
        end
    end

    // Assigning pipeline registers to output ports
    assign InstrD = InstrF_reg;
    assign PCD = PCF_reg;
    assign PCPlus4D = PCPlus4F_reg;

endmodule
