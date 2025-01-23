Bit-Darstellung 16 Bit Befehl:
- 6 Bits: Opcode
- 5 Bits: R1 / 10Bit-Immediate-Part-1
- 5 Bits: R2 / 5-Bit-Immediate / 10Bit-Immediate-Part-2

| **Befehl**  | **Opcode (Binär)** | **Beschreibung**                    | **Priority**|
|-------------|-------------------|-------------------------------------|----------------|
| NOP         | `000000`            | `no operation`                                |✅|
| ADD         | `000010`            | `R1 = R1 + R2`                                |✅|
| ADDI       | `000011`          | `R1 = R1 + 5-Bit-Immediate`                      |✅|
| SUBI       | `000100`          | `R1 = R1 - 5-Bit-Immediate`                      |✅|
| INCR      | `000101`          | `R1 = R1 + 1`                                     |✅|
| ANDI      | `000110`          | `R1 = R1 AND 5-Bit-Immediate`                     |✅|
| LSH     | `000111`            | `R1 = R2 << 5-Bit-Immediate` (Links-Shift)        |✅|
| RSH      | `001000`            | `R1 = R2 >> 5-Bit-Immediate` (Rechts-Shift)      |✅|
| MOV      | `001001`          | `R1 = R2`                                          |✅|
| MOVI      | `001010`          | `R1 = 5-Bit-Immediate`                            |✅|
| STORE      | `001011`          | `RAM[R2] = R1`                                   |1|
| LOAD_OPCODE      | `001100`          | `R1 = RAM[R2]`                             |1|
| CALL      | `001101`          | tbd                                               |3|
| RET      | `001110`          | tbd                                                |3|
| CMP      | `001111`          | CMP_REG = Vergleiche `R1` and `R2` (Gleichheit: 1; Gößer als `R2`: 2; sonst: 0)  |1|
| JMP      | `010000`          | `program_counter = 10Bit-Immediate)`                                             |1|
| JG      | `010001`          | `if CMP_REG == 2, program_counter = 10Bit-Immediate; else NOP`                    |1|
| JE      | `010010`          | `if CMP_REG == 1, program_counter = 10Bit-Immediate; else NOP`                    |1|
