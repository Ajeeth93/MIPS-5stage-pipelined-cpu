module MIPS_Pipeline_MainDecoder(
    input [5:0] Opcode,

    output RegWrite,
    output RegDst,
    output ALUSrc,
    output Branch,
    output MemWrite,
    output MemtoReg,
    output Jump,
    output [1:0] ALUOp
);

    reg [8:0] controls;

    assign {
        RegWrite,
        RegDst,
        ALUSrc,
        Branch,
        MemWrite,
        MemtoReg,
        Jump,
        ALUOp
    } = controls;

    always @(*) begin
        // Safe default: NOP
        controls = 9'b000000000;

        case (Opcode)
            6'b000000: controls = 9'b110000010; // R-type
            6'b100011: controls = 9'b101001000; // LW
            6'b101011: controls = 9'b001010000; // SW
            6'b000100: controls = 9'b000100001; // BEQ
            6'b001000: controls = 9'b101000000; // ADDI
            6'b000010: controls = 9'b000000100; // J
            default:   controls = 9'b000000000; // NOP/unsupported
        endcase
    end

endmodule
