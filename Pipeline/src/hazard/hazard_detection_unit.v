module  hazard_detection_unit(
    input ID_EX_MemReadEn, 
    input [4:0] ID_EX_rdE,
    input [4:0] rs1D,
    input [4:0] rs2D,

    // Optional: if you do branch detection early in ID
    input  wire        Branch_Detected,
    
    output reg         PCWrite,  // 1 = PC updates normally. || 0 = PC is “frozen” (stalled).
    output reg         IF_IDWrite, // 1 = The IF/ID pipeline register is updated on each clock cycle (normal operation). || 0 = Freeze the IF/ID pipeline register (do not latch the next instruction).
    output reg         ID_EXBubble, // 1 = Turn the instruction in ID into a NOP (bubble) as it goes into EX. || 0 = Normal operation (no bubble).
    output reg         IF_IDFlush // Flush (invalidate) the instruction in the IF/ID pipeline register(for branch flush).
);

    always @(*) begin
        // Default signals
        PCWrite     = 1'b1;
        IF_IDWrite  = 1'b1;
        ID_EXBubble = 1'b0;
        IF_IDFlush  = 1'b0;

        //--------------------------------------------
        // 1) Check for Load-Use Hazard
        //    If EX instruction is a load (EX_MemRead = 1) AND
        //    the ID instruction needs the same register,
        //    we must stall the pipeline by one cycle.
        //--------------------------------------------
        if (ID_EX_MemReadEn == 1'b1) begin
            // If the ID-stage instruction needs Rs1 or Rs2 that matches EX.Rd
            if (ID_EX_MemReadEn && 
                ((rs1D == ID_EX_rdE) || (rs2D == ID_EX_rdE))) begin

                // Stall signals
                PCWrite     = 1'b0;  // Freeze PC
                IF_IDWrite  = 1'b0;  // Freeze IF/ID
                ID_EXBubble = 1'b1;  // Insert bubble in ID→EX
            end
        end
        //--------------------------------------------
        // 2) Optional: Branch flush in ID stage
        //    If your design decides branch outcome in ID,
        //    you'd flush the IF/ID instruction if a branch is taken.
        //--------------------------------------------
        if (Branch_Detected == 1'b1) begin
            // For a taken branch, you typically flush instructions in IF/ID
            // (and maybe ID/EX) that came after the branch instruction.
            IF_IDFlush  = 1'b1;
            // PCWrite might also switch to loading the branch target,
            // but that typically is done in your main control unit.
        end
    end


endmodule