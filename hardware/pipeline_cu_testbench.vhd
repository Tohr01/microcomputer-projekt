library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit_tb is
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';

    component Pipeline_Control_Unit is
        port(
            clk       : in std_logic;
            rst       : in std_logic
        );
    end component;

begin

    UUT: Pipeline_Control_Unit
        port map(
            clk => clk,
            rst => rst
        );

    -- Taktprozess
    clk_process: process
    begin
        while now < 100 ms loop
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
        wait for 10 ns;
        rst <= '0';

        wait;
    end process;

end Behavioral;