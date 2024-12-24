`timescale 1ns/1ps

module ControlUnit_tb;

    // Inputs
    reg  [6:0] op;
    reg  [6:0] funct7;
    reg  [2:0] funct3;

    // Outputs
    wire RegWriteEn;
    wire MemtoReg;
    wire JAL;
    wire MemReadEn;
    wire MemWriteEn;
    wire IsBranch;
    wire ALUSrc;
    wire RegDst;
    wire BranchType;
    wire JALR;
    wire [1:0] ImmSrc;
    wire [2:0] alu_op;
    wire [1:0] MemSize;
    wire [1:0] LoadSize;

    // Instantiate the DUT
    ControlUnit dut (
        .op(op),
        .funct7(funct7),
        .funct3(funct3),

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
        .ALUOp(alu_op),
        .MemSize(MemSize),
        .LoadSize(LoadSize)
    );

    // Local parameters (taken from your module for convenience)
    localparam [6:0] OP_R    = 7'h33;  
    localparam [6:0] OP_I1   = 7'h13;  
    localparam [6:0] OP_I2   = 7'h1B;  
    localparam [6:0] OP_B    = 7'h63;  
    localparam [6:0] OP_JAL  = 7'h6F;  
    localparam [6:0] OP_JALR = 7'h67;  
    localparam [6:0] OP_L    = 7'h03;  
    localparam [6:0] OP_S    = 7'h23;  
    localparam [6:0] OP_LUI  = 7'h38;  

    localparam [6:0] FUNCT7_20 = 7'h20;  
    localparam [6:0] FUNCT7_00 = 7'h00;  

    localparam [2:0] FUNCT3_ADDW = 3'h1; 
    localparam [2:0] FUNCT3_AND  = 3'h7;
    localparam [2:0] FUNCT3_XOR  = 3'h3;
    localparam [2:0] FUNCT3_OR   = 3'h5;
    localparam [2:0] FUNCT3_SLT  = 3'h0; 
    localparam [2:0] FUNCT3_SLL  = 3'h4;
    localparam [2:0] FUNCT3_SRL  = 3'h2;
    localparam [2:0] FUNCT3_SUB  = 3'h6;

    localparam [2:0] FUNCT3_BEQ  = 3'h0;
    localparam [2:0] FUNCT3_BNE  = 3'h1;

    // Stimulus procedure
    initial begin
        // Print header
        $display("=====================================================");
        $display("  ControlUnit Testbench Starting...");
        $display("  Time |   op   | funct7 | funct3 | RegWriteEn MemtoReg JAL MemReadEn MemWriteEn IsBranch ALUSrc RegDst BranchType JALR ImmSrc alu_op MemSize LoadSize");
        $display("=====================================================");

        // R-type: addw => op=0x33, funct7=0x20, funct3=0x1
        op     = OP_R;
        funct7 = FUNCT7_20;
        funct3 = FUNCT3_ADDW;
        #10 display_outputs("R-type ADDW");

        // R-type: AND => op=0x33, funct7=0x00, funct3=0x7
        op     = OP_R;
        funct7 = FUNCT7_00;
        funct3 = FUNCT3_AND;
        #10 display_outputs("R-type AND");

        // R-type: SUB => op=0x33, funct7=0x00, funct3=0x6
        op     = OP_R;
        funct7 = FUNCT7_00;
        funct3 = FUNCT3_SUB;
        #10 display_outputs("R-type SUB");

        // I-type #1: addi => op=0x13, funct3=0x0
        op     = OP_I1;
        funct7 = 7'h00; // Not really used in immediate-type
        funct3 = 3'h0;
        #10 display_outputs("I-type ADDI");

        // I-type #1: ori => op=0x13, funct3=0x7
        op     = OP_I1;
        funct7 = 7'h00;
        funct3 = 3'h7;
        #10 display_outputs("I-type ORI");

        // I-type #2: andi => op=0x1B, funct3=0x6 (per your table)
        op     = OP_I2;
        funct7 = 7'h00;
        funct3 = 3'h6;
        #10 display_outputs("I-type ANDI");

        // Branch: beq => op=0x63, funct3=0x0
        op     = OP_B;
        funct7 = FUNCT7_00;  // Typically not used for branch
        funct3 = FUNCT3_BEQ;
        #10 display_outputs("B-type BEQ");

        // Branch: bne => op=0x63, funct3=0x1
        op     = OP_B;
        funct7 = FUNCT7_00;
        funct3 = FUNCT3_BNE;
        #10 display_outputs("B-type BNE");

        // JAL => op=0x6F
        op     = OP_JAL;
        funct7 = 7'h00;
        funct3 = 3'h0;
        #10 display_outputs("JAL");

        // JALR => op=0x67
        op     = OP_JALR;
        funct7 = 7'h00;
        funct3 = 3'h0;
        #10 display_outputs("JALR");

        // Load: lw => op=0x03, funct3=0x0
        op     = OP_L;
        funct7 = 7'h00;
        funct3 = 3'h0; // lw
        #10 display_outputs("Load LW");

        // Load: lh => op=0x03, funct3=0x2
        op     = OP_L;
        funct7 = 7'h00;
        funct3 = 3'h2; // lh
        #10 display_outputs("Load LH");

        // Store: sb => op=0x23, funct3=0x0
        op     = OP_S;
        funct7 = 7'h00;
        funct3 = 3'h0; // sb
        #10 display_outputs("Store SB");

        // Store: sw => op=0x23, funct3=0x2
        op     = OP_S;
        funct7 = 7'h00;
        funct3 = 3'h2; // sw
        #10 display_outputs("Store SW");

        // LUI => op=0x38
        op     = OP_LUI;
        funct7 = 7'h00;
        funct3 = 3'h0;
        #10 display_outputs("LUI");

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
            $display("%t | %h |  %h   |  %h   |     %b       %b       %b     %b         %b         %b       %b     %b      %b        %b   %b   %b      %b     %b   (%s)",
                $time,
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
                RegDst,
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
