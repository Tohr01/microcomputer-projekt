from dataclasses import dataclass

INSTRUCTION_WIDTH = 6


@dataclass
class Instruction:
    instruction_name: str  # Ex: mov, add, sub, etc.
    instruction_code: str  # Ex: 000000
    instruction_format: list[str]  # Ex: ['r', 'r'] Available formats: r, i, j

    def __init__(self, instruction_name: str, instruction_code: str, instruction_format: list[str]):
        assert len(instruction_code) == INSTRUCTION_WIDTH, \
            f'Instruction code for {instruction_name} must be {INSTRUCTION_WIDTH} bits long'

        self.instruction_name = instruction_name
        self.instruction_code = instruction_code
        self.instruction_format = [instruction_format.upper() for instruction_format in instruction_format]

    def parse(self, line: str):
        params = []
        for parameter_type in self.instruction_format:
            if parameter_type == 'R':
                # Expecting register
                pass
            elif parameter_type == 'I':
                # Expecting immediate
                pass
            elif parameter_type == 'J':
                # Expecting jump address
                pass

            else:
                raise ValueError(f'Unknown parameter type {parameter_type}')


class InstructionSet:
    instructions = {
        'nop': Instruction('nop', '000000', []),
        'hlt': Instruction('hlt', '000001', []),
        'add': Instruction('add', '000010', ['r', 'r']),
        'addi': Instruction('addi', '000011', ['r', 'i']),
        'subi': Instruction('subi', '000100', ['r', 'i']),
        'incr': Instruction('incr', '000101', []),
        'andi': Instruction('andi', '000110', ['r', 'i']),
        'lsh': Instruction('lsh', '000111', ['r', 'i']),
        'rsh': Instruction('rsh', '001000', ['r', 'i']),
        'mov': Instruction('mov', '001001', ['r', 'r']),
        'movi': Instruction('movi', '001010', ['r', 'i']),
        'store': Instruction('store', '001011', ['r', 'r']),
        'load': Instruction('load', '001100', ['r', 'r']),
        'call': Instruction('call', '001101', ['i']),
        'ret': Instruction('ret', '001110', ['i']),
        'cmp': Instruction('cmp', '001111', ['i']),
        'jmp': Instruction('jmp', '010000', ['i']),
        'jg': Instruction('jg', '010001', ['i']),
        'je': Instruction('je', '010010', ['i'])
    }

    @staticmethod
    def get_instruction(instruction_name: str) -> Instruction:
        return InstructionSet.instructions[instruction_name]
