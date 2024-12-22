module PC_Adder_tb;

  reg [31:0] in;
  wire [31:0] out;

  PC_Adder uut (
    .in(in),
    .out(out)
  );

  initial begin
    // Test case 1: Regular increment
    in = 32'd0;  
    #10 $display("in = %d, out = %d", in, out);

    // Test case 2: Increment from a higher address (decimal)
    in = 32'd65532; 
    #10 $display("in = %d, out = %d", in, out);

    // Test case 3: Edge case with maximum value (decimal)
    in = 32'd4294967295;
    #10 $display("in = %d, out = %d", in, out);

    $finish;
  end

endmodule
  