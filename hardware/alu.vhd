library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;
use work.opcodes_constants.ALL;

entity ALU is 
    generic (
        constant N: natural := 1
    );   
    port(
        -- inputs:
        A, B        : in signed(15 downto 0); -- Operants
        I           : in integer; -- Instruction
        out_alu     : out signed(15 downto 0); -- Output of ALU
        carryout_alu: out std_logic -- Carryout bit
    );
end ALU;

architecture Behavioral of ALU is
    -- Signal declarations
    signal res: signed(15 downto 0);

    -- Function declarations
    function overflow_detection_addition(func_A: signed; func_B: signed) return std_logic is 
        variable tmp: signed(16 downto 0);
    begin
        tmp := ('0' & func_A) + ('0' & func_B);
        return tmp(16); -- use MSB for carryout detection
    end function;

begin
    -- Architecture body
    process(A, B, I)
    begin
        carryout_alu <= '0';
        case I is
            when ADD_OP => res <= A + B; -- Addition
                carryout_alu <= overflow_detection_addition(A, B);
            when SUB_OP => res <= A - B; -- Substraction
                carryout_alu <= overflow_detection_addition(A, B);
            when AND_OP => res <= A and B; -- AND
            when OR_OP => res <= A or B; -- OR
            when XOR_OP => res <= A xor B; -- XOR
            when NOT_OP => res <= not A; -- NOT (bezieht sich nur auf A)
            when BEQ_OP => -- Equality check
                if(A=B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when BNE_OP => -- Inequality check
                if(A/=B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when BLT_OP => -- Less than check
                if(A<B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when BGT_OP => -- Greater than check
                if(B<A) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when LSH_OP => res <= signed(unsigned(A) sll N); -- Left shift
            when RSH_OP => res <= signed(unsigned(A) srl N); -- Right shift
            when others => res <= x"0000"; -- Default case
        end case;
    end process;

out_alu <= res;

end Behavioral;