#!/usr/bin/env python
#
# ******************************************************************************
#
# 6502 SECOND PROCESSOR ELITE DECRYPTION SCRIPT
#
# Written by Mark Moxon, and inspired by Kieran Connell's version for the
# cassette version of Elite
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
release = 2

for arg in argv[1:]:
    if arg == '-rel1':
        release = 1
    if arg == '-rel2':
        release = 2

print("Elite Decryption")

data_block = bytearray()

# Load assembled code file

elite_file = open('binaries/P.CODE', 'rb')
data_block.extend(elite_file.read())
elite_file.close()

# Third part: V, which reverses the order of bytes between G% and F%-1
# Can be reversed by simply repeating the reversal

if release == 1:
    # Source disc
    g = 0x10D1
    f = 0x81B0 - 1
elif release == 2:
    # SNG45
    g = 0x10D1
    f = 0x818F - 1

while g < f:
    tmp = data_block[g - 0x1000]
    data_block[g - 0x1000] = data_block[f - 0x1000]
    data_block[f - 0x1000] = tmp
    g += 1
    f -= 1

# Second part: SC routine, which EORs bytes between &1300 and &9FFF
# Can be reversed by simply repeating the EOR

for n in range(0x1300, 0xA000):
    data_block[n - 0x1000] = data_block[n - 0x1000] ^ (n % 256) ^ 0x75

# First part: ZP routine, which sets the checksum byte at S%-1
# Can be reversed by setting the checksum to an RTS, as in the source

s = 0x106A
data_block[s - 0x1000 - 1] = 0x60

# Write output file for 'CODE.decrypt.bin'

output_file = open('binaries/CODE.decrypt.bin', 'wb')
output_file.write(data_block)
output_file.close()
