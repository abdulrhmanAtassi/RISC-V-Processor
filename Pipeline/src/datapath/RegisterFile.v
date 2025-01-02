module RegisterFile (
    input clk,
    input rst,               // Reset input
    input [4:0] ReadRegister1, 
    input [4:0] ReadRegister2, 
    input [4:0] WriteRegister,
    input [63:0] WriteData,
    input WriteEnable,      // Control signal for enabling write
    output reg signed [63:0] ReadData1, 
    output reg signed [63:0] ReadData2
);

    // Define a 32x64 register array (32 registers, each 64 bits wide)
    reg signed [63:0] registers [0:31];
    integer i;

    // Reset logic and synchronous write
    // Synchronous reset + write on posedge
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end 
        else if (WriteEnable && WriteRegister != 5'b00000) begin
            registers[WriteRegister] <= WriteData;
        end
    end

    // Asynchronous read on negedge
    always @(negedge clk) begin
        ReadData1 = (ReadRegister1 == 5'd0) ? 64'b0 : registers[ReadRegister1];
        ReadData2 = (ReadRegister2 == 5'd0) ? 64'b0 : registers[ReadRegister2];
    end

endmodule
