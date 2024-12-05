library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

    -- Hilfsfunktion für Adressbreite 
    -- Berechnet die Anzahl der Bits, die benötigt werden, um eine bestimmte Anzahl von Adressen zu repräsentieren
    -- function log2ceil(n: natural) return natural is
    --     variable result : natural := 0;
    --     variable value  : natural := n-1;
    -- begin
    --     while value > 0 loop
    --         value := value / 2;
    --         result := result + 1;
    --     end loop;
    --     return result;
    -- end function;

entity RegisterBank is
    generic (
        REGISTER_BITS : natural := 3;  -- Anzahl der Register (Can be calculated by ceil(log2(num of registers)))
        DATA_WIDTH     : natural := 16  -- Breite der Register (16 Bit)
    );
    port (
        clk        : in  std_logic;                               -- Takt
        rst        : in  std_logic;                               -- Reset
        write_en   : in  std_logic;                               -- Schreibaktivierung
        read_addr  : in  unsigned(REGISTER_BITS-1 downto 0); -- Leseadresse
        write_addr : in  unsigned(REGISTER_BITS-1 downto 0); -- Schreibadresse
        data_in    : in  signed(DATA_WIDTH-1 downto 0);           -- Input
        data_out   : out signed(DATA_WIDTH-1 downto 0)            -- Output
    );
end RegisterBank;

architecture Behavioral of RegisterBank is
    -- Array für Register
    type reg_array is array (0 to REGISTER_BITS-1) of signed(DATA_WIDTH-1 downto 0);
    signal registers : reg_array := (others => (others => '0')); -- Initialisiere Register mit 0

begin
    -- Read
    process(clk)
    begin
        if rising_edge(clk) then
            data_out <= registers(to_integer(read_addr)); -- Auslesen aus Register
        end if;
    end process;

    -- Write
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                registers <= (others => (others => '0')); -- Reset Register
            elsif write_en = '1' then
                registers(to_integer(write_addr)) <= data_in; -- Schreibe in Register
            end if;
        end if;
    end process;

end Behavioral;

