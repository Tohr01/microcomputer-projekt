# Assembly code

## Structure
- Subroutines and loop entry point are denoted by `name:`
- Registers noted by `$TEXT`

## Registers
Constants: 
- `$0` Stores int number zero
- `$C1` Stores amounts of numbers for the sieve algorithm
- `$C2` Stores starting address of numbering sequence for algorithm
- `$C3` Stores max number 2 + $C1
- `$C4` Stores last valid address calculated by (numbers to write) + (starting address) - 1
Sieve:
current address
current number
square
strike_address

Temporary:
- `$R0`
- `$R1`
- `$R2`

Multiplication
- `$MULLEFT` Stores multiplicand
- `$MULRIGHT` Stores multiplier
- `$MULRES` Stores the result
- `$MULOV` Stores 1 if multiplication overflowed else 0

Misc:
- Compare register
- Carryout register

## Subroutine explanation
### MULTIPLY
- Before using multiply set `$MULLEFT` and `$MULRIGHT` to multiplicand and multiplier respectivly
- Call MULTIPLY subroutine
- Read result from `$MULRES` register

## Assembler important information
Processing steps:
1. Strip lines
2. Remove all `\n`
3. Remove single line comments
4. Capture all subroutines and loops and note address
5. Normal assembly steps


## New instructions
Jumping instructions:
- JE (Jump equal)
- JNE (Jump not equal)
- JG (Jump greater)
- JL (Jump less)
- RET (Return)

Register operations:
- MOVI (movi $R1, 2 # Move constant number on right in R1)

Arithmetical
- INCR (Increment by one)
- ANDI (andi $R3, $R1, 1; Perform AND bool operation n value of register R1 with value 1 and store in R3)
- addi (addi $C1, 2; increment by number)
- subi (addi $C1, 2; increment by number)
Misc:
- nop (No operation)