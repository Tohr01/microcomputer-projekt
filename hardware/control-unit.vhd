use IEEE.STD_LOGIC_1164.ALL;
use work.opcodes_constants.ALL;

entity ControlUnit is 
-- TODO Handle control signals?? See issue #16
    Port (
        clk: in std_logic;
        reset: in std_logic;
        instruction: out signed(15 downto 0)
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
    constant REGISTER_BITS : natural := 3;
    constant DATA_WIDTH    : natural := 16;

    COMPONENT ALU
    PORT(
        A        : in signed(15 downto 0);
        B        : in signed(15 downto 0);
        I           : in integer;
        out_alu     : out signed(15 downto 0);
        carryout_alu: out std_logic
        );
    END COMPONENT;

    COMPONENT RegisterBank
    port (
        clk        : in  std_logic;                               -- Takt
        rst        : in  std_logic;                               -- Reset
        write_en   : in  std_logic;                               -- Schreibaktivierung
        read_addr  : in  unsigned(REGISTER_BITS-1 downto 0);      -- Leseadresse
        write_addr : in  unsigned(REGISTER_BITS-1 downto 0);      -- Schreibadresse
        data_in    : in  signed(DATA_WIDTH-1 downto 0);           -- Input
        data_out   : out signed(DATA_WIDTH-1 downto 0)            -- Output
    );
    END COMPONENT;
    
    type state_type is (INSTRUCTION_FETCH, INSTRUCTION_DECODE, OPERANDS_FETCH, EXECUTE, RESULT_STORE, NEXT_INSTRUCTION);
    type mock_register_array is array (0 to 3) of unsigned(15 downto 0);

    signal program_counter: unsigned (31 downto 0) := (others => '0');
    signal state, next_state: state_type;
    signal mock_instruction_registers : mock_register_array := (
        0 => "0000000101000000", -- Opcode: 00000, A_reg: 001, B_reg: 010, Immediate/R3: 00/000 -> 2 + 1 = 3 (if RegisterBank[A_reg] = 2, RegisterBank[B_reg] = 1)
        1 => "0000001000100000", -- Opcode: 00000, A_reg: 001, B_reg: 010, Immediate/R3: 00/000 -> 2 - 1 = 1
        2 => "0110000100100000", -- Opcode: 01100, A_reg: 001, B_reg: 001, Immediate/R3: 00/000 -> 2 == 2 -> 1
        3 => "0110000101000000"  -- Opcode: 01100, A_reg: 001, B_reg: 010, Immediate/R3: 00/000 -> 2 == 1 -> 0
        others => (others => '0')
    )
    signal current_instruction: signed(15 downto 0);

    -- For decoding instructions
    signal opcode: unsigned(4 downto 0);
    signal A_reg: unsigned(2 downto 0);
    signal B_reg: unsigned(2 downto 0);
    signal immediate: unsigned(4 downto 0);

    -- Ports of ALU
    signal A : signed(15 downto 0) := (others => '0');
    signal B : signed(15 downto 0) := (others => '0');
    signal I : integer := 0;
    signal out_alu : signed(15 downto 0);
    signal carryout_alu : std_logic;

    -- Ports of Registerbank
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal write_en   : std_logic := '0';
    signal read_addr  : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal write_addr : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal data_in    : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out   : signed(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    ALU : entity work.ALU
    PORT MAP (
        A => A,
        B => B,
        I => I,
        out_alu => out_alu,
        carryout_alu => carryout_alu
    );

    RegisterBank : entity work.RegisterBank
    GENERIC MAP (
        REGISTER_BITS => REGISTER_BITS,
        DATA_WIDTH    => DATA_WIDTH
    )
    PORT MAP(
        clk        => clk,
        rst        => rst,
        write_en   => write_en,
        read_addr  => read_addr,
        write_addr => write_addr,
        data_in    => data_in,
        data_out   => data_out
    );
    
    -- Handle transition flow and reset
    process(clk, reset)
    begin
        if reset = '1' then
            state <= INSTRUCTION_FETCH;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process; 

    process(all)
    begin
        case state is
            when INSTRUCTION_FETCH =>
                -- Fetch instruction from RAM
                current_instruction <= mock_instruction_registers(to_integer(program_counter(4 downto 0)));
                next_state <= INSTRUCTION_DECODE;
            when INSTRUCTION_DECODE =>
                -- Decode instruction
                opcode <= unsigned(instruction(15 downto 11));
                A_reg <= unsigned(instruction(10 downto 8));
                B_reg <= unsigned(instruction(7 downto 5));
                immediate <= unsigned(instruction(4 downto 0));
                next_state <= OPERAND_FETCH;
            when OPERANDS_FETCH =>
                -- Reset Registerbank
                rst <= '1';
                wait for 20 ns;
                rst <= '0';
                -- Fetch operands
                write_en <= '0';
                read_addr <= A_reg;
                A <= data_out;
                write_en <= '0';
                read_addr <= B_reg;
                B <= data_out;
                next_state <= EXECUTE;
            when EXECUTE =>
                -- Execute instruction
                I <= to_integer(opcode);
                next_state <= RESULT_STORE;
            when RESULT_STORE =>
                -- Store result
                write_en <= '1';
                write_addr <= immediate(2 downto 0);
                data_in <= out_alu; -- TODO: check for carryout -> How to handle that?
                next_state <= NEXT_INSTRUCTION;
            when NEXT_INSTRUCTION =>
                -- Go to next instruction
                program_counter <= program_counter + 1;
                next_state <= INSTRUCTION_FETCH;
            when others =>
                next_state <= INSTRUCTION_FETCH;
        end case;
    end process;
end Behavioral