import os
import binascii
from functools import partial

i = 0
f = open('inst_rom.bin', 'rb')
f2 = open('inst_rom.data', 'w')
records = iter(partial(f.read,1), b'')
for r in records:
    r_int = int.from_bytes(r, byteorder='big')  #将 byte转化为 int
    #str_bin = bin(r_int).lstrip('0b')  #将int转化为二进制字符
    #str_bin = hex(r_int).lstrip('0b')  #将int转化为16进制字符
    #if r_int.bit_length() < 8 :  #以8bit为单位，不足8bit的补零
    #    str_bin = (8 - r_int.bit_length()) * '0' + str_bin
    str_bin = "{:02X}".format(r_int)
    f2.write(str_bin)
    '''i += 1
    if i == 4 :              #以32bit为单位分行
        f2.write('\n')
        i = 0
    '''
    f2.write('\n')
f.close
f2.close