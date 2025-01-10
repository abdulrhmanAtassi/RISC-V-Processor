`timescale 1ns/1ps
module InstractionMemory_tb;

    // Declare testbench signals
    reg [31:0] address;
    reg clock;
    reg rst;
    wire [31:0] q;

    // Instantiate the instruction memory module
    
    
    // InstructionMemory_IP uut1(
	// 	.address(address[31:2]),
	// 	//.clken(1'b1),
	// 	.clock(clock),
	// 	.q(q));
    Instruction_Memory_asy IMEM(
        .rst(rst),
        .A(address[9:2]),
        .RD(q)
    );

    // Clock generation
    always begin
        #10 clock = ~clock;  // Clock period of 10 units
    end

    // Initial block for test sequence
    initial begin
        
        // Initialize signals
        // clock = 0;
        address = 32'b0;
        rst = 1;
        #10 rst = 0;
        // Apply test vectors
       // #20 address = 32'h00;  // Read from address 0x00
        #20 address = 32'h04;  // Read from address 0x04
        #20 address = 32'h08;  // Read from address 0x08
        #20 address = 32'h0C;  // Read from address 0x0C
        #20 address = 32'h10;  // Read from address 0x10
        #20 address = 32'h14;  // Read from address 0x14

        // Test with an address out of range (expect invalid data or unknown)
        #20 address = 32'hFF;  // Read from address 0xFF

        // End the simulation after a few cycles
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | Clock=%h | address=%h | q=%h ", $time, clock, address, q);
    end

endmodule