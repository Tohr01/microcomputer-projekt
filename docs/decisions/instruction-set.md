Bit-Darstellung 16 Bit Befehl:
- 5 Bits: Opcode
- 3 Bits: R1
- 3 Bits: R2
- 5 Bits: R3 / Immediate

| **Befehl**  | **Opcode (Binär)** | **Beschreibung**                    | **Developer**|
|-------------|-------------------|-------------------------------------|----------------|
| ADD         | `00000`            | `R1 = R2 + R3`                      |Carl & Phil|
| SUB         | `00001`            | `R1 = R2 - R3`                      |Carl & Phil|
| ~MUL~       | ~`00010`~          | ~`R1 = R2 * R3`~                    |~Carl & Phil~|
| ~DIV~       | ~`00011`~          | ~`R1 = R2 / R3`~                    |~Carl & Phil~|
| LOAD        | `00100`            | `R1 = Mem[Addr]`                    |
| STORE       | `00101`            | `Mem[Addr] = R1`                    |
| AND         | `00110`            | `R1 = R2 AND R3`                    |Tizio & Jannik|
| OR          | `00111`            | `R1 = R2 OR R3`                     |Tizio & Jannik|
| XOR         | `01000`            | `R1 = R2 XOR R3`                    |Tizio & Jannik|
| NOT         | `01001`            | `R1 = NOT R2`                       |Tizio & Jannik|
| CMP         | `01010`            | Vergleiche `R1` und `R2`            |
| JUMP        | `01011`            | Unbedingter Sprung zu `Label`       |
| BEQ         | `01100`            | Sprung, wenn `R1 == R2`             |Carl & Phil|
| BNE         | `01101`            | Sprung, wenn `R1 != R2`             |Carl & Phil|
| BLT         | `01110`            | Sprung, wenn `R1 < R2`              |Carl & Phil|
| BGT         | `01111`            | Sprung, wenn `R1 > R2`              |Carl & Phil|
| LSH         | `10000`            | `R1 = R2 << N` (Links-Shift)        |Tizio & Jannik|
| RSH         | `10001`            | `R1 = R2 >> N` (Rechts-Shift)       |Tizio & Jannik|
| BITTEST     | `10010`            | Teste Bit `N` in `R1`               |
| OUT         | `10011`            | Sende den Wert aus `R1` an Display  |
