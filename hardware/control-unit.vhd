library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;

entity ControlUnit is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;
        instruction : out signed(15 downto 0)
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
    constant REGISTER_BITS : natural := 3;
    constant DATA_WIDTH    : natural := 16;

    -- ALU Declaration
    COMPONENT ALU
        port (
            A            : in signed(15 downto 0);
            B            : in signed(15 downto 0);
            I            : in integer;
            out_alu      : out signed(15 downto 0);
            carryout_alu : out std_logic
        );
    END COMPONENT;

    -- Register Bank Declaration
    COMPONENT RegisterBank
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            write_en   : in  std_logic;
            read_addr  : in  unsigned(REGISTER_BITS-1 downto 0);
            write_addr : in  unsigned(REGISTER_BITS-1 downto 0);
            data_in    : in  signed(DATA_WIDTH-1 downto 0);
            data_out   : out signed(DATA_WIDTH-1 downto 0)
        );
    END COMPONENT;

    -- State Definitions
    type state_type is (INSTRUCTION_FETCH, INSTRUCTION_DECODE, OPERAND_FETCH, WAIT_FOR_OPERANDS, EXECUTE, RESULT_STORE, NEXT_INSTRUCTION);
    signal state, next_state : state_type;

    -- Program Counter
    signal program_counter : unsigned(31 downto 0) := (others => '0');

    -- Instruction Register
    signal instruction_reg : signed(15 downto 0) := (others => '0');

    -- RAM Declaration
    type RAM_Type is array (0 to 15) of std_logic_vector(15 downto 0);
    RAM : RAM_Type := (others => (others => '0')); -- Mit Testbench Instruktionen in den RAM schreiben?


   -- RAM mit beispielhafter Belegung / Mock Instruction Register
   -- signal RAM : RAM_Type := (
    --    0 => "0000000101000000", -- Beispiel-Instruktion
    --    1 => "0000001000100000", -- Beispiel-Instruktion
    --    2 => "0110000100100000", -- Beispiel-Instruktion
    --   3 => "0110000101000000", -- Beispiel-Instruktion
    --   others => (others => '0')
   -- );

    -- Instruction Decoding
    signal opcode   : unsigned(4 downto 0);
    signal A_reg    : unsigned(2 downto 0);
    signal B_reg    : unsigned(2 downto 0);
    signal immediate: unsigned(4 downto 0);

    -- ALU Signals
    signal A, B     : signed(15 downto 0) := (others => '0');
    signal I        : integer := 0;
    signal out_alu  : signed(15 downto 0);
    signal carryout_alu : std_logic;

    -- Register Bank Signals
    signal write_en   : std_logic := '0';
    signal read_addr  : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal write_addr : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal data_in    : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out   : signed(DATA_WIDTH-1 downto 0);

begin
    -- ALU Instantiation    
    ALU : entity work.ALU
        port map (
            A => A,
            B => B,
            I => I,
            out_alu => out_alu,
            carryout_alu => carryout_alu
        );

    -- RegisterBank Instantiation
    RegisterBank : entity work.RegisterBank
        generic map (
            REGISTER_BITS => REGISTER_BITS,
            DATA_WIDTH    => DATA_WIDTH
        )
        port map (
            clk        => clk,
            rst        => reset,
            write_en   => write_en,
            read_addr  => read_addr,
            write_addr => write_addr,
            data_in    => data_in,
            data_out   => data_out
        );

    -- State Machine Process
    process(clk, reset)
    begin
        if reset = '1' then
            state <= INSTRUCTION_FETCH;
            program_counter <= (others => '0');
            instruction_reg <= (others => '0');
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Next State Logic and Control Signals
    process(state, program_counter, instruction_reg, data_out, carryout_alu)
    begin
        -- Default Signals
        next_state <= state;
        write_en <= '0';
        read_addr <= (others => '0');
        write_addr <= (others => '0');
        data_in <= (others => '0');
        A <= (others => '0');
        B <= (others => '0');
        I <= 0;

        case state is
            when INSTRUCTION_FETCH =>
                -- Fetch Instruction from RAM
                instruction_reg <= signed(to_integer(unsigned(RAM(to_integer(program_counter(4 downto 0))))));
                next_state <= INSTRUCTION_DECODE;

            when INSTRUCTION_DECODE =>
                -- Decode Instruction
                opcode <= unsigned(instruction_reg(15 downto 11));
                A_reg <= unsigned(instruction_reg(10 downto 8));
                B_reg <= unsigned(instruction_reg(7 downto 5));
                immediate <= unsigned(instruction_reg(4 downto 0));
                next_state <= OPERAND_FETCH;

            when OPERAND_FETCH =>
                -- Fetch Operands
                read_addr <= A_reg;
                A <= data_out;
                read_addr <= B_reg;
                B <= data_out;
                next_state <= WAIT_FOR_OPERANDS;

            when WAIT_FOR_OPERANDS =>
                -- Wait for Register Data to Stabilize
                next_state <= EXECUTE;

            when EXECUTE =>
                -- Execute Instruction
                I <= to_integer(opcode);
                next_state <= RESULT_STORE;

            when RESULT_STORE =>
                -- Write Result Back to Register
                write_en <= '1';
                write_addr <= immediate(2 downto 0);
                data_in <= out_alu;
                next_state <= NEXT_INSTRUCTION;

            when NEXT_INSTRUCTION =>
                -- Increment Program Counter
                program_counter <= program_counter + 1;
                next_state <= INSTRUCTION_FETCH;

            when others =>
                next_state <= INSTRUCTION_FETCH;
        end case;
    end process;
end Behavioral;
