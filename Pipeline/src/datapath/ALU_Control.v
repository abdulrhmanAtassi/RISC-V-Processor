module ALU_Control (
    input  [2:0] ALUOp,          // Refined ALUOp encoding
    input  [2:0] funct3,         // funct3 field from the instruction
    input  [6:0] funct7,         // funct7 field from the instruction
    output reg [3:0] ALUControl, // ALU operation control signal
    output reg WordOp             // Indicates if the operation is a 32-bit word operation
);

// Parameter Definitions

// ALU Control Codes
parameter [3:0] ALU_ADD  = 4'b0000;
parameter [3:0] ALU_SUB  = 4'b0001;
parameter [3:0] ALU_AND  = 4'b0010;
parameter [3:0] ALU_OR   = 4'b0011;
parameter [3:0] ALU_XOR  = 4'b0100;
parameter [3:0] ALU_SLT  = 4'b0101;
parameter [3:0] ALU_SLL  = 4'b0110;
parameter [3:0] ALU_SRL  = 4'b0111;
parameter [3:0] ALU_PASS = 4'b1000; // For LUI or Pass-Through Operations

// -------------------- ALU Operation Types --------------------
parameter [2:0] ALU_OP_R_TYPE = 3'b000; // R-Type Instructions
parameter [2:0] ALU_OP_I_TYPE = 3'b001; // I-Type Instructions
parameter [2:0] ALU_OP_S_TYPE = 3'b010; 
parameter [2:0] ALU_OP_JAL    = 3'b011; // JAL/JALR Instructions
parameter [2:0] ALU_OP_LOAD_TYPE = 3'b100; // LOAD-Type Instructions
parameter [2:0] ALU_OP_BRANCH = 3'b101; // Branch Instructions
parameter [2:0] ALU_OP_U_TYPE = 3'b111; // U-Type Instructions (e.g., LUI)
// parameter [2:0] ALU_OP_RESERVED    = 3'b111;

// funct3 Values for R-Type Instructions
parameter [2:0] FUNCT3_ADDW = 3'h1;
parameter [2:0] FUNCT3_SUB   = 3'h6;
parameter [2:0] FUNCT3_AND   = 3'h7;
parameter [2:0] FUNCT3_OR    = 3'h5;
parameter [2:0] FUNCT3_XOR   = 3'h3;
parameter [2:0] FUNCT3_SLT   = 3'h0;
parameter [2:0] FUNCT3_SLL   = 3'h4;
parameter [2:0] FUNCT3_SRL   = 3'h2;

// Control Logic
always @(*) begin
    // Default assignments
    ALUControl = ALU_ADD;
    WordOp     = 1'b0;

    case(ALUOp)
        ALU_OP_R_TYPE: begin
            case(funct3)
                FUNCT3_ADDW: begin
                    ALUControl = ALU_ADD;
                    WordOp     = 1'b1;
                end
                FUNCT3_SUB: begin
                    ALUControl = ALU_SUB;
                    WordOp     = 1'b0;
                end
                FUNCT3_AND: begin
                    ALUControl = ALU_AND;
                    WordOp     = 1'b0;
                end
                FUNCT3_OR: begin
                    ALUControl = ALU_OR;
                    WordOp     = 1'b0;
                end
                FUNCT3_XOR: begin
                    ALUControl = ALU_XOR;
                    WordOp     = 1'b0;
                end
                FUNCT3_SLT: begin
                    ALUControl = ALU_SLT;
                    WordOp     = 1'b0;
                end
                FUNCT3_SLL: begin
                    ALUControl = ALU_SLL;
                    WordOp     = 1'b0;
                end
                FUNCT3_SRL: begin
                    ALUControl = ALU_SRL;
                    WordOp     = 1'b0;
                end
                default: begin
                    ALUControl = ALU_ADD;
                    WordOp     = 1'b0;
                end
            endcase
        end

        ALU_OP_S_TYPE: begin
            // S-Type Instructions use ALUOp=001, regardless of funct3
            ALUControl = ALU_ADD; // Address computation
            WordOp     = 1'b0;    // Store operations do not require word operations
        end

        ALU_OP_I_TYPE: begin
            // I-Type Arithmetic Instructions (e.g., addiw)
            case(funct3)
                3'h0: begin // addiw
                    ALUControl = ALU_ADD;
                    WordOp     = 1'b1;
                end
                3'h6: begin //andi
                    ALUControl = ALU_AND;
                    WordOp     = 1'b0;
                end
                3'h7: begin //ori
                    ALUControl = ALU_OR;
                    WordOp     = 1'b0;
                end

                // Add more I-Type Arithmetic instructions here if needed
                default: begin
                    ALUControl = ALU_ADD;
                    WordOp     = 1'b0;
                end
            endcase
        end

        ALU_OP_LOAD_TYPE: begin
            // I-Type Load Instructions (e.g., lw, lh)
            ALUControl = ALU_ADD; // Address computation
            WordOp     = 1'b0;    // Load operations do not require word operations
        end

        ALU_OP_U_TYPE: begin
            // U-Type Instructions (e.g., lui)
            ALUControl = ALU_PASS;
            WordOp     = 1'b0;
        end

        ALU_OP_BRANCH: begin
            // Branch Instructions (e.g., beq, bne)
            ALUControl = ALU_SUB; // Compare operation
            WordOp     = 1'b0;
        end

        ALU_OP_JAL: begin
            // J-Type Instructions (e.g., jal, jalr)
            ALUControl = ALU_ADD; // Link address computation
            WordOp     = 1'b0;
        end

        // ALU_OP_RESERVED: begin
        //     // Reserved or Unused
        //     ALUControl = ALU_ADD;
        //     WordOp     = 1'b0;
        // end

        default: begin
            ALUControl = ALU_ADD;
            WordOp     = 1'b0;
        end
    endcase
end

endmodule
