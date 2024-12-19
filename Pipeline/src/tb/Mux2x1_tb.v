`timescale 1ns/1ps

module Mux2x1_tb;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg sel;

    // Output
    wire [31:0] y;

    Mux2x1 uut (
        .a(a), 
        .b(b), 
        .sel(sel), 
        .y(y)
    );


    initial begin
        a = 32'd10; 
        b = 32'd20; 

        sel = 0;
        // Test case 1
      #10 $display("Test case 1: y = %d, expected = %d", y, a);

        // Test case 2
        sel = 1;
      #10 $display("Test case 2: y = %d, expected = %d", y, b);

        // Test case 3
        sel = 0;
        a = 32'd1;
      #10 $display("Test case 3: y = %d, expected = %d", y, a);

        // Test case 4
        sel = 1;
        b = 32'h2;
      #10 $display("Test case 4: y = %d, expected = %d", y, b);
        $stop;
    end

endmodule