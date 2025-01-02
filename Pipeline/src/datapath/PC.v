module PC (
    input wire clk,           // Clock signal
    input wire rst,           // Reset signal
    input wire [63:0] pc_in,  // Input value for the PC register
    output reg [63:0] pc_out  // Output value of the PC register
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 64'b0;  // Reset the PC register to zero
        end else begin
            pc_out <= pc_in;  // Update the PC register with the input value
        end
    end

endmodule