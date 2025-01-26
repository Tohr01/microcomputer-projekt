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
        carryout_in : in  std_logic;
        data_out_A   : out signed(DATA_WIDTH-1 downto 0);
        data_out_B   : out signed(DATA_WIDTH-1 downto 0)
    );
end RegisterBank;

architecture Behavioral of RegisterBank is
    type reg_array is array (0 to 2**REGISTER_BITS) of signed(DATA_WIDTH-1 downto 0);
    signal registers : reg_array := (
        14 => "0000000000000000",  -- Carry flag
        15 => "0000000000011110",  -- Amount of numbers we have to check corresponds to 30
        16 => "0000001111101000",  -- Starting address of numbering sequence for algorithm (= 1000)
        17 => "0000000000011111",  -- Stores max number (in this case 31)
        18 => "0000010000000101",  -- Stores last valid address (in this case 1029)
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
                    14 => "0000000000000000",
                    15 => "0111010100110000",
                    16 => "0000001111101000",
                    17 => "0111010100110010",
                    18 => "0111100100010111",
                    others => (others => '0')
                );
            else
                registers(to_integer(write_addr)) <= data_in;
                if carryout_in = '1' then
                    registers(14) <= "0000000000000001";
                else
                    registers(14) <= "0000000000000000";
                end if;
            end if;
        end if;
    end process;

end Behavioral;

