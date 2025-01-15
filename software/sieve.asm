# TODO HANDLE CONSTANTS TO BIG
##### CONSTANTS #####
movi $0, 0      # CONSTANT: Stores number zero

movi $1, 1      # CONSTANT: Stores number one

movi $C1, 29
lsh $C1, 5
addi $C1, 9
lsh $C1, 5
addi $C1, 16    # CONSTANT: Amount of numbers we have to check corresponds to 30000

movi $C2, 31
lsh $C2, 5
addi $C2, 8     # CONSTANT: Starting address of numbering sequence for algorithm (= 1000)

mov $C3, $C1
addi $C3, 2     # CONSTANT: Stores max number
mov $C4, $C1
add $C4, $C2
subi $C4, 1     # CONSTANT: Stores last valid address calculated by (numbers to write) + (starting address) - 1
### END CONSTANTS ###

# Fill ram with continous seq of numbers
call FILL_RAM

# TODO Handle end of program

SIEVE_OF_ERATOSTHENES:
    # current_address = $C2
    # current_number = memory[current_address]
    # SIEVE_LOOP
    #   square = current_number * current_number
    # Check for overflow
    # cmp $OVERFLOW, $1
    # je OVERFLOW_HANDLING 

    #   is_prime = current_number == 0
    #   if is_prime != 0 (current_number is prime)
    #       STRIKE_MULTIPLES

    #   incr current_address
    #   incr current_number
    # jmp SIEVE_LOOP
    #
    # STRIKE_MULTIPLES:
    #   Strike_address = square
    #  
    #   STRIKE_LOOP:
    #       if Strike_address >= max_address
    #            return
    #       add Strike_address, current_prime (next address to strike)
    #       load striked_number, Strike_address (load current number to strike in register)
    #       or striked_number, mask (strike)

    mov $CADDR, $C2 # Store starting address in CADDR register
    SIEVE_LOOP:
        load $CNUM, $CADDR # Load number at $CADDR address from RAM in current num register

        # If $CNUM is 0 => not prime
        cmp $CNUM, $0
        je SIEVE_LOOP_NEXT_ITER

        mov $MULLEFT, $CNUM
        mov $MULRIGHT, $CNUM 
        call MULTIPLY # Calculate square
        cmp $OVERFLOW, $1
        je OVERFLOW_HANDLING 

        # $MULRES now contains square number (or overflowed num)
        
        cmp $MULRES, $C3
        # If square > $C3 finished
        jg NOOP_LOOP
        # HANDLE OVERFLOW HERE Check sth like overflow register

        # Location of square in memory is == Startaddress - 2 + square

        mov $SADDR, $C2
        subi $SADDR, 2
        add $SADDR, $MULRES

        # Strike address is not at memory address of square number

        STRIKE_MULTIPLES:
            store $0, $SADDR   # Strike number / address
            add $SADDR, $CNUM # Next multiple address

            # TODO Handle overflow
            # Handle address out of bounds
            cmp $SADDR, $C4
            jg SIEVE_LOOP_NEXT_ITER # If strke address > max valid address finished with strike

            jmp STRIKE_MULTIPLES

        
        SIEVE_LOOP_NEXT_ITER:
            incr $CADDR
            jmp SIEVE_LOOP


NOOP_LOOP:
    nop
    jmp NOOP_LOOP

FILL_RAM:
    # Will fill RAM starting at address C2 starting at number 2 until number 2 + $C1 - 1
    # Valid addresses are $C2 until $C2 + $C1 - 1 = $C4
    # Check if R1 > C1
    # If yes 
    #   return
    # If no write 
    #    R3 to MEM-ADDR R4
    #    INCR R0
    #    INCR R1
    #    INCR R2

    movi $R0, 0 # Iterator
    movi $R1, 2 # Starting number
    mov $R2, $C2 # Starting address
    
    FILL_RAM_LOOP:
        cmp $R0, $C1 # Compare iterator with max amount of numbers
        je FILL_RAM_EXIT # If iterator equal to max amount of numbers return

        store $R1, $R2 # Store number
        incr $R0 # Increment iterator
        incr $R1 # Increment number to write
        incr $R2 # Increment address to write to
        jmp FILL_RAM_LOOP

        FILL_RAM_EXIT:
            ret

# Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectivly
# Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
# TODO HANDLE overflowed
#
#    @TIZIO HIER OVERFLOW HANDLEN. mach sonst wenn das overflowed erstmal in nen $OVERFLOW register
#    Setz das auf 1 wenn overflow und sonst auf 0
# 
MULTIPLY:
    # Result = 0
    # While right > 0:
    #   If right is odd:
    #       Result = Result + left
    #   left = left << 1
    #   right = right >> 1

    movi $MULRES, 0 # set result to 0
    MULTIPLY_LOOP:
        cmp $MULRIGHT, $0 # Compare multiplier with 0
        je MULTIPLY_EXIT # Multiplication finished

        mov $R1, $MULRIGHT  # Copy data from MULRIGHT register to R1 register
        andi $R1, 1         # If R1 is 1 then val in MULRIGHT is odd
        cmp $R1, $1         # Check if value in R1 == 1 (value in R2) Esentially if MULRIGHT is odd
        
        je MULTIPLY_ADD_TO_RESULT # Perform Result = Result + left step
        
        MULTIPLY_SHIFT:
            lsh $MULLEFT, 1 # $MULLEFT = $MULLEFT << 1
            rsh $MULRIGHT, 1 # $MULRIGHT = $MULRIGHT >> 1
            jmp MULTIPLY_LOOP

        MULTIPLY_ADD_TO_RESULT:
            add $MULRES, $MULLEFT
            jmp MULTIPLY_SHIFT

        MULTIPLY_EXIT:
            ret

MULTIPLY_WITH_OVERFLOW_DETECTION:
    movi $MULRES, 0      # Set result to 0
    movi $OVERFLOW, 0    # Initialize overflow flag to 0
    movi $R2, 1          # Store one for comparison

    movi $MAX_VALUE, 31
    lsh $MAX_VALUE, 5
    addi $MAX_VALUE, 31
    lsh $MAX_VALUE, 5
    addi $MAX_VALUE, 31
    lsh $MAX_VALUE, 5
    addi $MAX_VALUE, 1 # Max value for 16-bit (2^16 -1)? (= 65535)

    MULTIPLY_LOOP:
        cmp $MULRIGHT, $0    # Compare multiplier with 0
        je MULTIPLY_EXIT     # Exit if finished

        mov $R1, $MULRIGHT   # Copy data from MULRIGHT to R1
        andi $R1, 1          # Check if MULRIGHT is odd
        cmp $R1, $R2         # Compare to 1 (odd check)

        je MULTIPLY_ADD_TO_RESULT # If odd, add left to result

        MULTIPLY_SHIFT:
            lsh $MULLEFT, 1  # $MULLEFT = $MULLEFT << 1
            rsh $MULRIGHT, 1 # $MULRIGHT = $MULRIGHT >> 1

            # Check for overflow during shift
            cmp $MULLEFT, $MAX_VALUE
            jg MULTIPLY_OVERFLOW # If MULLEFT exceeds max value, set overflow

            jmp MULTIPLY_LOOP

        MULTIPLY_ADD_TO_RESULT:
            add $MULRES, $MULLEFT # Add left to result
            # Check for overflow during addition
            cmp $MULRES, $MAX_VALUE
            jg MULTIPLY_OVERFLOW # If MULRES exceeds max value, set overflow

            jmp MULTIPLY_SHIFT

        MULTIPLY_OVERFLOW:
            movi $OVERFLOW, 1 # Set overflow flag
            ret               # Exit multiplication

        MULTIPLY_EXIT:
            ret               # Return from multiplication                 

OVERFLOW_HANDLING:
    # Terminate Programm 
    # Andere Möglichkeiten: Endlosschleife, Nummer überspringen
    jmp NOOP_LOOP