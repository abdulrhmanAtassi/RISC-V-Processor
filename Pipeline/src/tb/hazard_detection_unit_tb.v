`timescale 1ns/1ps

module hazard_detection_unit_tb;

    // Inputs
    reg ID_EX_MemReadEn;
    reg [4:0] ID_EX_rdE;
    reg [4:0] rs1D;
    reg [4:0] rs2D;
    reg Branch_Detected;

    // Outputs
    wire PCWrite;
    wire IF_IDWrite;
    wire ID_EXBubble;
    wire IF_IDFlush;

    // Instantiate the Unit Under Test (UUT)
    hazard_detection_unit uut (
        .ID_EX_MemReadEn(ID_EX_MemReadEn),
        .ID_EX_rdE(ID_EX_rdE),
        .rs1D(rs1D),
        .rs2D(rs2D),
        .Branch_Detected(Branch_Detected),
        .PCWrite(PCWrite),
        .IF_IDWrite(IF_IDWrite),
        .ID_EXBubble(ID_EXBubble),
        .IF_IDFlush(IF_IDFlush)
    );

    // Test procedure
    initial begin
        $monitor($time, " MemReadEn=%b, rdE=%d, rs1D=%d, rs2D=%d, Branch=%b | PCWrite=%b, IF_IDWrite=%b, ID_EXBubble=%b, IF_IDFlush=%b",
                 ID_EX_MemReadEn, ID_EX_rdE, rs1D, rs2D, Branch_Detected, PCWrite, IF_IDWrite, ID_EXBubble, IF_IDFlush);

        // Initialize inputs
        ID_EX_MemReadEn = 0;
        ID_EX_rdE = 0;
        rs1D = 0;
        rs2D = 0;
        Branch_Detected = 0;
        #10;

        // Case 1: No hazard, default operation
        ID_EX_MemReadEn = 0;
        ID_EX_rdE = 5'd10;
        rs1D = 5'd1;
        rs2D = 5'd2;
        Branch_Detected = 0;
        #10;

        // Case 2: Load-use hazard on rs1
        ID_EX_MemReadEn = 1;
        ID_EX_rdE = 5'd3;
        rs1D = 5'd3;  // rs1 matches rdE
        rs2D = 5'd4;
        Branch_Detected = 0;
        #10;

        // Case 3: Load-use hazard on rs2
        ID_EX_MemReadEn = 1;
        ID_EX_rdE = 5'd4;
        rs1D = 5'd5;
        rs2D = 5'd4;  // rs2 matches rdE
        Branch_Detected = 0;
        #10;

        // Case 4: No load-use hazard
        ID_EX_MemReadEn = 1;
        ID_EX_rdE = 5'd6;
        rs1D = 5'd7;
        rs2D = 5'd8;
        Branch_Detected = 0;
        #10;

        // Case 5: Branch detected
        ID_EX_MemReadEn = 0;
        ID_EX_rdE = 5'd9;
        rs1D = 5'd10;
        rs2D = 5'd11;
        Branch_Detected = 1;  // Branch detected
        #10;

        // Case 6: Both load-use hazard and branch detected (priority case)
        ID_EX_MemReadEn = 1;
        ID_EX_rdE = 5'd12;
        rs1D = 5'd12;
        rs2D = 5'd13;
        Branch_Detected = 1;  // Branch detected
        #10;

        // Finish simulation
        $finish;
    end

endmodule
