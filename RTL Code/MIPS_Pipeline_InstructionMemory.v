module MIPS_Pipeline_InstructionMemory(
    input [31:0] A,
    output [31:0] RD
);

    reg [31:0] RAM [0:63];

initial
begin
$readmemh("D:/XilinXISE/Projects/XilinxProjects/memfile.dat",RAM);
end

assign RD=RAM[A[7:2]];

endmodule
