library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;
use work.memPkg.ALL;

entity PIPELINE_CONTROL_UNIT is
    port (
        clk       : in std_logic;
        rst       : in std_logic
    );
end PIPELINE_CONTROL_UNIT;

architecture Behavioral of Pipeline_Control_Unit is
    constant REGISTER_BITS : natural := 5;
    constant DATA_WIDTH     : natural := 16;
    constant RAM_ADDR_WIDTH : natural := 10;
    constant RAM_DATA_WIDTH : natural := 16;

    signal program_counter: std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');

    signal instruction: unsigned(15 downto 0) := (others => '0');
    signal opcode_0, opcode_1, opcode_2, opcode_3   : unsigned(4 downto 0);
    signal A_reg_0, A_reg_1, A_reg_2, A_reg_3 : unsigned(2 downto 0) := (others => '0');
    signal B_reg_0    : unsigned(2 downto 0);
    signal immediate_0, immediate_1, immediate_2: unsigned(4 downto 0);

    -- ALU signals
    signal A, B: signed(15 downto 0);
    signal I: integer;
    signal res_internal: signed(15 downto 0);
    signal carry_internal: std_logic;

    -- RegisterBank signals
    signal register_read_addr_A           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_read_addr_B           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_write_addr          : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_data_in             : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal register_data_out_A_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal register_data_out_B_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    
    -- RAM signals
    signal ram_not_write_en        : std_logic := '1';
    signal ram_io_addr         : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ram_data_in         : std_logic_vector(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_data_out        : std_logic_vector(RAM_DATA_WIDTH-1 downto 0) := (others => '0');
    signal ram_file_io         : fileIoT := none;

    component ALU is
        generic (
            constant N: natural := 1
        );
        port(
            A, B        : in signed(15 downto 0);
            I           : in integer;
            out_alu     : out signed(15 downto 0);
            carryout_alu: out std_logic
        );
    end component;

    component RegisterBank is
        port (
            clk      : in std_logic;
            rst      : in std_logic;
            read_addr_A: in unsigned(REGISTER_BITS-1 downto 0);
            read_addr_B: in unsigned(REGISTER_BITS-1 downto 0);
            write_addr: in unsigned(REGISTER_BITS-1 downto 0);
            data_in  : in signed(DATA_WIDTH-1 downto 0);
            data_out_A : out signed(DATA_WIDTH-1 downto 0);
            data_out_B : out signed(DATA_WIDTH-1 downto 0)
        );
    end component;

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

    U1: ALU
        generic map (
            N => 1
        )
        port map (
            A => A,
            B => B,
            I => I,
            out_alu => res_internal,
            carryout_alu => carry_internal
        );

    U2: RegisterBank
        port map (
            clk => clk,
            rst => rst,
            read_addr_A => register_read_addr_A,
            read_addr_B => register_read_addr_B,
            write_addr => register_write_addr,
            data_in => register_data_in,
            data_out_A => register_data_out_A_internal,
            data_out_B => register_data_out_B_internal
        );

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

    -- 1. Instruction Fetch (IF) Stage
    IF_Stage: process(clk, rst)
    begin
        if rst = '1' then
            ram_file_io <= load, none after 5 ns;
            program_counter <= (others => '0');
            ram_io_addr <= (others => '0');
        elsif rising_edge(clk) then
            ram_not_write_en <= '1';
            instruction <= unsigned(ram_data_out);
            ram_io_addr <= std_logic_vector(unsigned(program_counter) + 1);
            program_counter <= std_logic_vector(unsigned(program_counter) + 1);
        end if;
    end process;

    -- 2. Instruction Decode (ID) Stage
    ID_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_0 <= unsigned(instruction(15 downto 11));
            A_reg_0 <= unsigned(instruction(10 downto 8));
            B_reg_0 <= unsigned(instruction(7 downto 5));
            immediate_0 <= unsigned(instruction(4 downto 0));
        end if;
    end process;

    -- 3. Operand Fetch (OF) Stage
    OF_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_1 <= opcode_0;
            A_reg_1 <= A_reg_0;
            immediate_1 <= immediate_0;
            if is_x(std_logic_vector(opcode_0)) or opcode_0 /= NOP_OP then -- don't do anything if opcode is NOP
                if not is_x(std_logic_vector(A_reg_0)) then
                    register_read_addr_A <= A_reg_0;
                end if;
                if not is_x(std_logic_vector(B_reg_0)) then
                    register_read_addr_B <= B_reg_0;
                end if;
            end if;
        end if;
    end process;

    -- 4. Wait For Operand (WFO) Stage
    WFO_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_2 <= opcode_1;
            A_reg_2 <= A_reg_1;
            immediate_2 <= immediate_1;
        end if;
    end process;

    -- 5. Execute (EX) Stage
    E_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_3 <= opcode_2;
            A_reg_3 <= A_reg_2;
            A <= register_data_out_A_internal;
            if is_x(std_logic_vector(opcode_2)) or opcode_2 /= NOP_OP then
                if not is_x(std_logic_vector(opcode_2)) then
                    if opcode_2 = ADD_IMMEDIATE_OP then
                        B <= signed("00000000000" & immediate_2);
                        I <= ADD_OP;
                    else
                        B <= register_data_out_B_internal;
                        I <= to_integer(opcode_2);
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- 6. Result Store (RS) Stage
    RS_Stage: process(clk)
    begin
        if rising_edge(clk) then
            if is_x(std_logic_vector(opcode_3)) or opcode_3 /= NOP_OP then
                if not is_x(std_logic_vector(A_reg_3)) then
                    register_write_addr <= A_reg_3;
                end if;
                register_data_in <= res_internal;
            end if;
        end if;
    end process;

end Behavioral;
