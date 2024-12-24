// File: tb_ALU_Control.v

`timescale 1ns / 1ps

module tb_ALU_Control;
    // Inputs
    reg [2:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7;

    // Outputs
    wire [3:0] ALUControl;
    wire WordOp;

    // Instantiate the ALU_Control module
    ALU_Control uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl),
        .WordOp(WordOp)
    );

    // Task to apply test vectors and display results
    task apply_test;
        input [2:0] test_ALUOp;
        input [2:0] test_funct3;
        input [6:0] test_funct7;
        input [31:0] test_case_number; // Numerical identifier
        input [3:0] expected_ALUControl;
        input       expected_WordOp;
        begin
            ALUOp    = test_ALUOp;
            funct3   = test_funct3;
            funct7   = test_funct7;
            #10; // Wait for combinational logic to settle

            // Compare outputs with expected values
            if ((ALUControl === expected_ALUControl) && (WordOp === expected_WordOp)) begin
                $display("PASS: Test Case %0d | ALUOp=%b, funct3=%b, funct7=%b | ALUControl=%b, WordOp=%b",
                         test_case_number, ALUOp, funct3, funct7, ALUControl, WordOp);
            end else begin
                $display("FAIL: Test Case %0d | ALUOp=%b, funct3=%b, funct7=%b | Expected ALUControl=%b, WordOp=%b | Got ALUControl=%b, WordOp=%b",
                         test_case_number, ALUOp, funct3, funct7, expected_ALUControl, expected_WordOp, ALUControl, WordOp);
            end
        end
    endtask

    initial begin
        // Initialize Inputs
        ALUOp    = 3'b000;
        funct3   = 3'b000;
        funct7   = 7'b0000000;

        // Display header
        $display("-------------------------------------------------------------");
        $display("ALU Control Module Testbench");
        $display("-------------------------------------------------------------");
        $display("Instruction | ALUOp | funct3 | funct7 | ALUControl | WordOp");
        $display("-------------------------------------------------------------");

        // ---------------------
        // R-Type Instructions
        // ---------------------

        // 1. addw: R-Type, funct3=0x1, funct7=0x20, ALUOp=000
        apply_test(3'b000, 3'h1, 7'h20, 1, 4'b0000, 1'b1); // ALUControl=ADD, WordOp=1

        // 2. sub: R-Type, funct3=0x6, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h6, 7'h00, 2, 4'b0001, 1'b0); // ALUControl=SUB, WordOp=0

        // 3. and: R-Type, funct3=0x7, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h7, 7'h00, 3, 4'b0010, 1'b0); // ALUControl=AND, WordOp=0

        // 4. or: R-Type, funct3=0x5, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h5, 7'h00, 4, 4'b0011, 1'b0); // ALUControl=OR, WordOp=0

        // 5. xor: R-Type, funct3=0x3, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h3, 7'h00, 5, 4'b0100, 1'b0); // ALUControl=XOR, WordOp=0

        // 6. slt: R-Type, funct3=0x0, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h0, 7'h00, 6, 4'b0101, 1'b0); // ALUControl=SLT, WordOp=0

        // 7. sll: R-Type, funct3=0x4, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h4, 7'h00, 7, 4'b0110, 1'b0); // ALUControl=SLL, WordOp=0

        // 8. srl: R-Type, funct3=0x2, funct7=0x00, ALUOp=000
        apply_test(3'b000, 3'h2, 7'h00, 8, 4'b0111, 1'b0); // ALUControl=SRL, WordOp=0

        // ---------------------
        // S-Type Instructions
        // ---------------------

        // 19. sw: S-Type, funct3=0x2, funct7=0x00, ALUOp=001
        apply_test(3'b010, 3'h2, 7'h00, 19, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // 20. sb: S-Type, funct3=0x0, funct7=0x00, ALUOp=001
        apply_test(3'b010, 3'h0, 7'h00, 20, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // ---------------------
        // I-Type Arithmetic Instructions
        // ---------------------

        // 9. addiw: I-Type Arithmetic, funct3=0x0, funct7=0x00, ALUOp=010
        apply_test(3'b001, 3'h0, 7'h00, 9, 4'b0000, 1'b1); // ALUControl=ADD, WordOp=1

        // ---------------------
        // I-Type Load Instructions
        // ---------------------

        // 17. lw: I-Type Load, funct3=0x0, funct7=0x00, ALUOp=011
        apply_test(3'b011, 3'h0, 7'h00, 17, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // 18. lh: I-Type Load, funct3=0x2, funct7=0x00, ALUOp=011
        apply_test(3'b011, 3'h2, 7'h00, 18, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // ---------------------
        // I-Type Logical Instructions
        // ---------------------

        // 10. ori: I-Type Logical, funct3=0x7, funct7=0x00, ALUOp=010
        apply_test(3'b001, 3'h7, 7'h00, 10, 4'b0011, 1'b0); // ALUControl=OR, WordOp=0

        // 11. andi: I-Type Logical, funct3=0x6, funct7=0x00, ALUOp=010
        apply_test(3'b001, 3'h6, 7'h00, 11, 4'b0010, 1'b0); // ALUControl=AND, WordOp=0

        // ---------------------
        // U-Type Instructions
        // ---------------------

        // 12. lui: U-Type, funct3=0x0, funct7=0x00, ALUOp=100
        apply_test(3'b111, 3'h0, 7'h00, 12, 4'b1000, 1'b0); // ALUControl=PASS, WordOp=0

        // ---------------------
        // Branch Instructions
        // ---------------------

        // 13. beq: Branch, funct3=0x0, funct7=0x00, ALUOp=101
        apply_test(3'b101, 3'h0, 7'h00, 13, 4'b0001, 1'b0); // ALUControl=SUB, WordOp=0

        // 14. bne: Branch, funct3=0x1, funct7=0x00, ALUOp=101
        apply_test(3'b101, 3'h1, 7'h00, 14, 4'b0001, 1'b0); // ALUControl=SUB, WordOp=0

        // ---------------------
        // J-Type Instructions
        // ---------------------

        // 15. jal: J-Type, funct3=0x0, funct7=0x00, ALUOp=110
        apply_test(3'b110, 3'h0, 7'h00, 15, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // 16. jalr: J-Type, funct3=0x0, funct7=0x00, ALUOp=110
        apply_test(3'b110, 3'h0, 7'h00, 16, 4'b0000, 1'b0); // ALUControl=ADD, WordOp=0

        // Finish simulation after all test cases
        #10;
        $finish;
    end

endmodule
