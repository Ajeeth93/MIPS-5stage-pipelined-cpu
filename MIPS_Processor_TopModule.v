module MIPS_Pipeline_Processor_TopModule(
    input clk,
    input rst,

    // Observation / Debug Outputs
    output [31:0] PCF,
    output [31:0] InstrF,
    output [31:0] InstrD,
    output [31:0] ALUOutE,
    output [31:0] ALUOutM,
    output [31:0] ResultW,
    output MemWriteM
);

    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire [31:0] DataAdr;
    wire [31:0] WriteData;

    MIPS_Pipeline_Processor CPU(
        .clk(clk),
        .rst(rst),
        .PCF(PCF),
        .InstrF(Instr),
        .MemWriteM(MemWriteM),
        .ALUOutM(DataAdr),
        .WriteDataM(WriteData),
        .ReadDataM(ReadData),
        .InstrD_out(InstrD),
        .ALUOutE_out(ALUOutE),
        .ALUOutM_out(ALUOutM),
        .ResultW_out(ResultW)
    );

    MIPS_Pipeline_InstructionMemory IMEM(
        .A(PCF),
        .RD(Instr)
    );
	 
    assign InstrF = Instr;

    MIPS_Pipeline_DataMemory DMEM(
        .A(DataAdr),
        .RD(ReadData),
        .WD(WriteData),
        .clk(clk),
        .WE(MemWriteM)
    );

endmodule
