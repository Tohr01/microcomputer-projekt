library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is 
    Port (
        A, B : in STD_LOGIC_VECTOR(15 downto 0) -- Operand A (16 Bit)
        I : in STD_LOGIC_VECTOR(4 downto 0) -- Opcode (5 Bit)
        out_alu : out STD_LOGIC_VECTOR(15 downto 0) -- Ergebnis (16 Bit)
        carryout_alu : out std_logic -- Null-Flag (Ergebnis ist 0)
    );
end ALU;


architecture Behavioral of ALU is
    signal res: STD_LOGIC_VECTOR(15 downto 0)
    signal tmp: STD_LOGIC_VECTOR(16 downto 0)
begin
    process(A, B, I)
    begin
        case (I) is
            when "00110" => res <= A and B; -- AND
            when "00111" => res <= A or B; -- OR
            when "01000" => res <= A xor B; -- XOR
            when "01001" => res <= not A; -- NOT (bezieht sich nur auf A)
            when "10000" => res <= std_logic_vector(unsigned(A) sll N)
            when "10001" => res <= std_logic_vector(unsigned(A) srl N)
            when others => res <= (others => '0'); -- Default case
        end case;  
    end process;

out_alu <= res;
tmp <= ('0' & A) + ('0' & B);
carryout_alu <= tmp(16)
end Behavioral;