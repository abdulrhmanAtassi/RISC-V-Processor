`timescale 1ns / 1ps

module benchmark_testbench;

  reg clk, reset;
  integer i;

  // Instantiate the processor (Unit Under Test)
  pipelined_processor uut (
    .clk(clk),
    .reset(reset)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns clock period
  end

  // Test Cases
  initial begin
    reset = 1;
    #10 reset = 0;

    // Run test cases sequentially
    test_case_1();
    test_case_2();
    test_case_3();
    test_case_4();
    test_case_5();

    $display("time: %d, All test cases passed!",$time);
    $finish;
  end

  // Task for Test Case 1
  task test_case_1;
    begin
      $display("Running Test Case 1...");
      // uut.instruction_memory[0] = 32'h00100093; // addiw x1, x0, 16
      // uut.instruction_memory[1] = 32'h00800113; // addiw x2, x0, 8
      // uut.instruction_memory[2] = 32'h00A00213; // addiw x4, x0, 10
      // uut.instruction_memory[3] = 32'h00000193; // addiw x3, x0, 0
      // uut.instruction_memory[4] = 32'h002081B3; // addw x3, x1, x2
      
      #120; // Wait for execution

      if (uut.decode_stage_inst.RF.registers[1] !== 16'h0010) $fatal("Test Case 1 Failed: x1 != 16 | U got %d", uut.decode_stage_inst.RF.registers[1]);
      if (uut.decode_stage_inst.RF.registers[2] !== 16'h0008) $fatal("Test Case 1 Failed: x2 != 8");
      if (uut.decode_stage_inst.RF.registers[3] !== 16'h0018) $fatal("Test Case 1 Failed: x3 != 24 | U got %d", uut.decode_stage_inst.RF.registers[3]);
      if (uut.decode_stage_inst.RF.registers[4] !== 16'h000A) $fatal("Test Case 1 Failed: x4 != 10");
    end
  endtask

  // Task for Test Case 2
  task test_case_2;
    begin
      $display("Running Test Case 2...");
      // uut.instruction_memory[0] = 32'h0FF00093; // addiw x1, x0, 0xFF
      // uut.instruction_memory[1] = 32'h0F000113; // addiw x2, x0, 0xF0
      // uut.instruction_memory[2] = 32'h00000213; // addiw x4, x0, 0
      // uut.instruction_memory[3] = 32'h00F00293; // andi x4, x1, 0x0F
      // uut.instruction_memory[4] = 32'h002083B3; // xor x7, x1, x2
      // uut.instruction_memory[5] = 32'h002081B3; // and x3, x1, x2
      // uut.instruction_memory[6] = 32'h00A01393; // ori x6, x2, 0x0A
      // uut.instruction_memory[7] = 32'h004103B3; // or x5, x3, x4

      #140; // Wait for execution

      if (uut.decode_stage_inst.RF.registers[1] !== 16'h00FF) $fatal("Test Case 2 Failed: x1 != 0xFF | U got %d", uut.decode_stage_inst.RF.registers[1]);
      if (uut.decode_stage_inst.RF.registers[2] !== 16'h00F0) $fatal("Test Case 2 Failed: x2 != 0xF0");
      if (uut.decode_stage_inst.RF.registers[3] !== 16'h00F0) $fatal("Test Case 2 Failed: x3 != 0xF0");
      if (uut.decode_stage_inst.RF.registers[4] !== 16'h000F) $fatal("Test Case 2 Failed: x4 != 0x0F");
      if (uut.decode_stage_inst.RF.registers[5] !== 16'h00FF) $fatal("Test Case 2 Failed: x5 != 0xFF | U got %d", uut.decode_stage_inst.RF.registers[5]);
      if (uut.decode_stage_inst.RF.registers[6] !== 16'h00FA) $fatal("Test Case 2 Failed: x6 != 0xFA");
      if (uut.decode_stage_inst.RF.registers[7] !== 16'h000F) $fatal("Test Case 2 Failed: x7 != 0x0F");
    end
  endtask

  // Task for Test Case 3
  task test_case_3;
    begin
      $display("Running Test Case 3...");
      // uut.instruction_memory[0] = 32'h03200093; // addiw x1, x0, 50
      // uut.instruction_memory[1] = 32'hFF600113; // addiw x2, x0, -10
      // uut.instruction_memory[2] = 32'h06400193; // addiw x3, x0, 100
      // uut.instruction_memory[3] = 32'h00000213; // addiw x4, x0, 0
      // uut.instruction_memory[4] = 32'h00000293; // addiw x5, x0, 0
      // uut.instruction_memory[5] = 32'h00000313; // addiw x6, x0, 0
      // uut.instruction_memory[6] = 32'h003102B3; // slt x5, x1, x3
      // uut.instruction_memory[7] = 32'h002082B3; // slt x4, x2, x1
      // uut.instruction_memory[8] = 32'h00218333; // slt x6, x3, x2

      #120; // Wait for execution

      if (uut.decode_stage_inst.RF.registers[1] !== 16'h0032) $fatal("Test Case 3 Failed: x1 != 50 | u got %d", uut.decode_stage_inst.RF.registers[1] );
      // Corrected comparison for a 64-bit register
      if (uut.decode_stage_inst.RF.registers[2] !== 64'hFFFFFFFFFFFFFFF6) 
        $fatal("Test Case 3 Failed: x2 != -10 | u got %h", uut.decode_stage_inst.RF.registers[2]);
      if (uut.decode_stage_inst.RF.registers[3] !== 16'h0064) $fatal("Test Case 3 Failed: x3 != 100 | u got %d", uut.decode_stage_inst.RF.registers[3] );
      if (uut.decode_stage_inst.RF.registers[4] !== 16'h0001) $fatal("Test Case 3 Failed: x4 != 1 | u got %d", uut.decode_stage_inst.RF.registers[4] );
      if (uut.decode_stage_inst.RF.registers[5] !== 16'h0001) $fatal("Test Case 3 Failed: x5 != 1 | u got %d", uut.decode_stage_inst.RF.registers[5] );
      if (uut.decode_stage_inst.RF.registers[6] !== 16'h0000) $fatal("Test Case 3 Failed: x6 != 0 | u got %d", uut.decode_stage_inst.RF.registers[6] );
    end
  endtask

  // Task for Test Case 4
  task test_case_4;
    begin
      $display("Running Test Case 4...");
      // uut.instruction_memory[0] = 32'h04000093; // addiw x1, x0, 64
      // uut.instruction_memory[1] = 32'h00200113; // addiw x2, x0, 2
      // uut.instruction_memory[2] = 32'h00300193; // addiw x3, x0, 3
      // uut.instruction_memory[3] = 32'h00000213; // addiw x4, x0, 0
      // uut.instruction_memory[4] = 32'h00000293; // addiw x5, x0, 0
      // uut.instruction_memory[5] = 32'h00310333; // srl x5, x1, x3
      // uut.instruction_memory[6] = 32'h00210233; // sll x4, x1, x2
      // uut.instruction_memory[7] = 32'h00000313; // addiw x6, x0, 0
      // uut.instruction_memory[8] = 32'h00218333; // sll x6, x5, x2

      #120; // Wait for execution

      if (uut.decode_stage_inst.RF.registers[1] !== 16'h0040) $fatal("Test Case 4 Failed: x1 != 64 |U got %0d", uut.decode_stage_inst.RF.registers[1]);
      if (uut.decode_stage_inst.RF.registers[2] !== 16'h0002) $fatal("Test Case 4 Failed: x2 != 2");
      if (uut.decode_stage_inst.RF.registers[3] !== 16'h0003) $fatal("Test Case 4 Failed: x3 != 3");
      if (uut.decode_stage_inst.RF.registers[4] !== 16'h0100) $fatal("Test Case 4 Failed: x4 != 256");
      if (uut.decode_stage_inst.RF.registers[5] !== 16'h0008) $fatal("Test Case 4 Failed: x5 != 8 | U got %d",uut.decode_stage_inst.RF.registers[5]);
      if (uut.decode_stage_inst.RF.registers[6] !== 16'h0020) $fatal("Test Case 4 Failed: x6 != 32");
    end
  endtask

  // Task for Test Case 5
  task test_case_5;
    begin
      $display("Running Test Case 5...");
      // uut.instruction_memory[0] = 32'h06400093; // addiw x1, x0, 100
      // uut.instruction_memory[1] = 32'h0C800113; // addiw x2, x0, 200
      // uut.instruction_memory[2] = 32'h02000193; // addiw x3, x0, 32
      // uut.instruction_memory[3] = 32'h00000313; // addiw x6, x0, 0
      // uut.instruction_memory[4] = 32'h00000393; // addiw x7, x0, 0
      // uut.instruction_memory[5] = 32'h02312023; // sw x1, 0(x3)
      // uut.instruction_memory[6] = 32'h02312423; // sw x2, 8(x3)
      // uut.instruction_memory[7] = 32'h00000413; // addiw x8, x0, 0
      // uut.instruction_memory[8] = 32'h00000493; // addiw x9, x0, 0
      // uut.instruction_memory[9] = 32'h00312083; // lw x4, 0(x3)
      // uut.instruction_memory[10] = 32'h00312483; // lw x5, 8(x3)

      #170; // Wait for execution

      if (uut.decode_stage_inst.RF.registers[1] !== 16'h0064) $fatal("Test Case 5 Failed: x1 != 100 | U go t%0d",  uut.decode_stage_inst.RF.registers[1]);
      if (uut.decode_stage_inst.RF.registers[2] !== 16'h00C8) $fatal("Test Case 5 Failed: x2 != 200");
      if (uut.decode_stage_inst.RF.registers[3] !== 16'h0020) $fatal("Test Case 5 Failed: x3 != 32");
      if (uut.decode_stage_inst.RF.registers[4] !== 16'h0064) $fatal("Test Case 5 Failed: MEM[32] != 100 | U got %d", uut.decode_stage_inst.RF.registers[4]);
      if (uut.decode_stage_inst.RF.registers[5] !== 16'h00C8) $fatal("Test Case 5 Failed: MEM[40] != 200 | U got %d", uut.decode_stage_inst.RF.registers[5]);
    end
  endtask

endmodule
