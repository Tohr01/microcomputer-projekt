from asm_config.instructions import Instruction
from asm_config.isa import InstructionSet
from typing import Optional


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

    def to_asm_line(self) -> str:
        return f'{self.instruction.instruction_name} {", ".join(self.parameters)}'

    def __repr__(self):
        return f'{self.instruction.instruction_name} {self.parameters = } {self.comment = } {self.jump_target_names = } {self.instruction.is_jump = }'
