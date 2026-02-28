# Memory Map - 5-Stage RV32IM RISC-V Core

## Address Space

| Base      | Size   | Region        | Description                    |
|-----------|--------|---------------|--------------------------------|
| 0x0000_0000 | 64 KB | Instruction   | Code and read-only data        |
| 0x0000_0000 | 64 KB | Data          | Stack, heap, variables         |
| 0x0000_1000 | -     | Exit/signaling | Store 0 = pass, non-zero = fail |

## Alignment

- **Instruction fetch:** 4-byte aligned (word)
- **Load/store:** Natural alignment (byte=1, half=2, word=4)

## Memory Interface (SRAM-like)

### Instruction Bus
- `instr_addr[31:0]` - Word-aligned address
- `instr_rdata[31:0]` - Instruction word
- `instr_req` - Request valid
- `instr_gnt` - Grant (1 cycle latency)

### Data Bus
- `data_addr[31:0]` - Byte address
- `data_wdata[31:0]` - Write data
- `data_rdata[31:0]` - Read data
- `data_we` - Write enable
- `data_be[3:0]` - Byte enable (per-byte write strobe)
- `data_req` - Request valid
- `data_gnt` - Grant (1 cycle latency)

## Reset Vector

- PC starts at `0x0000_0000` after reset
