# RISC-V Pipelined Processor

A 5-stage pipelined RISC-V processor implementation in Verilog HDL.

## Project Information

| Field | Details |
|-------|---------|
| **Course** | Computer Architecture 2 |
| **Institution** | Princess Sumaya University for Technology |
| **Supervisor** | Dr. Rajaa Alqudah |
| **Authors** | Abdulrhman Atassi <br>Sarah Al-Shobaki  |
| **Date** | December 20, 2024 |

## Architecture Overview

### Pipeline Stages
| Stage | Name | Description |
|-------|------|-------------|
| 1 | **IF** | Instruction Fetch - Retrieves instructions from memory |
| 2 | **ID** | Instruction Decode - Decodes instruction and reads registers |
| 3 | **EXE** | Execute - Performs ALU operations |
| 4 | **MEM** | Memory Access - Handles load/store operations |
| 5 | **WB** | Write Back - Writes results back to registers |

### Memory Configuration
| Memory Type | Size | Type | Usage |
|-------------|------|------|--------|
| Instruction Memory | 64K × 1 byte | Asynchronous ROM | Stores program instructions |
| Data Memory | 8K × 1 byte | Asynchronous RAM | Stores program data |

## Supported Instructions (20 Total)

### R-Type Instructions (8)
| Instruction | Mnemonic | Operation | Opcode/Funct3/Funct7 |
|-------------|----------|-----------|---------------------|
| Add Word | `addw` | R[rd] = R[rs1] + R[rs2] | 33/1/20 |
| And | `and` | R[rd] = R[rs1] & R[rs2] | 33/7/00 |
| XOR | `xor` | R[rd] = R[rs1] ^ R[rs2] | 33/3/00 |
| Or | `or` | R[rd] = R[rs1] \| R[rs2] | 33/5/00 |
| Set Less Than | `slt` | R[rd] = (R[rs1] < R[rs2]) ? 1 : 0 | 33/0/00 |
| Shift Left | `sll` | R[rd] = R[rs1] << R[rs2] | 33/4/00 |
| Shift Right | `srl` | R[rd] = R[rs1] >> R[rs2] | 33/2/00 |
| Subtract | `sub` | R[rd] = R[rs1] - R[rs2] | 33/6/00 |

### I-Type Instructions (6)
| Instruction | Mnemonic | Operation | Opcode/Funct3 |
|-------------|----------|-----------|---------------|
| Add Immediate Word | `addiw` | R[rd] = R[rs1] + imm | 13/0 |
| And Immediate | `andi` | R[rd] = R[rs1] & imm | 1B/6 |
| Jump And Link Register | `jalr` | R[rd]=PC+4; PC=R[rs1]+imm | 67/0 |
| Load Half Word | `lh` | R[rd] = {sign_ext, M[R[rs1]+imm](15:0)} | 03/2 |
| Load Word | `lw` | R[rd] = M[R[rs1]+imm](31:0) | 03/0 |
| Or Immediate | `ori` | R[rd] = R[rs1] \| imm | 13/7 |

### S-Type Instructions (2)
| Instruction | Mnemonic | Operation | Opcode/Funct3 |
|-------------|----------|-----------|---------------|
| Store Byte | `sb` | M[R[rs1]+imm](7:0) = R[rs2](7:0) | 23/0 |
| Store Word | `sw` | M[R[rs1]+imm](31:0) = R[rs2](31:0) | 23/2 |

### SB-Type Instructions (2)
| Instruction | Mnemonic | Operation | Opcode/Funct3 |
|-------------|----------|-----------|---------------|
| Branch On Equal | `beq` | if(R[rs1]==R[rs2]) PC=PC+{imm,1'b0} | 63/0 |
| Branch On Not Equal | `bne` | if(R[rs1]!=R[rs2]) PC=PC+{imm,1'b0} | 63/1 |

### U-Type Instructions (1)
| Instruction | Mnemonic | Operation | Opcode |
|-------------|----------|-----------|--------|
| Load Upper Immediate | `lui` | R[rd] = {imm, 12'b0} | 38 |

### UJ-Type Instructions (1)
| Instruction | Mnemonic | Operation | Opcode |
|-------------|----------|-----------|--------|
| Jump And Link | `jal` | R[rd]=PC+4; PC=PC+{imm,1'b0} | 6F |

## Core Components

| Component | Description | Features |
|-----------|-------------|----------|
| **Program Counter** | Tracks current instruction address | Increments by 4 or jumps to target |
| **Control Unit** | Generates control signals | Supports all instruction formats |
| **ALU** | Arithmetic Logic Unit | 8 operations (ADD, SUB, AND, OR, XOR, SLT, SLL, SRL) |
| **Register File** | 32 general-purpose registers | Dual read ports, single write port |
| **Immediate Generator** | Sign-extends immediate values | Supports all immediate formats |
| **Hazard Detection Unit** | Detects pipeline hazards | Implements stalling mechanism |
| **Forwarding Unit** | Resolves data hazards | EXE and MEM stage forwarding |

## Development Tools

| Tool | Purpose | Usage |
|------|---------|--------|
| **EDA Playground** | Initial Development | Module design and basic testing |
| **Intel Quartus** | Integration & Synthesis | Complete processor assembly |
| **Questa** | Simulation | Waveform analysis and verification |
| **GitHub** | Version Control | Code collaboration and backup |
| **Notion** | Documentation | Project organization and notes |
| **Python** | Assembler Tool | Convert assembly to machine code |

## Getting Started

### Prerequisites
- Intel Quartus Prime
- ModelSim/Questa
- Python 3.x (for assembler)

### Running the Processor
1. **Load Project**: Open the project in Quartus
2. **Compile Design**: Synthesize the Verilog files
3. **Load Program**: Use the assembler to convert your assembly code
4. **Simulate**: Run testbenches in Questa
5. **Analyze**: View waveforms and verify results

## Known Issues

| Issue | Impact | Status |
|-------|--------|--------|
| Branch/Loop Assembly | Testing limitation | Workaround available |
| Quartus IP Memory Delay | Timing issues | Resolved with custom async memory |

## Future Enhancements

- [ ] Implement 2-bit branch predictor
- [ ] Add instruction and data cache
- [ ] Implement loop unrolling optimization
- [ ] Extend instruction set support
- [ ] Add exception handling
- [ ] Performance optimization
