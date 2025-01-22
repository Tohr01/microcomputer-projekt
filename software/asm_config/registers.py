class REGISTER_BANK:
    REGISTERS = {
        "MAX_VALUE": 14,
        "C1": 15,
        "C2": 16,
        "C3": 17,
        "C4": 18,
        "0": 19,
        "1": 20,
        "OVERFLOW": 21,
        "CADDR": 22,
        "CNUM": 23,
        "MULLEFT": 24,
        "MULRIGHT": 25,
        "MULRES": 26,
        "SADDR": 27,
        "R0": 28,
        "R1": 29,
        "R2": 30
    }

    @classmethod
    def get_register(cls, register_name):
        try:
            reg_bin = format(cls.REGISTERS[register_name], 'b').zfill(5)
            assert len(reg_bin) <= 5, f'{register_name} is not 5 bits long'
            return reg_bin
        except KeyError:
            raise KeyError(f'{register_name} is not a valid register')


"""
reg_dict = {}
for i in range(len(REGISTER_BANK.REGISTERS) - 1, -1, -1):
    assert i < 32
    register_name = REGISTER_BANK.REGISTERS[i]
    num = 32 - len(REGISTER_BANK.REGISTERS) + i
    reg_dict[register_name] = num

for k, v in reversed(reg_dict.items()):
    print(f'"{k}": {v}')
"""

print(format(2**16 - 1, 'b').zfill(5))
