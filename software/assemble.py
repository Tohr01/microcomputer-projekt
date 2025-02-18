import argparse
import logging
import os
from typing import Optional

from simulator import Simulator
from line import Line
from asm_config.patterns import LINE_PATTERN, SUBROUTINE_LOOP_PATTERN, JUMP_PATTERN
from logger import logger, change_log_level

COMMENT_PREFIX = '#'


def assemble(filepath: str, enable_debug: Optional[bool] = False, include_comment: Optional[bool] = False, simulate: Optional[bool] = False, simulator_args: dict = {}):
    """
    Assembles an assembly language file into binary instructions.

    1. Read the assembly file.
    2. Strip whitespace from each line.
    3. Remove empty lines.
    4. Remove lines that contain only comments.
    5. Separate instructions and inline comments.
    6. Parse lines into `Line` objects.
    7. Identify and record jump target locations.
    8. Replace jump target names with their corresponding indices.
    9. Optionally run a simulation of the assembled code.
    10. Compile instructions into binary format.
    11. Write the binary instructions to a file.

    :param filepath (str): The path to the assembly file to be compiled to binary.
    :param enable_debug (Optional[bool]): If True, enables debug logging and writes intermediate files for debugging. Defaults to False.
    :param include_comment (Optional[bool]): If True, includes comments in the binary output. Defaults to False.
    :param simulate (Optional[bool]): If True, runs a simulation of the assembled code. Defaults to False.
    :param simulator_args (dict): Arguments to be passed to the simulator if simulation is enabled. Defaults to an empty dictionary.
   
    """
    file_handle = open(filepath, 'r')
    raw_asm = file_handle.read()
    file_handle.close()
    # Split by new line
    asm_lines = raw_asm.split('\n')
    # Strip lines
    asm_lines = strip_lines(asm_lines)
    logger.info('Stripped whitespaces from lines')
    # Remove empty lines
    asm_line_count = len(asm_lines)
    asm_lines = remove_empty_lines(asm_lines)
    logger.info(f'Removed empty {asm_line_count - len(asm_lines)} lines')
    # Remove comment lines only
    asm_line_count = len(asm_lines)
    asm_lines = remove_comment_lines(asm_lines)
    logger.info(f'Removed {asm_line_count - len(asm_lines)} comment only lines')
    # Write cleaned asm file to debug-cleaned-asm.txt file
    if enable_debug:
        logger.debug('Writing cleaned asm to debug file')
        with open('debug-cleaned-asm.txt', 'w') as f:
            f.write('\n'.join(asm_lines))
    # Separate inline comments from instructions
    asm_lines = separate_instructions_and_comments(asm_lines)
    logger.info('Seperated instructions and comments into different tuples')
    # Parse to Line objects
    lines = parse_to_line_objs(asm_lines)
    logger.info('Parsed line tuples to line instances')
    # Write debugged lines to debug-parsed-line-insts.txt file
    if enable_debug:
        logger.debug('Writing parsed lines to debug file')
        with open('debug-parsed-lines.txt', 'w') as f:
            f.write('\n'.join([*map(lambda line: str(line), lines)]))
    # Note indices of jump targets and names
    jump_target_indices = parse_jump_target_locations(lines)  # {name: index}
    logger.info(f'Parsed {len(jump_target_indices)} jump target locations')
    for name, index in jump_target_indices.items():
        logger.debug(f'Jump target {name} at index {jump_target_indices[name]}')
    # Replace jump target names with indices
    lines = replace_jump_target_names_with_indices(lines, jump_target_indices)
    logger.info('Replaced jump target names with indices')
    # Write debugged lines to debug-parsed-line-jumps.txt file
    if enable_debug:
        logger.debug('Writing parsed lines with jump target indices to debug file')
        with open('debug-parsed-lines-w-jumps.txt', 'w') as f:
            f.write('\n'.join([*map(lambda line: str(line), lines)]))
    # If user wants to run simulation run
    if simulate:
        logger.debug('Running simulation ...')
        simulator = Simulator(**simulator_args)
        simulator.run_simulation(lines)

    # Compile instructions to binary
    binary_instructions = compile_instructions(lines, include_comment)
    logger.info('Compiled instructions to binary')
    # Write binary instructions to file
    # extract filename without extension from path
    directory = os.path.splitext(os.path.dirname(filepath))[-1]
    filename, _suffix = os.path.splitext(os.path.basename(filepath))

    bin_filepath = f'{os.path.join(directory, filename)}.bin'
    with open(bin_filepath, 'w') as f:
        f.write('\n'.join(binary_instructions))
    logger.info(f'Wrote binary instructions to {bin_filepath}')


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

        line = Line(line_tuple, last_jump_target_names if last_jump_target_names else None)
        if jump_target_match is None:
            last_jump_target_names = []
        parsed_lines.append(line)

    assert len(last_jump_target_names) == 0, f'Unused subroutine or loop? {last_jump_target_names}'

    return parsed_lines


def parse_jump_target_locations(lines: list[Line]) -> dict[str, int]:
    jump_target_indices = {}
    for i, line in enumerate(lines):
        if line.jump_target_names is not None:
            for jump_target_name in line.jump_target_names:
                jump_target_indices[jump_target_name] = i
    return jump_target_indices


def replace_jump_target_names_with_indices(lines: list[Line], jump_target_indices: dict[str, int]) -> list[Line]:
    for line in lines:
        if line.instruction.is_jump:
            assert len(line.parameters) == 1, 'Jump instruction must have exactly one parameter'
            parameter = line.parameters[0]
            jump_target_match = JUMP_PATTERN.match(parameter)
            assert jump_target_match is not None, f'Invalid jump target {parameter}'
            jump_target_name = jump_target_match.group(1)
            line.parameters[0] = str(jump_target_indices[jump_target_name])
            if line.comment is None:
                line.comment = ''
            line.comment = f' --- Line jumps to {jump_target_name}'
    return lines


def compile_instructions(lines: list[Line], include_comment: bool = False) -> list[str]:
    binary_instructions = []
    for i, line in enumerate(lines):
        logger.debug(f'Compiling line {i+1} (address {i})')
        binary_instruction, comment = line.instruction.parse(line.parameters, line.comment, include_comment)
        if include_comment:
            binary_instruction += comment
        binary_instructions.append(f'{i} ' + binary_instruction)
    return binary_instructions


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='The file to be assembled')
    parser.add_argument('-d', '--debug', help='Start the assembler in debug mode', action='store_true')
    parser.add_argument('-c', '--comment', help='Include comment next to lines in assembled file', action='store_true')
    parser.add_argument('-s', '--simulate', help='Whether to run simulation', action='store_true')
    parser.add_argument('-p', '--prompt-debug', help='Whether to run simulation in prompt debug mode', action='store_true')

    args = parser.parse_args()

    file = args.file
    debug = args.debug
    include_comment = args.comment
    simulate = args.simulate

    simulator_args = {
        'pc_init': 0,
        'memory_init': {},
        'register_init': {'C1': 1000, 'C2': 1000, 'C3': 1001, 'C4': 1999},
        'prompt_debug': args.prompt_debug
    }

    if debug:
        change_log_level(logging.DEBUG)
    else:
        change_log_level(logging.INFO)

    assert os.path.exists(file) and not os.path.isdir(file), 'File does not exist'
    assemble(file, enable_debug=debug, include_comment=include_comment, simulate=simulate, simulator_args=simulator_args)
