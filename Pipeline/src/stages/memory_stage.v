module memory_stage (
    input             clk,
    input             rst,

    // Control signals from EX->MEM pipeline
    input             RegWriteEnM,   // Register write enable
    input             MemtoRegM,     // Select MEM data vs. ALU result to WB
    input             JALM,          // JAL/JALR indicator
    input             MemReadEnM,    // Memory read enable
    input             MemWriteEnM,   // Memory write enable

    // Store Size (SB=00, SH=01, SW=10)
    input      [1:0]  MemSizeM,
    // Load Size (LB=00, LH=01, LW=10)
    input      [1:0]  LoadSizeM,

    // Data signals from EX->MEM pipeline
    input      [4:0]  RdM,           // Destination register ID
    input      [63:0] PcPlus4M,      // PC+4 (for JAL/JALR)
    input      [63:0] ReadData2M,    // Data to store in MEM
    input      [63:0] ALUResultM,    // Computed address or next-stage data

    // Outputs to MEM->WB pipeline
    output            RegWriteEnW,
    output            MemtoRegW,
    output            JALW,
    output     [63:0] PcPlus4W,
    output     [63:0] ALUResultW,
    output     [63:0] ReadDataW,     // Data loaded from memory (64-bit, sign-extended)
    output     [4:0]  RdW
);

    reg         RegWriteEnM_R;
    reg         MemtoRegM_R;
    reg         JALM_R;
    reg  [63:0] PcPlus4M_R;
    reg  [63:0] ALUResultM_R;
    reg  [63:0] ReadDataM_R;     // Data loaded from memory (64-bit, sign-extended)
    reg  [4:0]  RdM_R;

    wire [31:0] effAddress  = ALUResultM[31:0];
    wire [1:0]  byteOffset  = effAddress[1:0];    // which byte in 32-bit word
    wire [12:0] baseAddress = effAddress[14:2];     // top 13 bits for address

    wire [31:0] writeData32 = ReadData2M[31:0];

    // Write-Enable Logic
    reg wren_lane0, wren_lane1, wren_lane2, wren_lane3;

    always @* begin
        // Default values
        wren_lane0 = 1'b0;
        wren_lane1 = 1'b0;
        wren_lane2 = 1'b0;
        wren_lane3 = 1'b0;

        if (MemWriteEnM) begin
            case (MemSizeM)
                2'b00: begin // SB
                    case (byteOffset)
                        2'b00: wren_lane0 = 1'b1;
                        2'b01: wren_lane1 = 1'b1;
                        2'b10: wren_lane2 = 1'b1;
                        2'b11: wren_lane3 = 1'b1;
                    endcase
                end
                2'b01: begin // SH
                    if (byteOffset == 2'b00) begin
                        wren_lane0 = 1'b1;
                        wren_lane1 = 1'b1;
                    end else if (byteOffset == 2'b10) begin
                        wren_lane2 = 1'b1;
                        wren_lane3 = 1'b1;
                    end
                end
                2'b10: begin // SW
                    if (byteOffset == 2'b00) begin
                        wren_lane0 = 1'b1;
                        wren_lane1 = 1'b1;
                        wren_lane2 = 1'b1;
                        wren_lane3 = 1'b1;
                    end
                end
            endcase
        end
    end

    // Lane Instantiations
    wire [7:0] readData0, readData1, readData2, readData3;

    DataMemory dataMemory_lane0 (.address(baseAddress), .clken(1'b1), .clock(clk),
        .data(writeData32[7:0]), .rden(MemReadEnM), .wren(wren_lane0), .q(readData0));

    DataMemory dataMemory_lane1 (.address(baseAddress), .clken(1'b1), .clock(clk),
        .data(writeData32[15:8]), .rden(MemReadEnM), .wren(wren_lane1), .q(readData1));

    DataMemory dataMemory_lane2 (.address(baseAddress), .clken(1'b1), .clock(clk),
        .data(writeData32[23:16]), .rden(MemReadEnM), .wren(wren_lane2), .q(readData2));

    DataMemory dataMemory_lane3 (.address(baseAddress), .clken(1'b1), .clock(clk),
        .data(writeData32[31:24]), .rden(MemReadEnM), .wren(wren_lane3), .q(readData3));

    wire [31:0] memReadData_comb = {readData3, readData2, readData1, readData0};
    reg [31:0] loadData32;

    always @* begin
        loadData32 = 32'b0;
        if (MemReadEnM) begin
            case (LoadSizeM)
                2'b00: begin // LB
                    case (byteOffset)
                        2'b00: loadData32 = {{24{memReadData_comb[7]}}, memReadData_comb[7:0]};
                        2'b01: loadData32 = {{24{memReadData_comb[15]}}, memReadData_comb[15:8]};
                        2'b10: loadData32 = {{24{memReadData_comb[23]}}, memReadData_comb[23:16]};
                        2'b11: loadData32 = {{24{memReadData_comb[31]}}, memReadData_comb[31:24]};
                    endcase
                end
                2'b01: begin // LH
                    if (byteOffset == 2'b00)
                        loadData32 = {{16{memReadData_comb[15]}}, memReadData_comb[15:0]};
                    else if (byteOffset == 2'b10)
                        loadData32 = {{16{memReadData_comb[31]}}, memReadData_comb[31:16]};
                end
                2'b10: loadData32 = {{32{memReadData_comb[31]}}, memReadData_comb}; // LW: Sign-extend
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteEnM_R <= 0;
            MemtoRegM_R <= 0;
            JALM_R <= 0;
            PcPlus4M_R <= 64'b0;
            ALUResultM_R <= 64'b0;
            ReadDataM_R <= 64'b0;
            RdM_R <= 5'b0;
        end else begin
            RegWriteEnM_R <= RegWriteEnM;
            MemtoRegM_R <= MemtoRegM;
            JALM_R <= JALM;
            PcPlus4M_R <= PcPlus4M;
            ALUResultM_R <= ALUResultM;
            if (MemReadEnM)
                ReadDataM_R <= {{32{loadData32[31]}}, loadData32}; // Sign-extend properly    
            RdM_R <= RdM;
        end
        
    end

    // Outputs assignment
    assign RegWriteEnW = RegWriteEnM_R;
    assign MemtoRegW = MemtoRegM_R;
    assign JALW = JALM_R;
    assign PcPlus4W = PcPlus4M_R;
    assign ALUResultW = ALUResultM_R;
    assign ReadDataW = ReadDataM_R; // Use pipeline register to ensure consistent timing
    assign RdW = RdM_R;

endmodule
