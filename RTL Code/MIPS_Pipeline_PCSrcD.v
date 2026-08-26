module MIPS_Pipeline_PCSrcD(
    input BranchD,
    input [31:0] RD1MuxOut,
    input [31:0] RD2MuxOut,
    output PCSrcD
);

    assign PCSrcD = BranchD && (RD1MuxOut == RD2MuxOut);

endmodule
