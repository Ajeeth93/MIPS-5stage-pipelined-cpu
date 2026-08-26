module MIPS_Pipeline_3to1MUX(
    input [31:0] Port0,
    input [31:0] Port1,
    input [31:0] Port2,
    output reg [31:0] Out,
    input [1:0] sel
);

    always @(*) begin
        case (sel)
            2'b00: Out = Port0;
            2'b01: Out = Port1;
            2'b10: Out = Port2;
            default: Out = Port0;
        endcase
    end

endmodule
