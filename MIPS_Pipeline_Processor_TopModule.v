module MIPS_Pipeline_Processor(
    input clk,
    input rst,

    // Instruction memory interface
    output [31:0] PCF,
    input  [31:0] InstrF,

    // Data memory interface
    output MemWriteM,
    output [31:0] ALUOutM,
    output [31:0] WriteDataM,
    input  [31:0] ReadDataM,

    // Debug outputs
    output [31:0] InstrD_out,
    output [31:0] ALUOutE_out,
    output [31:0] ALUOutM_out,
    output [31:0] ResultW_out
);

    // FETCH
	 
    wire [31:0] PCNextF;
    wire [31:0] PCPlus4F;

    // DECODE
	 
    wire [31:0] InstrD;
    wire [31:0] PCPlus4D;

    wire [4:0] RsD;
    wire [4:0] RtD;
    wire [4:0] RdD;

    wire [31:0] RD1D;
    wire [31:0] RD2D;
    wire [31:0] SignImmD;

    // EXECUTE
	 
    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] SrcAE;
    wire [31:0] SrcBE;
    wire [31:0] WriteDataE;
    wire [31:0] SignImmE;

    wire [4:0] RsE;
    wire [4:0] RtE;
    wire [4:0] RdE;
    wire [4:0] WriteRegE;

    wire [31:0] ALUOutE;

    // MEMORY
	 
    wire [4:0] WriteRegM;
    wire RegWriteM;
    wire MemtoRegM;

    // WRITEBACK
	 
    wire RegWriteW;
    wire MemtoRegW;

    wire [31:0] ReadDataW;
    wire [31:0] ALUOutW;
    wire [31:0] ResultW;
    wire [4:0] WriteRegW;

    // CONTROL
	 
    wire RegWriteD;
    wire MemtoRegD;
    wire MemWriteD;
    wire ALUSrcD;
    wire RegDstD;
    wire BranchD;
    wire JumpD;

    wire [2:0] ALUControlD;

    wire RegWriteE;
    wire MemtoRegE;
    wire MemWriteE;
    wire ALUSrcE;
    wire RegDstE;

    wire [2:0] ALUControlE;

    // HAZARD CONTROL
	 
    wire StallF;
    wire StallD;
    wire FlushE;

    wire ForwardAD;
    wire ForwardBD;

    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;

    // Flush the wrong-path instruction in IF/ID after a
    // branch or jump is taken.
    wire FlushD;

    // OPCODE / REGISTER FIELDS
	 
    wire [5:0] Opcode;
    wire [5:0] Funct;

    assign Opcode = InstrD[31:26];
    assign Funct  = InstrD[5:0];

    assign RsD = InstrD[25:21];
    assign RtD = InstrD[20:16];
    assign RdD = InstrD[15:11];

    // These are used to avoid unnecessary load-use stalls.
    // R-type: both Rs and Rt are sources
    // LW/ADDI: only Rs is a source
    // SW/BEQ: both Rs and Rt are sources
	 
    wire UsesRsD;
    wire UsesRtD;

    assign UsesRsD =
        (Opcode == 6'b000000) || // R-type
        (Opcode == 6'b100011) || // lw
        (Opcode == 6'b101011) || // sw
        (Opcode == 6'b000100) || // beq
        (Opcode == 6'b001000);   // addi

    assign UsesRtD =
        (Opcode == 6'b000000) || // R-type
        (Opcode == 6'b101011) || // sw
        (Opcode == 6'b000100);   // beq

    // FETCH STAGE
	 
    MIPS_Pipeline_ProgramCounter PC_REG(
        .PCin(PCNextF),
        .PCout(PCF),
        .clk(clk),
        .rst(rst),
        .en(!StallF)
    );

    MIPS_Pipeline_PCPlus4F PCPLUS4(
        .PCF(PCF),
        .PCPlus4F(PCPlus4F)
    );

    // BRANCH / JUMP TARGET LOGIC
	 
    wire [31:0] SignImmDShift;
    wire [31:0] PCBranchD;
    wire [31:0] PCJumpD;

    assign SignImmDShift = SignImmD << 2;

    MIPS_Pipeline_PCBranchDAdder BRANCHADD(
        .SignImmD2BitLeftShift(SignImmDShift),
        .PCPlus4D(PCPlus4D),
        .PCBranchD(PCBranchD)
    );

    // MIPS jump target:
    // {PC+4[31:28], instruction[25:0], 2'b00}
    assign PCJumpD = {
        PCPlus4D[31:28],
        InstrD[25:0],
        2'b00
    };

    // BRANCH COMPARATOR WITH FORWARDING
	 
    // Forward only a valid ALU result from MEM.
    // If the instruction in MEM is a load, its ALUOutM is the
    // address, not the loaded value; the hazard unit stalls
    // a dependent branch until the value reaches WB.
    wire [31:0] BranchRD1D;
    wire [31:0] BranchRD2D;
	 wire PCSrcD;

    assign BranchRD1D = ForwardAD ? ALUOutM : RD1D;
    assign BranchRD2D = ForwardBD ? ALUOutM : RD2D;

    MIPS_Pipeline_PCSrcD PCSRC(
        .BranchD(BranchD),
        .PCSrcD(PCSrcD),
        .RD1MuxOut(BranchRD1D),
        .RD2MuxOut(BranchRD2D)
    );

    // 3-way next-PC selection:
    // 00 = sequential
    // 01 = branch
    // 10 = jump
    wire [1:0] PCSelectD;

    assign PCSelectD =
        JumpD  ? 2'b10 :
        PCSrcD ? 2'b01 :
                 2'b00;

    MIPS_Pipeline_3to1MUX PCMUX(
        .Port0(PCPlus4F),
        .Port1(PCBranchD),
        .Port2(PCJumpD),
        .Out(PCNextF),
        .sel(PCSelectD)
    );

    assign FlushD = PCSrcD || JumpD;

    // IF/ID PIPELINE REGISTER
	 
    MIPS_Pipeline_FetchDecodePipeline FDREG(
        .InstrF(InstrF),
        .InstrD(InstrD),
        .PCPlus4D(PCPlus4D),
        .PCPlus4F(PCPlus4F),
        .clk(clk),
        .rst(rst),
        .StallD(StallD),
        .FlushD(FlushD)
    );

    // CONTROL UNIT
	 
    MIPS_Pipeline_ControlUnit CONTROL(
        .Opcode(Opcode),
        .Funct(Funct),
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),
        .BranchD(BranchD),
        .JumpD(JumpD)
    );

    // REGISTER FILE
	 
    MIPS_Pipeline_RegisterFile RF(
        .A1(RsD),
        .A2(RtD),
        .A3(WriteRegW),
        .WE3(RegWriteW),
        .RD1(RD1D),
        .RD2(RD2D),
        .WD3(ResultW),
        .clk(clk),
        .rst(rst)
    );

    // SIGN EXTEND
	 
    MIPS_Pipeline_SignExtend SE(
        .InstrD(InstrD[15:0]),
        .SignImmD(SignImmD)
    );

    // ID/EX PIPELINE REGISTER
	 
    MIPS_Pipeline_DataExecutePipeline ID_EX(
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),

        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .RegDstE(RegDstE),

        .RD1D(RD1D),
        .RD2D(RD2D),
        .RD1E(RD1E),
        .RD2E(RD2E),

        .RsD(RsD),
        .RtD(RtD),
        .RdD(RdD),

        .RsE(RsE),
        .RtE(RtE),
        .RdE(RdE),

        .SignImmD(SignImmD),
        .SignImmE(SignImmE),

        .clk(clk),
        .rst(rst),
        .FlushE(FlushE)
    );

    // FORWARDING MUXES
	 
    MIPS_Pipeline_3to1MUX FORWARD_A(
        .Port0(RD1E),
        .Port1(ResultW),
        .Port2(ALUOutM),
        .Out(SrcAE),
        .sel(ForwardAE)
    );

    MIPS_Pipeline_3to1MUX FORWARD_B(
        .Port0(RD2E),
        .Port1(ResultW),
        .Port2(ALUOutM),
        .Out(WriteDataE),
        .sel(ForwardBE)
    );

    // ALU SOURCE MUX
	 
    MIPS_Pipeline_01_2to1MUX ALUSRCMUX(
        .Port0(WriteDataE),
        .Port1(SignImmE),
        .Out(SrcBE),
        .sel(ALUSrcE)
    );

    // DESTINATION REGISTER MUX
	 
    assign WriteRegE = RegDstE ? RdE : RtE;

    // ALU
	 
    MIPS_Pipeline_ALU ALU(
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),
        .ALUControlE(ALUControlE),
        .ALUOutE(ALUOutE)
    );

    // EX/MEM PIPELINE REGISTER

    MIPS_Pipeline_ExecuteMemoryPipeline EX_MEM(
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),

        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),
        .MemWriteM(MemWriteM),

        .ALUOutE(ALUOutE),
        .ALUOutM(ALUOutM),

        .WriteDataE(WriteDataE),
        .WriteDataM(WriteDataM),

        .WriteRegE(WriteRegE),
        .WriteRegM(WriteRegM),

        .clk(clk),
        .rst(rst)
    );

    // MEM/WB PIPELINE REGISTER
	 
    MIPS_Pipeline_MemoryWritePipeline MEM_WB(
        .RegWriteM(RegWriteM),
        .MemtoRegM(MemtoRegM),

        .RegWriteW(RegWriteW),
        .MemtoRegW(MemtoRegW),

        .ReadDataM(ReadDataM),
        .ReadDataW(ReadDataW),

        .ALUOutM(ALUOutM),
        .ALUOutW(ALUOutW),

        .WriteRegM(WriteRegM),
        .WriteRegW(WriteRegW),

        .clk(clk),
        .rst(rst)
    );

    // WRITEBACK MUX
	 
    MIPS_Pipeline_10_2to1MUX WBMUX(
        .Port1(ReadDataW),
        .Port0(ALUOutW),
        .Out(ResultW),
        .sel(MemtoRegW)
    );

    // HAZARD UNIT
	 
    MIPS_Pipeline_HazardUnit HAZARD(
        .RsD(RsD),
        .RtD(RtD),

        .RsE(RsE),
        .RtE(RtE),

        .WriteRegE(WriteRegE),
        .WriteRegM(WriteRegM),
        .WriteRegW(WriteRegW),

        .BranchD(BranchD),

        .MemtoRegE(MemtoRegE),
        .MemtoRegM(MemtoRegM),

        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),

        .UsesRsD(UsesRsD),
        .UsesRtD(UsesRtD),

        .StallF(StallF),
        .StallD(StallD),

        .ForwardAD(ForwardAD),
        .ForwardBD(ForwardBD),

        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),

        .FlushE(FlushE)
    );

    // DEBUG OUTPUTS
	 
    assign InstrD_out  = InstrD;
    assign ALUOutE_out = ALUOutE;
    assign ALUOutM_out = ALUOutM;
    assign ResultW_out = ResultW;

endmodule
