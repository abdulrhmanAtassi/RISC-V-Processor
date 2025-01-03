module Mux4x1(
    input      [63:0] a,  // First 32-bit input
    input      [63:0] b,  // Second 32-bit input
    input      [63:0] c,  // Third 32-bit input
    input      [63:0] d,  // Fourth 32-bit input
    input      [1:0]  sel,// 2-bit Select
    output reg [63:0] y   // 32-bit output
);

    always @(*) begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;
            default: y = 64'b0; 
        endcase
    end

endmodule
