`timescale 1ns / 1ps
module forwarding_unit_tb();

    // Testbench signals
    reg EX_MEM_RegWriteEn;
    reg MEM_WB_RegWriteEn;
    reg [4:0] EX_MEM_rd;
    reg [4:0] MEM_WB_rd;
    reg [4:0] ID_EX_rs1;
    reg [4:0] ID_EX_rs2;
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    // Instantiate the forwarding_unit module
    forwarding_unit uut (
        .EX_MEM_RegWriteEn(EX_MEM_RegWriteEn),
        .MEM_WB_RegWriteEn(MEM_WB_RegWriteEn),
        .EX_MEM_rd(EX_MEM_rd),
        .MEM_WB_rd(MEM_WB_rd),
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    //monitoring the whole values of forwardA and forwardB and registers
    initial begin
        $monitor("Time=%d, forwardA = %b, forwardB = %b, EX_MEM_RegWriteEn = %b, MEM_WB_RegWriteEn = %b, EX_MEM_rd = %b, MEM_WB_rd = %b, ID_EX_rs1 = %b, ID_EX_rs2 = %b", $time, forwardA, forwardB, EX_MEM_RegWriteEn, MEM_WB_RegWriteEn, EX_MEM_rd, MEM_WB_rd, ID_EX_rs1, ID_EX_rs2);
    end
    // Initial block for simulation setup
    initial begin
        // Initialize signals
        EX_MEM_RegWriteEn = 0;
        MEM_WB_RegWriteEn = 0;
        EX_MEM_rd = 5'b0;
        MEM_WB_rd = 5'b0;
        ID_EX_rs1 = 5'b0;
        ID_EX_rs2 = 5'b0;

        // Test no forwarding
        #10 ID_EX_rs1 = 5'b00001; ID_EX_rs2 = 5'b00010;
        #10 EX_MEM_RegWriteEn = 1; EX_MEM_rd = 5'b00001; MEM_WB_RegWriteEn = 1; MEM_WB_rd = 5'b00010;
        #10;

        // Test forwarding from MEM/WB
        #10 ID_EX_rs1 = 5'b00001; ID_EX_rs2 = 5'b00010;
        #10 EX_MEM_RegWriteEn = 1; EX_MEM_rd = 5'b00000; MEM_WB_RegWriteEn = 1; MEM_WB_rd = 5'b00001;
        #10;

        // Test forwarding from EX/MEM
        #10 ID_EX_rs1 = 5'b00001; ID_EX_rs2 = 5'b00010;
        #10 EX_MEM_RegWriteEn = 1; EX_MEM_rd = 5'b00001; MEM_WB_RegWriteEn = 1; MEM_WB_rd = 5'b00000;
        #10;
    end
endmodule