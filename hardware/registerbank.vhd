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
    signal registers : reg_array := (others => (others => '0')); -- init values here

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
                registers <= (others => (others => '0')); -- init values here
            else
                registers(to_integer(write_addr)) <= data_in;
            end if;
        end if;
    end process;

end Behavioral;

