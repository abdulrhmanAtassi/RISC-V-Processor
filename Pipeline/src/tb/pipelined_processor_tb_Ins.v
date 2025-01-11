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

     // Monitor Register File
    // initial begin
    // $monitor("Time=%0t | x0=%0d | x1=%0d | x2=%0d | x3=%0d | x4=%0d | x5=%0d | x6=%0d | x7=%0d",
    //         $time,
    //         uut.decode_stage_inst.RF.registers[0],
    //         uut.decode_stage_inst.RF.registers[1],
    //         uut.decode_stage_inst.RF.registers[2],
    //         uut.decode_stage_inst.RF.registers[3],
    //         uut.decode_stage_inst.RF.registers[4],
    //         uut.decode_stage_inst.RF.registers[5],
    //         uut.decode_stage_inst.RF.registers[6],
    //         uut.decode_stage_inst.RF.registers[7]);
    // end

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
            $display("PC: %0d, Imm: %0d, ReadData1: %0d, ReadData2: %0d, ResultW: %0d, x2: %0d", 
                        uut.decode_stage_inst.PCD, uut.decode_stage_inst.ImmE, 
                        uut.decode_stage_inst.ReadData1E, uut.decode_stage_inst.ReadData2E, uut.decode_stage_inst.ResultW, uut.decode_stage_inst.RF.registers[2]);
            $display("RegWrite: %b, ALUOp: %b, ALUSrc: %b", 
                        uut.decode_stage_inst.RegWriteEnE, uut.decode_stage_inst.ALUOpE, uut.decode_stage_inst.ALUSrcE);
            // display the hazard detection unit signals
            $display("Hazard Detection Unit: PCWriteD: %b, IF_IDWriteD: %b, MemReadEnE: %b, RdE: %0d", 
                        uut.decode_stage_inst.PCWriteD_R, uut.decode_stage_inst.IF_IDWriteD_R, uut.decode_stage_inst.MemReadEnBE, uut.decode_stage_inst.RdBE);

            // Execute stage signals
            $display("Execute Stage:");
            $display("ALUResult: %0d, ReadData2: %0d, Rd: %0d", 
                        uut.execution_stage_inst.ALUResultW, uut.execution_stage_inst.ReadData2M, uut.execution_stage_inst.RdM);
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
                    // ,   uut.writeback_stage_inst.RDW
                    );
            // $display("RegWrite: %b", uut.writeback_stage_inst.RegWriteEnD);
            // forwording signals
            $display("ForwardA: %b, ForwardB: %b, EX_MEM_RegWriteEn: %b, MEM_WB_RegWriteEN:%b ,EX_MEM_rd: %0d, MEM_WB_RD: %0d, ID_EX_rs1: %0d, ID_EX_rs2: %0d",
                    uut.forwarding_unit_inst.forwardA, uut.forwarding_unit_inst.forwardB, uut.forwarding_unit_inst.EX_MEM_RegWriteEn,uut.forwarding_unit_inst.MEM_WB_RegWriteEn , uut.forwarding_unit_inst.EX_MEM_rd ,uut.forwarding_unit_inst.MEM_WB_rd ,uut.forwarding_unit_inst.ID_EX_rs1 ,uut.forwarding_unit_inst.ID_EX_rs2);
            // Finish simulation
            $display("--------------------------------------------------------");
        end
    end

    // Testbench
    initial begin
        // Initialize inputs
        reset = 1;

        // Wait for a few clock cycles
        #20;
        reset = 0;

        // Wait for instructions to propagate through pipeline
        #700;

        // Check results
        $display("Checking results...");

        // Expected results
        // if (uut.decode_stage_inst.RF.registers[1] !== 16) $fatal("Test failed: x1 != 16");
        // if (uut.decode_stage_inst.RF.registers[2] !== 8) $fatal("Test failed: x2 != 8");
        // if (uut.decode_stage_inst.RF.registers[4] !== 10) $fatal("Test failed: x4 != 10");
        // if (uut.decode_stage_inst.RF.registers[3] !== 24) $fatal("Test failed: x3 != 24");
        if (uut.decode_stage_inst.RF.registers[1] !== 16'h00FF)
        $fatal("Test failed: x1 != 0xFF");

        // addiw x2, x0, 0xF0 -> x2 = 0xF0
        if (uut.decode_stage_inst.RF.registers[2] !== 16'h00F0)
        $fatal("Test failed: x2 != 0xF0");

        // addiw x4, x0, 0 -> x4 = 0
        // if (uut.decode_stage_inst.RF.registers[4] !== 16'h0000)
        // $fatal("Test failed: x4 != 0x0");

        // andi x4, x1, 0x0F -> x4 = x1 & 0x0F = 0x0F
        if (uut.decode_stage_inst.RF.registers[4] !== 16'h000F)
        $fatal("Test failed: x4 != 0xF");

        // xor x7, x1, x2 -> x7 = x1 ^ x2 = 0xFF ^ 0xF0 = 0x0F
        if (uut.decode_stage_inst.RF.registers[7] !== 16'h000F)
        $fatal("Test failed: x7 != 0x0F");

        // and x3, x1, x2 -> x3 = x1 & x2 = 0xFF & 0xF0 = 0xF0
        if (uut.decode_stage_inst.RF.registers[3] !== 16'h00F0)
        $fatal("Test failed: x3 != 0xF0");

        // ori x6, x2, 0x0A -> x6 = x2 | 0x0A = 0xF0 | 0x0A = 0xFA
        if (uut.decode_stage_inst.RF.registers[6] !== 16'h00FA)
        $fatal("Test failed: x6 != 0xFA");

        // or x5, x3, x4 -> x5 = x3 | x4 = 0xF0 | 0x0F = 0xFF
        if (uut.decode_stage_inst.RF.registers[5] !== 16'h00FF)
        $fatal("Test failed: x5 != 0xFF");

 
        $display("All tests passed!");

        // Finish simulation
        $stop;
    end

endmodule

