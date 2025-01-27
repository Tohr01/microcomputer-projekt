import re
from typing import Optional

LINE_PATTERN = re.compile(r'^([^#]+)(#\s*(.+)\s*)?$')  # Separates line into instruction and comment (Group 1: Instruction, Group 3: Comment)
REGISTER_PATTERN = re.compile(r'\$([^ \n,]+)')  # Group 1: Register name
IMMEDIATE_PATTERN = re.compile(r'(\d+)')  # Group 1: Immediate value
SUBROUTINE_LOOP_PATTERN = re.compile(r'(\w+):')  # Group 1: Subroutine or loop name
JUMP_PATTERN = re.compile(r'(\w+)')  # Group 1: Jump target name

def get_immediate_num(immediate: str, max_bits: Optional[int] = None) -> int:
    immediate_match = IMMEDIATE_PATTERN.match(immediate)
    assert immediate_match is not None, f'{immediate} is not a valid immediate'
    num = int(immediate_match.group(1))
    if max_bits is not None:
        assert num < 2 ** max_bits, f'{num} is too high for {max_bits} bits'
    return num

def get_register_name(register: str) -> str:
    register_match = REGISTER_PATTERN.match(register)
    assert register_match is not None, f'{register} is not a valid register'
    return register_match.group(1)