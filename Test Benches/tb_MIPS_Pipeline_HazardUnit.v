module tb_MIPS_Pipeline_HazardUnit;

    // DUT INPUTS

    reg [4:0] RsD;
    reg [4:0] RtD;

    reg [4:0] RsE;
    reg [4:0] RtE;

    reg [4:0] WriteRegE;
    reg [4:0] WriteRegM;
    reg [4:0] WriteRegW;

    reg BranchD;

    reg MemtoRegE;
    reg MemtoRegM;

    reg RegWriteE;
    reg RegWriteM;
    reg RegWriteW;

    reg UsesRsD;
    reg UsesRtD;

    // DUT OUTPUTS

    wire StallF;
    wire StallD;

    wire ForwardAD;
    wire ForwardBD;

    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;

    wire FlushE;

    // DUT

    MIPS_Pipeline_HazardUnit DUT (

        .RsD(RsD),
        .RtD(RtD),

        .RsE(RsE),
        .RtE(RtE),

        .WriteRegE(WriteRegE),
        .WriteRegM(WriteRegM),
        .WriteRegW(WriteRegW),

        .BranchD(BranchD),

        .MemtoRegE(MemtoRegE),
        .MemtoRegM(MemtoRegM),

        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),

        .UsesRsD(UsesRsD),
        .UsesRtD(UsesRtD),

        .StallF(StallF),
        .StallD(StallD),

        .ForwardAD(ForwardAD),
        .ForwardBD(ForwardBD),

        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),

        .FlushE(FlushE)
    );


    // DISPLAY TASK

    task display_outputs;
        begin
            #1;

            $display(
                "TIME=%0t | StallF=%b StallD=%b FlushE=%b | " ,
                $time, StallF, StallD, FlushE
            );

            $display(
                "           ForwardAE=%b ForwardBE=%b | " ,
                ForwardAE, ForwardBE
            );

            $display(
                "           ForwardAD=%b ForwardBD=%b",
                ForwardAD, ForwardBD
            );

            $display("-----------------------------------------------");
        end
    endtask


    // INITIALIZE ALL INPUTS

    initial begin

        RsD        = 5'd0;
        RtD        = 5'd0;

        RsE        = 5'd0;
        RtE        = 5'd0;

        WriteRegE  = 5'd0;
        WriteRegM  = 5'd0;
        WriteRegW  = 5'd0;

        BranchD    = 1'b0;

        MemtoRegE  = 1'b0;
        MemtoRegM  = 1'b0;

        RegWriteE  = 1'b0;
        RegWriteM  = 1'b0;
        RegWriteW  = 1'b0;

        UsesRsD    = 1'b0;
        UsesRtD    = 1'b0;

        #10;


        // TEST 1
        // No hazards

        $display("TEST 1: No hazards");

        RsE = 5'd1;
        RtE = 5'd2;

        WriteRegM = 5'd3;
        WriteRegW = 5'd4;

        RegWriteM = 1'b0;
        RegWriteW = 1'b0;

        #1;

        display_outputs;


        // TEST 2
        // Forward A from MEM
        //
        // RsE == WriteRegM

        $display("TEST 2: Forward A from MEM");

        RsE = 5'd8;

        WriteRegM = 5'd8;
        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        #1;

        display_outputs;


        // TEST 3
        // Forward B from MEM

        $display("TEST 3: Forward B from MEM");

        RsE = 5'd1;
        RtE = 5'd9;

        WriteRegM = 5'd9;
        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        #1;

        display_outputs;


        // TEST 4
        // Forward A from WB

        $display("TEST 4: Forward A from WB");

        RsE = 5'd10;

        WriteRegM = 5'd20;
        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        WriteRegW = 5'd10;
        RegWriteW = 1'b1;

        #1;

        display_outputs;


        // TEST 5
        // Forward B from WB

        $display("TEST 5: Forward B from WB");

        RsE = 5'd1;
        RtE = 5'd11;

        WriteRegM = 5'd20;
        WriteRegW = 5'd11;

        RegWriteM = 1'b0;
        RegWriteW = 1'b1;

        #1;

        display_outputs;


        // TEST 6
        // MEM forwarding has priority over WB
        //
        // Both MEM and WB write the same register.
        // MEM should win.

        $display("TEST 6: MEM forwarding priority over WB");

        RsE = 5'd12;

        WriteRegM = 5'd12;
        WriteRegW = 5'd12;

        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        RegWriteW = 1'b1;

        #1;

        display_outputs;


        // TEST 7
        // Load-use hazard
        //
        // Instruction in EX is LW to register 8.
        // Instruction in ID uses register 8 as Rs.
        //
        // Expected:
        // StallF = 1
        // StallD = 1
        // FlushE = 1

        $display("TEST 7: Load-use hazard through RsD");

        RsD = 5'd8;
        RtD = 5'd2;

        UsesRsD = 1'b1;
        UsesRtD = 1'b0;

        WriteRegE = 5'd8;

        MemtoRegE = 1'b1;
        RegWriteE = 1'b1;

        #1;

        display_outputs;


        // TEST 8
        // Load-use hazard through RtD

        $display("TEST 8: Load-use hazard through RtD");

        RsD = 5'd1;
        RtD = 5'd9;

        UsesRsD = 1'b0;
        UsesRtD = 1'b1;

        WriteRegE = 5'd9;

        MemtoRegE = 1'b1;
        RegWriteE = 1'b1;

        #1;

        display_outputs;


        // TEST 9
        // Load-use hazard should NOT occur if register is $zero

        $display("TEST 9: No hazard for register $zero");

        RsD = 5'd0;
        RtD = 5'd2;

        UsesRsD = 1'b1;
        UsesRtD = 1'b0;

        WriteRegE = 5'd0;

        MemtoRegE = 1'b1;
        RegWriteE = 1'b1;

        #1;

        display_outputs;


        // TEST 10
        // Branch depending on ALU result currently in MEM
        //
        // Expected:
        // ForwardAD = 1

        $display("TEST 10: Branch forwarding from MEM");

        BranchD = 1'b1;

        RsD = 5'd8;
        RtD = 5'd9;

        WriteRegM = 5'd8;

        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        #1;

        display_outputs;


        // TEST 11
        // Branch uses Rt value produced in MEM

        $display("TEST 11: Branch forwarding through RtD");

        RsD = 5'd8;
        RtD = 5'd9;

        WriteRegM = 5'd9;

        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        #1;

        display_outputs;


        // TEST 12
        // Branch depends on instruction currently in EX
        //
        // Result is not available yet.
        //
        // Expected:
        // StallF = 1
        // StallD = 1
        // FlushE = 1

        $display("TEST 12: Branch hazard from EX");

        BranchD = 1'b1;

        RsD = 5'd8;
        RtD = 5'd9;

        WriteRegE = 5'd8;

        RegWriteE = 1'b1;
        MemtoRegE = 1'b0;

        #1;

        display_outputs;


        // TEST 13
        // Branch depends on LW currently in MEM
        //
        // Loaded data isn't available until WB.
        //
        // Expected:
        // StallF = 1
        // StallD = 1
        // FlushE = 1

        $display("TEST 13: Branch hazard from load in MEM");

        BranchD = 1'b1;

        RsD = 5'd10;
        RtD = 5'd11;

        WriteRegE = 5'd20;
        RegWriteE = 1'b0;

        WriteRegM = 5'd10;

        RegWriteM = 1'b1;
        MemtoRegM = 1'b1;

        #1;

        display_outputs;


        // TEST 14
        // Branch depends on ALU instruction in MEM.
        //
        // No stall is required because ForwardAD/BD can
        // provide ALUOutM.

        $display("TEST 14: Branch forwarding from ALU in MEM");

        BranchD = 1'b1;

        RsD = 5'd12;
        RtD = 5'd13;

        WriteRegE = 5'd20;
        RegWriteE = 1'b0;

        WriteRegM = 5'd12;

        RegWriteM = 1'b1;
        MemtoRegM = 1'b0;

        #1;

        display_outputs;


        // TEST 15
        // Branch with no dependency

        $display("TEST 15: Branch with no hazard");

        BranchD = 1'b1;

        RsD = 5'd14;
        RtD = 5'd15;

        WriteRegE = 5'd20;
        RegWriteE = 1'b0;

        WriteRegM = 5'd21;
        RegWriteM = 1'b0;

        WriteRegW = 5'd22;
        RegWriteW = 1'b0;

        #1;

        display_outputs;


        // END

        $display("===============================================");
        $display("      HAZARD UNIT TESTBENCH COMPLETE");
        $display("===============================================");

        $finish;

    end

endmodule
