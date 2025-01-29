class REGISTER_BANK:
    REGISTERS = {
        "OVERFLOW": 14,
        "C1": 15,
        "C2": 16,
        "C3": 17,
        "C4": 18,
        "0": 19,
        "1": 20,
        "CADDR": 21,
        "CNUM": 22,
        "MULLEFT": 23,
        "MULRIGHT": 24,
        "MULRES": 25,
        "SADDR": 26,
        "R0": 27,
        "R1": 28,
        "R2": 29
    }

    @classmethod
    def get_register(cls, register_name):
        try:
            reg_bin = format(cls.REGISTERS[register_name], 'b').zfill(5)
            assert len(reg_bin) <= 5, f'{register_name} is not 5 bits long'
            return reg_bin
        except KeyError:
            raise KeyError(f'{register_name} is not a valid register')
