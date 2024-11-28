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
        -- Test 1: Addition (A + B)
        for iterator in 0 to 15 loop
            A <= x"0005";
            B <= x"0003";
            I <= "00000";
            wait for 10 ms;
        end loop;
    end process;

END;