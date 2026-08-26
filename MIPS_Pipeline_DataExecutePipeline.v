module MIPS_Pipeline_DataExecutePipeline(
    input RegWriteD,
    input MemtoRegD,
    input MemWriteD,
    input [2:0] ALUControlD,
    input ALUSrcD,
    input RegDstD,

    output reg RegWriteE,
    output reg MemtoRegE,
    output reg MemWriteE,
    output reg [2:0] ALUControlE,
    output reg ALUSrcE,
    output reg RegDstE,

    input [31:0] RD1D,
    input [31:0] RD2D,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,

    input [4:0] RsD,
    input [4:0] RtD,
    input [4:0] RdD,
    output reg [4:0] RsE,
    output reg [4:0] RtE,
    output reg [4:0] RdE,

    input [31:0] SignImmD,
    output reg [31:0] SignImmE,

    input clk,
    input rst,
    input FlushE
);

    always @(posedge clk) begin
        if (rst) begin
            RegWriteE  <= 1'b0;
            MemtoRegE  <= 1'b0;
            MemWriteE  <= 1'b0;
            ALUControlE <= 3'b000;
            ALUSrcE    <= 1'b0;
            RegDstE    <= 1'b0;

            RD1E       <= 32'b0;
            RD2E       <= 32'b0;
            SignImmE   <= 32'b0;

            RsE        <= 5'b0;
            RtE        <= 5'b0;
            RdE        <= 5'b0;
        end
        else if (FlushE) begin
            // Insert a NOP into EX.
            RegWriteE   <= 1'b0;
            MemtoRegE   <= 1'b0;
            MemWriteE   <= 1'b0;
            ALUControlE <= 3'b000;
            ALUSrcE     <= 1'b0;
            RegDstE     <= 1'b0;

            RD1E        <= 32'b0;
            RD2E        <= 32'b0;
            SignImmE    <= 32'b0;

            RsE         <= 5'b0;
            RtE         <= 5'b0;
            RdE         <= 5'b0;
        end
        else begin
            RegWriteE   <= RegWriteD;
            MemtoRegE   <= MemtoRegD;
            MemWriteE   <= MemWriteD;
            ALUControlE <= ALUControlD;
            ALUSrcE     <= ALUSrcD;
            RegDstE     <= RegDstD;

            RD1E        <= RD1D;
            RD2E        <= RD2D;
            SignImmE    <= SignImmD;

            RsE         <= RsD;
            RtE         <= RtD;
            RdE         <= RdD;
        end
    end

endmodule
