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
    output reg        RegWriteEnW,
    output reg        MemtoRegW,
    output reg        JALW,
    output reg [63:0] PcPlus4W,
    output reg [63:0] ALUResultW,
    output reg [63:0] ReadDataW,     // Data loaded from memory (64-bit, sign-extended)
    output reg [4:0]  RdW
);
    //----------------------------------------------------
    // 1) Address Calculation
    //----------------------------------------------------
    wire [31:0] effAddress  = ALUResultM[31:0];
    wire [1:0]  byteOffset  = effAddress[1:0];    // which byte in 32-bit word
    wire [12:0] baseAddress = effAddress[14:2];   // top 13 bits for address

    // We'll store the lower 32 bits of ReadData2M into memory
    wire [31:0] writeData32 = ReadData2M[31:0];

    //----------------------------------------------------
    // 2) Write-Enable Logic
    //----------------------------------------------------
    reg wren_lane0, wren_lane1, wren_lane2, wren_lane3;
    always @* begin
        wren_lane0 = 1'b0;
        wren_lane1 = 1'b0;
        wren_lane2 = 1'b0;
        wren_lane3 = 1'b0;

        if (MemWriteEnM) begin
            case (MemSizeM)
                2'b00: begin
                    // SB => store 1 byte => offset picks the lane
                    case (byteOffset)
                        2'b00: wren_lane0 = 1'b1;
                        2'b01: wren_lane1 = 1'b1;
                        2'b10: wren_lane2 = 1'b1;
                        2'b11: wren_lane3 = 1'b1;
                    endcase
                end
                2'b01: begin
                    // SH => store 2 bytes => offset=0 => lanes0..1, offset=2 => lanes2..3
                    if (byteOffset == 2'b00) begin
                        wren_lane0 = 1'b1;
                        wren_lane1 = 1'b1;
                    end else if (byteOffset == 2'b10) begin
                        wren_lane2 = 1'b1;
                        wren_lane3 = 1'b1;
                    end
                end
                2'b10: begin
                    // SW => store 4 bytes => offset=0 => lanes0..3
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

    //----------------------------------------------------
    // 3) Instantiate Four Single-Port Byte RAMs
    //----------------------------------------------------
    // DataMemory IP: address[12:0], clken, clock, data[7:0],
    //                rden, wren, q[7:0]
    // We'll combine them to form a 32-bit interface.

    wire [7:0] readData0, readData1, readData2, readData3;

    // Lane 0
    DataMemory dataMemory_lane0 (
        .address (baseAddress),
        .clken   (1'b1),
        .clock   (clk),
        .data    (writeData32[7:0]),
        .rden    (MemReadEnM),
        .wren    (wren_lane0),
        .q       (readData0)
    );

    // Lane 1
    DataMemory dataMemory_lane1 (
        .address (baseAddress),
        .clken   (1'b1),
        .clock   (clk),
        .data    (writeData32[15:8]),
        .rden    (MemReadEnM),
        .wren    (wren_lane1),
        .q       (readData1)
    );

    // Lane 2
    DataMemory dataMemory_lane2 (
        .address (baseAddress),
        .clken   (1'b1),
        .clock   (clk),
        .data    (writeData32[23:16]),
        .rden    (MemReadEnM),
        .wren    (wren_lane2),
        .q       (readData2)
    );

    // Lane 3
    DataMemory dataMemory_lane3 (
        .address (baseAddress),
        .clken   (1'b1),
        .clock   (clk),
        .data    (writeData32[31:24]),
        .rden    (MemReadEnM),
        .wren    (wren_lane3),
        .q       (readData3)
    );

    // Combine them into a 32-bit word
    wire [31:0] memReadData_comb = {readData3, readData2, readData1, readData0};

    //----------------------------------------------------
    // 4) Pipeline Registers for One-Cycle Read Latency
    //----------------------------------------------------
    reg [31:0] memData_reg;   // latched RAM output
    reg [1:0]  LoadSize_reg;  // latched load size
    reg [1:0]  byteOffset_reg;// latched offset
    reg        MemReadEn_reg; // latched read enable

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            memData_reg    <= 32'd0;
            LoadSize_reg   <= 2'd0;
            byteOffset_reg <= 2'd0;
            MemReadEn_reg  <= 1'b0;
        end else begin
            // Latch the RAM output this cycle, for sign-extension next cycle
            memData_reg    <= memReadData_comb;
            LoadSize_reg   <= LoadSizeM;
            byteOffset_reg <= byteOffset;
            MemReadEn_reg  <= MemReadEnM;
        end
    end

    //----------------------------------------------------
    // 5) MEM->WB Pipeline Register + Sign-Extension
    //----------------------------------------------------
    reg [31:0] loadData32;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteEnW <= 1'b0;
            MemtoRegW   <= 1'b0;
            JALW        <= 1'b0;
            PcPlus4W    <= 64'd0;
            ALUResultW  <= 64'd0;
            RdW         <= 5'd0;
            loadData32  <= 32'd0;
        end else begin
            // Pass pipeline signals
            RegWriteEnW <= RegWriteEnM;
            MemtoRegW   <= MemtoRegM;
            JALW        <= JALM;
            PcPlus4W    <= PcPlus4M;
            ALUResultW  <= ALUResultM;
            RdW         <= RdM;

            // Default to 0 if no read
            loadData32  <= 32'd0;

            // Sign-extend only if we did a read
            if (MemReadEn_reg) begin
                case (LoadSize_reg)
                    2'b00: begin
                        // LB => load one byte, sign-extend
                        case (byteOffset_reg)
                            2'b00: loadData32 <= {{24{memData_reg[7]}},  memData_reg[7:0]};
                            2'b01: loadData32 <= {{24{memData_reg[15]}}, memData_reg[15:8]};
                            2'b10: loadData32 <= {{24{memData_reg[23]}}, memData_reg[23:16]};
                            2'b11: loadData32 <= {{24{memData_reg[31]}}, memData_reg[31:24]};
                        endcase
                    end
                    2'b01: begin
                        // LH => load half-word, sign-extend
                        case (byteOffset_reg)
                            2'b00: loadData32 <= {{16{memData_reg[15]}}, memData_reg[15:0]};
                            2'b10: loadData32 <= {{16{memData_reg[31]}}, memData_reg[31:16]};
                        endcase
                    end
                    2'b10: begin
                        // LW => load word
                        // offset=0 => use entire memData_reg
                        if (byteOffset_reg == 2'b00)
                            loadData32 <= memData_reg;
                    end
                    // 2'b11 => (not used or LBU/LHU if extended)
                endcase
            end
        end
    end

    // Finally sign-extend from 32 -> 64 bits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ReadDataW <= 64'd0;
        end else begin
            ReadDataW <= {{32{loadData32[31]}}, loadData32};
        end
    end

endmodule
