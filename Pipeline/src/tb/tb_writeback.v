`timescale 1ns / 1ps

module tb_writeback();

    // Testbench signals
    reg clk;
    reg rst;
    reg [4:0] RDM;
    reg RegWriteEnM;
    reg MemtoRegM;
    reg JALM;
    reg [31:0] PCPlus4W;
    reg [31:0] ALU_ResultW;
    reg [31:0] ReadDataW;

    wire [4:0] RdD;
    wire [31:0] ResultD;
    wire RegWriteEnD;

    // Instantiate the DUT (Device Under Test)
    writeback_stage dut (
        .clk(clk),
        .rst(rst),

        .MemtoRegM(MemtoRegM),
        .JALM(JALM),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .ResultD(ResultD)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        RDM = 5'b0;
        RegWriteEnM = 0;
        MemtoRegM = 0;
        JALM = 0;
        PCPlus4W = 32'b0;
        ALU_ResultW = 32'b0;
        ReadDataW = 32'b0;

        // Apply reset
        #10 rst = 0;

        // Test case 1: Select ALU result
        RDM = 5'd10;
        RegWriteEnM = 1;
        MemtoRegM = 0;
        JALM = 0;
        ALU_ResultW = 32'hAABBCCDD;
        #10;

        // Test case 2: Select memory read data
        MemtoRegM = 1;
        ReadDataW = 32'h11223344;
        #10;

        // Test case 3: Select PC+4 (JAL)
        MemtoRegM = 0;
        JALM = 1;
        PCPlus4W = 32'h55667788;
        #10;

        // Test case 4: Invalid mux select (default to 0)
        MemtoRegM = 1;
        JALM = 1;
        #10;

        // Test case 5: Reset active
        rst = 1;
        #10 rst = 0;

        // End simulation
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0dns, RdD=%b, ResultD=%h, RegWriteEnD=%b", 
                $time, RdD, ResultD, RegWriteEnD);
    end

endmodule
