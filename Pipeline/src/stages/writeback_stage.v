module writeback_stage(
    input             clk,
    input             rst,
    // Pipeline control signals and data from MEM stage
    input      [4:0]  RD_M,        // Destination register from MEM stage
    input             RegWriteEn_M, 
    input             MemtoReg_M, 
    input             JAL_M,
    // Data inputs for potential write-back
    input      [31:0] PCPlus4W, 
    input      [31:0] ALU_ResultW, 
    input      [31:0] ReadDataW,
    // Outputs (latched)
    output reg [4:0]  RD_W,        // Destination register latched into WB
    output reg [31:0] ResultW      // Write-back data latched into WB
);

    // Internal wire from the 4x1 Mux
    wire [31:0] mux_out;
    wire [1:0]  mux_sel;

    // Create the mux select from JAL_M and MemtoReg_M
    //   - For example, {JAL_M, MemtoReg_M} might be:
    //       2'b00 -> ALU result
    //       2'b01 -> Memory read data
    //       2'b10 -> PC+4 (JAL)
    //       2'b11 -> not used / default
    assign mux_sel = {JAL_M, MemtoReg_M};

    // Instantiate the 4x1 Mux
    // We only really use three inputs (a, b, c).
    // Input d is wired to 0 here, but you can choose any default value.
    Mux4x1 result_mux(
        .a   (ALU_ResultW),
        .b   (ReadDataW),
        .c   (PCPlus4W),
        .d   (32'b0),        // Unused fourth input
        .sel (mux_sel),
        .y   (mux_out)
    );

    // Synchronous logic to latch RD_W and ResultW
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD_W    <= 5'b0;
            ResultW <= 32'b0;
        end else begin
            // Capture the Destination Register
            RD_W <= RD_M;

            // If needed, you can gate this with RegWriteEn_M
            // to zero out ResultW when not writing. 
            // For now, we always latch the mux_out.
            if (RegWriteEn_M) begin
                ResultW <= mux_out;
            end else begin
                // If register writing is disabled, you could hold the old value,
                // or simply write zero. This depends on your design specs.
                ResultW <= 32'b0;
            end
        end
    end

endmodule