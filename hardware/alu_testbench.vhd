LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

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
        A        : in std_logic_vector(15 downto 0);
        B        : in std_logic_vector(15 downto 0);
        I           : in std_logic_vector(4 downto 0);
        out_alu     : out std_logic_vector(15 downto 0);
        carryout_alu: out std_logic;
        );
    END COMPONENT;

   signal A : std_logic_vector(15 downto 0) := (others => '0');
   signal B : std_logic_vector(15 downto 0) := (others => '0');
   signal I : std_logic_vector(4 downto 0) := (others => '0');

  --Outputs
   signal out_alu : std_logic_vector(15 downto 0);
   signal carryout_alu : std_logic;
 
 signal i:integer;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ALU PORT MAP (
        A => A,
        B => B,
        I => I,
        out_alu => out_alu
        carryout_alu => carryout_alu
    );

    stim_proc: process
    begin  
        -- Test 1: Addition (A + B)
        A <= x"0005";
        B <= x"0003";
        I <= "00000"
        wait for 10 ns;
    end process;

END;