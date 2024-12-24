module ControlUnit(
    input  [6:0] op,
    input  [6:0] funct7,
    input  [2:0] funct3,

    output reg RegWriteEn,
    output reg MemtoReg,
    output reg JAL,
    output reg MemReadEn,
    output reg MemWriteEn,
    output reg IsBranch,
    output reg ALUSrc,
    output reg RegDst,
    output reg BranchType,
    output reg JALR,
    output reg [2:0] ImmSrc,
    output reg [2:0] ALUOp,     // Instruction-Type-Based ALU operation
    output reg [1:0] MemSize,   // For load/store sizes
    output reg [1:0] LoadSize
);
    
    // -------------------- ALU Operation Types --------------------
    parameter [2:0] ALU_OP_R_TYPE = 3'b000; // R-Type Instructions
    parameter [2:0] ALU_OP_I_TYPE = 3'b001; // I-Type Instructions
    parameter [2:0] ALU_OP_S_TYPE = 3'b010; 
    parameter [2:0] ALU_OP_JAL    = 3'b011; // JAL/JALR Instructions
    parameter [2:0] ALU_OP_LOAD_TYPE = 3'b100; // LOAD-Type Instructions
    parameter [2:0] ALU_OP_BRANCH = 3'b101; // Branch Instructions
    parameter [2:0] ALU_OP_U_TYPE = 3'b111; // U-Type Instructions (e.g., LUI)


    // Add more as needed
    
    // -------------------- Immediate Types ------------------------
    parameter [2:0] IMM_I  = 3'b000;
    parameter [2:0] IMM_S  = 3'b001;
    parameter [2:0] IMM_SB = 3'b010;
    parameter [2:0] IMM_U  = 3'b011;
    parameter [2:0] IMM_UJ  = 3'b100;
    
    // -------------------- Opcodes -------------------------------
    parameter [6:0] OP_R    = 7'h33;  // R-type (addw, and, or, sub, etc.)
    parameter [6:0] OP_I1   = 7'h13;  // I-type #1 (addi, ori, addiw, etc.)
    parameter [6:0] OP_I2   = 7'h1B;  // I-type #2 (andi, addiw)
    parameter [6:0] OP_B    = 7'h63;  // Branch (beq, bne, ...)
    parameter [6:0] OP_JAL  = 7'h6F;  
    parameter [6:0] OP_JALR = 7'h67;  
    parameter [6:0] OP_L    = 7'h03;  // Loads (lw, lh)
    parameter [6:0] OP_S    = 7'h23;  // Stores (sw, sb)
    parameter [6:0] OP_LUI  = 7'h38;  // LUI (changed to 0x37 based on RISC-V spec)
    
    // -------------------- funct3 values --------------------------
    parameter [2:0] FUNCT3_ADDW = 3'h1; // addw
    parameter [2:0] FUNCT3_AND  = 3'h7;
    parameter [2:0] FUNCT3_XOR  = 3'h3;
    parameter [2:0] FUNCT3_OR   = 3'h5;
    parameter [2:0] FUNCT3_SLT  = 3'h0;
    parameter [2:0] FUNCT3_SLL  = 3'h4;
    parameter [2:0] FUNCT3_SRL  = 3'h2;
    parameter [2:0] FUNCT3_SUB  = 3'h6;
    
    parameter [2:0] FUNCT3_BEQ  = 3'h0;
    parameter [2:0] FUNCT3_BNE  = 3'h1;
    
    // -------------------- Control Logic ---------------------------
    always @(*) begin
        // Default/reset values
        RegWriteEn  = 0;
        MemtoReg    = 0;
        JAL         = 0;
        MemReadEn   = 0;
        MemWriteEn  = 0;
        IsBranch    = 0;
        ALUSrc      = 0;
        RegDst      = 0;
        BranchType  = 0;
        JALR        = 0;
        ImmSrc      = IMM_I;
        ALUOp       = ALU_OP_R_TYPE; // default ALU op
        MemSize     = 2'b00;          // Default memory size
        LoadSize    = 2'b00;          // Default load size
    
        case(op)
    
            // ------------
            // R-Type
            // ------------
            OP_R: begin
                RegWriteEn = 1;
                ALUOp       = ALU_OP_R_TYPE;
            end
    
            // ------------
            // I-Type #1 (e.g., addiw, ori, etc.)
            // ------------
            OP_I1: begin
                RegWriteEn = 1;
                ALUSrc     = 1;
                ImmSrc     = IMM_I;
                ALUOp      = ALU_OP_I_TYPE;
            end
    
            // ------------
            // I-Type #2 (andi, etc.)
            // ------------
            OP_I2: begin
                RegWriteEn = 1;
                ALUSrc     = 1;
                ImmSrc     = IMM_I;
                ALUOp      = ALU_OP_I_TYPE;
            end
    
            // ------------
            // Branch (beq, bne)
            // ------------
            OP_B: begin
                IsBranch = 1;
                ImmSrc   = IMM_SB;
                ALUOp    = ALU_OP_BRANCH;
                case(funct3)
                    FUNCT3_BEQ: BranchType = 1; // beq => branch if equal
                    FUNCT3_BNE: BranchType = 0; // bne => branch if not equal
                    default:    BranchType = 1; // safe default
                endcase
            end
    
            // ------------
            // JAL => 6F
            // ------------
            OP_JAL: begin
                JAL        = 1;
                RegWriteEn = 1;
                MemtoReg   = 1;
                ImmSrc     = IMM_UJ;
                ALUOp      = ALU_OP_JAL;
            end
    
            // ------------
            // JALR => 67/0
            // ------------
            OP_JALR: begin
                JALR       = 1;
                RegWriteEn = 1;
                MemtoReg   = 1;
                ALUSrc     = 1;
                ImmSrc     = IMM_I;
                ALUOp      = ALU_OP_JAL;
            end
    
            // ------------
            // Loads (lw => 03/0, lh => 03/2, etc.)
            // ------------
            OP_L: begin
                RegWriteEn = 1;
                MemReadEn  = 1;
                MemtoReg   = 1;
                ALUSrc     = 1;    // Address = rs1 + imm
                ALUOp      = ALU_OP_LOAD_TYPE; // Compute address
    
                case(funct3)
                    3'h0: begin // lw
                        MemSize  = 2'b10; // Word
                        LoadSize = 2'b10; // Load Word
                    end
                    3'h2: begin // lh
                        MemSize  = 2'b01; // Halfword
                        LoadSize = 2'b01; // Load Halfword
                    end
                    // Add more cases if supporting lb, lhu, etc.
                    default: begin
                        MemSize  = 2'b10; // Default to word
                        LoadSize = 2'b10;
                    end
                endcase
            end
    
            // ------------
            // Stores (sw => 23/2, sb => 23/0, etc.)
            // ------------
            OP_S: begin
                MemWriteEn = 1;
                ALUSrc     = 1;    // Address = rs1 + imm
                ImmSrc     = IMM_S;
                ALUOp      = ALU_OP_S_TYPE; // Compute address
    
                case(funct3)
                    3'h0: MemSize = 2'b00; // sb
                    3'h2: MemSize = 2'b10; // sw
                    // Add more cases if supporting sh, etc.
                    default: MemSize = 2'b10; // Default to word
                endcase
            end
    
            // ------------
            // LUI Instruction
            // ------------
            OP_LUI: begin
                RegWriteEn = 1;     // Enable register write
                ALUSrc     = 1;     // Use immediate as operand
                ImmSrc     = IMM_U; // U-type immediate
                MemReadEn  = 0; 
                MemWriteEn = 0;
                MemtoReg   = 0;     // Data comes from ALU (immediate)
                ALUOp      = ALU_OP_U_TYPE; // Use U-Type ALU operation
            end
    
            default: begin
                // No action or set to safe defaults
            end
        endcase
    end
    
endmodule