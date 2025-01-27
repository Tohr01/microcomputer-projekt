1. IF
2. ID
3. OF - nop
4. WFO - nop
5. EX - nop
6. RS - Speicher

$0 = 0
$1 = 1

addi $0, 1
nop [RS]
nop
nop
addi $0, 2 [OF]

Nach unbedinten Sprünge kein nop:
jmp ZIEL

cmp $0, $1
nop 
nop 
nop 
je frgrt
nop [RS]
nop 
nop
nop
nop
nop [IF]