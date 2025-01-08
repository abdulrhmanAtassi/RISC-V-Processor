module Instruction_Memory_asy(rst, A, RD);

  input rst;
  input [9:0] A;         // 10-bit address for 1024 locations
  output [31:0] RD;

  reg [31:0] mem [1023:0];  // 1KB memory

  assign RD = (rst == 1'b0) ? 32'b0 : mem[A];  // Output zero if reset is active

  integer i;
  initial begin
    // Initialize all memory to zero
    for (i = 0; i < 1024; i = i + 1) begin
      mem[i] = 32'b0;
    end
    // Load specific instructions
    mem[0] = 32'hFFC4A303;  // Example instruction
    mem[1] = 32'h11111111;  // Example instruction
  end

endmodule
