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
    output reg BranchType,
    output reg JALR,
    output reg [2:0] ImmSrc,
    output reg [2:0] alu_op,
    output reg [1:0] MemSize,
    output reg [1:0] LoadSize
);

// -------------------- ALU Operation Codes --------------------
parameter [2:0] ALU_OP_ADD = 3'b000;
parameter [2:0] ALU_OP_SUB = 3'b001;
parameter [2:0] ALU_OP_AND = 3'b010;
parameter [2:0] ALU_OP_OR  = 3'b011;
parameter [2:0] ALU_OP_XOR = 3'b100;
parameter [2:0] ALU_OP_SLT = 3'b101;
parameter [2:0] ALU_OP_SLL = 3'b110;
parameter [2:0] ALU_OP_SRL = 3'b111;

// -------------------- Immediate Types ------------------------
parameter [2:0] IMM_I  = 3'b000;
parameter [2:0] IMM_S  = 3'b001;
parameter [2:0] IMM_SB = 3'b010;
parameter [2:0] IMM_U  = 3'b011;
parameter [2:0] IMM_UJ  = 3'b100;

// -------------------- Opcodes -------------------------------
parameter [6:0] OP_R    = 7'h33;  // R-type (addw, and, or, sub, etc.)
parameter [6:0] OP_I1   = 7'h13;  // I-type #1 (addi, ori, addiw, etc.)
parameter [6:0] OP_I2   = 7'h1B;  // I-type #2 (andi)
parameter [6:0] OP_B    = 7'h63;  // Branch (beq, bne, ...)
parameter [6:0] OP_JAL  = 7'h6F;  
parameter [6:0] OP_JALR = 7'h67;  
parameter [6:0] OP_L    = 7'h03;  // Loads (lw, lh)
parameter [6:0] OP_S    = 7'h23;  // Stores (sw, sb)
parameter [6:0] OP_LUI  = 7'h38;  // LUI

// -------------------- funct7 values --------------------------
parameter [6:0] FUNCT7_20 = 7'h20;  // (0x20) used by e.g. addw (RV64)
parameter [6:0] FUNCT7_00 = 7'h00;  

// -------------------- funct3 values --------------------------
parameter [2:0] FUNCT3_ADDW = 3'h1; // addw => opcode=0x33, funct3=1, funct7=0x20
parameter [2:0] FUNCT3_AND  = 3'h7;
parameter [2:0] FUNCT3_XOR  = 3'h3;
parameter [2:0] FUNCT3_OR   = 3'h5;
parameter [2:0] FUNCT3_SLT  = 3'h0; // slt => 33/0/00
parameter [2:0] FUNCT3_SLL  = 3'h4;
parameter [2:0] FUNCT3_SRL  = 3'h2;
parameter [2:0] FUNCT3_SUB  = 3'h6;

// Branch funct3
parameter [2:0] FUNCT3_BEQ  = 3'h0;
parameter [2:0] FUNCT3_BNE  = 3'h1;

always @(*) begin
    // Default/reset values
    RegWriteEn  = 0;
    MemtoReg    = 0;
    JAL         = 0;
    MemReadEn   = 0;
    MemWriteEn  = 0;
    IsBranch    = 0;
    ALUSrc      = 0;
    BranchType  = 0;
    JALR        = 0;
    ImmSrc      = IMM_I;
    alu_op      = ALU_OP_ADD; // default ALU op
    MemSize     = 2'b00;     
    LoadSize    = 2'b00; 

    case(op)

        // ------------
        // R-Type
        // ------------
        OP_R: begin
            RegWriteEn = 1;
            case({funct7,funct3})
                // addw => opcode=0x33, funct7=0x20, funct3=0x1
                {FUNCT7_20, FUNCT3_ADDW} : alu_op = ALU_OP_ADD; 

                // and => 33/7/00
                {FUNCT7_00, FUNCT3_AND}  : alu_op = ALU_OP_AND;

                // xor => 33/3/00
                {FUNCT7_00, FUNCT3_XOR}  : alu_op = ALU_OP_XOR;

                // or  => 33/5/00
                {FUNCT7_00, FUNCT3_OR}   : alu_op = ALU_OP_OR;

                // slt => 33/0/00
                {FUNCT7_00, FUNCT3_SLT}  : alu_op = ALU_OP_SLT;

                // sll => 33/4/00
                {FUNCT7_00, FUNCT3_SLL}  : alu_op = ALU_OP_SLL;

                // srl => 33/2/00
                {FUNCT7_00, FUNCT3_SRL}  : alu_op = ALU_OP_SRL;

                // sub => 33/6/00
                {FUNCT7_00, FUNCT3_SUB}  : alu_op = ALU_OP_SUB;

                default: alu_op = ALU_OP_ADD;
            endcase
        end

        // ------------
        // I-Type #1 (e.g., addiw, ori, etc.)
        // ------------
        OP_I1: begin
            RegWriteEn = 1;
            ALUSrc     = 1;
            ImmSrc     = IMM_I;
            case(funct3)
                // addiw => 13/0
                3'h0: alu_op = ALU_OP_ADD;

                // ori => 13/7
                3'h7: alu_op = ALU_OP_OR;

                default: alu_op = ALU_OP_ADD;
            endcase
        end

        // ------------
        // I-Type #2 (andi => 1B/6)
        // ------------
        OP_I2: begin
            RegWriteEn = 1;
            ALUSrc     = 1;
            ImmSrc     = IMM_I;
            // Only one option in your table => andi
            alu_op = ALU_OP_AND; 
        end

        // ------------
        // Branch (beq, bne => 63/0 or 63/1)
        // ------------
        OP_B: begin
            IsBranch = 1;
            ImmSrc   = IMM_SB;
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
        end

        // ------------
        // JALR => 67/0
        // ------------
        OP_JALR: begin
            JALR       = 1;
            JAL        = 1;
            RegWriteEn = 1;
            MemtoReg   = 1;
            ALUSrc     = 1;
            ImmSrc     = IMM_I;
        end

        // ------------
        // Loads (lw => 03/0, lh => 03/2, etc.)
        // ------------
        OP_L: begin
            RegWriteEn = 1;
            MemReadEn  = 1;
            MemtoReg   = 1;
            ALUSrc     = 1;
            alu_op     = ALU_OP_ADD; // base + offset
            case(funct3)
                3'h0: begin // lw
                MemSize = 2'b10; // word
                LoadSize = 2'b10; // lw (32-bit)
                end
                3'h2: begin // lh
                    MemSize = 2'b01; // halfword
                    LoadSize = 2'b01; // lh (16-bit)
                end
                // etc. (lb, lhu, etc. if you extend)
            endcase
        end

        // ------------
        // Stores (sw => 23/2, sb => 23/0, etc.)
        // ------------
        OP_S: begin
            MemWriteEn = 1;
            ALUSrc     = 1;
            ImmSrc     = IMM_S;
            alu_op     = ALU_OP_ADD; // base + offset
            case(funct3)
                3'h0: MemSize = 2'b00; // sb
                3'h1: MemSize = 2'b01; // sh
                3'h2: MemSize = 2'b10; // sw
            endcase
        end

        // ------------
        // LUI => 38
        // ------------
        OP_LUI: begin
            RegWriteEn = 1;
            ALUSrc     = 1;
            ImmSrc     = IMM_U;
            // LUI itself does not really need an ALU operation; 
            // but you can keep alu_op=ALU_OP_ADD or something safe
        end

        default: begin
            // No action
        end
    endcase
end

endmodule
