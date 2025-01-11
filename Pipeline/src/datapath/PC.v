module PC (
    input wire clk,           // Clock signal
    input wire rst,           // Reset signal
    input PCWrite,        // Enable signal for PC update
    input wire [63:0] pc_in,  // Input value for the PC register
    output  [63:0] pc_out // Output value of the PC register
);

    reg [63:0] pc_reg; // Internal register to hold PC value

    always @(negedge clk or posedge rst) begin
        if (rst) 
            pc_reg <= 64'b0;  // Reset the PC register to zero
        else if (PCWrite)
            pc_reg <= pc_in;  // Update PC only if PCWrite is enabled
        else
            pc_reg <= pc_reg; // Hold current PC value
    end

    assign pc_out = pc_reg; // Drive output from internal register

endmodule
