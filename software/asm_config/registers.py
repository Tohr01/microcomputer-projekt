REGISTERS = {
    '0' : '00000', # Stores number 0
    'C1' : '00001', # Stores amount of number for the sieve algorithm
    'C2' : '00010', # Stores starting address of numbering sequence 
    'C3' : '00011', # Stores max number 2 + C1
    'C4' : '00100', # Stores last valid address calculated by (numbers to write) + (starting address) - 1
    'OVERFLOW' : '00101',
    'CADDR' : '00110', # Sieve current address
    'CNUM' : '00111',
    'MULLEFT' : '01000',
    'MULRIGHT' : '01001',
    'MULRES' : '01010',
    'SADDR' : '01011',
    'R0' : '01100', # Temp 1
    'R1' : '01101', # Temp 2
    'R2' : '01110', # Temp 3
    'MAX_VALUE' : '01111'
}