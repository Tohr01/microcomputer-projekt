from .instructions import Instruction


class InstructionSet:
    instructions = {
        'nop': Instruction('nop', '000000', [], []),
        'hlt': Instruction('hlt', '000001', [], []),
        'add': Instruction('add', '000010', ['r', 'r'], [5, 5]),
        'addi': Instruction('addi', '000011', ['r', 'i'], [5, 5]),
        'subi': Instruction('subi', '000100', ['r', 'i'], [5, 5]),
        # 'incr': Instruction('incr', '000101', ['r'], [5]), depreacted
        'andi': Instruction('andi', '000110', ['r', 'i'], [5, 5]),
        'lsh': Instruction('lsh', '000111', ['r', 'i'], [5, 5]),
        'rsh': Instruction('rsh', '001000', ['r', 'i'], [5, 5]),
        'mov': Instruction('mov', '001001', ['r', 'r'], [5, 5]),
        'movi': Instruction('movi', '001010', ['r', 'i'], [5, 5]),
        'store': Instruction('store', '001011', ['r', 'r'], [5, 5]),
        'load': Instruction('load', '001100', ['r', 'r'], [5, 5]),
        'call': Instruction('call', '001101', ['i'], [10], True),
        'ret': Instruction('ret', '001110', [], []),
        'cmp': Instruction('cmp', '001111', ['r', 'r'], [5, 5]),
        'jmp': Instruction('jmp', '010000', ['i'], [10], True),
        'jg': Instruction('jg', '010001', ['i'], [10], True),
        'je': Instruction('je', '010010', ['i'], [10], True),
        'dump_mem': Instruction('dump_mem', '010011', [], []),
    }

    @staticmethod
    def get_instruction(instruction_name: str) -> Instruction:
        return InstructionSet.instructions[instruction_name]

def format_for_vhdl():
    for instruction_name, instruction in InstructionSet.instructions.items():
        print(f'constant {instruction_name.upper()}_OP : integer := {int(instruction.instruction_code, 2)}')
