library library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is 
     generic (
        constant N: natural := 1
     );   
    port(
        -- inputs:
        A, B        : in std_logic_vector(15 downto 0); -- Operants
        I           : in std_logic_vector(4 downto 0); -- Instruction
        out_alu     : out std_logic_vector(15 downto 0); -- Output of ALU
        carryout_alu: out std_logic; -- Carryout bit
    )
end ALU;

architecture Behavioral of ALU is
    -- Signal declarations
    signal res: std_logic_vector(15 downto 0)

    -- Function declarations
    function overflow_detection_addition(A: std_logic_vector; B: std_logic_vector) return std_logic is 
        variable tmp: std_logic_vector(16 downto 0);
    begin
        tmp <= ('0' & A) + ('0' & B);
        return tmp(16); -- use MSB for carryout detection
    end function;

    function overflow_detection_multiplication(A: std_logic_vector; B: std_logic_vector; res: unsigned(31 downto 0)) return std_logic is
        variable tmp: std_logic_vector(16 downto 0);
    begin
        if res(A'length + B'length - 1 downto 16) /= 0 then
            return '1';
        else
            return '0';
        end if;
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
            when "00010" => -- Multiplication
                res <= to_unsigned((to_integer(unsigned(A)) * to_integer(unsigned(B))), A'length + B'length);
                carryout_alu <= overflow_detection_multiplication(A, B, res);
                res <= std_logic_vector(full_product(15 downto 0));
            when "00011" => -- Division
                if B(B'length downto 0 /= 0) then
                    res <= std_logic_vector(to_unsigned((to_integer(unsigned(A)) / to_integer(unsigned(B))),16));
                else
                    res <= x'0000';
                    carryout_alu <= '1';
            when "00110" => res <= A and B; -- AND
            when "00111" => res <= A or B; -- OR
            when "01000" => res <= A xor B; -- XOR
            when "01001" => res <= not A; -- NOT (bezieht sich nur auf A)
            when "01100" => -- Equality check
                if(A=B) then
                    res <= x'0001';
                else
                    res <= x'0000';
                end if;
            when "01101" => res -- Inequality check
                if(A/=B) then
                    res <= x'0001';
                else
                    res <= x'0000';
                end if;
            when "01110" => res -- Less than check
                if(A<B) then
                    res <= x'0001';
                else
                    res <= x'0000';
                end if;
            when "01111" => res -- Greater than check
                if(B<A) then
                    res <= x'0001';
                else
                    res <= x'0000';
                end if;
            when "10000" => res <= std_logic_vector(unsigned(A) sll N) -- Left shift
            when "10001" => res <= std_logic_vector(unsigned(A) srl N) -- Right shift
            when others => res <= (others => NULL); -- Default case
        end case;
    end process;

out_alu <= res;

end Behavioral;