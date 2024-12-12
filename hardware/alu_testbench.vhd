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
        out_alu     : out signed(15 downto 0);
        carryout_alu: out std_logic
    );
    END COMPONENT;

    -- Signals 
    signal A            : signed(15 downto 0) := (others => '0');
    signal B            : signed(15 downto 0) := (others => '0');
    signal I            : integer := 0;

    -- Outputs
    signal out_alu      : signed(15 downto 0);
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
        -- Normal Test Cases
        
        -- Test 1: Addition (Normal)
        A <= to_signed(5, 16);
        B <= to_signed(3, 16);
        I <= ADD_OP;
        wait for 10 ns;

        -- Test 2: Subtraction (Normal)
        A <= to_signed(10, 16);
        B <= to_signed(5, 16);
        I <= SUB_OP;
        wait for 10 ns;

        -- Edge Cases

        -- Test 3: Addition (Positive Overflow)
        A <= to_signed(32767, 16); -- Max positive
        B <= to_signed(1, 16); 
        I <= ADD_OP;
        wait for 10 ns;

        -- Test 4: Subtraction (Negative Overflow)
        A <= to_signed(-32768, 16); -- Max negative
        B <= to_signed(1, 16); 
        I <= SUB_OP;
        wait for 10 ns;

        -- Test 5: AND (All bits high)
        A <= to_signed(-1, 16); -- All bits are '1'
        B <= to_signed(-1, 16); -- All bits are '1'
        I <= AND_OP;
        wait for 10 ns;

        -- Test 6: OR (Edge with zeros)
        A <= to_signed(0, 16);
        B <= to_signed(-1, 16); -- All bits are '1'
        I <= OR_OP;
        wait for 10 ns;

        -- Test 7: XOR (Self XOR should yield zero)
        A <= to_signed(1234, 16);
        B <= to_signed(1234, 16);
        I <= XOR_OP;
        wait for 10 ns;

        -- Test 8: NOT (Boundary check)
        A <= to_signed(0, 16); -- All bits are '0'
        B <= to_signed(0, 16); -- Unused
        I <= NOT_OP;
        wait for 10 ns;

        -- Negative Test Cases
        
        -- Test 9: Division by Zero (Assuming DIV_OP exists)
        A <= to_signed(15, 16);
        B <= to_signed(0, 16); -- Division by zero
        I <= 99999; -- Dummy operation for robustness
        wait for 10 ns;

        -- Test 10: Invalid Opcode
        A <= to_signed(5, 16);
        B <= to_signed(3, 16);
        I <= 99999; -- Invalid opcode
        wait for 10 ns;

        -- Test 11: Shifts with boundary conditions
        A <= to_signed(1, 16); -- Only least significant bit set
        I <= LSH_OP; -- Left shift
        wait for 10 ns;

        A <= to_signed(-32768, 16); -- Max negative
        I <= RSH_OP; -- Right shift
        wait for 10 ns;

        -- Test 12: Comparison (Boundary checks)
        A <= to_signed(-32768, 16); -- Max negative
        B <= to_signed(32767, 16); -- Max positive
        I <= BLT_OP; -- A < B
        wait for 10 ns;

        -- Test 13: Equality with zero
        A <= to_signed(0, 16);
        B <= to_signed(0, 16);
        I <= BEQ_OP; -- A == B
        wait for 10 ns;

        -- End of test
        wait;
    end process;

END behavior;