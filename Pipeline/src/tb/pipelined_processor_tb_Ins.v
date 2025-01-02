`timescale 1ns / 1ps

module pipelined_processor_tb_Ins;
    // Inputs
    reg clk;
    reg reset;

    // Instantiate the Unit Under Test (UUT)
    pipelined_processor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Trace pipeline stages
    initial begin
        $monitor("Time: %0dns", $time);
        forever begin
            #10;
            $display("--------------------------------------------------------");
            $display("Time: %0dns", $time);
            
            // Fetch stage signals
            $display("Fetch Stage:");
            $display("PC: %0d, PC+4: %0d, Instruction: %h", uut.fetch_stage_inst.PCD, uut.fetch_stage_inst.PCPlus4D, uut.fetch_stage_inst.InstrD);

            // Decode stage signals
            $display("Decode Stage:");
            $display("PC: %0d, Imm: %0d, ReadData1: %0d, ReadData2: %0d", 
                     uut.decode_stage_inst.PCD, uut.decode_stage_inst.ImmE, 
                     uut.decode_stage_inst.ReadData1E, uut.decode_stage_inst.ReadData2E);
            $display("RegWrite: %b, ALUOp: %b, ALUSrc: %b", 
                     uut.decode_stage_inst.RegWriteEnE, uut.decode_stage_inst.ALUOpE, uut.decode_stage_inst.ALUSrcE);

            // Execute stage signals
            $display("Execute Stage:");
            $display("ALUResult: %0d, ReadData2: %0d, Rd: %0d", 
                     uut.execution_stage_inst.ALUResultM, uut.execution_stage_inst.ReadData2M, uut.execution_stage_inst.RdM);
            $display("MemRead: %b, MemWrite: %b, RegWrite: %b", 
                     uut.execution_stage_inst.MemReadEnM, uut.execution_stage_inst.MemWriteEnM, uut.execution_stage_inst.RegWriteEnM);

            // Memory stage signals
            $display("Memory Stage:");
            $display("ALUResult: %0d, ReadData: %0d, Rd: %0d", 
                     uut.memory_stage_inst.ALUResultW, uut.memory_stage_inst.ReadDataW, uut.memory_stage_inst.RdW);
            $display("MemtoReg: %b, RegWrite: %b", 
                     uut.memory_stage_inst.MemtoRegW, uut.memory_stage_inst.RegWriteEnW);

            // Writeback stage signals
            $display("Writeback Stage:");
            $display("Result: %0d, Rd: ", 
                     uut.writeback_stage_inst.ResultD
                    //  , uut.writeback_stage_inst.RDW
                     );
            // $display("RegWrite: %b", uut.writeback_stage_inst.RegWriteEnD);
            $display("--------------------------------------------------------");
        end
    end

    // Testbench
    initial begin
        // Initialize inputs
        reset = 1;

        // Wait for a few clock cycles
        #50;
        reset = 0;

        // Wait for instructions to propagate through pipeline
        #250;

        // Check results
        $display("Checking results...");

        // Expected results
        if (uut.decode_stage_inst.RF.registers[1] !== 16) $fatal("Test failed: x1 != 16");
        if (uut.decode_stage_inst.RF.registers[2] !== 8) $fatal("Test failed: x2 != 8");
        if (uut.decode_stage_inst.RF.registers[4] !== 10) $fatal("Test failed: x4 != 10");
        if (uut.decode_stage_inst.RF.registers[3] !== 24) $fatal("Test failed: x3 != 24");

        $display("All tests passed!");

        // Finish simulation
        $stop;
    end

endmodule
