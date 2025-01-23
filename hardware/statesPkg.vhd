package statesPkg is
    constant IDLE                   : integer := 0;
    constant INSTRUCTION_FETCH      : integer := 1;
    constant WAIT_FOR_INSTRUCTION   : integer := 2;
    constant INSTRUCTION_DECODE     : integer := 3;
    constant OPERAND_FETCH_A        : integer := 4;
    constant OPERAND_FETCH_B        : integer := 5;
    constant WAIT_FOR_OPERAND_A     : integer := 6;
    constant WAIT_FOR_OPERAND_B     : integer := 7;
    constant EXECUTE                : integer := 8; 
    constant RESULT_STORE           : integer := 9;
    constant NEXT_INSTRUCTION       : integer := 10;
end package statesPkg;