module MIPS_Pipeline_01_2to1MUX(
    input [31:0] Port0,
    input [31:0] Port1,
    output reg [31:0] Out,
    input sel
);

    always @(*) begin
        if (sel)
            Out = Port1;
        else
            Out = Port0;
    end

endmodule
