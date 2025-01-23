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
addi $C3, 2     # CONSTANT: Stores max number
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
