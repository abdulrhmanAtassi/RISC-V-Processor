`timescale 1ns / 1ps

module EqReg_tb;

    // Testbench signals
    reg [63:0] Data1;        // 63-bit input data1
    reg [63:0] Data2;        // 63-bit input data2
    reg BranchType;          // Branch type (1 for equality, 0 for inequality)
    wire Branch;             // Output signal indicating branch decision

    // Instantiate the EqReg module
    EqReg uut (
        .Data1(Data1),
        .Data2(Data2),
        .BranchType(BranchType),
        .Branch(Branch)
    );

    // Test procedure
    initial begin
        // Apply test vectors to check all conditions

        // Test case 1: Data1 == Data2, BranchType = 1 (Equality branch)
        Data1 = 63'd42;  // Data1 = 42
        Data2 = 63'd42;  // Data2 = 42
        BranchType = 1;  // Equality branch
        #10;             // Wait for 10 time units
        $display("Test Case 1: Data1 = %d, Data2 = %d, BranchType = %b, Branch = %b", Data1, Data2, BranchType, Branch);

        // Test case 2: Data1 != Data2, BranchType = 1 (Equality branch)
        Data1 = 63'd42;  // Data1 = 42
        Data2 = 63'd15;  // Data2 = 15
        BranchType = 1;  // Equality branch
        #10;             // Wait for 10 time units
        $display("Test Case 2: Data1 = %d, Data2 = %d, BranchType = %b, Branch = %b", Data1, Data2, BranchType, Branch);

        // Test case 3: Data1 != Data2, BranchType = 0 (Inequality branch)
        Data1 = 63'd42;  // Data1 = 42
        Data2 = 63'd15;  // Data2 = 15
        BranchType = 0;  // Inequality branch
        #10;             // Wait for 10 time units
        $display("Test Case 3: Data1 = %d, Data2 = %d, BranchType = %b, Branch = %b", Data1, Data2, BranchType, Branch);

        // Test case 4: Data1 == Data2, BranchType = 0 (Inequality branch)
        Data1 = 63'd42;  // Data1 = 42
        Data2 = 63'd42;  // Data2 = 42
        BranchType = 0;  // Inequality branch
        #10;             // Wait for 10 time units
        $display("Test Case 4: Data1 = %d, Data2 = %d, BranchType = %b, Branch = %b", Data1, Data2, BranchType, Branch);

        // Finish simulation
        $finish;
    end

endmodule
