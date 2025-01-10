// This forwarding unit solves the data hazard problem in my RISC-V pipeline by forwarding
// data from later pipeline stages (EX/MEM and MEM/WB) to earlier stages (ID/EX).
// It checks if the destination register of an instruction in the EX/MEM or MEM/WB stage
// matches the source registers of the instruction in the ID/EX stage and forwards the
// data accordingly to avoid stalls and ensure correct execution.
module forwarding_unit(
    input EX_MEM_RegWriteEn,
    input MEM_WB_RegWriteEn,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);

    //forwardA
    //forwardA = 00, no forwarding
    //forwardA = 01, forward from MEM/WB
    //forwardA = 10, forward from EX/MEM
    always @(*)
    begin
        // ForwardA logic
        if (MEM_WB_RegWriteEn && (MEM_WB_rd != 5'b0) &&
            !(EX_MEM_RegWriteEn && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) &&
            (MEM_WB_rd == ID_EX_rs1)) begin
            forwardA = 2'b01; // Forward from MEM/WB
        end else if (EX_MEM_RegWriteEn && (EX_MEM_rd != 5'b0) &&
                    (EX_MEM_rd == ID_EX_rs1)) begin
            forwardA = 2'b10; // Forward from EX/MEM
        end else begin
            forwardA = 2'b00; // No forwarding
        end
    end

    //forwardB
    //forwardB = 2'b00, no forwarding
    //forwardB = 2'b01, forward from MEM/WB
    //forwardB = 2'b10, forward from EX/MEM
    always @(*)
    begin
        // ForwardB logic
        if (MEM_WB_RegWriteEn && (MEM_WB_rd != 5'b0) &&
            !(EX_MEM_RegWriteEn && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) &&
            (MEM_WB_rd == ID_EX_rs2)) begin
            forwardB = 2'b01; // Forward from MEM/WB
        end else if (EX_MEM_RegWriteEn && (EX_MEM_rd != 5'b0) &&
                    (EX_MEM_rd == ID_EX_rs2)) begin
            forwardB = 2'b10; // Forward from EX/MEM
        end else begin
            forwardB = 2'b00; // No forwarding
        end
    end

endmodule