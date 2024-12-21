module pipelined_processor (
    input clk,
    input reset
);
    // Instantiate pipeline stages and interconnect logic here
// Control signals
    wire PCSrcD;
    wire JalD;

    // Data signals
    wire [31:0] PCTargetD;
    wire [31:0] InstrD;
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;

    // Instantiate fetch stage
    fetch_stage fetch_stage_inst (
        .clk(clk),
        .rst(rst),
        .PCSrcD(PCSrcD),
        .JalD(JalD),
        .PCTargetD(PCTargetD),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );
endmodule