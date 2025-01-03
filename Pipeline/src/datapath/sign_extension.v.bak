module sign_extension (
    input [31:0] instruction,  
    input [2:0] imm_type,       
    output reg [31:0] imm_out  
);

    always @(*) begin
        case (imm_type)
            3'b000: begin // I-type (e.g., ADDI, LUI, JALR)
                imm_out = {{20{instruction[31]}}, instruction[31:20]}; 
            end

            3'b001: begin // S-type (e.g., SW, SH, SB)
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; 
            end

            3'b010: begin // SB-type (e.g., BEQ, BNE)
                imm_out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
            end

            3'b011: begin // U-type (e.g., LUI, AUIPC)
                imm_out = {instruction[31:12], 12'b0};
            end

            3'b100: begin // UJ-type (e.g., JAL)
                imm_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; 
            end

            default: begin
                imm_out = 32'b0; 
            end
        endcase
    end
endmodule

