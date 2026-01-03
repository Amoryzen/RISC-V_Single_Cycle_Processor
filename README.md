# RISC-V Single Cycle Processor (RV32I)

## 📌 Project Overview
This repository contains a Register-Transfer Level (RTL) implementation of a **Single-Cycle RISC-V Processor** supporting the **RV32I** base integer instruction set. Designed using **Verilog HDL**, this project serves as a core module for understanding computer architecture principles, specifically the data path and control logic of a RISC-style processor.

The processor is capable of executing a variety of instructions including arithmetic, logic, load/store capabilities, and control flow operations (branch/jump) in a single clock cycle.

## 🚀 Key Features
*   **Core Architecture**: 32-bit Single-Cycle RISC-V (RV32I).
*   **Instruction Support**:
    *   **Arithmetic/Logic**: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`.
    *   **Immediates**: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU`.
    *   **Memory Access**: `LB`, `LH`, `LW`, `LBU`, `LHU`, `SB`, `SH`, `SW`.
    *   **Control Flow**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`, `JAL`, `JALR`.
    *   **Upper Immediate**: `LUI`, `AUIPC`.
*   **Modular Design**: Distinct modules for ALU, Control Unit, Register File, Immediate Generator, and Memory interfaces.
*   **Debug-Ready**: The top-level module exposes critical internal signals (PC, ALU Output, Register Write Data) for easy waveform analysis and debugging.

## 🛠️ Tech Stack & Tools
*   **Language**: Verilog HDL
*   **IDE / Synthesis**: Intel Quartus Prime
*   **Simulation**: ModelSim / Quartus Vector Waveform (`.vwf`)
*   **Target Device**: Generic FPGA / Simulation-only (configurable)

## 📂 Project Structure
```
RISC-V_Single_Cycle_Processor/
├── toplevel_rv32i.v        # Top-level module integrating all components
├── ctrl_unit_rv32i.v       # Main Control Unit (Decoder & Control Signals)
├── alu_rv32i.v             # Arithmetic Logic Unit (ALU)
├── reg_file_rv32i.v        # 32x32-bit Register File
├── data_mem_rv32i.v        # Data Memory Module
├── instr_rom_rv32i.v       # Instruction Memory (ROM)
├── imm_select_rv32i.v      # Immediate Generator
├── brancher_rv32i.v        # Branch comparison logic
├── test_vector.s           # RISC-V Assembly test code for validation
└── *.v                     # Component submodules (Adder, Muxes, etc.)
```

## ⚡ Installation & Usage

### Prerequisites
*   Intel Quartus Prime (Lite/Standard/Pro) installed.
*   A RISC-V Assembler (like Venus) if you wish to modify `test_vector.s` and regenerate memory initialization files.

### 1. Open the Project
1.  Launch **Intel Quartus Prime**.
2.  Open the project file: `toplevel_rv32i.qpf`.
3.  Ensure all Verilog files are added to the project hierarchy.

### 2. Compile/Synthesize
1.  Run **Analysis & Synthesis** to check for syntax errors and logic validity.
2.  (Optional) Run full compilation if targeting specific FPGA hardware.

### 3. Run Simulation
**Using Vector Waveform File (.vwf):**
1.  Open `toplevel_rv32i.vwf` (if available).
2.  Run Functional Simulation to verify instruction execution cycle-by-cycle.

**Using ModelSim:**
1.  Launch ModelSim from Quartus.
2.  Compile all `.v` files.
3.  Simulate `toplevel_rv32i` module.
4.  Monitor `PC`, `instr`, `ALU_output`, and `dmem_out` to track program flow.

## 🧪 Testing
A sample assembly program is provided in `test_vector.s` to validate the processor's functionality.

**Test Scenario (`test_vector.s`):**
1.  **Initialize**: Loads values `a = 2325` and `b = 71`.
2.  **Operations**:
    *   Performs **Division** (manual loop) to find `2325 / 71`.
    *   Performs **Remainder** (manual loop) to find `2325 % 71`.
    *   Performs **Multiplication** (manual loop) to verify `(Quotient * b) + Remainder == a`.
3.  **Result**:
    *   If the validation passes, the processor stores `1` in register `a0`.
    *   Use the simulation waveform to check if register `a0` (x10) contains `1` at the end of execution.

## 🔮 Roadmap / Future Work
*   [ ] Implement Pipelining (5-stage) to improve throughput.
*   [ ] Add Hazard Detection and Forwarding Unit.
*   [ ] Support CSR (Control and Status Registers) for system-level instructions.
*   [ ] Interface with physical FPGA I/O (LEDs, 7-Segment Displays).

## 📄 License
This project is open-source and available under the **MIT License**.

---
**Authors:** Rafi Ananta Alden, Didan Attaric
**Course:** EL3011 Computer System Architecture
