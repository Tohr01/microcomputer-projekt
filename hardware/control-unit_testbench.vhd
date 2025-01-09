LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.NUMERIC_STD.all;
use work.opcodes_constants.all;

ENTITY tb_ControlUnit IS
END tb_ControlUnit;

ARCHITECTURE behavior OF tb_ControlUnit IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ControlUnit
    PORT(
        clk        : in std_logic;
        reset      : in std_logic;
        instruction: out signed(15 downto 0) 
        );
    END COMPONENT;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal instruction : signed(15 downto 0) := (others => '0');

BEGIN
    uut: ControlUnit PORT MAP (
        clk => clk,
        reset => reset,
        instruction => instruction
    );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 100 ns;

        assert false report "Simulation ended" severity note;
        wait;
    end process;
end; 