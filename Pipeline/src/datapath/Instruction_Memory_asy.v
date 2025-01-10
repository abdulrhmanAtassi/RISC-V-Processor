module Instruction_Memory_asy(
  input rst,                // Reset signal
  input [9:0] A,            // 10-bit address (word-aligned for 1024 locations)
  output  [31:0] RD          // 32-bit read data
);

  // Declare 1KB memory (1024 words, each 32 bits)
  reg [31:0] mem [1023:0];
  
  // Combinational read: RD directly reflects mem[A]
  // always @(*) begin
  //   if (rst)
  //     RD <= 32'b0;
  //   else
  //     RD <= mem[A];
  // end
  assign RD = (rst) ? {32{1'b0}} : mem[A];

// assign RD = RD_reg;
  // Memory initialization
  integer i;
  initial begin
    // Default all memory to zero
    for (i = 0; i < 1024; i = i + 1) begin
      mem[i] = 32'b0;
    end
    // Load instructions from an external file (e.g., "instructions.hex")
    $readmemh("../../instructions.hex", mem);
  end

endmodule
