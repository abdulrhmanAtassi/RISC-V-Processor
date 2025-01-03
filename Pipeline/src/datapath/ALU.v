module ALU (
    input  [63:0] operand1,   // First operand
    input  [63:0] operand2,   // Second operand or immediate
    input  [3:0]  ALUControl, // ALU operation control signal
    input         WordOp,      // 1 = 32-bit operation, 0 = 64-bit operation
    output [63:0] ALUResult    // Result of the ALU operation
);

// Intermediate signals for 32-bit operations
wire signed [31:0] operand1_32 = operand1[31:0];
wire signed [31:0] operand2_32 = operand2[31:0];
wire signed [31:0] result_32;
wire signed [63:0] result_64;

// ALU operation parameters
parameter [3:0] ALU_ADD  = 4'b0000;
parameter [3:0] ALU_SUB  = 4'b0001;
parameter [3:0] ALU_AND  = 4'b0010;
parameter [3:0] ALU_OR   = 4'b0011;
parameter [3:0] ALU_XOR  = 4'b0100;
parameter [3:0] ALU_SLT  = 4'b0101;
parameter [3:0] ALU_SLL  = 4'b0110;
parameter [3:0] ALU_SRL  = 4'b0111;
parameter [3:0] ALU_PASS = 4'b1000; // For LUI or Pass-Through Operations

// 32-bit Operations
assign result_32 =  (ALUControl == ALU_ADD)  ? (operand1_32 + operand2_32) :
                    (ALUControl == ALU_SUB)  ? (operand1_32 - operand2_32) :
                    (ALUControl == ALU_AND)  ? (operand1_32 & operand2_32) :
                    (ALUControl == ALU_OR)   ? (operand1_32 | operand2_32) :
                    (ALUControl == ALU_XOR)  ? (operand1_32 ^ operand2_32) :
                    (ALUControl == ALU_SLT)  ? ((operand1_32 < operand2_32) ? 32'd1 : 32'd0) :
                    (ALUControl == ALU_SLL)  ? (operand1_32 << operand2_32[4:0]) :
                    (ALUControl == ALU_SRL)  ? (operand1_32 >>> operand2_32[4:0]) : // Arithmetic shift right
                    (ALUControl == ALU_PASS) ? operand2_32 : // PASS operation for LUI
                    32'd0; // Default

// 64-bit Operations
assign result_64 =  (ALUControl == ALU_ADD)  ? (operand1 + operand2) :
                    (ALUControl == ALU_SUB)  ? (operand1 - operand2) :
                    (ALUControl == ALU_AND)  ? (operand1 & operand2) :
                    (ALUControl == ALU_OR)   ? (operand1 | operand2) :
                    (ALUControl == ALU_XOR)  ? (operand1 ^ operand2) :
                    (ALUControl == ALU_SLT)  ? ((operand1 < operand2) ? 64'd1 : 64'd0) :
                    (ALUControl == ALU_SLL)  ? (operand1 << operand2[5:0]) :
                    (ALUControl == ALU_SRL)  ? (operand1 >>> operand2[5:0]) : // Arithmetic shift right
                    (ALUControl == ALU_PASS) ? operand2 : // PASS operation for LUI
                    64'd0; // Default

// Select between 32-bit and 64-bit results
assign ALUResult = (WordOp) ? { {32{result_32[31]} }, result_32 } : result_64;

endmodule
