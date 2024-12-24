`timescale 1ns / 1ps

module memory_stage_tb;
    reg clk;
    reg rst;

    // Control signals
    reg RegWriteEnM;
    reg MemtoRegM;
    reg JALM;
    reg MemReadEnM;
    reg MemWriteEnM;

    // Size signals
    reg [1:0] MemSizeM;
    reg [1:0] LoadSizeM;

    // Data signals
    reg [4:0] RdM;
    reg [63:0] PcPlus4M;
    reg [63:0] ReadData2M;
    reg [63:0] ALUResultM;

    // Outputs
    wire RegWriteEnW;
    wire MemtoRegW;
    wire JALW;
    wire [63:0] PcPlus4W;
    wire [63:0] ALUResultW;
    wire [63:0] ReadDataW;
    wire [4:0] RdW;

    // Instantiate the memory_stage module
    memory_stage uut (
        .clk(clk),
        .rst(rst),
        .RegWriteEnM(RegWriteEnM),
        .MemtoRegM(MemtoRegM),
        .JALM(JALM),
        .MemReadEnM(MemReadEnM),
        .MemWriteEnM(MemWriteEnM),
        .MemSizeM(MemSizeM),
        .LoadSizeM(LoadSizeM),
        .RdM(RdM),
        .PcPlus4M(PcPlus4M),
        .ReadData2M(ReadData2M),
        .ALUResultM(ALUResultM),
        .RegWriteEnW(RegWriteEnW),
        .MemtoRegW(MemtoRegW),
        .JALW(JALW),
        .PcPlus4W(PcPlus4W),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .RdW(RdW)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 1;
        RegWriteEnM = 0;
        MemtoRegM = 0;
        JALM = 0;
        MemReadEnM = 0;
        MemWriteEnM = 0;
        MemSizeM = 2'b00;
        LoadSizeM = 2'b00;
        RdM = 5'd0;
        PcPlus4M = 64'd0;
        ReadData2M = 64'd0;
        ALUResultM = 64'd0;

        // Release reset
        #10 rst = 0;

        // --- Test 1: SB->LB at address=0 offset=0 ---
        // Write byte 0xAA to address 0
        @(posedge clk);
        MemWriteEnM = 1;
        MemSizeM = 2'b00; // SB
        ALUResultM = 64'd0; // address=0
        ReadData2M = 64'h00000000000000AA; // Data to write (only lower byte)
        RdM = 5'd1;
        @(posedge clk);
        MemWriteEnM = 0;

        // Initiate LB read from address=0
        @(posedge clk);
        MemReadEnM = 1;
        LoadSizeM = 2'b00; // LB
        ALUResultM = 64'd0; // address=0
        RdM = 5'd1;
        @(posedge clk);
        MemReadEnM = 0;

        // Wait two cycles for data to propagate through pipeline
        @(posedge clk); // Cycle N+1: Data is in memData_reg
        @(posedge clk); // Cycle N+2: ReadDataW should have the data
        // Check ReadDataW
        $display("Test 1: ReadDataW = %h (Expected: FFFFFFFFFFFFFFAA)", ReadDataW);

        // --- Test 2: SH->LH at address=4 offset=0 ---
        // Write half-word 0xBEEF to address=4
        @(posedge clk);
        MemWriteEnM = 1;
        MemSizeM = 2'b01; // SH
        ALUResultM = 64'd4; // address=4
        ReadData2M = 64'h000000000000BEEF; // Data to write (lower 2 bytes)
        RdM = 5'd2;
        @(posedge clk);
        MemWriteEnM = 0;

        // Initiate LH read from address=4
        @(posedge clk);
        MemReadEnM = 1;
        LoadSizeM = 2'b01; // LH
        ALUResultM = 64'd4; // address=4
        RdM = 5'd2;
        @(posedge clk);
        MemReadEnM = 0;

        // Wait two cycles for data to propagate through pipeline
        @(posedge clk); // Cycle N+1
        @(posedge clk); // Cycle N+2
        // Check ReadDataW
        $display("Test 2: ReadDataW = %h (Expected: FFFFFFFFFFFFFBEEF)", ReadDataW);

        // --- Test 3: SW->LW at address=8 offset=0 ---
        // Write word 0xDEADBEEF to address=8
        @(posedge clk);
        MemWriteEnM = 1;
        MemSizeM = 2'b10; // SW
        ALUResultM = 64'd8; // address=8
        ReadData2M = 64'h00000000DEADBEEF; // Data to write (lower 4 bytes)
        RdM = 5'd3;
        @(posedge clk);
        MemWriteEnM = 0;

        // Initiate LW read from address=8
        @(posedge clk);
        MemReadEnM = 1;
        LoadSizeM = 2'b10; // LW
        ALUResultM = 64'd8; // address=8
        RdM = 5'd3;
        @(posedge clk);
        MemReadEnM = 0;

        // Wait two cycles for data to propagate through pipeline
        @(posedge clk); // Cycle N+1
        @(posedge clk); // Cycle N+2
        // Check ReadDataW
        $display("Test 3: ReadDataW = %h (Expected: FFFFFFFFDEADBEEF)", ReadDataW);

        // --- Test 4: SB->LB at address=0xD offset=1 ---
        // Write byte 0xAB to address=0xD
        @(posedge clk);
        MemWriteEnM = 1;
        MemSizeM = 2'b00; // SB
        ALUResultM = 64'd13; // address=0xD
        ReadData2M = 64'h00000000000000AB; // Data to write (only lower byte)
        RdM = 5'd4;
        @(posedge clk);
        MemWriteEnM = 0;

        // Initiate LB read from address=0xD
        @(posedge clk);
        MemReadEnM = 1;
        LoadSizeM = 2'b00; // LB
        ALUResultM = 64'd13; // address=0xD
        RdM = 5'd4;
        @(posedge clk);
        MemReadEnM = 0;

        // Wait two cycles for data to propagate through pipeline
        @(posedge clk); // Cycle N+1
        @(posedge clk); // Cycle N+2
        // Check ReadDataW
        $display("Test 4: ReadDataW = %h (Expected: FFFFFFFFFFFFFFAB)", ReadDataW);

        // End simulation
        #10 $finish;
    end
endmodule
