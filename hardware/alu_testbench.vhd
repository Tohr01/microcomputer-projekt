LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- USE ieee.numeric_std.ALL;
 
ENTITY tb_ALU IS
END tb_ALU;
 
ARCHITECTURE behavior OF tb_ALU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ALU
    PORT(
        -- inputs:
        A        : in signed(15 downto 0);
        B        : in signed(15 downto 0);
        I           : in signed(4 downto 0);
        out_alu     : out signed(15 downto 0);
        carryout_alu: out std_logic
        );
    END COMPONENT;

   signal A : signed(15 downto 0) := (others => '0');
   signal B : signed(15 downto 0) := (others => '0');
   signal I : signed(4 downto 0) := (others => '0');

  --Outputs
   signal out_alu : signed(15 downto 0);
   signal carryout_alu : std_logic;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ALU PORT MAP (
        A => A,
        B => B,
        I => I,
        out_alu => out_alu,
        carryout_alu => carryout_alu
    );

    stim_proc: process
    begin  
        for iterator in 0 to 2 loop
            -- Test 1: Addition (A + B)
            A <= x"0005";
            B <= x"0003";
            I <= "00000";
            wait for 10 ns;

            -- Test 2: Subtraktion (A - B)  
            A <= x"0005";
            B <= x"0003";
            I <= "00001";
            wait for 10 ns;

            -- Test ?: Multiplikation (A * B)  
            --    A <= x"0005";
            --    B <= x"0003";
            --    I <= "00001"; 

            -- Test ?: Division (A / B)  
            --   A <= x"0005";
            --   B <= x"0003";
            --   I <= "00001";    
      
            -- Test 3: And  
            A <= x"0F0F";  
            B <= x"00FF";
            I <= "00110";
            wait for 10 ns;

            -- Test 4: Or
            A <= x"0F0F";  
            B <= x"00FF";
            I <= "00111";
            wait for 10 ns;

            -- Test 5: XOR  
            A <= x"0F0F";  
            B <= x"00FF";
            I <= "01000";
            wait for 10 ns;

           -- Test 6: NOT  
            A <= x"0F0F";  
            B <= x"0000";
            I <= "01001";

            -- Test 7: Equals  
            A <= x"0005";
            B <= x"0005";
            I <= "01100";
            wait for 10 ns;

            -- Test 8: Inequal  
            A <= x"0005";
            B <= x"0003";
            I <= "01101";
            wait for 10 ns;

            -- Test 9: Less than  
            A <= x"0003";
            B <= x"0005";
            I <= "01110";
            wait for 10 ns;

            -- Test 10: Greater than
            A <= x"0005";
            B <= x"0003";
            I <= "01111";
            wait for 10 ns;

            -- Test 11: Left Shift  
            A <= x"0005";
            B <= x"0000";
            I <= "00001";
            wait for 10 ns;

            -- Test 12: Right Shift  
            A <= x"0005";
            B <= x"0000";
            I <= "00001";
            wait for 10 ns;
        end loop;
    end process;

END;