library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit_tb is
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal start     : std_logic := '0';
    signal instruction: unsigned(15 downto 0) := (others => '0');
    signal done_internal      : std_logic;

    component Control_Unit is
        port(
            clk       : in std_logic;
            rst       : in std_logic;
            start     : in std_logic;
            instruction: in unsigned(15 downto 0);
            done      : out std_logic
        );
    end component;

begin

    UUT: Control_Unit
        port map(
            clk => clk,
            rst => rst,
            start => start,
            instruction => instruction,
            done => done_internal
        );

    -- Taktprozess
    clk_process: process
    begin
        while now < 1 ms loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    -- Testprozess
    test_process: process
    begin
        -- Reset und Initialisierung
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Testfall 1: ADD immediate=1 to value in A_reg=000 and store the result in A_reg
        instruction <= unsigned'("0001000000000001");
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';
        wait for 100 ns;
        -- Testfall 2: ADD immediate=2 to value in A_reg=001 and store the result in A_reg
        instruction <= unsigned'("0001000100000010");
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';
        wait for 100 ns;

        -- Testfall 3: ADD A_reg=000 to B_reg=001 and store the result in A_reg
        instruction <= unsigned'("0000000000100000");
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';

        wait;
    end process;

end Behavioral;