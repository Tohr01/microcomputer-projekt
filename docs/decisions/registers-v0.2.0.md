| **Registertyp**  | **Adresse (Binär)** | **Beschreibung**                    |
|-------------|-------------------|-------------------------------------|
| CMP_REG        | `00000`            | `stores latest value of compare method (0,1,2)`     |
| OVERFLOW        | `01110`             | `indicates if an arithmetic overflow occurred`        |
| C1              | `01111`             |                                     |
| C2              | `10000`             |                                    |
| C3              | `10001`             |                                     |
| C4              | `10010`             |                                     |
| 0               | `10011`             |                                    |
| 1               | `10100`             |                                    |
| CADDR           | `10101`             | `current address`                                     |
| CNUM            | `10110`             | `current numerical value`                             |
| MULLEFT         | `10111`             | `left operand for multiplication`                     |
| MULRIGHT        | `11000`             | `right operand for multiplication`                    |
| MULRES          | `11001`             | `result of multiplication`                            |
| SADDR           | `11010`             |                                      |
| R0              | `11011`             | `register 0 for general use`                          |
| R1              | `11100`             | `register 1 for general use`                          |
| R2              | `11101`             | `register 2 for general use`                          |