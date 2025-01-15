class REGISTER_BANK:
    REGISTERS = [
        '0',
        '1',
        'C1',
        'C2',
        'C3',
        'C4',
        'OVERFLOW',
        'CADDR',
        'CNUM',
        'MULLEFT',
        'MULRIGHT',
        'MULRES',
        'SADDR',
        'R0',
        'R1',
        'R2',
        'MAX_VALUE'
    ]

    @classmethod
    def get_register(self, item):
        try:
            return format(self.REGISTERS.index(item), 'b').zfill(5)
        except ValueError:
            raise KeyError(f'{item} is not a valid register')


