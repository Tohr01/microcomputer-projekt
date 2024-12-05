library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity ALU is 
    generic (
        constant N: natural := 1
     );   
    port(
        -- inputs:
        A, B        : in signed(15 downto 0); -- Operants
        I           : in signed(4 downto 0); -- Instruction
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
        case (I) is
            when "00000" => res <= A + B; -- Addition
                carryout_alu <= overflow_detection_addition(A, B);
            when "00001" => res <= A - B; -- Substraction
                carryout_alu <= overflow_detection_addition(A, B);
            when "00110" => res <= A and B; -- AND
            when "00111" => res <= A or B; -- OR
            when "01000" => res <= A xor B; -- XOR
            when "01001" => res <= not A; -- NOT (bezieht sich nur auf A)
            when "01100" => -- Equality check
                if(A=B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when "01101" => -- Inequality check
                if(A/=B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when "01110" => -- Less than check
                if(A<B) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when "01111" => -- Greater than check
                if(B<A) then
                    res <= x"0001";
                else
                    res <= x"0000";
                end if;
            when "10000" => res <= signed(unsigned(A) sll N); -- Left shift
            when "10001" => res <= signed(unsigned(A) srl N); -- Right shift
            when others => res <= x"0000"; -- Default case
        end case;
    end process;

out_alu <= res;

end Behavioral;