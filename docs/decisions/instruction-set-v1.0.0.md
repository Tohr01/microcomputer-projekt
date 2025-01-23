Bit-Darstellung 16 Bit Befehl:
- 6 Bits: Opcode
- 5 Bits: R1 / 10Bit-Immediate-Part-1
- 5 Bits: R2 / Immediate / 10Bit-Immediate-Part-2

| **Befehl**  | **Opcode (Binär)** | **Beschreibung**                    | **Priority**|
|-------------|-------------------|-------------------------------------|----------------|
| NOP         | `00000`            | `no operation`                      |1|
| ADD         | `00001`            | `R1 = R1 + R2`                      |1|
| ADDI       | `00010`          | `R1 = R1 + IMMEDIATE`                   |1|
| SUBI       | `00011`          | `R1 = R1 - IMMEDIATE`                 |1|
| INCR      | `00100`          | `R1 = R1 + 1`                          |1|
| ANDI      | `00101`          | `R1 = R1 AND IMMEDIATE`                  |1|
| LSH     | `00110`            | `R1 = R2 << N` (Links-Shift)        |1|
| RSH      | `00111`            | `R1 = R2 >> N` (Rechts-Shift)       |1|
| MOV      | `01000`          | `R1 = R2`                           |1|
| MOVI      | `01001`          | `R1 = IMEDIATE`                  |1|
| STORE      | `01010`          | `RAM[R2] = R1`                  |1|
| LOAD      | `01011`          | `R1 = RAM[R2]`                  |1|
| CALL      | `01100`          | tbd                             |3|
| RET      | `01101`          | tbd                               |3|
| CMP      | `01110`          | CMP_REG = Vergleiche `R1` and `R2` (Gleichheit: 1; Gößer als `R2`: 2; sonst: 0)  |1|
| JMP      | `01111`          | `program_counter = IMMEDIATE(10Bit-Immediate)`     |1|
| JG      | `10000`          | `if CMP_REG == 2, program_counter = IMMEDIATE(10Bit-Immediate); else NOP`     |1|
| JE      | `10001`          | `if CMP_REG == 1, program_counter = IMMEDIATE(10Bit-Immediate); else NOP`     |1|
