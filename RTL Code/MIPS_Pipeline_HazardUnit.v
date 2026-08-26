module MIPS_Pipeline_HazardUnit(
    input [4:0] RsD,
    input [4:0] RtD,

    input [4:0] RsE,
    input [4:0] RtE,

    input [4:0] WriteRegE,
    input [4:0] WriteRegM,
    input [4:0] WriteRegW,

    input BranchD,

    input MemtoRegE,
    input MemtoRegM,

    input RegWriteE,
    input RegWriteM,
    input RegWriteW,

    input UsesRsD,
    input UsesRtD,

    output reg StallF,
    output reg StallD,

    output reg ForwardAD,
    output reg ForwardBD,

    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,

    output reg FlushE
);

    reg lwstall;
 
    // EX-stage forwarding
    //
    // Do not forward ALUOutM when the MEM-stage instruction is
    // a load. In that case ALUOutM is the load address, not the
    // loaded data.
	 
    always @(*) begin
        if ((RsE != 5'd0) &&
            (RsE == WriteRegM) &&
            RegWriteM &&
            !MemtoRegM)
            ForwardAE = 2'b10;
        else if ((RsE != 5'd0) &&
                 (RsE == WriteRegW) &&
                 RegWriteW)
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
    end

    always @(*) begin
        if ((RtE != 5'd0) &&
            (RtE == WriteRegM) &&
            RegWriteM &&
            !MemtoRegM)
            ForwardBE = 2'b10;
        else if ((RtE != 5'd0) &&
                 (RtE == WriteRegW) &&
                 RegWriteW)
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

     
    // Branch forwarding from MEM.
    // Again, only ALU results are valid here.
    // Loads are handled by the branch stall logic below.
     
    always @(*) begin
        if ((RsD != 5'd0) &&
            (RsD == WriteRegM) &&
            RegWriteM &&
            !MemtoRegM)
            ForwardAD = 1'b1;
        else
            ForwardAD = 1'b0;
    end

    always @(*) begin
        if ((RtD != 5'd0) &&
            (RtD == WriteRegM) &&
            RegWriteM &&
            !MemtoRegM)
            ForwardBD = 1'b1;
        else
            ForwardBD = 1'b0;
    end
     
    // Hazard detection
     
    always @(*) begin

        // Normal load-use hazard:
        // load is in EX and the instruction in ID consumes
        // the register being loaded.
        lwstall =
            (MemtoRegE &&
             (WriteRegE != 5'd0) &&
             (
                (UsesRsD && (WriteRegE == RsD)) ||
                (UsesRtD && (WriteRegE == RtD))
             ));

        // Branch hazards:
        //
        // If branch is in ID and the producer is in EX,
        // the result is not available yet -> stall.
        //
        // If branch is in ID and a load is in MEM,
        // loaded data is not available until WB -> stall.
        //
        // If an ALU instruction is in MEM, ForwardAD/BD supplies
        // ALUOutM directly to the branch comparator.
        if (BranchD &&
            RegWriteE &&
            (WriteRegE != 5'd0) &&
            ((WriteRegE == RsD) || (WriteRegE == RtD)))
            lwstall = 1'b1;

        if (BranchD &&
            MemtoRegM &&
            RegWriteM &&
            (WriteRegM != 5'd0) &&
            ((WriteRegM == RsD) || (WriteRegM == RtD)))
            lwstall = 1'b1;

        StallF = lwstall;
        StallD = lwstall;

        // Insert a bubble into EX when ID is stalled.
        FlushE = lwstall;
    end

endmodule
