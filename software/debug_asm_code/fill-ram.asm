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

    je NO # If iterator equal to max amount of numbers return

    nop 
    nop 
    nop 
    nop 
    nop 
    nop 

    store $R1, $R2 # Store number
    
    # Needs nop???

    addi $R0, 1 # Increment iterator
    addi $R1, 1 # Increment number to write 
    addi $R2, 1 # Increment address to write to

    jmp FILL_RAM_LOOP


NO:
hlt