Bit-Darstellung 16 Bit Befehl:
- 5 Bits: Opcode
- 3 Bits: R1
- 3 Bits: R2
- 5 Bits: Immediate

| **Befehl**  | **Opcode (Binär)** | **Beschreibung**                    | **Developer**|
|-------------|-------------------|-------------------------------------|----------------|
| ✅ ADD         | `00000`            | `R1 = R1 + R2`                      |Carl & Phil|
| ✅ SUB         | `00001`            | `R1 = R1 - R2`                      |Carl & Phil|
| ✅ ADD_IMMEDIATE       | `00010`          | `R1 = R1 + IMMEDIATE`                    |Phil|
| LOAD        | `00100`            | `R1 = Mem[Addr]`                    |
| STORE       | `00101`            | `Mem[Addr] = R1`                    |
| ✅ AND         | `00110`            | `R1 = R1 AND R2`                    |Tizio & Jannik|
| ✅ OR          | `00111`            | `R1 = R1 OR R2`                     |Tizio & Jannik|
| ✅ XOR         | `01000`            | `R1 = R1 XOR R2`                    |Tizio & Jannik|
| ✅ NOT         | `01001`            | `R1 = NOT R2`                       |Tizio & Jannik|
| CMP         | `01010`            | Vergleiche `R1` und `R2`            |
| JUMP        | `01011`            | Unbedingter Sprung zu `Label`       |
| 🟠 BEQ ("Sprung" fehlt)         | `01100`            | Sprung, wenn `R1 == R2`             |Carl & Phil|
| 🟠 BNE ("Sprung" fehlt)        | `01101`            | Sprung, wenn `R1 != R2`             |Carl & Phil|
| 🟠 BLT ("Sprung" fehlt)        | `01110`            | Sprung, wenn `R1 < R2`              |Carl & Phil|
| 🟠 BGT ("Sprung" fehlt)        | `01111`            | Sprung, wenn `R1 > R2`              |Carl & Phil|
| ✅ LSH         | `10000`            | `R1 = R2 << N` (Links-Shift)        |Tizio & Jannik|
| ✅ RSH         | `10001`            | `R1 = R2 >> N` (Rechts-Shift)       |Tizio & Jannik|
| BITTEST     | `10010`            | Teste Bit `N` in `R1`               |
| OUT         | `10011`            | Sende den Wert aus `R1` an Display  |
