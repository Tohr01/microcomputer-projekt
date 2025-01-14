library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;

entity CONTROL_UNIT is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;
        instruction: in unsigned(15 downto 0);
        done      : out std_logic
    );
end CONTROL_UNIT;

architecture Behavioral of Control_Unit is
    constant REGISTER_BITS : natural := 3;
    constant DATA_WIDTH     : natural := 16;

    type state_type is (IDLE, INSTRUCTION_FETCH, INSTRUCTION_DECODE, OPERAND_FETCH_A, OPERAND_FETCH_B, WAIT_FOR_OPERAND_A, WAIT_FOR_OPERAND_B, EXECUTE, RESULT_STORE, NEXT_INSTRUCTION);
    signal current_state, next_state : state_type;
    signal opcode   : unsigned(4 downto 0);
    signal A_reg    : unsigned(2 downto 0);
    signal B_reg    : unsigned(2 downto 0);
    signal immediate: unsigned(4 downto 0);

    -- ALU signals
    signal A, B: signed(15 downto 0);
    signal I: integer;
    signal res_internal: signed(15 downto 0);
    signal carry_internal: std_logic;

    -- RegisterBank signals
    signal write_en            : std_logic := '0';
    signal read_addr           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal write_addr          : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal data_in             : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_out_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');

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
            write_en => write_en,
            read_addr => read_addr,
            write_addr => write_addr,
            data_in => data_in,
            data_out => data_out_internal
        );

    process(clk, rst)
    begin
        -- on reset, we go back to IDLE state and reset signals to default values
        -- -> since current_state changed to IDLE, the second process will be triggered
        if rst = '1' then
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
                next_state <= INSTRUCTION_DECODE;
            when INSTRUCTION_DECODE =>
                opcode <= unsigned(instruction(15 downto 11));
                A_reg <= unsigned(instruction(10 downto 8));
                B_reg <= unsigned(instruction(7 downto 5));
                immediate <= unsigned(instruction(4 downto 0));
                next_state <= OPERAND_FETCH_A;
            when OPERAND_FETCH_A =>
                write_en <= '0';
                read_addr <= A_reg;
                next_state <= WAIT_FOR_OPERAND_A;
            when WAIT_FOR_OPERAND_A =>
                A <= data_out_internal;
                if opcode = ADD_IMMEDIATE_OP then
                    B <= signed("00000000000" & immediate);
                    next_state <= EXECUTE;
                else
                    next_state <= OPERAND_FETCH_B;
                end if;
            when OPERAND_FETCH_B =>
                read_addr <= B_reg;
                next_state <= WAIT_FOR_OPERAND_B;
            when WAIT_FOR_OPERAND_B =>
                B <= data_out_internal;
                next_state <= EXECUTE;
            when EXECUTE =>
                if opcode = ADD_IMMEDIATE_OP then
                    I <= ADD_OP;
                else 
                    I <= to_integer(opcode);
                end if;
                next_state <= RESULT_STORE;
            when RESULT_STORE =>
                write_en <= '1';
                write_addr <= A_reg;
                data_in <= res_internal;
                -- TODO: Handle carryout
                -- carry_internal;
                next_state <= IDLE;
            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;