`timescale 1ns / 1ps

module pipelined_processor_tb;

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

    // Stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        
        // Wait for global reset to finish
        #50;
        reset = 0;

        // Provide test program (assembly code)
        // Assembly program: 
        // addi x0, x0, 0   -> NOP
        // addiw x1, x0, 16 -> x1 = 16
        // addiw x2, x0, 8  -> x2 = 8
        // addiw x4, x0, 10 -> x4 = 10
        // addiw x3, x0, 0  -> x3 = 0
        
        // Memory initialization with test instructions
        //$readmemb("instructions.mem", uut.fetch_stage_inst.instruction_memory.mem);

        // Wait for execution to complete
        //#100;

        // Monitor outputs
        $monitor("Time: %0dns | Clk: %b |InstrD: %h| Imm: %d | ALUOpE: %d | funct3E: %b | funct7E: %b | ALUControl: %b | WordOp: %b | ALUResultE: %d | ALUResultM: %d",// | MUXout_PC_F: %h | PCD: %h |InstrD: %h",// | x1: %d | x2: %d | x3: %d | x4: %d", 
            $time, 
            clk,
            uut.InstrD,
            uut.ImmE,
            uut.decode_stage_inst.ALUOpD,
            uut.funct3E,
            uut.funct7E,
            uut.execution_stage_inst.ALUControl,
            uut.execution_stage_inst.WordOp ,
            uut.execution_stage_inst.ALUResultE ,
            uut.decode_stage_inst.RF.registers[1]
            // uut.decode_stage_inst.rd 
            // uut.fetch_stage_inst.PCF ,
            // uut.fetch_stage_inst.PCPlus4F,
            // uut.fetch_stage_inst.InstrD,
            // uut.writeback_stage_inst.ResultD, 
            // uut.decode_stage_inst.ReadData1E, 
            // uut.decode_stage_inst.ReadData2E, 
            // uut.execution_stage_inst.ALUResultM
            );

        // End simulation
        #100;
        $stop;
    end

endmodule
