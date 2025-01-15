from dataclasses import dataclass
from typing import Optional, Union

from .patterns import REGISTER_PATTERN, IMMEDIATE_PATTERN
from .registers import REGISTER_BANK
from .util import to_binary_string
from logger import logger

INSTRUCTION_WIDTH = 16
OPCODE_WIDTH = 6


@dataclass
class Instruction:
    instruction_name: str  # Ex: mov, add, sub, etc.
    instruction_code: str  # Ex: 000000
    instruction_format: list[str]  # Ex: ['R', 'R'] Available formats: R, I
    instruction_format_lengths: list[int]  # Ex: [5, 5] Lengths of the formats
    is_jump: bool = False  # Is this instruction a jump instruction?

    def __init__(self, instruction_name: str, instruction_code: str, instruction_format: list[str], instruction_format_lengths: list[int], is_jump: bool = False):
        assert len(instruction_code) == OPCODE_WIDTH, \
            f'Instruction code for {instruction_name} must be {OPCODE_WIDTH} bits long'
        assert len(instruction_format) == len(instruction_format_lengths), \
            f'Instruction format and lengths must have the same length'

        self.instruction_name = instruction_name
        self.instruction_code = instruction_code
        self.instruction_format = [instruction_format.upper() for instruction_format in instruction_format]
        self.instruction_format_lengths = instruction_format_lengths
        self.is_jump = is_jump

    def parse(self, parameters: list[str], comment: Optional[str] = None, return_comment: bool = False) -> tuple[str, Optional[str]]:
        binary_instruction_arr = [self.instruction_code]
        # Will parse parameters backwards: Meaning instructions e.g. that have the
        # following for: OPCODE IMMEDIATE will be parsed to
        # self.instruction_code [0...0] (<- potentially empty) NUMBER
        bits_left = INSTRUCTION_WIDTH - OPCODE_WIDTH

        for idx in range(len(self.instruction_format) - 1, -1, -1):
            parameter_type = self.instruction_format[idx]
            try:
                parameter = parameters[idx]
            except IndexError:
                raise IndexError(f'Missing parameter {parameter_type} in parameter array {parameters} at index {idx}')
            logger.debug(f'Parsing parameter {parameter} of type {parameter_type} at index {idx}')
            if parameter_type == 'R':
                # Expecting register
                register_match = REGISTER_PATTERN.match(parameter)
                assert register_match is not None, f'{parameter} is not a valid register'
                register_name = register_match.group(1)
                register_code = REGISTER_BANK.get_register(register_name)
                assert len(register_code) == self.instruction_format_lengths[idx], f'{register_name} is not {self.instruction_format_lengths[idx]} bits long'
                logger.debug(f'Converted register name {parameter} to register code {register_code}')
                bits_left -= len(register_code)
                binary_instruction_arr.insert(1, register_code)
            elif parameter_type == 'I':
                # Expecting immediate
                immediate_match = IMMEDIATE_PATTERN.match(parameter)
                assert immediate_match is not None, f'{parameter} is not a valid immediate'
                immediate_int = int(immediate_match.group(1))
                immediate_byte_str = to_binary_string(immediate_int, width=self.instruction_format_lengths[idx])
                logger.debug(f'Converted immediate {parameter} to immediate byte string {immediate_byte_str}')
                assert len(immediate_byte_str) <= bits_left, f'{immediate_int} is too high for {bits_left}'
                bits_left -= len(immediate_byte_str)
                binary_instruction_arr.insert(1, immediate_byte_str)
            else:
                raise ValueError(f'Unknown parameter type {parameter_type}')

            assert bits_left >= 0, f'Parameter exceeded {INSTRUCTION_WIDTH - OPCODE_WIDTH} bits'

        # Fill with empty zero bits right to OPCODE
        if bits_left > 0:
            logger.debug(f'Filling {bits_left} bits with 0 right to opcode')
            binary_instruction_arr.insert(1, '0' * bits_left)

        # Merge to one instruction str
        instruction_str = ''.join(binary_instruction_arr)
        assert len(instruction_str) == INSTRUCTION_WIDTH, f'{instruction_str} is not of length {INSTRUCTION_WIDTH}'

        if return_comment:
            l_comment = f' ; [{self.instruction_name} {",".join(parameters)}]'
            if comment is not None:
                l_comment += f' COMMENT: {comment}'
            return instruction_str, l_comment
        return instruction_str, None
