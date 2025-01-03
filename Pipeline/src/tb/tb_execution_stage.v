`timescale 1ns / 1ps

module tb_execution_stage;

    // --------------------------------------
    // Testbench signals
    // --------------------------------------
    reg               clk;
    reg               rst;
    reg               RegWriteEnE;
    reg               MemtoRegE;
    reg               JALE;
    reg               MemReadEnE;
    reg               MemWriteEnE;
    reg               ALUSrcE;      // For I-type, we typically set ALUSrc=1
    reg  [1:0]        MemSizeE;     // Byte/Half/Word/Double? Adjust as needed
    reg  [1:0]        LoadSizeE;    // Similarly for loads
    reg  [2:0]        ALUOpE;       // This is from your table: R=000, I=001, S=010, JAL=011, etc.
    reg  [2:0]        funct3E;
    reg  [4:0]        RdE;
    reg  [6:0]        funct7E;
    reg  [63:0]       PCPlus4E;
    reg  signed [63:0] ImmE;
    reg  signed [63:0] ReadData1E;
    reg  signed [63:0] ReadData2E;

    wire              RegWriteEnM;
    wire              MemtoRegM;
    wire              JALM;
    wire              MemReadEnM;
    wire              MemWriteEnM;
    wire [1:0]        MemSizeM;
    wire [1:0]        LoadSizeM;
    wire [4:0]        RdM;
    wire [63:0]       PcPlus4M;
    wire signed [63:0] ReadData2M;
    wire signed [63:0] ALUResultM;

    // --------------------------------------
    // DUT Instantiation
    // --------------------------------------
    execution_stage dut (
        .clk         (clk),
        .rst         (rst),
        .RegWriteEnE (RegWriteEnE),
        .MemtoRegE   (MemtoRegE),
        .JALE        (JALE),
        .MemReadEnE  (MemReadEnE),
        .MemWriteEnE (MemWriteEnE),
        .ALUSrcE     (ALUSrcE),
        .MemSizeE    (MemSizeE),
        .LoadSizeE   (LoadSizeE),
        .ALUOpE      (ALUOpE),
        .funct3E     (funct3E),
        .RdE         (RdE),
        .funct7E     (funct7E),
        .PCPlus4E    (PCPlus4E),
        .ImmE        (ImmE),
        .ReadData1E  (ReadData1E),
        .ReadData2E  (ReadData2E),

        .RegWriteEnM (RegWriteEnM),
        .MemtoRegM   (MemtoRegM),
        .JALM        (JALM),
        .MemReadEnM  (MemReadEnM),
        .MemWriteEnM (MemWriteEnM),
        .MemSizeM    (MemSizeM),
        .LoadSizeM   (LoadSizeM),
        .RdM         (RdM),
        .PcPlus4M    (PcPlus4M),
        .ReadData2M  (ReadData2M),
        .ALUResultM  (ALUResultM)
    );

    // --------------------------------------
    // Clock generation: 10 ns period
    // --------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --------------------------------------
    // apply_test task
    // --------------------------------------
    task apply_test;
        input [2:0]  t_ALUOpE;
        input [2:0]  t_funct3E;
        input [6:0]  t_funct7E;
        input        t_RegWriteEnE;
        input        t_MemtoRegE;
        input        t_JALE;
        input        t_MemReadEnE;
        input        t_MemWriteEnE;
        input        t_ALUSrcE;
        input [1:0]  t_MemSizeE;
        input [1:0]  t_LoadSizeE;
        input [63:0] t_PCPlus4E;
        input [63:0] t_ImmE;
        input [63:0] t_ReadData1E;
        input [63:0] t_ReadData2E;
        input [4:0]  t_RdE;
        input [31:0] wait_cycles;
        input [79:0] instr_name; // for printing in $display

        begin
            $display("\n--- Starting test: %0s ---", instr_name);
            
            ALUOpE      = t_ALUOpE;
            funct3E     = t_funct3E;
            funct7E     = t_funct7E;
            RegWriteEnE = t_RegWriteEnE;
            MemtoRegE   = t_MemtoRegE;
            JALE        = t_JALE;
            MemReadEnE  = t_MemReadEnE;
            MemWriteEnE = t_MemWriteEnE;
            ALUSrcE     = t_ALUSrcE;
            MemSizeE    = t_MemSizeE;
            LoadSizeE   = t_LoadSizeE;
            PCPlus4E    = t_PCPlus4E;
            ImmE        = t_ImmE;
            ReadData1E  = t_ReadData1E;
            ReadData2E  = t_ReadData2E;
            RdE         = t_RdE;

            // Wait
            repeat(wait_cycles) @(posedge clk);

            // Print some outputs
            $display("   ALUResultM  = %0d (0x%0h)", ALUResultM, ALUResultM);
            $display("   RegWriteEnM = %b", RegWriteEnM);
            $display("   MemReadEnM  = %b, MemWriteEnM = %b", MemReadEnM, MemWriteEnM);
            $display("   RdM         = %d", RdM);
            $display("--- End of test: %0s ---", instr_name);
        end
    endtask

    // --------------------------------------
    // Main Test Sequence
    // --------------------------------------
    initial begin
        // Initial reset
        rst          = 1;
        RegWriteEnE  = 0;
        MemtoRegE    = 0;
        JALE         = 0;
        MemReadEnE   = 0;
        MemWriteEnE  = 0;
        ALUSrcE      = 0;
        MemSizeE     = 2'b00;
        LoadSizeE    = 2'b00;
        ALUOpE       = 3'b000;
        funct3E      = 3'b000;
        funct7E      = 7'b0000000;
        PCPlus4E     = 64'h0;
        ImmE         = 64'h0;
        ReadData1E   = 64'h0;
        ReadData2E   = 64'h0;
        RdE          = 5'd0;

        // Wait a few cycles in reset
        #12;
        rst = 0;

        // --------------------------------------------------------
        //  Instruction Table from your specification
        // --------------------------------------------------------
        // NAME   | ALUOp | funct3 | funct7 | Comments
        // ------ | ----- | ------ | ------ | ----------------------
        // addiw  | 001   | 0x00   |  N/A   | I-type
        // andi   | 001   | 0x06   |  N/A   | I-type
        // jalr   | 011   | 0x00   |  N/A   | JAL
        // lh     | 100   | 0x02   |  N/A   | LOAD
        // lw     | 100   | 0x00   |  N/A   | LOAD
        // ori    | 001   | 0x07   |  N/A   | I-type
        // addw   | 000   | 0x01   | 0x20   | R-type
        // and    | 000   | 0x07   | 0x00   | R-type
        // xor    | 000   | 0x03   | 0x00   | R-type
        // or     | 000   | 0x05   | 0x00   | R-type
        // slt    | 000   | 0x00   | 0x00   | R-type
        // sll    | 000   | 0x04   | 0x00   | R-type
        // srl    | 000   | 0x02   | 0x00   | R-type
        // sub    | 000   | 0x06   | 0x00   | R-type
        // sb     | 010   | 0x00   |  N/A   | S-type
        // sw     | 010   | 0x02   |  N/A   | S-type
        // beq    | 101   | 0x00   |  N/A   | BRANCH
        // bne    | 101   | 0x01   |  N/A   | BRANCH
        // lui    | 111   |   -    |   -    | U-type
        // jal    | 011   |   -    |   -    | JAL

        // 1) addiw (I-type, ALUOp=001, funct3=0x00)
        apply_test(3'b001, 3'h0, 7'b0000000,
                   1,0,0,   // RegWrite=1, MemtoReg=0, JALE=0
                   0,0,     // MemRead=0, MemWrite=0
                   1,       // ALUSrc=1 (I-type)
                   2'b00,2'b00,
                   64'h1000, // PCPlus4E
                   64'd5,    // ImmE
                   64'd20,   // ReadData1E
                   64'd999,  // ReadData2E (unused in I-type)
                   5'd1,
                   5, "addiw");

        // 2) andi (I-type, ALUOp=001, funct3=0x06)
        apply_test(3'b001, 3'h6, 7'b0000000,
                   1,0,0,
                   0,0,
                   1,
                   2'b00,2'b00,
                   64'h1004,
                   64'hFF0F,  // imm
                   64'hABCD_EF, // R1
                   64'd0,
                   5'd2,
                   5, "andi");

        // 3) jalr (JAL, ALUOp=011, funct3=0x00)
        // Typically sets JALE=1 and ALUSrc=1 if you compute PC=R1+imm
        apply_test(3'b011, 3'h0, 7'b0000000,
                   1,0,1,   // RegWrite=1, MemtoReg=0, JALE=1
                   0,0,
                   1,
                   2'b00,2'b00,
                   64'h1008,
                   64'd8,   // imm
                   64'h200, // R1
                   64'd0,
                   5'd3,
                   5, "jalr");

        // 4) lh (LOAD-type, ALUOp=100, funct3=0x02)
        // R1 + imm => address for halfword load
        apply_test(3'b100, 3'h2, 7'b0000000,
                   1,1,0,   // RegWrite=1, MemtoReg=1
                   1,0,     // MemRead=1, MemWrite=0
                   1,       // ALUSrc=1
                   2'b01, 2'b01, // halfword
                   64'h100C,
                   64'd4,   // imm
                   64'h100, // base address
                   64'd0,
                   5'd4,
                   5, "lh");

        // 5) lw (LOAD-type, ALUOp=100, funct3=0x00)
        apply_test(3'b100, 3'h0, 7'b0000000,
                   1,1,0,
                   1,0,
                   1,
                   2'b10,2'b10, // word
                   64'h1010,
                   64'd8,
                   64'h200,
                   64'd0,
                   5'd5,
                   5, "lw");

        // 6) ori (I-type, ALUOp=001, funct3=0x07)
        apply_test(3'b001, 3'h7, 7'b0000000,
                   1,0,0,
                   0,0,
                   1,
                   2'b00,2'b00,
                   64'h1014,
                   64'hF0F0,
                   64'hA5A5,
                   64'd0,
                   5'd6,
                   5, "ori");

        // 7) addw (R-type, ALUOp=000, funct3=0x01, funct7=0x20)
        apply_test(3'b000, 3'h1, 7'h20,
                   1,0,0,
                   0,0,
                   0, // R-type => ALUSrc=0
                   2'b00,2'b00,
                   64'h1018,
                   64'd0,
                   64'd10,
                   64'd5,
                   5'd7,
                   5, "addw");

        // 8) and  (R-type, ALUOp=000, funct3=0x07, funct7=0x00)
        apply_test(3'b000, 3'h7, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h101C,
                   64'd0,
                   64'hF0F0_F0F0_F0F0_F0F0,
                   64'h5555_AAAA_5555_AAAA,
                   5'd8,
                   5, "and");

        // 9) xor  (R-type, ALUOp=000, funct3=0x03, funct7=0x00)
        apply_test(3'b000, 3'h3, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1020,
                   64'd0,
                   64'd1234,
                   64'd999,
                   5'd9,
                   5, "xor");

        // 10) or  (R-type, ALUOp=000, funct3=0x05, funct7=0x00)
        apply_test(3'b000, 3'h5, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1024,
                   64'd0,
                   64'h0F0F,
                   64'hF000,
                   5'd10,
                   5, "or");

        // 11) slt (R-type, ALUOp=000, funct3=0x00, funct7=0x00)
        apply_test(3'b000, 3'h0, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1028,
                   64'd0,
                   64'd1,
                   64'd10,
                   5'd11,
                   5, "slt");

        // 12) sll (R-type, ALUOp=000, funct3=0x04, funct7=0x00)
        apply_test(3'b000, 3'h4, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h102C,
                   64'd0,
                   64'd1,
                   64'd3,
                   5'd12,
                   5, "sll");

        // 13) srl (R-type, ALUOp=000, funct3=0x02, funct7=0x00)
        apply_test(3'b000, 3'h2, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1030,
                   64'd0,
                   64'hF0,
                   64'd4,
                   5'd13,
                   5, "srl");

        // 14) sub (R-type, ALUOp=000, funct3=0x06, funct7=0x00)
        apply_test(3'b000, 3'h6, 7'h00,
                   1,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1034,
                   64'd0,
                   64'd20,
                   64'd7,
                   5'd14,
                   5, "sub");

        // 15) sb (S-type, ALUOp=010, funct3=0x00)
        // MemWrite=1, size=byte
        apply_test(3'b010, 3'h0, 7'b0000000,
                   0,0,0,  // RegWrite=0, MemtoReg=0
                   0,1,    // Read=0, Write=1
                   1,      // ALUSrc=1 => address = R1+imm
                   2'b00,2'b00,
                   64'h1038,
                   64'd4,
                   64'h300,
                   64'd0,
                   5'd0,
                   5, "sb");

        // 16) sw (S-type, ALUOp=010, funct3=0x02)
        // MemWrite=1, size=word
        apply_test(3'b010, 3'h2, 7'b0000000,
                   0,0,0,
                   0,1,
                   1,
                   2'b10,2'b10,
                   64'h103C,
                   64'd8,
                   64'h400,
                   64'd12345,
                   5'd0,
                   5, "sw");

        // 17) beq (BRANCH, ALUOp=101, funct3=0x00)
        apply_test(3'b101, 3'h0, 7'b0000000,
                   0,0,0,
                   0,0,
                   0, // Usually branch offset from Imm
                   2'b00,2'b00,
                   64'h1040,
                   64'd16,
                   64'd10,
                   64'd10,  // R1 == R2 => branch taken
                   5'd0,
                   5, "beq");

        // 18) bne (BRANCH, ALUOp=101, funct3=0x01)
        apply_test(3'b101, 3'h1, 7'b0000000,
                   0,0,0,
                   0,0,
                   0,
                   2'b00,2'b00,
                   64'h1044,
                   64'd20,
                   64'd1,
                   64'd2,   // R1 != R2 => branch taken
                   5'd0,
                   5, "bne");

        // 19) lui (U-type, ALUOp=111)
        // Typically: result = imm << 12
        // We'll set ALUSrc=1 to pass imm into the ALU. 
        // If your design for LUI just uses ImmE in a separate path, that’s also valid.
        apply_test(3'b111, 3'h0, 7'b0000000,
                    1,0,0,
                    0,0,
                    1,
                    2'b00,2'b00,
                    64'h1048,
                    64'hFFFF,  // imm
                    64'd0,
                    64'd0,
                    5'd19,
                    5, "lui");

        // 20) jal (JAL, ALUOp=011)
        // Similar to jalr, but we often ignore funct3/funct7. 
        apply_test(3'b011, 3'h0, 7'b0000000,
                    1,0,1,    // RegWrite=1, MemtoReg=0, JALE=1
                    0,0,
                    1,
                    2'b00,2'b00,
                    64'h104C,
                    64'd64,
                    64'd100,
                    64'd0,
                    5'd20,
                    5, "jal");

        // Done
        $display("\nAll 20 instruction tests completed using the new table!\n");
        #20;
        $finish;
    end

endmodule
