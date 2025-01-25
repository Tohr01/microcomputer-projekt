library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterBank is
    generic (
        constant REGISTER_BITS : natural := 5;
        constant DATA_WIDTH     : natural := 16
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        read_addr_A  : in  unsigned(REGISTER_BITS-1 downto 0);
        read_addr_B  : in  unsigned(REGISTER_BITS-1 downto 0);
        write_addr : in  unsigned(REGISTER_BITS-1 downto 0);
        data_in    : in  signed(DATA_WIDTH-1 downto 0);
        data_out_A   : out signed(DATA_WIDTH-1 downto 0);
        data_out_B   : out signed(DATA_WIDTH-1 downto 0)
    );
end RegisterBank;

architecture Behavioral of RegisterBank is
    type reg_array is array (0 to REGISTER_BITS-1) of signed(DATA_WIDTH-1 downto 0);
    signal registers : reg_array := (
        14 => "1111111111111111",  -- Max value for 16-bit (2^16 -1) (= 65535)
        15 => "0111010100110000",  -- Amount of numbers we have to check corresponds to 30000
        16 => "0000001111101000",  -- Starting address of numbering sequence for algorithm (= 1000)
        17 => "0111010100110010",  -- Stores max number (in this case 30002)
        18 => "0111100100010111",  -- Stores last valid address (in this case 30999)
        others => (others => '0')
    );

begin
    -- Read
    process(clk)
    begin
        if rising_edge(clk) then
            data_out_A <= registers(to_integer(read_addr_A));
            data_out_B <= registers(to_integer(read_addr_B));
        end if;
    end process;

    -- Write
    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                registers <= (
                    14 => "1111111111111111",  -- Max value for 16-bit (2^16 -1) (= 65535)
                    15 => "0111010100110000",  -- Amount of numbers we have to check corresponds to 30000
                    16 => "0000001111101000",  -- Starting address of numbering sequence for algorithm (= 1000)
                    17 => "0111010100110010",  -- Stores max number (in this case 30002)
                    18 => "0111100100010111",  -- Stores last valid address (in this case 30999)
                    others => (others => '0')
                );
            else
                registers(to_integer(write_addr)) <= data_in;
            end if;
        end if;
    end process;

end Behavioral;

