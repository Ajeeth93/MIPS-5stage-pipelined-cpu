module MIPS_Pipeline_PCBranchDAdder(
    input [31:0] SignImmD2BitLeftShift,
    input [31:0] PCPlus4D,
    output [31:0] PCBranchD
);

    assign PCBranchD = PCPlus4D + SignImmD2BitLeftShift;

endmodule
