library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes_constants.ALL;
-- use work.memPkg.ALL;

entity PIPELINE_CONTROL_UNIT is
    port (
        clk       : in std_logic;
        nRst       : in std_logic;
        iAddr	: out	std_logic_vector( 9 downto 0);	-- instMem address
        iData	: in	std_logic_vector(15 downto 0);	-- instMem data
        dnWE	: out	std_logic;			            -- dataMem write-ena
        dAddr	: out	std_logic_vector(14 downto 0);	-- dataMem address
        dDataI	: in	std_logic_vector(15 downto 0);	-- dataMem data RAM->
        dDataO	: out	std_logic_vector(15 downto 0);	-- dataMem data ->RAM
        led : out std_logic_vector(7 downto 0)
        );
end PIPELINE_CONTROL_UNIT;

architecture Behavioral of Pipeline_Control_Unit is
    constant REGISTER_BITS : natural := 5;
    constant DATA_WIDTH     : natural := 16;
    constant CMP_REG_ADDR   : unsigned := "00000";

    signal program_counter: std_logic_vector(15 downto 0) := (others => '0');
    signal jump_program_counter_0, jump_program_counter_1: std_logic_vector(9 downto 0) := (others => 'U');

    signal instruction: unsigned(15 downto 0) := (others => '0');
    signal opcode_0, opcode_1, opcode_2, opcode_3   : unsigned(5 downto 0);
    signal A_reg_0, A_reg_1, A_reg_2, A_reg_3 : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal B_reg_0, B_reg_1, B_reg_2, B_reg_3    : unsigned(REGISTER_BITS-1 downto 0);

    -- ALU signals
    signal A, B: signed(15 downto 0);
    signal I: integer;
    signal Imm: signed(15 downto 0);
    signal res_internal: signed(15 downto 0);
    signal carry_internal: std_logic;

    -- RegisterBank signals
    signal register_read_addr_A           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_read_addr_B           : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_write_addr          : unsigned(REGISTER_BITS-1 downto 0) := (others => '0');
    signal register_data_in             : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal register_carryout_in         : std_logic;
    signal register_data_out_A_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal register_data_out_B_internal   : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    
    component ALU is
        port(
            A, B        : in signed(15 downto 0);
            I           : in integer;
            Imm         : in signed(15 downto 0);
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
            carryout_in: in std_logic;
            data_out_A : out signed(DATA_WIDTH-1 downto 0);
            data_out_B : out signed(DATA_WIDTH-1 downto 0)
        );
    end component;
begin

    U1: ALU
        port map (
            A => A,
            B => B,
            I => I,
            Imm => Imm,
            out_alu => res_internal,
            carryout_alu => carry_internal
        );

    U2: RegisterBank
        port map (
            clk => clk,
            rst => nRst,
            read_addr_A => register_read_addr_A,
            read_addr_B => register_read_addr_B,
            write_addr => register_write_addr,
            data_in => register_data_in,
            carryout_in => register_carryout_in,
            data_out_A => register_data_out_A_internal,
            data_out_B => register_data_out_B_internal
        );

    -- 1. Instruction Fetch (IF) Stage
    IF_Stage: process(clk, nRst)
    begin
        if (program_counter(7 downto 0) = "00101110") then
            led <= "11111111";
        elsif unsigned(program_counter(7 downto 0)) < 27 then
            led <= "10100101";
        else
            led <= "00000000";
        end if;

        if nRst = '1' then
            program_counter <= (others => '0');
            iAddr <= (others => '0');
        elsif rising_edge(clk) then
            instruction <= unsigned(iData);
            if jump_program_counter_1 /= "1111111111" then
                iAddr <= jump_program_counter_1;
                program_counter <= "000000" & jump_program_counter_1;
            elsif to_integer(unsigned(instruction(15 downto 10))) = JMP then
                iAddr <= std_logic_vector(unsigned(instruction(9 downto 0)));
                program_counter <=  std_logic_vector(unsigned("000000" & instruction(9 downto 0)));
            else
                iAddr <= std_logic_vector(unsigned(program_counter) + 1)(9 downto 0);
                program_counter <= std_logic_vector(unsigned(program_counter) + 1);
            end if;
        end if;
    end process;

    -- 2. Instruction Decode (ID) Stage
    ID_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_0 <= unsigned(instruction(15 downto 10));
            A_reg_0  <= unsigned(instruction(9 downto 5));
            B_reg_0  <= unsigned(instruction(4 downto 0));
        end if;
    end process;

    -- 3. Operand Fetch (OF) Stage
    OF_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_1 <= opcode_0;
            A_reg_1 <= A_reg_0;
            B_reg_1 <= B_reg_0;
            if opcode_0 /= NOP and opcode_0 /= JE and opcode_0 /= JG and opcode_0 /= JMP then 
                register_read_addr_A <= A_reg_0;
                register_read_addr_B <= B_reg_0;
            elsif opcode_0 = JE or opcode_0 = JG then
                register_read_addr_A <= CMP_REG_ADDR;
            end if;
        end if;
    end process;

    -- 4. Wait For Operand (WFO) Stage
    WFO_Stage: process(clk)
    begin
        if rising_edge(clk) then
            opcode_2 <= opcode_1;
            A_reg_2 <= A_reg_1;
            B_reg_2 <= B_reg_1;
        end if;
    end process;

    -- 5. Execute (EX) Stage
    E_Stage: process(clk)
    begin
        if rising_edge(clk) then
            dnWE <= '1';
            opcode_3 <= opcode_2;
            A_reg_3 <= A_reg_2;
            B_reg_3 <= B_reg_2;
            case to_integer(opcode_2) is
                when STORE =>
                    dnWE <= '0';
                    dAddr <= std_logic_vector(B)(14 downto 0);
                    dDataO <= std_logic_vector(A);
                when NOP =>
                    jump_program_counter_0 <= (others => '1');
                when JE =>
                    if register_data_out_A_internal = x"0001" then
                        jump_program_counter_0 <= std_logic_vector(A_reg_2 & B_reg_2);
                    end if;
                when JG =>
                    if register_data_out_A_internal = x"0002" then
                        jump_program_counter_0 <= std_logic_vector(A_reg_2 & B_reg_2);
                    end if;
                when LOAD_OPCODE =>
                    dAddr <= std_logic_vector(register_data_out_B_internal)(14 downto 0);
                when others =>
                    A <= register_data_out_A_internal;
                    B <= register_data_out_B_internal;
                    Imm <= signed("00000000000" & B_reg_2);
                    I <= to_integer(opcode_2);
            end case;
        end if;
    end process;

    -- 6. Result Store (RS) Stage
    RS_Stage: process(clk)
    begin
        if rising_edge(clk) then
            case to_integer(opcode_3) is
                when STORE =>
                    null;
                when LOAD_OPCODE =>
                    register_write_addr <= A_reg_3;
                    register_data_in <= signed(dDataI);
                when CMP =>
                    register_write_addr <= CMP_REG_ADDR;
                    register_data_in <= res_internal;
                when NOP =>
                    jump_program_counter_1 <= jump_program_counter_0;
                when JE =>
                    jump_program_counter_1 <= jump_program_counter_0;
                when JG =>
                    jump_program_counter_1 <= jump_program_counter_0;
                when JMP =>
                    null;
                when others =>
                    register_write_addr <= A_reg_3;
                    register_data_in <= res_internal;
                    register_carryout_in <= carry_internal;
            end case;
        end if;
    end process;
end Behavioral;
