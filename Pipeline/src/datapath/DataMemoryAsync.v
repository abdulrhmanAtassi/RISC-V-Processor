module DataMemoryAsync (
    input [12:0] address,  // 13-bit address (2^13 = 8K bytes)
    input signed [7:0] data_in,   // 8-bit data input (1 byte)
    input rden,            // Read enable signal
    input wren,            // Write enable signal
    output signed [7:0] data_out  // 8-bit data output (1 byte)
);

    // Declare memory (8K x 1 byte)
    reg signed [7:0] memory [0:8191]; // 8192 locations for 8K memory (2^13)

    // Continuous assignment for asynchronous read
    assign data_out = (rden) ? memory[address] : 8'b0;

    always @(*) begin
        if (wren) begin
            // Write operation
            memory[address] = data_in;
        end
    end
endmodule
