from asm_config.registers import REGISTER_BANK
from asm_config.patterns import get_register_name, get_immediate_num
from line import Line
from logger import logger
class Simulator:
    # NOTE: CMP register: 0 is equal, 1 is > and 2 is <

    pc: int # Program counter
    memory: dict[int, int] # 16 bit : 16 bit
    registers_bank: dict[int, int] # 16 bit : 16 bit

    debug_mode: bool

    def __init__(self, pc_init: int = 0, memory_init: dict[int, int] = {}, register_init: dict[int, int] = {}, debug: bool = False):
        self.pc = pc_init
        self.memory = {}
        self.memory.update(memory_init)
        # Init register keys and init with 0
        self.registers_bank = {}
        for reg_name in REGISTER_BANK.REGISTERS.keys():
            self.registers_bank[reg_name] = 0
        # Add special registers
        # Compare register
        self.registers_bank['CMP'] = 0

        self.debug_mode = debug

    def run_simulation(self, lines: list[Line]):
        # Load program in memory
        for i, line in enumerate(lines):
            assert i not in self.memory, 'Memory address already in use when loading lines in RAM'
            self.memory[i] = line
        # Run program

        while True:
            line = self.memory[self.pc]
            stop_program = self.execute_instruction(line)

            self.validate_register_bank()
            if self.debug_mode:
                input('Press enter to continue: ')

            self.dump_mem()
            self.dump_registers()
            
            if stop_program:
                break
            if self.pc not in self.memory:
                logger.warning(f'Program counter is out of bounds: {self.pc}. Stopping program')
                break

    def execute_instruction(self, line: Line) -> bool:
        instruction_name = line.instruction.instruction_name
        logger.debug(f'Executing instruction with name: {line.to_asm_line()}')
        if instruction_name == 'nop':
            # Do nothing
            pass
        elif instruction_name == 'hlt':
            # Stop the program
            return True
        elif instruction_name == 'add':
            rl = get_register_name(line.parameters[0])
            rr = get_register_name(line.parameters[1])
            self.registers_bank[rl] += self.registers_bank[rr]
        elif instruction_name == 'addi':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] += ir
        elif instruction_name == 'subi':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] -= ir
        elif instruction_name == 'incr':
            rl = get_register_name(line.parameters[0])
            self.registers_bank[rl] += 1
        elif instruction_name == 'andi':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] &= ir
        elif instruction_name == 'lsh':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] <<= ir
        elif instruction_name == 'rsh':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] >>= ir
        elif instruction_name == 'mov':
            rl = get_register_name(line.parameters[0])
            rr = get_register_name(line.parameters[1])
            self.registers_bank[rl] = self.registers_bank[rr]
        elif instruction_name == 'movi':
            rl = get_register_name(line.parameters[0])
            ir = get_immediate_num(line.parameters[1], line.instruction.instruction_format_lengths[1])
            self.registers_bank[rl] = ir
        elif instruction_name == 'store':
            rl = get_register_name(line.parameters[0])
            rr = get_register_name(line.parameters[1])
            logger.debug(f'Storing {self.registers_bank[rl]} at memory address {self.registers_bank[rr]}')
            self.memory[self.registers_bank[rr]] = self.registers_bank[rl]
        elif instruction_name == 'load':
            rl = get_register_name(line.parameters[0])
            rr = get_register_name(line.parameters[1])
            logger.debug(f'Loading memory address {self.registers_bank[rr]} into register {rl}')
            self.registers_bank[rl] = self.memory[self.registers_bank[rr]]
        elif instruction_name == 'call':
            raise NotImplementedError('Call instruction not implemented')
        elif instruction_name == 'ret':
            raise NotImplementedError('Ret instruction not implemented')
        elif instruction_name == 'cmp':
            rl = get_register_name(line.parameters[0])
            rr = get_register_name(line.parameters[1])
            if self.registers_bank[rl] == self.registers_bank[rr]:
                self.registers_bank['CMP'] = 0
            elif self.registers_bank[rl] > self.registers_bank[rr]:
                self.registers_bank['CMP'] = 1
            elif self.registers_bank[rl] < self.registers_bank[rr]:
                self.registers_bank['CMP'] = 2
        elif instruction_name == 'jmp':
            ir = get_immediate_num(line.parameters[0], line.instruction.instruction_format_lengths[0])
            logger.debug(f'Jumping to memory address {ir}')
            self.pc = ir
            return False
        elif instruction_name == 'jg':
            ir = get_immediate_num(line.parameters[0], line.instruction.instruction_format_lengths[0])
            if self.registers_bank['CMP'] == 1:
                logger.debug(f'Jumping (jump greater) to memory address {ir}')
                self.pc = ir
                return False
        elif instruction_name == 'je':
            ir = get_immediate_num(line.parameters[0], line.instruction.instruction_format_lengths[0])
            if self.registers_bank['CMP'] == 0:
                logger.debug(f'Jumping (jump equal) to memory address {ir}')
                self.pc = ir
                return False
        else:
            raise ValueError(f'Instruction {instruction_name} not implemented')


        self.pc += 1

    def validate_register_bank(self):
        for reg_key, reg_content in self.registers_bank.items():
            assert 0 <= reg_content <= 2**16 - 1, f'Register {reg_key} has value {reg_content} which is not in range [0, 2^16 - 1]'

    def dump_mem(self):
        mem_csv_handle = open('memory_dump.csv', 'w')
        mem_csv_handle.write('Address,Value\n')
        for address, value in self.memory.items():
            mem_csv_handle.write(f'{address},{value}\n')
        mem_csv_handle.close()

    def dump_registers(self):
        reg_csv_handle = open('register_dump.csv', 'w')
        reg_csv_handle.write('Register,Value\n')
        for reg_name, reg_content in self.registers_bank.items():
            reg_csv_handle.write(f'{reg_name},{reg_content}\n')
        reg_csv_handle.close()