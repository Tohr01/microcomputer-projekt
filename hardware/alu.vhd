library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.opcodes_constants.ALL;

entity ALU is  
    port(
        -- inputs:
        A, B        : in signed(15 downto 0); -- Operants
        I           : in integer; -- Instruction
        Imm         : in signed(15 downto 0); --Immediate
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
    process(A, B, I, Imm)
    begin
        carryout_alu <= '0';
        case I is
            when ADD => 
                res <= A + B; 
                carryout_alu <= overflow_detection_addition(A, B);
            when ADDI =>
                res <= A + Imm; 
                carryout_alu <= overflow_detection_addition(A, Imm);
            when SUBI => 
                res <= A - Imm;    
                carryout_alu <= overflow_detection_addition(A, IMM);
            when ANDI =>
                res <= A and Imm;
            when MOV => 
                res <= B;
            when MOVI =>
                res <= Imm;            
            when INCR => 
                res <= A + 1;
                carryout_alu <= overflow_detection_addition(A, to_signed(1, 16));
            when CMP =>
                if (A=B) then 
                    res <= x"0001";
                elsif (A>B) then
                    res <= x"0002";    
                else
                    res <= x"0000"; 
                end if;
            when LSH => res <= signed(unsigned(A) sll to_integer(unsigned(Imm))); 
            when RSH => res <= signed(unsigned(A) srl to_integer(unsigned(Imm))); 
            when others => res <= x"0000"; -- Default case
        end case;
    end process;

out_alu <= res;

end Behavioral;