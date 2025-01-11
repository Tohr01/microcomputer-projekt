library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterBank_tb is
end RegisterBank_tb;

architecture Behavioral of RegisterBank_tb is
    constant REGISTER_BITS : natural := 3;
    constant DATA_WIDTH     : natural := 16;

    COMPONENT RegisterBank
    port (
        clk        : in  std_logic;                               -- Takt
        rst        : in  std_logic;                               -- Reset
        write_en   : in  std_logic;                               -- Schreibaktivierung
        read_addr  : in  unsigned(REGISTER_BITS-1 downto 0); -- Leseadresse
        write_addr : in  unsigned(REGISTER_BITS-1 downto 0); -- Schreibadresse
        data_in    : in  signed(DATA_WIDTH-1 downto 0);           -- Input
        data_out   : out signed(DATA_WIDTH-1 downto 0)            -- Output
    );
    END COMPONENT;


    -- Ports der Registerbank
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal write_en   : std_logic := '0';
    signal read_addr  : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal write_addr : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal data_in    : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out   : signed(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    -- Registerbank-Instanz
    uut: entity work.RegisterBank
    generic map (
        REGISTER_BITS => REGISTER_BITS,
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

    -- Takt erzeugen
    clk_process: process
    begin
        while now < 100 us loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    process
    begin
        report "Simulation started";

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

        report "Simulation finished";
        wait;
    end process;
end Behavioral;
