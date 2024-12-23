module Mux2x1 #(parameter size = 32) (
    input [size - 1:0] a, b, // Inputs with parameterized width
    input sel,                     // Selection signal
    output [size - 1:0] y      // Output with parameterized width
);

    // Logic: Select input based on 's'
    assign y = ~sel ? a : b;

endmodule