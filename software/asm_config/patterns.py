import re

LINE_PATTERN = re.compile(r'^([^#]+)(#\s*(.+)\s*)?$')  # Separates line into instruction and comment (Group 1: Instruction, Group 3: Comment)
REGISTER_PATTERN = re.compile(r'\$([^ \n,]+)')  # Group 1: Register name
IMMEDIATE_PATTERN = re.compile(r'(\d+)')  # Group 1: Immediate value
SUBROUTINE_LOOP_PATTERN = re.compile(r'(\w+):')  # Group 1: Subroutine or loop name
JUMP_PATTERN = re.compile(r'(\w+)')  # Group 1: Jump target name
