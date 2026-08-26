module tb_MIPS_Pipeline_ALU_Decoder;

    // Inputs
    reg [5:0] Funct;
    reg [1:0] ALUOp;

    // Output
    wire [2:0] ALUControl;

    // Instantiate the DUT
    MIPS_Pipeline_ALU_Decoder dut (
        .Funct(Funct),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    // Test task
    task test_alu_decoder;
        input [1:0] test_ALUOp;
        input [5:0] test_Funct;
        input [2:0] expected_ALUControl;

        begin
            ALUOp = test_ALUOp;
            Funct = test_Funct;
            #10;

            if (ALUControl === expected_ALUControl) begin
                $display(
                    "PASS: ALUOp=%b Funct=%b | ALUControl=%b",
                    ALUOp,
                    Funct,
                    ALUControl
                );
            end
            else begin
                $display(
                    "FAIL: ALUOp=%b Funct=%b | Expected=%b | Got=%b",
                    ALUOp,
                    Funct,
                    expected_ALUControl,
                    ALUControl
                );
            end
        end
    endtask

    initial begin

        $display("==============================================");
        $display(" MIPS ALU Decoder Testbench");
        $display("==============================================");

        // ------------------------------------------------
        // ALUOp = 00 -> ADD
        // Funct is ignored
        // ------------------------------------------------
        test_alu_decoder(
            2'b00,
            6'b000000,
            3'b010
        );

        // ------------------------------------------------
        // ALUOp = 01 -> SUB
        // Funct is ignored
        // ------------------------------------------------
        test_alu_decoder(
            2'b01,
            6'b000000,
            3'b110
        );

        // ------------------------------------------------
        // ALUOp = 10 -> R-type instructions
        // ------------------------------------------------

        // ADD
        test_alu_decoder(
            2'b10,
            6'b100000,
            3'b010
        );

        // SUB
        test_alu_decoder(
            2'b10,
            6'b100010,
            3'b110
        );

        // AND
        test_alu_decoder(
            2'b10,
            6'b100100,
            3'b000
        );

        // OR
        test_alu_decoder(
            2'b10,
            6'b100101,
            3'b001
        );

        // SLT
        test_alu_decoder(
            2'b10,
            6'b101010,
            3'b111
        );

        // ------------------------------------------------
        // Unsupported R-type function
        // Should default to AND (000)
        // ------------------------------------------------
        test_alu_decoder(
            2'b10,
            6'b111111,
            3'b000
        );

        // ------------------------------------------------
        // Unsupported ALUOp
        // Should default to 000
        // ------------------------------------------------
        test_alu_decoder(
            2'b11,
            6'b000000,
            3'b000
        );

        $display("==============================================");
        $display(" Testbench Complete");
        $display("==============================================");

        #10;
        $finish;

    end

endmodule
