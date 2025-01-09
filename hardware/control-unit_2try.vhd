library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;

entity CONTROL_UNIT is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;
        result    : out signed(15 downto 0);
        carryout  : out std_logic;
        done      : out std_logic
    );
end CONTROL_UNIT;

architecture Behavioral of Control_Unit is

    type state_type is (IDLE, INSTRUCTION_FETCH, INSTRUCTION_DECODE, OPERAND_FETCH, WAIT_FOR_OPERANDS, EXECUTE, RESULT_STORE, NEXT_INSTRUCTION);
    signal current_state, next_state : state_type;
    signal instruction: unsigned(15 downto 0);
    signal opcode   : unsigned(4 downto 0);
    signal A_reg    : unsigned(2 downto 0);
    signal B_reg    : unsigned(2 downto 0);
    signal immediate: unsigned(4 downto 0);

    signal A, B: signed(15 downto 0);
    signal I: integer;
    signal res_internal: signed(15 downto 0);
    signal carry_internal: std_logic;

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

    process(clk, rst)
    begin
        -- on reset, we go back to IDLE state and reset signals to default values
        -- -> since current_state changed to IDLE, the second process will be triggered
        if rst = '1' then
            current_state <= IDLE;
            result <= (others => '0');
            carryout <= '0';
            done <= '0';
        -- on rising edge of clock, we update the current state
        -- -> since current_state changed, the second process will be triggered
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, start)
    begin
        case current_state is
            when IDLE =>
                done <= '0';
                if start = '1' then
                    next_state <= INSTRUCTION_FETCH;
                else
                    next_state <= IDLE;
                end if;
            when INSTRUCTION_FETCH =>
                -- fetch instruction from random access memory
                instruction <= unsigned'("0000000100100000");
                next_state <= INSTRUCTION_DECODE;
            when INSTRUCTION_DECODE =>
                opcode <= unsigned(instruction(15 downto 11));
                A_reg <= unsigned(instruction(10 downto 8));
                B_reg <= unsigned(instruction(7 downto 5));
                next_state <= OPERAND_FETCH;
            when OPERAND_FETCH =>
                A <= to_signed(5, 16);
                B <= to_signed(3, 16);
                next_state <= EXECUTE;
            when EXECUTE =>
                I <= to_integer(opcode);
                next_state <= RESULT_STORE;
            when RESULT_STORE =>
                result <= res_internal; 
                carryout <= carry_internal;
                done <= '1';
                next_state <= IDLE; -- Loop back to idle after completion
            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;