movi $0, 0
movi $1, 1
movi $CNUM, 2
nop
nop
nop
##### MULTIPLY #####
# Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectively
# Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
# TODO HANDLE overflowed

# Calculate square
mov $MULLEFT, $CNUM    
mov $MULRIGHT, $CNUM 
movi $MULRES, 0          # Set result to 0
##### MULTIPLY #####
# Requires MULLEFT and MULRIGHT register to be set to multiplicand and multiplier respectively
# Writes to MULLEFT, MULRIGHT, MULRES, R1, R2 registers
# TODO HANDLE overflowed

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
jmp NOOP_LOOP
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
store $OVERFLOW, $C2
nop
nop
nop
nop
nop
nop
dump_mem