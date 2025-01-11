module fetch_stage (
    input clk,                  // Clock signal
    input rst,                  // Reset signal
    input PCSrcD,               // PC Source control (for branches/jumps)
    input JalD,                 // Jump signal (for jump link)
    input PCWriteF,              // Enable signal for PC update (from hazard detection)
    input IF_IDWriteF,                // Stall signal (from hazard detection)
    input IF_IDFlushF,
    input [63:0] PCTargetD,     // Target address for branching/jumping
    output [31:0] InstrD,       // Instruction at current PC
    output [63:0] PCD,          // Current PC value
    output [63:0] PCPlus4D      // PC + 4 value
);

    // Declaring internal wires
    wire [63:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    // Registers for pipeline stage
    reg [31:0] InstrF_reg;
    reg [63:0] PCF_reg, PCPlus4F_reg;

    // PC Mux: Select either PC + 4 or PCTargetD based on branch/jump control signals
    Mux2x1 #(64) pc_mux (
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
        .PCWrite(PCWriteF),      // Enable PC update (hazard detection)
        // .PCWrite(1'b1),
        .pc_in(PC_F),           // Next PC (either PC + 4 or jump/branch target)
        .pc_out(PCF)            // Current PC
    );

    //Instruction Memory: Fetch instruction at the current PC
    // InstructionMemory_IP IMEM (
    //     //.aclr(1'b1),
    //     .address(PCF[9:2]),     // Address input (current PC)
    //     //.clken(1'b1),
    //     .clock(clk),            // Clock signal
    //     .q(InstrF)              // Instruction output
    // );
    Instruction_Memory_asy IMEM(
        .rst(rst),
        .A(PCF[11:2]),
        .RD(InstrF)
    );


    // PC Adder: Calculate PC + 4 (for sequential PC)
    PC_Adder pc_add (
        .in(PCF),          // Connects to input port 'in'
        .out(PCPlus4F)     // Connects to output port 'out'
    );
    // Additional signal to indicate initialization

    // Initialize the pipeline
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // On global reset
            InstrF_reg    <= 32'h00000000; 
            PCF_reg       <= 64'h00000000;
            PCPlus4F_reg  <= 64'h00000000;
        end 
        else if (IF_IDFlushF) begin
            // Flush: turn the fetched instruction into a NOP (or 0)
            InstrF_reg    <= 32'h00000193;  // e.g., RISC-V NOP is 0x00000013 (ADDI x0,x0,0)
            PCF_reg       <= 64'h00000000;
            PCPlus4F_reg  <= 64'h00000000;
        end
        else if (IF_IDWriteF) begin    // IF_IDWriteF
            // Normal operation: latch new instruction and PC
            InstrF_reg    <= InstrF;  
            PCF_reg       <= PCF;
            PCPlus4F_reg  <= PCPlus4F;
        end
        // else if IF_IDWriteF=0 => stall (keep old values)
    end

    // Assign outputs
    assign InstrD = InstrF_reg;
    assign PCD = PCF_reg;
    assign PCPlus4D = PCPlus4F_reg;
endmodule