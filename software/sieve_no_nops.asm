##### CONSTANTS #####
movi $0, 0      # CONSTANT: Stores number zero

movi $1, 1      # CONSTANT: Stores number one

# $C1 CONSTANT: Amount of numbers we have to check corresponds to 30000

# $C2 CONSTANT: Starting address of numbering sequence for algorithm (= 1000)

# $C3 CONSTANT: Stores max number (calculated by numbers to write + 1)

# $C4 CONSTANT: Stores last valid address calculated by (numbers to write) + (starting address) - 1

### END CONSTANTS ###

movi $R1, 2  # Starting number [RS]
mov $R2, $C2 # Starting address [EX]

FILL_RAM_LOOP:
    cmp $R0, $C1 # Compare iterator with max amount of numbers

    je SIEVE_OF_ERATOSTHENES # If iterator equal to max amount of numbers return

    store $R1, $R2 # Store number

    addi $R0, 1 # Increment iterator
    addi $R1, 1 # Increment number to write 
    addi $R2, 1 # Increment address to write to

    jmp FILL_RAM_LOOP

SIEVE_OF_ERATOSTHENES:
    mov $CADDR, $C2 # Store starting address in CADDR register
    
    SIEVE_LOOP:
        load $CNUM, $CADDR # Load number at $CADDR address from RAM in current num register [WFO]
        
        # If $CNUM is 0 => not prime
        cmp $CNUM, $0

        je SIEVE_LOOP_NEXT_ITER

        ##### MULTIPLY #####
        # Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectively
        # Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
        
        # Calculate square
        mov $MULLEFT, $CNUM    
        mov $MULRIGHT, $CNUM 
        movi $MULRES, 0          # Set result to 0

        MULTIPLY_LOOP:
            cmp $MULRIGHT, $0    # Compare multiplier with 0

            je MULTIPLY_EXIT     # Exit if finished

            mov $R1, $MULRIGHT   # Copy data from MULRIGHT to R1
            
            andi $R1, 1          # Check if MULRIGHT is odd
            
            cmp $R1, $1          # Compare to 1 (odd check)

            je MULTIPLY_ADD_TO_RESULT # If odd, add left to result

            MULTIPLY_SHIFT:
                rsh $MULRIGHT, 1 # $MULRIGHT = $MULRIGHT >> 1

                cmp $MULRIGHT, $0 # Check if multiplicand is 0

                je MULTIPLY_EXIT
               
                lsh $MULLEFT, 1  # $MULLEFT = $MULLEFT << 1

                # Check for overflow during shift
                cmp $OVERFLOW, $1

                je NOOP_LOOP # OVERFLOW register == 1

                jmp MULTIPLY_LOOP    

            MULTIPLY_ADD_TO_RESULT:
                add $MULRES, $MULLEFT # Add left to result

                # Check for overflow during addition
                cmp $OVERFLOW, $1

                je NOOP_LOOP # If MULRES exceeds max value, set overflow

                jmp MULTIPLY_SHIFT

        ### END MULTIPLY ###


        MULTIPLY_EXIT:
            # $MULRES now contains square number (or overflowed num)
            cmp $MULRES, $C3

            # If square > $C3 finished
            jg NOOP_LOOP
            
        # Location of square in memory is equal to Startaddress - 2 + square
        mov $SADDR, $C2

        subi $SADDR, 2
        
        add $SADDR, $MULRES

        # Strike address is now at memory address of square number

        STRIKE_MULTIPLES:
            store $0, $SADDR   # Strike number / address
            add $SADDR, $CNUM  # Next multiple address

            cmp $OVERFLOW, $1 # Check for overflow if saddr + cnum >= 2^16

            je SIEVE_LOOP_NEXT_ITER # Handle address out of bounds due to overflow

            cmp $SADDR, $C4         # Check if stike address > last valid address

            jg SIEVE_LOOP_NEXT_ITER 

            jmp STRIKE_MULTIPLES

        
        SIEVE_LOOP_NEXT_ITER:
            addi $CADDR, 1

            jmp SIEVE_LOOP


NOOP_LOOP:
    nop
