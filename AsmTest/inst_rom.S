	.org 0x0                # Program starts from 0x0
   .global _start          # Set global symbol
   .set noat               # Free to use $1(at) register
_start:
   ori $1,$0,0x1100        # $1 = $0 | 0x1100 = 0x1100
   ori $1,$1,0x0020        # $1 = $1 | 0x0020 = 0x1120
   ori $1,$1,0x4400        # $1 = $1 | 0x4400 = 0x5520
   ori $1,$1,0x0044        # $1 = $1 | 0x0044 = 0x5564

