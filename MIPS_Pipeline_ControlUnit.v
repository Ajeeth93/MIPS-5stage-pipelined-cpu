module MIPS_Pipeline_ControlUnit(
    input [5:0] Opcode,
    input [5:0] Funct,

    output RegWriteD,
    output MemtoRegD,
    output MemWriteD,
    output [2:0] ALUControlD,
    output ALUSrcD,
    output RegDstD,
    output BranchD,
    output JumpD
);

    wire [1:0] ALUOp;

    MIPS_Pipeline_ALU_Decoder ALUD1(
        .Funct(Funct),
        .ALUOp(ALUOp),
        .ALUControl(ALUControlD)
    );

    MIPS_Pipeline_MainDecoder MD1(
        .Opcode(Opcode),
        .RegWrite(RegWriteD),
        .RegDst(RegDstD),
        .ALUSrc(ALUSrcD),
        .Branch(BranchD),
        .MemWrite(MemWriteD),
        .MemtoReg(MemtoRegD),
        .ALUOp(ALUOp),
        .Jump(JumpD)
    );

endmodule
