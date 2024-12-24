module EqReg (
    input signed [63:0] Data1,   // 64-bit input data1
    input signed [63:0] Data2,   // 64-bit input data2
    input BranchType,            // Branch type (1 for equality, 0 for inequality)
    output reg Branch            // Output signal indicating branch decision
);

    // Evaluate branch condition based on BranchType
    always @(*) begin
        Branch = (BranchType) ? (Data1 == Data2) : (Data1 != Data2);
    end

endmodule
