#!/usr/bin/env python
#
# ******************************************************************************
#
# ELITE CHECKSUM SCRIPT
#
# Written by Mark Moxon, and inspired by Kieran Connell's version for the tape
# version of Elite
#
# This script applies encryption and checksums to the compiled binary for the
# main parasite game code. It reads the unencrypted "CODE.unprot.bin" binary and
# generates an encrypted version as "P.CODE", based on the code in the original
# "S.PCODES" BASIC source program
#
# ******************************************************************************

from __future__ import print_function
import sys

argv = sys.argv
argc = len(argv)
Encrypt = True

if argc > 1 and argv[1] == '-u':
    Encrypt = False

print("Elite Big Code File")
print("Encryption = ", Encrypt)

data_block = bytearray()

# Load assembled code file

elite_file = open('output/CODE.unprot.bin', 'rb')
data_block.extend(elite_file.read())
elite_file.close()

# Commander data checksum

commander_start = 12 + 5
commander_offset = 0x52
CH = 0x4B - 2
CY = 0
for i in range(CH, 0, -1):
    CH = CH + CY + data_block[commander_start + i + 7]
    CY = (CH > 255) & 1
    CH = CH % 256
    CH = CH ^ data_block[commander_start + i + 8]

print("Commander checksum = ", CH)

# Must have Commander checksum otherwise game will lock

if Encrypt:
    data_block[commander_start + commander_offset] = CH ^ 0xA9
    data_block[commander_start + commander_offset + 1] = CH
else:
    print("WARNING! Commander checksum must be copied into elite-source.asm as CH% = ", CH)

# First part: ZP routine, which sets the checksum byte at S%-1

s = 0x106A

s_checksum = 0x10
carry = 1
for x in range(0x10, 0xA0):
    for y in [0] + list(range(255, 0, -1)):
        i = x * 256 + y
        s_checksum += data_block[i - 0x1000] + carry
        if s_checksum > 255:
            carry = 1
        else:
            carry = 0
        s_checksum = s_checksum % 256
        s_checksum ^= y
        s_checksum = s_checksum % 256
        sub = x + (1 - carry)
        if sub > s_checksum:
            s_checksum = s_checksum + 256 - sub
            carry = 0
        else:
            s_checksum -= sub
            carry = 1
        s_checksum = s_checksum % 256
    carry = 0
    s_checksum = s_checksum % 256
s_checksum = s_checksum % 256

print("S%-1 checksum = ", s_checksum)

if Encrypt:
    data_block[s - 0x1000 - 1] = s_checksum % 256

# Second part: SC routine, which EORs bytes between &1300 and &9FFF

if Encrypt:
    for n in range(0x1300, 0xA000):
        data_block[n - 0x1000] = data_block[n - 0x1000] ^ (n % 256) ^ 0x75

# Third part: V, which reverses the order of bytes between G% and F%-1

# The values of G% and F% are hardcoded, which is not ideal - they should
# really come from the build process. Maybe later!

g = 0x10D1
f = 0x81B0 - 1

if Encrypt:
    while g < f:
        tmp = data_block[g - 0x1000]
        data_block[g - 0x1000] = data_block[f - 0x1000]
        data_block[f - 0x1000] = tmp
        g += 1
        f -= 1

# Write output file for 'ELTcode'

output_file = open('output/P.CODE.bin', 'wb')
output_file.write(data_block)
output_file.close()
