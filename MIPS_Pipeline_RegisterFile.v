module MIPS_Pipeline_RegisterFile(
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input WE3,
    output [31:0] RD1,
    output [31:0] RD2,
    input [31:0] WD3,
    input clk,
    input rst
);

    reg [31:0] Reg [0:31];
    integer i;

    assign RD1 = (A1 != 5'd0) ? Reg[A1] : 32'b0;
    assign RD2 = (A2 != 5'd0) ? Reg[A2] : 32'b0;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                Reg[i] <= 32'b0;
        end
        else if (WE3 && (A3 != 5'd0)) begin
            Reg[A3] <= WD3;
        end
    end

endmodule
