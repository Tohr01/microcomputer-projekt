library IEEE;
use IEEE.numeric_std.all;

package opcodes_constants is
    constant NOP : integer := 0;
    constant HLT : integer := 1;
    constant ADD : integer := 2;
    constant ADDI : integer := 3;
    constant SUBI : integer := 4;
    constant INCR : integer := 5;
    constant ANDI : integer := 6;
    constant LSH : integer := 7;
    constant RSH : integer := 8;
    constant MOV : integer := 9;
    constant MOVI : integer := 10;
    constant STORE : integer := 11;
    constant LOAD_OPCODE : integer := 12;
    constant CALL : integer := 13;
    constant RET : integer := 14;
    constant CMP : integer := 15;
    constant JMP : integer := 16;
    constant JG : integer := 17;
    constant JE : integer := 18;
    constant DUMP_OPCODE : integer := 19;
    constant VIS_LED : integer := 20;
end package opcodes_constants;