import argparse
import logging
import os
import sys
from typing import Optional

from asm_config import Instruction, InstructionSet
from patterns import LINE_PATTERN, SUBROUTINE_LOOP_PATTERN

COMMENT_PREFIX = '#'

logger = logging.getLogger('assembler')
logger.setLevel(logging.DEBUG)
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setLevel(logging.DEBUG)

formatter = logging.Formatter('[%(name)s] - [%(levelname)s] - %(message)s')
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)


class Line:
    instruction: Instruction
    parameters: list[str]
    comment: Optional[str]
    jump_target_names: Optional[list[str]]

    def __init__(self, line_tuple: tuple[list[str], Optional[str]], jump_target_names: Optional[list[str]] = None):
        assert len(line_tuple) >= 1, 'Line tuple must have at least one elements'
        instruction_list = line_tuple[0]
        assert len(instruction_list) >= 1, 'Instruction list must have at least one element'
        self.instruction = InstructionSet.get_instruction(instruction_list[0])
        self.parameters = instruction_list[1:]
        self.comment = line_tuple[1]
        self.jump_target_names = None or jump_target_names

    def __repr__(self):
        return f'{self.instruction.instruction_name} {self.parameters = } {self.comment = } {self.jump_target_names = }'

def assemble(filepath: str):
    file_handle = open(file, 'r')
    raw_asm = file_handle.read()
    file_handle.close()
    # Split by new line
    asm_lines = raw_asm.split('\n')
    # Strip lines
    asm_lines = strip_lines(asm_lines)
    logger.debug('Stripped whitespaces from lines')
    # Remove empty lines
    asm_line_count = len(asm_lines)
    asm_lines = remove_empty_lines(asm_lines)
    logger.debug(f'Removed empty {asm_line_count - len(asm_lines)} lines')
    # Remove comment lines only
    asm_line_count = len(asm_lines)
    asm_lines = remove_comment_lines(asm_lines)
    logger.debug(f'Removed {asm_line_count - len(asm_lines)} comment only lines')
    # Separate inline comments from instructions
    asm_lines = separate_instructions_and_comments(asm_lines)
    # Parse to Line objects
    lines = parse_to_line_objs(asm_lines)
    print('\n'.join([*map(lambda line: str(line), lines)]))


def strip_lines(lines: list[str]) -> list[str]:
    return [*map(lambda line: line.strip(), lines)]


def remove_empty_lines(lines: list[str]) -> list[str]:
    return [*filter(lambda line: line != '', lines)]


def remove_comment_lines(lines: list[str]) -> list[str]:
    return [*filter(lambda line: not line.startswith(COMMENT_PREFIX), lines)]


def separate_instructions_and_comments(lines: list[str]) -> list[tuple[list[str], Optional[str]]]:
    asm_lines = []
    for line in lines:
        comment_match = LINE_PATTERN.match(line)
        assert comment_match is not None
        instruction_str = comment_match.group(1).strip()
        # Process instruction string (remove commas -> split by spaces -> remove empty strings)
        instruction_str = instruction_str.replace(',', '')
        instruction = instruction_str.split(' ')
        instruction = [*filter(lambda part: part != '', instruction)]
        comment_str = comment_match.group(3)
        asm_lines.append((instruction, comment_str))
    return asm_lines


def parse_to_line_objs(lines: list[tuple[list[str], Optional[str]]]) -> list[Line]:
    parsed_lines = []
    last_jump_target_names = []
    for i, line_tuple in enumerate(lines):
        # Check if line is a jump target point
        jump_target_match = SUBROUTINE_LOOP_PATTERN.match(line_tuple[0][0])
        if jump_target_match is not None:
            last_jump_target_names.append(jump_target_match.group(1))
            continue

        print(line_tuple)
        line = Line(line_tuple, last_jump_target_names)
        if jump_target_match is None:
            last_jump_target_names = []
        parsed_lines.append(line)

    assert len(last_jump_target_names) == 0, f'Unused subroutine or loop? {last_jump_target_names}'

    return parsed_lines

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='The file to be assembled')
    args = parser.parse_args()

    file = args.file
    assert os.path.exists(file) and not os.path.isdir(file), 'File does not exist'
    assemble(file)
