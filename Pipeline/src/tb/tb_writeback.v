`timescale 1ns/1ps

module tb_writeback;

    // -------------------------------
    // Testbench Signals
    // -------------------------------
    reg         clk;
    reg         rst;
    reg  [4:0]  RD_M;
    reg         RegWriteEn_M;
    reg         MemtoReg_M;
    reg         JAL_M;
    reg  [31:0] PCPlus4W;
    reg  [31:0] ALU_ResultW;
    reg  [31:0] ReadDataW;
    
    wire [4:0]  RD_W;
    wire [31:0] ResultW;

    // -------------------------------
    // Clock Generation
    // -------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // -------------------------------
    // DUT Instantiation
    // -------------------------------
    writeback_stage DUT (
        .clk          (clk),
        .rst          (rst),
        .RD_M         (RD_M),
        .RegWriteEn_M (RegWriteEn_M),
        .MemtoReg_M   (MemtoReg_M),
        .JAL_M        (JAL_M),
        .PCPlus4W     (PCPlus4W),
        .ALU_ResultW  (ALU_ResultW),
        .ReadDataW    (ReadDataW),
        .RD_W         (RD_W),
        .ResultW      (ResultW)
    );

    // -------------------------------
    // Stimulus
    // -------------------------------
    initial begin
        // Initialize signals
        rst          = 1;
        RD_M         = 5'd0;
        RegWriteEn_M = 0;
        MemtoReg_M   = 0;
        JAL_M        = 0;
        PCPlus4W     = 32'h0000_0004;
        ALU_ResultW  = 32'hAAAA_AAAA;
        ReadDataW    = 32'h5555_5555;
        
        // Wait a couple of clock edges for reset
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        
        // TEST 1: Normal ALU Write-Back (JAL=0, MemtoReg=0)
        // Expect: ResultW = ALU_ResultW after the next rising edge
        RD_M         = 5'd10;
        RegWriteEn_M = 1;
        MemtoReg_M   = 0; 
        JAL_M        = 0; 
        ALU_ResultW  = 32'hAAAA_AAAA;
        ReadDataW    = 32'h5555_5555;
        PCPlus4W     = 32'h0000_00F0;
        
        @(posedge clk);  // Wait one clock
        $display("Time=%0t | [ALU] RD_W=%0d, ResultW=0x%08h", 
                 $time, RD_W, ResultW);
        
        // TEST 2: Memory Load (JAL=0, MemtoReg=1)
        // Expect: ResultW = ReadDataW
        RD_M         = 5'd11;
        RegWriteEn_M = 1;
        MemtoReg_M   = 1; 
        JAL_M        = 0; 
        ALU_ResultW  = 32'hBBBB_BBBB;
        ReadDataW    = 32'hCCCC_CCCC;
        PCPlus4W     = 32'h0000_0F00;
        
        @(posedge clk);
        $display("Time=%0t | [MEM] RD_W=%0d, ResultW=0x%08h", 
                 $time, RD_W, ResultW);

        // TEST 3: Jump And Link (JAL=1, MemtoReg=0)
        // Expect: ResultW = PCPlus4W
        RD_M         = 5'd12;
        RegWriteEn_M = 1;
        MemtoReg_M   = 0;
        JAL_M        = 1;
        ALU_ResultW  = 32'hDDDD_DDDD;
        ReadDataW    = 32'hEEEE_EEEE;
        PCPlus4W     = 32'h0000_F000;

        @(posedge clk);
        $display("Time=%0t | [JAL] RD_W=%0d, ResultW=0x%08h", 
                 $time, RD_W, ResultW);
        
        // TEST 4: No Register Write (RegWriteEn=0)
        // Expect: ResultW = 0 on next cycle (based on DUT code)
        RD_M         = 5'd15;
        RegWriteEn_M = 0;  // Disables writing the result
        MemtoReg_M   = 0;
        JAL_M        = 0;
        ALU_ResultW  = 32'h9999_9999;
        ReadDataW    = 32'h8888_8888;
        PCPlus4W     = 32'h0000_1111;

        @(posedge clk);
        $display("Time=%0t | [No Write] RD_W=%0d, ResultW=0x%08h", 
                 $time, RD_W, ResultW);

        // Finish the simulation
        @(posedge clk);
        $display("Testbench completed at time=%0t", $time);
        $stop;
    end

endmodule
