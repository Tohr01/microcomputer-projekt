library IEEE;
use IEEE.numeric_std.all;

package opcodes_constants is
    constant ADD_OP : integer := 0;
    constant SUB_OP : integer := 1;
    constant LOAD_OP : integer := 4;
    constant STORE_OP : integer := 5;
    constant AND_OP : integer := 6;
    constant OR_OP : integer := 7;
    constant XOR_OP : integer := 8;
    constant NOT_OP : integer := 9;
    constant CMP_OP : integer := 10;
    constant JUMP_OP : integer := 11;
    constant BEQ_OP : integer := 12;
    constant BNE_OP : integer := 13;
    constant BLT_OP : integer := 14;
    constant BGT_OP : integer := 15;
    constant LSH_OP : integer := 16;
    constant RSH_OP : integer := 17;
    constant BITTEST_OP : integer := 18;
end package opcodes_constants;