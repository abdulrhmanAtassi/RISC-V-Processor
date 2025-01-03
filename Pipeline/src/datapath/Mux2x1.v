module Mux2x1 #(parameter size = 32) (
    input [size - 1:0] a, b, // Inputs with parameterized width
    input sel,               // Selection signal
    output reg [size - 1:0] y // Output with parameterized width, declared as reg for procedural assignment
);

    // Logic: Select input based on 'sel'
    always @(*) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = {size{1'b0}}; // Output zeros with the width of 'size'
        endcase
    end

endmodule
