# MIPS-5stage-pipelined-cpu

A **32-bit MIPS 5-stage pipelined processor** implemented in **Verilog RTL**.

The processor follows the classic five-stage pipeline architecture:

**IF → ID → EX → MEM → WB**

with dedicated pipeline registers between each stage.

---

## Features

- 32-bit MIPS datapath
- 5-stage instruction pipeline
- Modular Verilog RTL design
- ALU operations:
  - `ADD`
  - `SUB`
  - `AND`
  - `OR`
  - `SLT`
- Supported instructions:
  - R-type
  - `LW`
  - `SW`
  - `BEQ`
  - `ADDI`
  - `J`
- Data forwarding for RAW hazards
- Load-use hazard detection
- Pipeline stalls
- Branch hazard handling
- Pipeline flushing for branches and jumps
- Separate instruction and data memory
- Dedicated Verilog testbenches
- RTL simulation waveforms

---

## Architecture

```text
                    MIPS 5-Stage Pipeline

        ┌──────────────┐
        │      IF      │
        │ Instruction  │
        │    Fetch     │
        └──────┬───────┘
               │
             IF/ID
               │
        ┌──────▼───────┐
        │      ID      │
        │ Instruction  │
        │    Decode    │
        └──────┬───────┘
               │
             ID/EX
               │
        ┌──────▼───────┐
        │      EX      │
        │ Execute / ALU│
        └──────┬───────┘
               │
            EX/MEM
               │
        ┌──────▼───────┐
        │     MEM      │
        │    Memory    │
        │    Access    │
        └──────┬───────┘
               │
            MEM/WB
               │
        ┌──────▼───────┐
        │      WB      │
        │  Write Back  │
        └──────────────┘
Pipeline Stages
Instruction Fetch (IF)
Fetches the instruction from instruction memory and updates the Program Counter (PC).
Instruction Decode (ID)
Decodes the instruction, reads register operands, generates control signals, and handles branch comparison and immediate generation.
Execute (EX)
Performs ALU operations and selects the required operands using the forwarding logic.
Memory Access (MEM)
Handles load (LW) and store (SW) operations through data memory.
Write Back (WB)
Writes the ALU result or loaded memory data back into the register file.
Hazard Handling

The processor includes dedicated hardware logic for managing dynamic pipeline hazards.

Data Forwarding

Forwarding paths bypass data directly to the EX stage to minimize stalls caused by Read-After-Write (RAW) data dependencies.

        EX/MEM ──────────┐
                         │
        MEM/WB ──────────┼──► Forwarding MUX ──► ALU
                         │
        Register File ───┘
Load-Use Hazard

When an instruction immediately depends on a value loaded from memory, forwarding alone cannot resolve the hazard.

Example:

lw   $t0, 0($t1)
add  $t2, $t0, $t3

The hazard detection unit detects this dependency, freezes the PC and IF/ID pipeline registers, and inserts a pipeline stall (bubble) into the ID/EX stage.

Control Hazards

Branches (BEQ) and jumps (J) can cause incorrectly fetched instructions to enter the pipeline.

The processor handles control-flow changes using pipeline flushing and dynamic PC selection.

Supported Instructions
Instruction	Type	Operation
ADD	R-type	Register addition
SUB	R-type	Register subtraction
AND	R-type	Bitwise AND
OR	R-type	Bitwise OR
SLT	R-type	Set on less than
LW	I-type	Load word
SW	I-type	Store word
BEQ	I-type	Branch if equal
ADDI	I-type	Add immediate
J	J-type	Jump
RTL Schematic




Repository Structure
MIPS-5stage-pipelined-cpu/
│
├── RTL Code/
│   ├── MIPS_Pipeline_ALU.v
│   ├── MIPS_Pipeline_ALU_Decoder.v
│   ├── MIPS_Pipeline_ControlUnit.v
│   ├── MIPS_Pipeline_MainDecoder.v
│   ├── MIPS_Pipeline_HazardUnit.v
│   ├── MIPS_Pipeline_RegisterFile.v
│   ├── MIPS_Pipeline_InstructionMemory.v
│   ├── MIPS_Pipeline_DataMemory.v
│   ├── MIPS_Pipeline_FetchDecodePipeline.v
│   ├── MIPS_Pipeline_DataExecutePipeline.v
│   ├── MIPS_Pipeline_ExecuteMemoryPipeline.v
│   ├── MIPS_Pipeline_MemoryWritePipeline.v
│   └── MIPS_Pipeline_Processor_TopModule.v
│
├── Test Benches/
│   ├── tb_MIPS_Pipeline_ALU_Decoder.v
│   ├── tb_MIPS_Pipeline_ControlUnit.v
│   ├── tb_MIPS_Pipeline_HazardUnit.v
│   ├── tb_MIPS_Pipeline_MainDecoder.v
│   └── tb_MIPS_Pipeline_Processor_TopModule.v
│
├── Simulation Waveforms/
│   ├── MIPS_ALUDecoder_Simulation.PNG
│   ├── MIPS_ControlUnit_Simulation_Verification.PNG
│   ├── MIPS_HazardousUnit_Testbench_Simulation_Verification.PNG
│   ├── MIPS_MainDecoder_Simulation_Verification.PNG
│   └── MIPS_Pipeline_Processor_Simulation.PNG
│
├── RTL Schematics/
│   └── MIPS_RTL_Schematics.jpg
│
└── README.md
Verification

The design includes modular and system-level testbenches for functional verification.

Simulation waveforms are provided for:

ALU Decoder
Main Decoder
Control Unit
Hazard Unit
Complete MIPS Pipeline Processor
Tools & Technologies
Language: Verilog HDL
Domain: Digital Design & Computer Architecture
Simulation: RTL Simulation
Tools: ModelSim / Vivado / EDA Playground
Project Goals

This project demonstrates practical implementation of:

MIPS processor datapath and control-unit design
Five-stage instruction pipelining
Pipeline register design
Data forwarding for dependency resolution
Hazard detection and stall generation
Branch and jump handling
Pipeline flushing
RTL module organization
Testbench-based functional verification
Author

Ajeeth93

GitHub: github.com/Ajeeth93


**One important point:** I kept the `RTL Schematic` image reference as:

```markdown
![MIPS RTL Schematic](RTL%20Schematics/MIPS_RTL_Schematics.jpg)

because your folder contains RTL Schematics/MIPS_RTL_Schematics.jpg. GitHub should render that image automatically when the README is in the repository root.