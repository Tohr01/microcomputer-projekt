library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterBank_tb is
end RegisterBank_tb;

architecture Behavioral of RegisterBank_tb is
    constant REGISTER_COUNT : natural := 8;
    constant DATA_WIDTH     : natural := 16;

    -- Ports der Registerbank
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal write_en   : std_logic := '0';
    signal read_addr  : unsigned(2 downto 0);
    signal write_addr : unsigned(2 downto 0);
    signal data_in    : signed(DATA_WIDTH-1 downto 0);
    signal data_out   : signed(DATA_WIDTH-1 downto 0);

    -- Registerbank-Instanz
    uut: entity work.RegisterBank
        generic map (
            REGISTER_COUNT => REGISTER_COUNT,
            DATA_WIDTH     => DATA_WIDTH
        )
        port map (
            clk        => clk,
            rst        => rst,
            write_en   => write_en,
            read_addr  => read_addr,
            write_addr => write_addr,
            data_in    => data_in,
            data_out   => data_out
        );

begin
    -- Takt erzeugen
    clk <= not clk after 10 ns;

    process
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Test 1: Schreibe in Register 1
        write_en <= '1';
        write_addr <= "001";
        data_in <= to_signed(42, DATA_WIDTH);
        wait for 20 ns;

        -- Test 2: Lese aus Register 1
        write_en <= '0';
        read_addr <= "001";
        wait for 20 ns;

        -- Test 3: Schreibe in Register 2
        write_en <= '1';
        write_addr <= "010";
        data_in <= to_signed(99, DATA_WIDTH);
        wait for 20 ns;

        -- Test 4: Lese aus Register 2
        write_en <= '0';
        read_addr <= "010";
        wait for 20 ns;

        wait;
    end process;
end Behavioral;
