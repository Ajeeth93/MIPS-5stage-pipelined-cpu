module MIPS_Pipeline_FetchDecodePipeline(
    input [31:0] InstrF,
    input [31:0] PCPlus4F,
    input clk,
    input rst,
    input StallD,
    input FlushD,
    output reg [31:0] InstrD,
    output reg [31:0] PCPlus4D
);

    always @(posedge clk) begin
        if (rst) begin
            InstrD   <= 32'b0;
            PCPlus4D <= 32'b0;
        end
        else if (FlushD) begin
            InstrD   <= 32'b0;
            PCPlus4D <= 32'b0;
        end
        else if (!StallD) begin
            InstrD   <= InstrF;
            PCPlus4D <= PCPlus4F;
        end
    end

endmodule
