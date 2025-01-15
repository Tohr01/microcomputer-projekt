library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.memPkg.all;

entity PIPELINE_CONTROL_UNIT is
    port (
        clk       : in std_logic;
        rst       : in std_logic
    );
end PIPELINE_CONTROL_UNIT;

architecture Behavioral of Pipeline_Control_Unit is
    constant RAM_ADDR_WIDTH : natural := 10;
    constant RAM_DATA_WIDTH : natural := 16;

    signal program_counter: std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');

    signal instruction: unsigned(15 downto 0);
    signal opcode_0   : unsigned(4 downto 0);
    signal A_reg_0    : unsigned(2 downto 0);
    signal B_reg_0    : unsigned(2 downto 0);
    signal immediate_0: unsigned(4 downto 0);
    
    -- RAM signals
    signal ram_not_write_en        : std_logic := '1';
    signal ram_io_addr         : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ram_data_in         : std_logic_vector(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_data_out        : std_logic_vector(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_file_io         : fileIoT := none;

    component ramIO is 
        generic (
            addrWd: integer range 2 to 16 := RAM_ADDR_WIDTH;
            dataWd: integer range 2 to 32 := RAM_DATA_WIDTH;
            fileId: string := "ram.dat"
        );
        port (
            -- nCS: in std_logic;
            nWE: in std_logic;
            addr: in std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
            dataI: in std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
            dataO: out std_logic_vector(RAM_DATA_WIDTH-1 downto 0);
            fileIO: in fileIoT
        );
    end component;
    
begin

    U3: ramIO
        generic map (
            addrWd => RAM_ADDR_WIDTH,
            dataWd => RAM_DATA_WIDTH,
            fileId => "ram.dat"
        )
        port map (
            nWE => ram_not_write_en,
            addr => ram_io_addr,
            dataI => ram_data_in,
            dataO => ram_data_out,
            fileIO => ram_file_io
        );

    -- Instruction Fetch (IF) Stage
    IF_Stage: process(clk, rst)
    begin
        if rst = '1' then
            ram_file_io <= load, none after 5 ns;
            program_counter <= (others => '0');
        elsif rising_edge(clk) then
            ram_not_write_en <= '1';
            ram_io_addr <= program_counter;
            instruction <= unsigned(ram_data_out);
            program_counter <= std_logic_vector(unsigned(program_counter) + 1);
        end if;
    end process;

    -- Instruction Decode (ID) Stage
    ID_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode <= unsigned(instruction(15 downto 11));
            A_reg <= unsigned(instruction(10 downto 8));
            B_reg <= unsigned(instruction(7 downto 5));
            immediate <= unsigned(instruction(4 downto 0));
        end if;
    end process;

end Behavioral;
