module PC_Adder (in, out);

  input [31:0] in; 
  output [31:0] out; 

  assign out = in + 4;

endmodule
