from typing import Optional

def to_binary_string(num: int, width: Optional[int] = None) -> str:
    if width:
        b_str = format(num, f'0{width}b')
    else:
        b_str = format(num, 'b')

    assert len(b_str) == width, f'{b_str} is not {width} long'

    return b_str
