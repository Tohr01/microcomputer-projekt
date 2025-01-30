##### CONSTANTS #####
movi $0, 0      # CONSTANT: Stores number zero

movi $1, 1      # CONSTANT: Stores number one

# $C1 CONSTANT: Amount of numbers we have to check corresponds to 30000

# $C2 CONSTANT: Starting address of numbering sequence for algorithm (= 1000)

# $C3 CONSTANT: Stores max number (calculated by numbers to write + 1)

# $C4 CONSTANT: Stores last valid address calculated by (numbers to write) + (starting address) - 1

### END CONSTANTS ###

# Fill ram with continuous sequence of numbers
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

movi $R0, 0  # Iterator
movi $R1, 2  # Starting number [RS]
mov $R2, $C2 # Starting address [EX]

nop 

FILL_RAM_LOOP:
    cmp $R0, $C1 # Compare iterator with max amount of numbers
    
    nop 
    nop 
    nop 

    je SIEVE_OF_ERATOSTHENES # If iterator equal to max amount of numbers return

    nop 
    nop 
    nop 
    nop 
    nop 
    nop 

    store $R1, $R2 # Store number

    addi $R0, 1 # Increment iterator
    addi $R1, 1 # Increment number to write 
    addi $R2, 1 # Increment address to write to

    jmp FILL_RAM_LOOP

    nop
    nop
    nop
    nop
    nop
    nop


SIEVE_OF_ERATOSTHENES:
    # current_address = $C2
    # current_number = memory[current_address]
    # SIEVE_LOOP
    #   square = current_number * current_number
    # Check for overflow
    # cmp $OVERFLOW, $1
    # je NOOP_LOOP 

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
    
    nop
    nop
    nop

    SIEVE_LOOP:
        load $CNUM, $CADDR # Load number at $CADDR address from RAM in current num register [WFO]
        
        nop
        nop
        nop
        
        # If $CNUM is 0 => not prime
        cmp $CNUM, $0
        
        nop
        nop
        nop

        je SIEVE_LOOP_NEXT_ITER

        nop
        nop
        nop
        nop
        nop
        nop

        ##### MULTIPLY #####
        # Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectively
        # Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
        
        # Calculate square
        mov $MULLEFT, $CNUM    
        mov $MULRIGHT, $CNUM 
        movi $MULRES, 0          # Set result to 0

        nop
        nop

        MULTIPLY_LOOP:
            cmp $MULRIGHT, $0    # Compare multiplier with 0
            
            nop
            nop
            nop

            je MULTIPLY_EXIT     # Exit if finished

            nop
            nop
            nop
            nop
            nop
            nop

            mov $R1, $MULRIGHT   # Copy data from MULRIGHT to R1
            
            nop
            nop
            nop
            
            andi $R1, 1          # Check if MULRIGHT is odd
            
            nop
            nop
            nop
            
            cmp $R1, $1          # Compare to 1 (odd check)
            
            nop
            nop
            nop

            je MULTIPLY_ADD_TO_RESULT # If odd, add left to result

            nop
            nop
            nop
            nop
            nop
            nop

            MULTIPLY_SHIFT:
                rsh $MULRIGHT, 1 # $MULRIGHT = $MULRIGHT >> 1
                
                nop
                nop
                nop

                cmp $MULRIGHT, $0 # Check if multiplicand is 0

                nop
                nop
                nop

                je MULTIPLY_EXIT

                nop
                nop
                nop
                nop
                nop
                nop
               
                lsh $MULLEFT, 1  # $MULLEFT = $MULLEFT << 1

                nop
                nop
                nop

                # Check for overflow during shift
                cmp $OVERFLOW, $1

                nop
                nop
                nop

                je NOOP_LOOP # OVERFLOW register == 1

                nop
                nop
                nop
                nop
                nop
                nop

                jmp MULTIPLY_LOOP    
                nop
                nop
                nop
                nop
                nop
                nop

            MULTIPLY_ADD_TO_RESULT:
                add $MULRES, $MULLEFT # Add left to result
                
                nop
                nop
                nop

                # Check for overflow during addition
                cmp $OVERFLOW, $1
                
                nop
                nop
                nop

                je NOOP_LOOP # If MULRES exceeds max value, set overflow
                
                nop
                nop
                nop
                nop
                nop
                nop

                jmp MULTIPLY_SHIFT
                nop
                nop
                nop
                nop
                nop
                nop

        ### END MULTIPLY ###


        MULTIPLY_EXIT:
            # $MULRES now contains square number (or overflowed num)
            cmp $MULRES, $C3
            
            nop
            nop
            nop

            # If square > $C3 finished
            jg NOOP_LOOP
            
            nop
            nop
            nop
            nop
            nop
            nop


        # Location of square in memory is equal to Startaddress - 2 + square
        mov $SADDR, $C2
        
        nop
        nop
        nop

        subi $SADDR, 2
        
        nop
        nop
        nop
        
        add $SADDR, $MULRES

        nop
        nop
        nop

        # Strike address is now at memory address of square number

        STRIKE_MULTIPLES:
            store $0, $SADDR   # Strike number / address
            add $SADDR, $CNUM  # Next multiple address
            
            nop
            nop
            nop

            cmp $OVERFLOW, $1 # Check for overflow if saddr + cnum >= 2^16
            
            nop
            nop
            nop

            je SIEVE_LOOP_NEXT_ITER # Handle address out of bounds due to overflow

            nop
            nop
            nop
            nop
            nop
            nop

            cmp $SADDR, $C4         # Check if stike address > last valid address

            nop
            nop
            nop

            jg SIEVE_LOOP_NEXT_ITER 
            
            nop
            nop
            nop
            nop
            nop
            nop

            jmp STRIKE_MULTIPLES
            nop
            nop
            nop
            nop
            nop
            nop

        
        SIEVE_LOOP_NEXT_ITER:
            addi $CADDR, 1
            nop
            nop
            jmp SIEVE_LOOP
            
            nop
            nop
            nop
            nop
            nop
            nop


NOOP_LOOP:
    nop
    nop
    nop
    nop
    nop
    nop
    dump_mem