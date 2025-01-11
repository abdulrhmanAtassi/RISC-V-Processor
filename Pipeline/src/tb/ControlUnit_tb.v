`timescale 1ns/1ps

module ControlUnit_tb;

    // Inputs
    reg  [6:0] op;
    reg  [6:0] funct7;
    reg  [2:0] funct3;
    reg        ID_EXBubble;

    // Outputs
    wire RegWriteEn;
    wire MemtoReg;
    wire JAL;
    wire MemReadEn;
    wire MemWriteEn;
    wire IsBranch;
    wire ALUSrc;
    wire BranchType;
    wire JALR;
    wire [2:0] ImmSrc;
    wire [2:0] alu_op;
    wire [1:0] MemSize;
    wire [1:0] LoadSize;

    // Instantiate the DUT
    ControlUnit dut (
        .op(op),
        .funct7(funct7),
        .funct3(funct3),
        .ID_EXBubble(ID_EXBubble),

        .RegWriteEn(RegWriteEn),
        .MemtoReg(MemtoReg),
        .JAL(JAL),
        .MemReadEn(MemReadEn),
        .MemWriteEn(MemWriteEn),
        .IsBranch(IsBranch),
        .ALUSrc(ALUSrc),
        .BranchType(BranchType),
        .JALR(JALR),
        .ImmSrc(ImmSrc),
        .alu_op(alu_op),
        .MemSize(MemSize),
        .LoadSize(LoadSize)
    );

    // Local parameters for opcodes and functions
    localparam [6:0] OP_R    = 7'h33;
    localparam [6:0] OP_B    = 7'h63;
    localparam [2:0] FUNCT3_BEQ  = 3'h0;

    // Stimulus procedure
    initial begin
        // Print header
        $display("=====================================================");
        $display("  ControlUnit Testbench: Testing Bubble Behavior");
        $display("=====================================================");
        $display("  Time | Bubble |   op   | funct7 | funct3 | RegWriteEn MemtoReg JAL MemReadEn MemWriteEn IsBranch ALUSrc BranchType JALR ImmSrc alu_op MemSize LoadSize");
        $display("=====================================================");

        // Normal R-type operation without bubble
        ID_EXBubble = 0;
        op     = OP_R;
        funct7 = 7'h00;
        funct3 = 3'h0;
        #10 display_outputs("R-type without Bubble");

        // R-type operation with bubble
        ID_EXBubble = 1;
        op     = OP_R;
        funct7 = 7'h00;
        funct3 = 3'h0;
        #10 display_outputs("R-type with Bubble");

        // Branch operation without bubble
        ID_EXBubble = 0;
        op     = OP_B;
        funct7 = 7'h00;
        funct3 = FUNCT3_BEQ;
        #10 display_outputs("Branch without Bubble");

        // Branch operation with bubble
        ID_EXBubble = 1;
        op     = OP_B;
        funct7 = 7'h00;
        funct3 = FUNCT3_BEQ;
        #10 display_outputs("Branch with Bubble");

        // End of test
        $display("=====================================================");
        $display("  ControlUnit Testbench Complete.");
        $display("=====================================================");
        $finish;
    end

    // Task to display output signals
    task display_outputs;
        input [127:0] instr_name;
        begin
            $display("%t |   %b    | %h |  %h   |  %h   |     %b       %b       %b     %b         %b         %b       %b      %b     %b   %b      %b    (%s)",
                $time,
                ID_EXBubble,
                op,
                funct7,
                funct3,
                RegWriteEn,
                MemtoReg,
                JAL,
                MemReadEn,
                MemWriteEn,
                IsBranch,
                ALUSrc,
                BranchType,
                JALR,
                ImmSrc,
                alu_op,
                MemSize,
                LoadSize,
                instr_name
            );
        end
    endtask

endmodule
