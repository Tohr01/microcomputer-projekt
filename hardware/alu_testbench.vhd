LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.all;
use work.opcodes_constants.all;

ENTITY tb_ALU IS
END tb_ALU;
 
ARCHITECTURE behavior OF tb_ALU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ALU
    PORT(
        -- inputs:
        A        : in signed(15 downto 0);
        B        : in signed(15 downto 0);
        I           : in integer;
        out_alu     : out signed(15 downto 0);
        carryout_alu: out std_logic
        );
    END COMPONENT;

   signal A : signed(15 downto 0) := (others => '0');
   signal B : signed(15 downto 0) := (others => '0');
   signal I : integer := 0;

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
        A <= x"0005";
        B <= x"0003";
        I <= ADD_OP; 
        wait for 10 ns;

        -- Test 2: Subtraction (A - B)
        A <= x"0005";
        B <= x"0003";
        I <= SUB_OP; 
        wait for 10 ns;

        -- Test 3: AND
        A <= x"0F0F";
        B <= x"00FF";
        I <= AND_OP; 
        wait for 10 ns;

        -- Test 4: OR
        A <= x"0F0F";
        B <= x"00FF";
        I <= OR_OP; 
        wait for 10 ns;

        -- Test 5: XOR
        A <= x"0F0F";
        B <= x"00FF";
        I <= XOR_OP; 
        wait for 10 ns;

        -- Test 6: NOT (operates only on A)
        A <= x"0F0F";
        B <= x"0000"; -- B is not used in NOT operation
        I <= NOT_OP; 
        wait for 10 ns;

        -- Test 7: Equals
        A <= x"0005";
        B <= x"0005";
        I <= BEQ_OP; 
        wait for 10 ns;

        -- Test 8: Not Equals
        A <= x"0005";
        B <= x"0003";
        I <= BNE_OP; 
        wait for 10 ns;

        -- Test 9: Less Than
        A <= x"0003";
        B <= x"0005";
        I <= BLT_OP; 
        wait for 10 ns;

        -- Test 10: Greater Than
        A <= x"0005";
        B <= x"0003";
        I <= BGT_OP; 
        wait for 10 ns;

        -- Test 11: Left Shift
        A <= x"0005";
        B <= x"0000"; -- B is not used in shift operation
        I <= LSH_OP; 
        wait for 10 ns;

        -- Test 12: Right Shift
        A <= x"0005";
        B <= x"0000"; -- B is not used in shift operation
        I <= RSH_OP; 
        wait for 10 ns;
        wait;
    end process;

END;