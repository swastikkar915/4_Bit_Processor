# 4_Bit_Processor
A 4-Bit Microprocessor designed from scratch using Verilog
A fully functional, custom 4-bit microprocessor designed from scratch using Verilog and simulated in Xilinx Vivado. 

## Project Overview
This project implements a complete **Fetch-Decode-Execute** cycle based on a custom Instruction Set Architecture (ISA). It was built to demonstrate fundamental computer architecture concepts, bridging the gap between digital logic and programmable hardware.

### Key Hardware Components Implemented:
* **Program Counter (PC) & ROM:** Drives the execution flow and holds the instruction sequence.
* **Control Unit:** Custom combinational logic to decode 8-bit instructions, route data, and toggle control signals.
* **Arithmetic Logic Unit (ALU):** Performs arithmetic operations (ADD, SUB).
* **Register File:** Contains two 4-bit general-purpose registers (`R0`, `R1`).
* **Data Memory (RAM):** 16x4-bit storage allowing the processor to save and read variables across clock cycles.

## Tools & Technologies
* **Hardware Description Language:** Verilog (RTL)
* **Simulation & Synthesis:** Xilinx Vivado
* **Target Architecture:** Designed with FPGA integration in mind (Artix-7)

## Custom Instruction Set Architecture (ISA)
The processor uses an 8-bit instruction word (`[7:4]` Opcode, `[3:0]` Immediate/Address):

| Opcode | Mnemonic | Description |
| :--- | :--- | :--- |
| `0001` | `LOAD R0, imm` | Load immediate 4-bit value into R0 |
| `0010` | `LOAD R1, imm` | Load immediate 4-bit value into R1 |
| `0011` | `ADD` | Add R1 to R0, store in R0 |
| `0100` | `SUB` | Subtract R1 from R0, store in R0 |
| `0101` | `LOAD_RAM R0, addr`| Fetch data from RAM address into R0 |
| `0110` | `STORE_RAM R0, addr`| Store R0 data into RAM address |

## 📊 Simulation & Verification
The processor was verified using a custom testbench running a sequence of mathematical operations and memory storage commands. The waveform below verifies the successful execution of the core ISA precisely on the rising clock edges.

[Simulation Waveform](waveform.png)
