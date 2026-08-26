module MIPS_Pipeline_ExecuteMemoryPipeline(
    input RegWriteE,
    input MemtoRegE,
    input MemWriteE,

    output reg RegWriteM,
    output reg MemtoRegM,
    output reg MemWriteM,

    input [31:0] ALUOutE,
    output reg [31:0] ALUOutM,

    input [31:0] WriteDataE,
    output reg [31:0] WriteDataM,

    input [4:0] WriteRegE,
    output reg [4:0] WriteRegM,

    input clk,
    input rst
);

    always @(posedge clk) begin
        if (rst) begin
            RegWriteM <= 1'b0;
            MemtoRegM <= 1'b0;
            MemWriteM <= 1'b0;
            ALUOutM   <= 32'b0;
            WriteDataM <= 32'b0;
            WriteRegM <= 5'b0;
        end
        else begin
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;
            MemWriteM <= MemWriteE;
            ALUOutM   <= ALUOutE;
            WriteDataM <= WriteDataE;
            WriteRegM <= WriteRegE;
        end
    end

endmodule
