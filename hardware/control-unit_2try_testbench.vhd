library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit_tb is
-- Leere Entität für die Testbench
end Control_Unit_tb;

architecture Behavioral of Control_Unit_tb is

    -- Signale zur Verbindung mit der Control Unit
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal start     : std_logic := '0';
    signal result    : signed(15 downto 0);
    signal carryout  : std_logic;
    signal done_internal      : std_logic;

    -- Instanziierung der Control Unit
    component Control_Unit is
        port(
            clk       : in std_logic;
            rst       : in std_logic;
            start     : in std_logic;
            result    : out signed(15 downto 0);
            carryout  : out std_logic;
            done      : out std_logic
        );
    end component;

begin

    -- Verbinden der Signale mit der Instanz der Control Unit
    UUT: Control_Unit
        port map(
            clk => clk,
            rst => rst,
            start => start,
            result => result,
            carryout => carryout,
            done => done_internal
        );

    -- Taktprozess
    clk_process: process
    begin
        while now < 100 us loop -- Ändern Sie '1 us' auf die gewünschte Simulationsdauer
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait; -- Stoppt den Prozess nach 1 us
    end process;

    -- Testprozess
    test_process: process
    begin
        -- Reset und Initialisierung
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- Testfall 1:
        start <= '1';
        wait for 50 ns;
        
        -- Warten auf den Abschluss der Berechnung
        wait until done_internal = '1';
        assert (result = to_signed(8, 16)) report "Addition - Test fehlgeschlagen" severity error;
        report "Addition - Test erfolgreich" severity note;
        
        -- Weitere Testfälle können hier hinzugefügt werden

        -- Simulation stoppen
        wait;
    end process;

end Behavioral;