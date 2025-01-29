| **Registertyp**  | **Adresse (Binär)** | **Beschreibung**                    |
|-------------|-------------------|-------------------------------------|
| CMP_REG        | `00000`            | stores latest value of compare method (0,1,2)    |
| OVERFLOW        | `01110`             | indicates if an arithmetic overflow occurred      |
| C1              | `01111`             | Amount of numbers we have to check corresponds                                    |
| C2              | `10000`             | Starting address of numbering sequence for algorithm (first valid number is at this address)|
| C3              | `10001`             | Stores max number (calculated by numbers to write + 1)|
| C4              | `10010`             | Stores last valid address calculated by `(numbers to write) + (starting address) - 1`|
| 0               | `10011`             | Stores constant 0 |
| 1               | `10100`             | Stores constant 1 |
| CADDR           | `10101`             | Current read address for main sieve algorithm (address of current base number) |
| CNUM            | `10110`             | Current number at $CADDR address                             |
| MULLEFT         | `10111`             | Multiplicand                     |
| MULRIGHT        | `11000`             | Multiplicator                    |
| MULRES          | `11001`             | Result of multiplcation                            |
| SADDR           | `11010`             | Current striking address (Starts at: location of square in memory is equal to `Startaddress - 2 + square`)|
| R0              | `11011`             | Register 0 for general use                          |
| R1              | `11100`             | Register 1 for general use                          |
| R2              | `11101`             | Register 2 for general use                          |