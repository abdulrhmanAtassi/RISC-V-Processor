module Mux2x1(
    input wire [31:0] a,     
    input wire [31:0] b,    
    input wire sel,         
    output reg [31:0] y     
);

    always @(*) begin
        if (sel == 1'b1)
            y = b;
        else
            y = a; 
    end

endmodule