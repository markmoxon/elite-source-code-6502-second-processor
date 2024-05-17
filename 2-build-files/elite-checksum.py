#!/usr/bin/env python
#
# ******************************************************************************
#
# 6502 SECOND PROCESSOR ELITE CHECKSUM SCRIPT
#
# Written by Mark Moxon, and inspired by Kieran Connell's version for the
# cassette version of Elite
#
# This script applies encryption and checksums to the compiled binary for the
# main parasite game code. It reads the unencrypted "P.CODE.unprot.bin" binary
# and generates an encrypted version as "P.CODE", based on the code in the
# original "S.PCODES" BASIC source program
#
# ******************************************************************************

from __future__ import print_function
import sys

argv = sys.argv
Encrypt = True
release = 2

for arg in argv[1:]:
    if arg == "-u":
        Encrypt = False
    if arg == "-rel1":
        release = 1
    if arg == "-rel2":
        release = 2
    if arg == "-rel3":
        release = 3

print("6502SP Elite Checksum")
print("Encryption = ", Encrypt)

# Configuration variables for scrambling code and calculating checksums
#
# Values must match those in 3-assembled-output/compile.txt
#
# If you alter the source code, then you should extract the correct values for
# the following variables and plug them into the following, otherwise the game
# will fail the checksum process and will hang on loading
#
# You can find the correct values for these variables by building your updated
# source, and then searching compile.txt for "elite-checksum.py", where the new
# values will be listed

if release == 1:
    # Source disc variant
    s = 0x106A                  # S%
    g = 0x10D1                  # G%
    f = 0x81FD                  # F%
elif release == 2:
    # SNG45 variant
    s = 0x106A                  # S%
    g = 0x10D1                  # G%
    f = 0x81F2                  # F%
elif release == 3:
    # Executive variant
    s = 0x106C                  # S%
    g = 0x10D3                  # G%
    f = 0x8358                  # F%

# Load assembled code file for P.CODE

data_block = bytearray()

elite_file = open("3-assembled-output/P.CODE.unprot.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()

# Commander data checksum

if release == 1:
    # Source disc
    commander_start = 12 + 5
elif release == 2:
    # SNG45
    commander_start = 12 + 5
elif release == 3:
    # Executive
    commander_start = 14 + 5

commander_offset = 0x52
CH = 0x4B - 2
CY = 0
for i in range(CH, 0, -1):
    CH = CH + CY + data_block[commander_start + i + 7]
    CY = (CH > 255) & 1
    CH = CH % 256
    CH = CH ^ data_block[commander_start + i + 8]

print("Commander checksum = ", hex(CH))

# Must have Commander checksum otherwise game will lock

if Encrypt:
    data_block[commander_start + commander_offset] = CH ^ 0xA9
    data_block[commander_start + commander_offset + 1] = CH

# First part: ZP routine, which sets the checksum byte at S%-1

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

if Encrypt:
    f -= 1
    while g < f:
        tmp = data_block[g - 0x1000]
        data_block[g - 0x1000] = data_block[f - 0x1000]
        data_block[f - 0x1000] = tmp
        g += 1
        f -= 1

# Write output file for P.CODE

output_file = open("3-assembled-output/P.CODE.bin", "wb")
output_file.write(data_block)
output_file.close()

print("3-assembled-output/P.CODE.bin file saved")
