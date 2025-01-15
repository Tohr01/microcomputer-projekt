
from dataclasses import dataclass
from typing import Optional, Union
from registers import REGISTERS
from patterns import REGISTER_PATTERN, IMMEDIATE_PATTERN
from util import to_binary_string

INSTRUCTION_WIDTH = 16
OPCODE_WIDTH = 6



@dataclass
class Instruction:
    instruction_name: str  # Ex: mov, add, sub, etc.
    instruction_code: str  # Ex: 000000
    instruction_format: list[str]  # Ex: ['R', 'R'] Available formats: R, I

    def __init__(self, instruction_name: str, instruction_code: str, instruction_format: list[str]):
        assert len(instruction_code) == OPCODE_WIDTH, \
            f'Instruction code for {instruction_name} must be {OPCODE_WIDTH} bits long'

        self.instruction_name = instruction_name
        self.instruction_code = instruction_code
        self.instruction_format = [instruction_format.upper() for instruction_format in instruction_format]

    def parse(self, parameters: list[str], comment: Optional[str] = None, return_comment: bool = False) -> Union[tuple[str, str], str]:
        binary_instruction_arr = [self.instruction_code]
        # Will parse parameters backwards: Meaning instructions e.g. that have the
        # following for: OPCODE IMMEDIATE will be parsed to
        # self.instruction_code [0...0] (<- potentially empty) NUMBER
        print(self.instruction_format)
        bits_left = INSTRUCTION_WIDTH - OPCODE_WIDTH

        for idx, parameter_type in enumerate(reversed(self.instruction_format)):
            try:
                parameter = parameters[idx]
            except IndexError:
                raise IndexError(f'Missing parameter {parameter_type} in parameter array {parameters} at index {idx} ')
            if parameter_type == 'R':

                # Expecting register
                register_match = REGISTER_PATTERN.match(parameter)
                assert register_match is not None, f'{parameter} is not a valid register'
                register_name = register_match.group(1)
                register_code = REGISTERS[register_name]
                bits_left -= len(register_code)
                binary_instruction_arr.insert(1, register_code)
            elif parameter_type == 'I':
                # Expecting immediate
                immediate_match = IMMEDIATE_PATTERN.match(parameter)
                assert immediate_match is not None, f'{parameter} is not a valid immediate'
                immediate_int = int(immediate_match.group(1))
                immediate_byte_str = to_binary_string(immediate_int)
                assert len(immediate_byte_str) <= bits_left, f'{immediate_int} is too high for {bits_left}'
                bits_left -= len(immediate_byte_str)
                binary_instruction_arr.insert(1, immediate_byte_str)
            else:
                raise ValueError(f'Unknown parameter type {parameter_type}')
            
            assert bits_left >= 0, f'Parameter exceeded {INSTRUCTION_WIDTH - OPCODE_WIDTH} bits'

            # Fill with empty zero bits right to OPCODE
            if bits_left > 0:
                binary_instruction_arr.insert(1, '0'*bits_left)

            # Merge to one instruction str
            instruction_str = ''.join(binary_instruction_arr)
            assert instruction_str == INSTRUCTION_WIDTH, f'{instruction_str} is not of length {INSTRUCTION_WIDTH}'

            if return_comment:
                l_comment = f' ; [{self.instr} {",".join(parameters)}]'
                if comment is not None:
                    l_comment += f' COMMENT: {comment}'
                return (instruction_str, l_comment)
            return instruction_str


instr = Instruction('mov', '000000', ['R', 'R'])
print(instr.parse(['$R1', '$R2'], return_comment=True))

 
