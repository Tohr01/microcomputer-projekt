from typing import Optional


def calc_instruction_chains_high_number(number: int, target_register: str):
    pass


def to_binary_string(num: int, width: Optional[int] = None) -> str:
    if width:
        return format(num, f'0{width}b')
    return format(num, 'b')

