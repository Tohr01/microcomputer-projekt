from typing import Optional

def calc_instruction_chains_high_number(number: int, target_register: str):
    pass


def to_binary_string(num: int, width: Optional[int] = None) -> str:
    if width:
        b_str = format(num, f'0{width}b')
    else:
        b_str = format(num, 'b')

    assert len(b_str) == width, f'{b_str} is not {width} long'

    return b_str