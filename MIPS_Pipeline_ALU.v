module MIPS_Pipeline_ALU(
    input [31:0] SrcAE,
    input [31:0] SrcBE,
    input [2:0] ALUControlE,
    output reg [31:0] ALUOutE
);

    always @(*) begin
        case (ALUControlE)
            3'b010: ALUOutE = SrcAE + SrcBE; // ADD
            3'b110: ALUOutE = SrcAE - SrcBE; // SUB
            3'b000: ALUOutE = SrcAE & SrcBE; // AND
            3'b001: ALUOutE = SrcAE | SrcBE; // OR

            3'b111: begin                    // SLT
                if ($signed(SrcAE) < $signed(SrcBE))
                    ALUOutE = 32'b1;
                else
                    ALUOutE = 32'b0;
            end

            default: ALUOutE = 32'b0;
        endcase
    end

endmodule
