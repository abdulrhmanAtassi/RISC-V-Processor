module writeback_stage(
    input             clk,
    input             rst,
    // Pipeline control signals and data from MEM stage
    input      [4:0]  RDM,        // Destination register from MEM stage
    input             RegWriteEnM, 
    input             MemtoRegM, 
    input             JALM,
    // Data inputs for potential write-back
    input      [31:0] PCPlus4W, 
    input      [31:0] ALU_ResultW, 
    input      [31:0] ReadDataW,
    // Outputs (latched)
    output  [4:0]  RdD,        // Destination register latched into WB
    output  [31:0] ResultD,      // Write-back data latched into WB
    output RegWriteEnD
);

    wire [4:0]  RDW;    
    wire [31:0] ResultW;

    reg RegWriteEnW_R;
    reg [4:0]  RdW_R;    
    reg [31:0] ResultW_R;
    
    // Internal wire from the 4x1 Mux
    wire [1:0]  mux_sel;

    // Create the mux select from JAL_M and MemtoReg_M
    //   - For example, {JAL_M, MemtoReg_M} might be:
    //       2'b00 -> ALU result
    //       2'b01 -> Memory read data
    //       2'b10 -> PC+4 (JAL)
    //       2'b11 -> not used / default
    assign mux_sel = {JALM, MemtoRegM};

    // Instantiate the 4x1 Mux
    // We only really use three inputs (a, b, c).
    // Input d is wired to 0 here, but you can choose any default value.
    Mux4x1 result_mux(
        .a   (ALU_ResultW),
        .b   (ReadDataW),
        .c   (PCPlus4W),
        .d   (32'b0),        // Unused fourth input
        .sel (mux_sel),
        .y   (ResultW)
    );

    // Synchronous logic to latch RD_W and ResultW
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RdW_R    <= 5'b0;
            ResultW_R <= 32'b0;
            RegWriteEnW_R <= 1'b0;
        end else begin
            // Capture the Destination Register
            RdW_R <= RDM;
            ResultW_R <= ResultW;
            RegWriteEnW_R <= RegWriteEnM;

        end
    end

    assign RdD = RdW_R;
    assign ResultD = ResultW_R;
    assign RegWriteEnD = RegWriteEnW_R;
endmodule