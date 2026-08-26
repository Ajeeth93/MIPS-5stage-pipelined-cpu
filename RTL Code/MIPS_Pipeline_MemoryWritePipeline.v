module MIPS_Pipeline_MemoryWritePipeline(
    input RegWriteM,
    input MemtoRegM,

    output reg RegWriteW,
    output reg MemtoRegW,

    input [31:0] ReadDataM,
    output reg [31:0] ReadDataW,

    input [31:0] ALUOutM,
    output reg [31:0] ALUOutW,

    input [4:0] WriteRegM,
    output reg [4:0] WriteRegW,

    input clk,
    input rst
);

    always @(posedge clk) begin
        if (rst) begin
            RegWriteW <= 1'b0;
            MemtoRegW <= 1'b0;
            ReadDataW <= 32'b0;
            ALUOutW   <= 32'b0;
            WriteRegW <= 5'b0;
        end
        else begin
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            ReadDataW <= ReadDataM;
            ALUOutW   <= ALUOutM;
            WriteRegW <= WriteRegM;
        end
    end

endmodule
