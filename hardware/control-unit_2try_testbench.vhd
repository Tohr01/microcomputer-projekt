library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit_tb is
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal start     : std_logic := '0';
    signal done_internal      : std_logic;

    component Control_Unit is
        port(
            clk       : in std_logic;
            rst       : in std_logic;
            start     : in std_logic;
            done      : out std_logic
        );
    end component;

begin

    UUT: Control_Unit
        port map(
            clk => clk,
            rst => rst,
            start => start,
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

        -- run with first instruction from RAM
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';
        wait for 100 ns;

        -- run with second instruction from RAM
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';
        wait for 100 ns;

        -- run with third instruction from RAM
        start <= '1';
        wait for 50 ns;
        start <= '0';
        wait until done_internal = '1';

        wait;
    end process;

end Behavioral;