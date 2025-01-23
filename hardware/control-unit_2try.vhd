library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;
use work.statesPkg.ALL;
use work.memPkg.all;

entity CONTROL_UNIT is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;
        -- instruction: in unsigned(15 downto 0);
        state     : out integer;
        done      : out std_logic
    );
end CONTROL_UNIT;

architecture Behavioral of Control_Unit is
    constant REGISTER_BITS : natural := 3;
    constant DATA_WIDTH     : natural := 16;
    constant RAM_ADDR_WIDTH : natural := 10;
    constant RAM_DATA_WIDTH : natural := 16;

    signal current_state, next_state : integer;
    signal instruction: unsigned(15 downto 0);
    signal opcode   : unsigned(4 downto 0);
    signal A_reg    : unsigned(2 downto 0);
    signal B_reg    : unsigned(2 downto 0);
    signal immediate: unsigned(4 downto 0);
    signal program_counter: std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others => '0');

    -- ALU signals
    signal A, B: signed(15 downto 0);
    signal I: integer;
    signal res_internal: signed(15 downto 0);
    signal carry_internal: std_logic;

    -- RegisterBank signals
    signal register_write_en            : std_logic := '0';
    signal register_read_addr           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_write_addr          : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_data_in             : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal register_data_out_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');

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
            write_en : in std_logic;
            read_addr: in unsigned(REGISTER_BITS-1 downto 0);
            write_addr: in unsigned(REGISTER_BITS-1 downto 0);
            data_in  : in signed(DATA_WIDTH-1 downto 0);
            data_out : out signed(DATA_WIDTH-1 downto 0)
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
            write_en => register_write_en,
            read_addr => register_read_addr,
            write_addr => register_write_addr,
            data_in => register_data_in,
            data_out => register_data_out_internal
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

    process(clk, rst)
    begin
        -- on reset, we go back to IDLE state and reset signals to default values
        -- -> since current_state changed to IDLE, the second process will be triggered
        if rst = '1' then
            ram_file_io <= load, none after 5 ns;
            current_state <= IDLE;
        -- on rising edge of clock, we update the current state
        -- -> since current_state changed, the second process will be triggered
        elsif rising_edge(clk) then
            if current_state = RESULT_STORE and next_state = IDLE then
                done <= '1';
            else
                done <= '0';
            end if;
            current_state <= next_state;
        end if;
    end process;

    process(current_state, start)
    begin
        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= INSTRUCTION_FETCH;
                else
                    next_state <= IDLE;
                end if;
            when INSTRUCTION_FETCH =>
                -- fetch instruction from random access memory
                ram_not_write_en <= '1';
                ram_io_addr <= program_counter;
                next_state <= WAIT_FOR_INSTRUCTION;
            when WAIT_FOR_INSTRUCTION =>
                instruction <= unsigned(ram_data_out);
                next_state <= INSTRUCTION_DECODE;
            when INSTRUCTION_DECODE =>
                opcode <= unsigned(instruction(15 downto 11));
                A_reg <= unsigned(instruction(10 downto 8));
                B_reg <= unsigned(instruction(7 downto 5));
                immediate <= unsigned(instruction(4 downto 0));
                next_state <= OPERAND_FETCH_A;
            when OPERAND_FETCH_A =>
                register_write_en <= '0';
                register_read_addr <= A_reg;
                next_state <= WAIT_FOR_OPERAND_A;
            when WAIT_FOR_OPERAND_A =>
                A <= register_data_out_internal;
                if opcode = ADD_IMMEDIATE_OP then
                    B <= signed("00000000000" & immediate);
                    next_state <= EXECUTE;
                else
                    next_state <= OPERAND_FETCH_B;
                end if;
            when OPERAND_FETCH_B =>
                register_read_addr <= B_reg;
                next_state <= WAIT_FOR_OPERAND_B;
            when WAIT_FOR_OPERAND_B =>
                B <= register_data_out_internal;
                next_state <= EXECUTE;
            when EXECUTE =>
                if opcode = ADD_IMMEDIATE_OP then
                    I <= ADD_OP;
                else 
                    I <= to_integer(opcode);
                end if;
                next_state <= RESULT_STORE;
            when RESULT_STORE =>
                register_write_en <= '1';
                register_write_addr <= A_reg;
                register_data_in <= res_internal;
                -- TODO: Handle carryout
                -- carry_internal;
                program_counter <= std_logic_vector(unsigned(program_counter) + 1);
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    state <= current_state;

end Behavioral;