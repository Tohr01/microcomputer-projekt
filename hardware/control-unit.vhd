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
    
    type state_type is (INSTRUCTION_FETCH, INSTRUCTION_DECODE, OPERAND_FETCH, EXECUTE, RESULT_STORE, NEXT_INSTRUCTION);
    type mock_register_array is array (0 to 1) of unsigned(31 downto 0);

    signal program_counter: signed (31 downto 0) := (others => '0');
    signal state, next_state: state_type;
    signal mock_instruction_registers : mock_register_array := (
        0 => ADD_OP,
        1 => SUB_OP,
        others => (others => '0')
    )
    signal current_instruction: signed(15 downto 0);
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

    MOV R1, R2 -> 0001 0001 0010 0000
    ADD R1, R3
    JMP 0x04

    process(state)
    begin
        case state is
            when INSTRUCTION_FETCH =>
                -- Fetch instruction from memory, ausm RAM and move to instruction register
                ram_register_address <= program_counter;
                current_instruction <= -- value from RRRRAMMM at ram_register_address
                next_state <= INSTRUCTION_DECODE;
            when INSTRUCTION_DECODE =>
                -- Decode instruction
                next_state <= OPERAND_FETCH;
            when OPERAND_FETCH =>
                -- Fetch operands
                next_state <= EXECUTE;
            when EXECUTE =>
                -- Execute instruction
                next_state <= RESULT_STORE;
            when RESULT_STORE =>
                -- Store result
                next_state <= NEXT_INSTRUCTION;
            when NEXT_INSTRUCTION =>
                -- Go to next instruction
                next_state <= INSTRUCTION_FETCH;
            when others =>
                next_state <= INSTRUCTION_FETCH;
        end case;
    end process;
end Behavioral