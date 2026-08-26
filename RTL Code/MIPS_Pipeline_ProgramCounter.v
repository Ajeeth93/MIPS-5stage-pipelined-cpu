module MIPS_Pipeline_ProgramCounter(
    input [31:0] PCin,
    output reg [31:0] PCout,
    input clk,
    input rst,
    input en
);

    always @(posedge clk) begin
        if (rst)
            PCout <= 32'b0;
        else if (en)
            PCout <= PCin;
    end

endmodule
