module fetch_stage_tb;

    // Testbench signals
    reg clk;
    reg rst;
    reg PCSrcD;
    reg JalD;
    reg [31:0] PCTargetD;
    wire [31:0] InstrD;
    wire [31:0] PCD, PCPlus4D;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns clock period

    // Instantiate the fetch_stage module
    fetch_stage uut (
        .clk(clk),
        .rst(rst),
        .PCSrcD(PCSrcD),
        .JalD(JalD),
        .PCTargetD(PCTargetD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // Simulated instruction memory (stub)
    reg [31:0] instruction_memory [0:15]; // Small instruction memory for testing

    initial begin
        // Initialize instruction memory
        instruction_memory[0] = 32'h00000001; // Sample instruction 1
        instruction_memory[1] = 32'h00000002; // Sample instruction 2
        instruction_memory[2] = 32'h00000003; // Sample instruction 3
        instruction_memory[3] = 32'h00000004; // Sample instruction 4
    end

    // Override instruction memory (stub the IMEM in fetch_stage)
    assign uut.IMEM.q = instruction_memory[uut.IMEM.adress[3:0]];

    // Testbench procedure
    initial begin
        // Initial conditions
        rst = 1;
        PCSrcD = 0;
        JalD = 0;
        PCTargetD = 0;

        // Reset phase
        #10 rst = 0; // Apply reset
        #10 rst = 1; // Release reset

        // Test case 1: Normal PC increment (PC + 4)
        #10;
        PCSrcD = 0;
        JalD = 0;
        #20; // Wait two clock cycles

        // Test case 2: Branch/jump to PCTargetD
        #10;
        PCSrcD = 1;
        PCTargetD = 32'h00000010; // Set target PC
        #20;
        PCSrcD = 0; // Return to normal increment

        // Test case 3: JalD (simulating jump and link)
        #10;
        JalD = 1;
        PCTargetD = 32'h00000020; // Set jump address
        #20;
        JalD = 0; // Return to normal increment

        // Test case 4: Random instruction checks
        #10;
        PCTargetD = 32'h00000004; // Address to fetch specific instruction
        PCSrcD = 1;
        #20;

        // End simulation
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor(
            "Time=%0t | clk=%b | rst=%b | PCSrcD=%b | JalD=%b | PCTargetD=%h | InstrD=%h | PCD=%h | PCPlus4D=%h",
            $time, clk, rst, PCSrcD, JalD, PCTargetD, InstrD, PCD, PCPlus4D
        );
    end

endmodule
