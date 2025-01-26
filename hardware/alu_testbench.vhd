LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.NUMERIC_STD.ALL;
USE work.opcodes_constants.ALL;

ENTITY tb_ALU IS
END tb_ALU;

ARCHITECTURE behavior OF tb_ALU IS

    COMPONENT ALU
    PORT(
        -- Inputs:
        A           : in signed(15 downto 0);
        B           : in signed(15 downto 0);
        I           : in integer;
        Imm         : in signed(15 downto 0);
        out_alu     : out signed(15 downto 0);
        carryout_alu: out std_logic
    );
    END COMPONENT;

    -- Signals 
    signal A            : signed(15 downto 0) := (others => '0');
    signal B            : signed(15 downto 0) := (others => '0');
    signal I            : integer := 0;
    signal Imm         : signed(15 downto 0);

    -- Outputs
    signal out_alu      : signed(15 downto 0);
    signal carryout_alu : std_logic;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: ALU PORT MAP (
        A => A,
        B => B,
        I => I,
        Imm => Imm,
        out_alu => out_alu,
        carryout_alu => carryout_alu
    );

    stim_proc: process
    begin
        -- Normal Test Cases
        
        -- Test 1: Addition (Normal)
        A <= to_signed(5, 16);
        B <= to_signed(3, 16);
        I <= ADD;
        wait for 10 ns;

        -- Test 2: Subtraction (Normal)
        A <= to_signed(10, 16);
        Imm <= to_signed(5, 16);
        I <= SUBI;
        wait for 10 ns;

        -- Edge Cases

        -- Test 3: Addition (Positive Overflow)
        A <= to_signed(32767, 16); -- Max positive
        B <= to_signed(1, 16); 
        I <= ADD;
        wait for 10 ns;

        -- Test 4: Subtraction (Negative Overflow)
        A <= to_signed(-32768, 16); -- Max negative
        Imm <= to_signed(1, 16); 
        I <= SUBI;
        wait for 10 ns;

        -- Negative Test Cases
        -- Test 5: Invalid Opcode
        A <= to_signed(5, 16);
        B <= to_signed(3, 16);
        I <= 99999; -- Invalid opcode
        wait for 10 ns;

        -- Test 6: Shifts with boundary conditions
        A <= to_signed(1, 16); -- Only least significant bit set
        I <= LSH; -- Left shift
        wait for 10 ns;

        A <= to_signed(-32768, 16); -- Max negative
        I <= RSH; -- Right shift
        wait for 10 ns;

        -- End of test
        wait;
    end process;

END behavior;