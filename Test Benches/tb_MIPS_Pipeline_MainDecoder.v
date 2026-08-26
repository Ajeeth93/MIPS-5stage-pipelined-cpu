module tb_MIPS_Pipeline_MainDecoder;

    // Inputs
    reg [5:0] Opcode;

    // Outputs
    wire RegWrite;
    wire RegDst;
    wire ALUSrc;
    wire Branch;
    wire MemWrite;
    wire MemtoReg;
    wire Jump;
    wire [1:0] ALUOp;

    // Instantiate the DUT (Device Under Test)
    MIPS_Pipeline_MainDecoder dut (
        .Opcode(Opcode),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    // Task to test an opcode
    task test_opcode;
        input [5:0] test_opcode;
        input [8:0] expected_controls;

        begin
            Opcode = test_opcode;
            #10;

            if ({
                RegWrite,
                RegDst,
                ALUSrc,
                Branch,
                MemWrite,
                MemtoReg,
                Jump,
                ALUOp
            } === expected_controls) begin

                $display(
                    "PASS: Opcode=%b | Controls=%b",
                    Opcode,
                    {
                        RegWrite,
                        RegDst,
                        ALUSrc,
                        Branch,
                        MemWrite,
                        MemtoReg,
                        Jump,
                        ALUOp
                    }
                );

            end else begin

                $display(
                    "FAIL: Opcode=%b | Expected=%b | Got=%b",
                    Opcode,
                    expected_controls,
                    {
                        RegWrite,
                        RegDst,
                        ALUSrc,
                        Branch,
                        MemWrite,
                        MemtoReg,
                        Jump,
                        ALUOp
                    }
                );

            end
        end
    endtask

    initial begin

        $display("==============================================");
        $display(" MIPS Main Decoder Testbench");
        $display("==============================================");

        // R-type
        // Opcode = 000000
        // Controls = 110000010
        test_opcode(6'b000000, 9'b110000010);

        // LW
        // Opcode = 100011
        // Controls = 101001000
        test_opcode(6'b100011, 9'b101001000);

        // SW
        // Opcode = 101011
        // Controls = 001010000
        test_opcode(6'b101011, 9'b001010000);

        // BEQ
        // Opcode = 000100
        // Controls = 000100001
        test_opcode(6'b000100, 9'b000100001);

        // ADDI
        // Opcode = 001000
        // Controls = 101000000
        test_opcode(6'b001000, 9'b101000000);

        // J
        // Opcode = 000010
        // Controls = 000000100
        test_opcode(6'b000010, 9'b000000100);

        // Unsupported opcode
        // Should produce NOP controls
        // Controls = 000000000
        test_opcode(6'b111111, 9'b000000000);

        $display("==============================================");
        $display(" Testbench Complete");
        $display("==============================================");

        #10;
        $finish;
    end

endmodule
