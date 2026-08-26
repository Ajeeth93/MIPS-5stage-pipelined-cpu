module MIPS_Pipeline_DataMemory(
    input [31:0] A,
    input [31:0] WD,
    input clk,
    input WE,
    output [31:0] RD
);

    reg [31:0] RAM [0:63];

    assign RD = RAM[A[7:2]];

    always @(posedge clk) begin
        if (WE)
            RAM[A[7:2]] <= WD;
    end

endmodule
