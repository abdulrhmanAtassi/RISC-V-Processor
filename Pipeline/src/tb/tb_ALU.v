module tb_ALU;
    reg signed [63:0] operand1;
    reg signed [63:0] operand2;
    reg [3:0]  ALUControl;
    reg        WordOp;
    wire signed [63:0] ALUResult;

    // Instantiate ALU
    ALU uut (
        .operand1(operand1),
        .operand2(operand2),
        .ALUControl(ALUControl),
        .WordOp(WordOp),
        .ALUResult(ALUResult)
    );

    initial begin
        // Initialize Inputs
        operand1 = 64'd10; operand2 = 64'd5; ALUControl = 4'b0000; WordOp = 0; // ADD
        #10;
        $display("ADD (64-bit): %d + %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'd10; operand2 = 64'd5; ALUControl = 4'b0001; WordOp = 0; // SUB
        #10;
        $display("SUB (64-bit): %d - %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'hFFFF_FFFF_FFFF_FFFF; operand2 = 64'h0000_0000_0000_00FF; ALUControl = 4'b0010; WordOp = 0; // AND
        #10;
        $display("AND (64-bit): %h & %h = %h", operand1, operand2, ALUResult);

        operand1 = 64'd10; operand2 = 64'd5; ALUControl = 4'b0011; WordOp = 0; // OR
        #10;
        $display("OR (64-bit): %d | %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'd10; operand2 = 64'd5; ALUControl = 4'b0100; WordOp = 0; // XOR
        #10;
        $display("XOR (64-bit): %d ^ %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'd3; operand2 = 64'd5; ALUControl = 4'b0101; WordOp = 0; // SLT
        #10;
        $display("SLT (64-bit): %d < %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'd2; operand2 = 64'd1; ALUControl = 4'b0110; WordOp = 0; // SLL
        #10;
        $display("SLL (64-bit): %d << %d = %d", operand1, operand2, ALUResult);

        operand1 = 64'd8; operand2 = 64'd2; ALUControl = 4'b0111; WordOp = 0; // SRL
        #10;
        $display("SRL (64-bit): %d >> %d = %d", operand1, operand2, ALUResult);

        // 32-bit Operations
        operand1 = 32'd10; operand2 = 32'd5; ALUControl = 4'b0000; WordOp = 1; // ADDW
        #10;
        $display("ADDW (32-bit): %d + %d = %d", operand1, operand2, ALUResult);

        operand1 = 32'd10; operand2 = 32'd5; ALUControl = 4'b0001; WordOp = 1; // SUBW
        #10;
        $display("SUBW (32-bit): %d - %d = %d", operand1, operand2, ALUResult);

        operand1 = 32'hFFFF_FFFF; operand2 = 32'h0000_00FF; ALUControl = 4'b0010; WordOp = 1; // ANDW
        #10;
        $display("ANDW (32-bit): %h & %h = %h", operand1, operand2, ALUResult);

        operand1 = 32'd10; operand2 = 32'd5; ALUControl = 4'b0011; WordOp = 1; // ORW
        #10;
        $display("ORW (32-bit): %d | %d = %d", operand1, operand2, ALUResult);

        operand1 = 32'd10; operand2 = 32'd5; ALUControl = 4'b0100; WordOp = 1; // XORW
        #10;
        $display("XORW (32-bit): %d ^ %d = %d", operand1, operand2, ALUResult);

        // Pass-Through Operation (LUI)
        operand1 = 64'd0; operand2 = 64'h1234_5678_9ABC_DEF0; ALUControl = 4'b1000; WordOp = 0; // PASS
        #10;
        $display("PASS (LUI): %h = %h", ALUResult, operand2);

        // Add more test cases as needed
        #10 $finish;
    end
endmodule
