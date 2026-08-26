module tb_MIPS_Pipeline_ControlUnit;

    // Inputs
    reg [5:0] Opcode;
    reg [5:0] Funct;

    // Outputs
    wire RegWriteD;
    wire MemtoRegD;
    wire MemWriteD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire RegDstD;
    wire BranchD;
    wire JumpD;

    // Instantiate the DUT
    MIPS_Pipeline_ControlUnit dut (
        .Opcode(Opcode),
        .Funct(Funct),
        .RegWriteD(RegWriteD),
        .MemtoRegD(MemtoRegD),
        .MemWriteD(MemWriteD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RegDstD(RegDstD),
        .BranchD(BranchD),
        .JumpD(JumpD)
    );

    // Test Task
	 
    task test_control_unit;

        input [5:0] test_Opcode;
        input [5:0] test_Funct;

        input expected_RegWrite;
        input expected_MemtoReg;
        input expected_MemWrite;
        input [2:0] expected_ALUControl;
        input expected_ALUSrc;
        input expected_RegDst;
        input expected_Branch;
        input expected_Jump;

        begin

            Opcode = test_Opcode;
            Funct  = test_Funct;

            #10;

            if (
                RegWriteD    === expected_RegWrite    &&
                MemtoRegD    === expected_MemtoReg    &&
                MemWriteD    === expected_MemWrite    &&
                ALUControlD  === expected_ALUControl  &&
                ALUSrcD      === expected_ALUSrc      &&
                RegDstD      === expected_RegDst      &&
                BranchD      === expected_Branch      &&
                JumpD        === expected_Jump
            ) begin

                $display(
                    "PASS: Opcode=%b Funct=%b | RegWrite=%b MemtoReg=%b MemWrite=%b ALUControl=%b ALUSrc=%b RegDst=%b Branch=%b Jump=%b",
                    Opcode,
                    Funct,
                    RegWriteD,
                    MemtoRegD,
                    MemWriteD,
                    ALUControlD,
                    ALUSrcD,
                    RegDstD,
                    BranchD,
                    JumpD
                );

            end
            else begin

                $display(
                    "FAIL: Opcode=%b Funct=%b",
                    Opcode,
                    Funct
                );

                $display(
                    "      Expected: RegWrite=%b MemtoReg=%b MemWrite=%b ALUControl=%b ALUSrc=%b RegDst=%b Branch=%b Jump=%b",
                    expected_RegWrite,
                    expected_MemtoReg,
                    expected_MemWrite,
                    expected_ALUControl,
                    expected_ALUSrc,
                    expected_RegDst,
                    expected_Branch,
                    expected_Jump
                );

                $display(
                    "      Got:      RegWrite=%b MemtoReg=%b MemWrite=%b ALUControl=%b ALUSrc=%b RegDst=%b Branch=%b Jump=%b",
                    RegWriteD,
                    MemtoRegD,
                    MemWriteD,
                    ALUControlD,
                    ALUSrcD,
                    RegDstD,
                    BranchD,
                    JumpD
                );

            end

        end

    endtask


    // Test Sequence
	 
    initial begin

        $display("==================================================");
        $display(" MIPS Pipeline Control Unit Testbench");
        $display("==================================================");

        // R-Type ADD
        //
        // Opcode     = 000000
        // Funct      = 100000
        //
        // RegWrite   = 1
        // MemtoReg   = 0
        // MemWrite   = 0
        // ALUControl = 010 (ADD)
        // ALUSrc     = 0
        // RegDst     = 1
        // Branch     = 0
        // Jump       = 0
		  
        test_control_unit(
            6'b000000,
            6'b100000,
            1'b1,
            1'b0,
            1'b0,
            3'b010,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        // R-Type SUB
		  
        test_control_unit(
            6'b000000,
            6'b100010,
            1'b1,
            1'b0,
            1'b0,
            3'b110,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        // R-Type AND
		  
        test_control_unit(
            6'b000000,
            6'b100100,
            1'b1,
            1'b0,
            1'b0,
            3'b000,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        // R-Type OR
		  
        test_control_unit(
            6'b000000,
            6'b100101,
            1'b1,
            1'b0,
            1'b0,
            3'b001,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        // R-Type SLT
		  
        test_control_unit(
            6'b000000,
            6'b101010,
            1'b1,
            1'b0,
            1'b0,
            3'b111,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );


        // LW
        //
        // Opcode = 100011
        //
        // RegWrite   = 1
        // MemtoReg   = 1
        // MemWrite   = 0
        // ALUControl = 010 (ADD)
        // ALUSrc     = 1
        // RegDst     = 0
        // Branch     = 0
        // Jump       = 0
		  
        test_control_unit(
            6'b100011,
            6'b000000,
            1'b1,
            1'b1,
            1'b0,
            3'b010,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        // SW
        //
        // Opcode = 101011
        //
        // RegWrite   = 0
        // MemtoReg   = 0
        // MemWrite   = 1
        // ALUControl = 010 (ADD)
        // ALUSrc     = 1
        // RegDst     = 0
        // Branch     = 0
        // Jump       = 0
		  
        test_control_unit(
            6'b101011,
            6'b000000,
            1'b0,
            1'b0,
            1'b1,
            3'b010,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        // BEQ
        //
        // Opcode = 000100
        //
        // RegWrite   = 0
        // MemtoReg   = 0
        // MemWrite   = 0
        // ALUControl = 110 (SUB)
        // ALUSrc     = 0
        // RegDst     = 0
        // Branch     = 1
        // Jump       = 0
		  
        test_control_unit(
            6'b000100,
            6'b000000,
            1'b0,
            1'b0,
            1'b0,
            3'b110,
            1'b0,
            1'b0,
            1'b1,
            1'b0
        );


        // ADDI
        //
        // Opcode = 001000
        //
        // RegWrite   = 1
        // MemtoReg   = 0
        // MemWrite   = 0
        // ALUControl = 010 (ADD)
        // ALUSrc     = 1
        // RegDst     = 0
        // Branch     = 0
        // Jump       = 0
		  
        test_control_unit(
            6'b001000,
            6'b000000,
            1'b1,
            1'b0,
            1'b0,
            3'b010,
            1'b1,
            1'b0,
            1'b0,
            1'b0
        );


        // JUMP
        //
        // Opcode = 000010
        //
        // RegWrite   = 0
        // MemtoReg   = 0
        // MemWrite   = 0
        // ALUControl = 000 (default)
        // ALUSrc     = 0
        // RegDst     = 0
        // Branch     = 0
        // Jump       = 1
		  
        test_control_unit(
            6'b000010,
            6'b000000,
            1'b0,
            1'b0,
            1'b0,
            3'b000,
            1'b0,
            1'b0,
            1'b0,
            1'b1
        );


        // Unsupported Opcode
        //
        // All main control signals should be 0.
        // ALUOp = 00 -> ALUControl = ADD (010)
        //
        // Note: Because the MainDecoder uses ALUOp=00
        // as its default, ALUControl will be 010.
		  
        test_control_unit(
            6'b111111,
            6'b000000,
            1'b0,
            1'b0,
            1'b0,
            3'b010,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );


        $display("==================================================");
        $display(" Testbench Complete");
        $display("==================================================");

        #10;
        $finish;

    end

endmodule
