module tb_top_module;

    // Testbench signals
	 
    reg clk;
    reg rst;

    wire [31:0] PCF;
    wire [31:0] InstrF;
    wire [31:0] InstrD;
    wire [31:0] ALUOutE;
    wire [31:0] ALUOutM;
    wire [31:0] ResultW;
    wire        MemWriteM;

    // DUT
	 
    MIPS_Pipeline_Processor_TopModule DUT (
        .clk       (clk),
        .rst       (rst),

        .PCF       (PCF),
        .InstrF   (InstrF),
        .InstrD   (InstrD),
        .ALUOutE  (ALUOutE),
        .ALUOutM  (ALUOutM),
        .ResultW  (ResultW),
        .MemWriteM(MemWriteM)
    );

    // Clock: 10 ns period
	 
    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // Reset and simulation
	 
    initial begin

        // Reset processor
        rst = 1'b1;

        #20;

        // Release reset
        rst = 1'b0;

        // Run processor
        #250;

        $display("========================================");
        $display("           SIMULATION COMPLETE");
        $display("========================================");

        // Register values
        $display("$t0 ($8)  = %h", DUT.CPU.RF.Reg[8]);
        $display("$t1 ($9)  = %h", DUT.CPU.RF.Reg[9]);
        $display("$t2 ($10) = %h", DUT.CPU.RF.Reg[10]);
        $display("$t3 ($11) = %h", DUT.CPU.RF.Reg[11]);
        $display("$t4 ($12) = %h", DUT.CPU.RF.Reg[12]);

        // Data memory
        $display("MEM[0] = %h", DUT.DMEM.RAM[0]);
        $display("MEM[1] = %h", DUT.DMEM.RAM[1]);
        $display("MEM[2] = %h", DUT.DMEM.RAM[2]);

        $display("========================================");

        $finish;
    end

    // Monitor pipeline
	 
    always @(posedge clk) begin
        if (!rst) begin
            $display(
                "TIME=%0t  PC=%h  InstrF=%h  InstrD=%h  ALU_E=%h  ALU_M=%h  ResultW=%h  MemWrite=%b",
                $time,
                PCF,
                InstrF,
                InstrD,
                ALUOutE,
                ALUOutM,
                ResultW,
                MemWriteM
            );
        end
    end

endmodule
