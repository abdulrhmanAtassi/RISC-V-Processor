module sign_extension_tb;


    reg [31:0] instruction;   
    reg [2:0] imm_type;       
    wire [31:0] imm_out; 

    sign_extension uut (
        .instruction(instruction),
        .imm_type(imm_type),
        .imm_out(imm_out)
    );

    initial begin
        $display("Time\timm_type\tInstruction\timm_out");

        // Test I-type (imm_type = 3'b000)
        imm_type = 3'b000;
        instruction = 32'b00000000000010010000000000110011;  // Example: ADDI x1, x2, 0xFFF (12-bit immediate)
        #10;
        $display("%0t\t%b\t\t%h\t\t%h", $time, imm_type, instruction, imm_out);

        // Test S-type (imm_type = 3'b001)
        imm_type = 3'b001;
        instruction = 32'b00000000000010100001000010000011;  // Example: SW x1, 0xFFF(x2) (12-bit immediate)
        #10;
        $display("%0t\t%b\t\t%h\t\t%h", $time, imm_type, instruction, imm_out);

        // Test SB-type (imm_type = 3'b010)
        imm_type = 3'b010;
        instruction = 32'b00000000000010010010000001100011;  // Example: BEQ x1, x2, 0xFFF (13-bit immediate)
        #10;
        $display("%0t\t%b\t\t%h\t\t%h", $time, imm_type, instruction, imm_out);

        // Test U-type (imm_type = 3'b011)
        imm_type = 3'b011;
        instruction = 32'b00000000000000010000000001101111;  // Example: LUI x1, 0xFFF (upper 20 bits)
        #10;
        $display("%0t\t%b\t\t%h\t\t%h", $time, imm_type, instruction, imm_out);

        // Test UJ-type (imm_type = 3'b100)
        imm_type = 3'b100;
        instruction = 32'b00000000000000110000000011011111;  // Example: JAL x1, 0xFFF (21-bit immediate)
        #10;
        $display("%0t\t%b\t\t%h\t\t%h", $time, imm_type, instruction, imm_out);

        // End of the simulation
        $finish;
	end
endmodule

  