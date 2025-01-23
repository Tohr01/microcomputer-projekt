def calc_instruction_chains_high_number(number: int, target_register: str):
    if number == 0:
        print(f'movi {target_register}, 0')
        return
    bin_number = format(number, 'b')
    assert len(bin_number) <= 16, f'{number} is too high'
    bin_number = bin_number.zfill(16)
    first_one_idx = next(idx for idx in range(len(bin_number)) if bin_number[idx] == '1')
    bin_number_chunks = [bin_number[i:i + 5] for i in range(first_one_idx, len(bin_number), 5)]
    for i, bin_number_chunk in enumerate(bin_number_chunks):
        if i == 0:
            print(f'movi {target_register}, {int(bin_number_chunk, 2)}')
        else:
            print(f'lsh {target_register}, {len(bin_number_chunk)}')
            print(f'addi {target_register}, {int(bin_number_chunk, 2)}')


calc_instruction_chains_high_number(2**16-1, '$MAX_VALUE')
print((((((31 << 5) + 31) << 5) + 31) << 1) + 1)