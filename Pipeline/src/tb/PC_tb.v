`timescale 1ns / 1ps

module PC_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] pc_in;

    // Outputs
    wire [31:0] pc_out;

    PC uut (
        .clk(clk), 
        .rst(rst), 
        .pc_in(pc_in), 
        .pc_out(pc_out)
    );

    always begin
        #5 clk = ~clk; 
    end

    initial begin
        clk = 0;
        rst = 0;
        pc_in = 32'd0;

        rst = 1;
        #10;
        rst = 0;


        pc_in = 32'd1;
      #10 $display("Test case 1: pc_out = %d, expected = 1", pc_out);

        pc_in = 32'd2;
      #10 $display("Test case 1: pc_out = %d, expected = 2", pc_out);

        rst = 1;
        #10 $display("Test case 2: pc_out = %d, expected = 0", pc_out);
        rst = 0;

        pc_in = 32'd300;
      #10 $display("Test case 3: pc_out = %d, expected = 300", pc_out);

        $stop; 
    end

endmodule