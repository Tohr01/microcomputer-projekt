# TODO HANDLE CONSTANTS TO BIG
# TODO @HARDWARE handle constants registers
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
addi $C3, 1     # CONSTANT: Stores max number (calculated by numbers to write + 1)

mov $C4, $C1
add $C4, $C2
subi $C4, 1     # CONSTANT: Stores last valid address calculated by (numbers to write) + (starting address) - 1

movi $MAX_VALUE, 31
lsh $MAX_VALUE, 5
addi $MAX_VALUE, 31
lsh $MAX_VALUE, 5
addi $MAX_VALUE, 31
lsh $MAX_VALUE, 1
addi $MAX_VALUE, 1 # Max value for 16-bit (2^16 -1)? (= 65535)

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

movi $R0, 0 # Iterator
movi $R1, 2 # Starting number [RS]
mov $R2, $C2 # Starting address [EX]

nop
nop
nop

FILL_RAM_LOOP:
    cmp $R0, $C1 # Compare iterator with max amount of numbers
    
    nop
    nop

    je SIEVE_OF_ERATOSTHENES # If iterator equal to max amount of numbers return

    nop
    nop
    nop
    nop

    store $R1, $R2 # Store number

    nop # [RS]
    nop # [EX]

    incr $R0 # Increment iterator # [WFO]
    nop
    incr $R1 # Increment number to write # [RS]
    nop
    incr $R2 # Increment address to write to [EX]
    nop

    jmp FILL_RAM_LOOP # [WFO]

    nop # [OPF]
    nop # [ID]
    nop # [IF]


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

    nop # [RS]
    nop # [EX]

    SIEVE_LOOP:
        load $CNUM, $CADDR # Load number at $CADDR address from RAM in current num register [WFO]
        
        nop
        nop

        # If $CNUM is 0 => not prime
        cmp $CNUM, $0

        nop
        nop

        je SIEVE_LOOP_NEXT_ITER

        nop
        nop
        nop
        nop

        ##### MULTIPLY #####
        # Calculate square
        mov $MULLEFT, $CNUM
        mov $MULRIGHT, $CNUM 

        # Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectively
        # Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
        # TODO HANDLE overflowed
        #
        movi $MULRES, 0      # Set result to 0
        movi $OVERFLOW, 0    # Initialize overflow flag to 0

        MULTIPLY_LOOP:
            cmp $MULRIGHT, $0    # Compare multiplier with 0
            
            nop
            nop

            je MULTIPLY_EXIT     # Exit if finished

            nop
            nop
            nop
            nop

            mov $R1, $MULRIGHT   # Copy data from MULRIGHT to R1
            andi $R1, 1          # Check if MULRIGHT is odd
            cmp $R1, $1        # Compare to 1 (odd check)

            nop
            nop

            je MULTIPLY_ADD_TO_RESULT # If odd, add left to result

            MULTIPLY_SHIFT:
                lsh $MULLEFT, 1  # $MULLEFT = $MULLEFT << 1
                rsh $MULRIGHT, 1 # $MULRIGHT = $MULRIGHT >> 1

                # Check for overflow during shift
                cmp $MULLEFT, $MAX_VALUE
                jg MULTIPLY_OVERFLOW # If MULLEFT exceeds max value, set overflow

                nop
                jmp MULTIPLY_LOOP

            MULTIPLY_ADD_TO_RESULT:
                add $MULRES, $MULLEFT # Add left to result
                # Check for overflow during addition
                cmp $MULRES, $MAX_VALUE
                jg MULTIPLY_OVERFLOW # If MULRES exceeds max value, set overflow

                nop
                jmp MULTIPLY_SHIFT

            MULTIPLY_OVERFLOW:
                movi $OVERFLOW, 1 # Set overflow flag
                jmp MULTIPLY_EXIT

        ### END MULTIPLY ###


        MULTIPLY_EXIT:
        cmp $OVERFLOW, $1
        nop # Delay slot for cmp to complete
        je OVERFLOW_HANDLING 

        # $MULRES now contains square number (or overflowed num)
        
        cmp $MULRES, $C3
        nop
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
            nop 
            jg SIEVE_LOOP_NEXT_ITER # If strike address > max valid address finished with strike

            jmp STRIKE_MULTIPLES

        
        SIEVE_LOOP_NEXT_ITER:
            incr $CADDR
            jmp SIEVE_LOOP


NOOP_LOOP:
    nop
    jmp NOOP_LOOP
          

OVERFLOW_HANDLING:
    # Terminate Program 
    jmp NOOP_LOOP
