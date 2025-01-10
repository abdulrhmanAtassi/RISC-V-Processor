`timescale 1ns / 1ps

module DataMemoryAsync_tb;

    // Testbench signals
    reg [12:0] tb_address;
    reg [7:0] tb_data_in;
    reg tb_rden;
    reg tb_wren;
    wire [7:0] tb_data_out;

    // Instantiate the DataMemoryAsync module
    DataMemoryAsync uut (
        .address(tb_address),
        .data_in(tb_data_in),
        .rden(tb_rden),
        .wren(tb_wren),
        .data_out(tb_data_out)
    );

    // Monitor changes in signals
    initial begin
        $monitor(
            "Time = %0t | Address = %d | Data In = %h | RDEN = %b | WREN = %b | Data Out = %h",
            $time, tb_address, tb_data_in, tb_rden, tb_wren, tb_data_out
        );
    end

    // Test procedure
    initial begin
        // Initialize signals
        tb_address = 13'd0;
        tb_data_in = 8'd0;
        tb_rden = 0;
        tb_wren = 0;

        // Write operation: Write 0xA5 to address 10
        #10;
        tb_address = 13'd10;  // Address to write
        tb_data_in = 8'hA5;   // Data to write
        tb_wren = 1;          // Enable write
        #10;
        tb_wren = 0;          // Disable write

        // Read operation: Read from address 10
        #10;
        tb_address = 13'd10;  // Address to read
        tb_rden = 1;          // Enable read
        #10;
        tb_rden = 0;          // Disable read

        // Write operation: Write 0x5A to address 20
        #10;
        tb_address = 13'd20;  // Address to write
        tb_data_in = 8'h5A;   // Data to write
        tb_wren = 1;          // Enable write
        #10;
        tb_wren = 0;          // Disable write

        // Read operation: Read from address 20
        #10;
        tb_address = 13'd20;  // Address to read
        tb_rden = 1;          // Enable read
        #10;
        tb_rden = 0;          // Disable read

        // End simulation
        #20;
        $stop;
    end

endmodule
