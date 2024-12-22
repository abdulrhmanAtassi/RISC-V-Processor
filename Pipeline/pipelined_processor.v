module pipelined_processor(
    input clock // Declare clock as input
);

    // Registers
    reg [7:0] address;

    // Outputs
    wire [31:0] q;

    // Instantiate instructionMemory
    InstructionMemory uut (
        .address(address),
        .clken(1'b1), // Constant enable
        .clock(clock),
        .q(q)
    );

    // Optionally, you can add a clock-based process to modify `address`
    always @(posedge clock) begin
        // Example: increment address
        address <= address + 1;
    end

endmodule
