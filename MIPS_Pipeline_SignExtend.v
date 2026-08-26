module MIPS_Pipeline_SignExtend(
    input [15:0] InstrD,
    output [31:0] SignImmD
);

    assign SignImmD = {{16{InstrD[15]}}, InstrD};

endmodule
