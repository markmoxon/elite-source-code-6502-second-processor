#!/usr/bin/env python
#
# ******************************************************************************
#
# 6502 SECOND PROCESSOR ELITE DECRYPTION SCRIPT
#
# Written by Mark Moxon
#
# This script removes encryption and checksums from the compiled binary for
# the main game code. It reads the encrypted "P.CODE.bin" binary and generates a
# decrypted version as "P.CODE.decrypt.bin"
#
# Files are saved using the decrypt.bin suffix so they don't overwrite any
# existing unprot.bin files, so they can be compared if required
#
# Run this script by changing directory to the repository's root folder and
# running the script with "python sources/elite-decrypt.py"
#
# You can decrypt specific versions by adding the following arguments, as in
# "python sources/elite-decrypt.py -rel1" for example:
#
#   -rel1   Decrypt the source disc version from Ian Bell's site
#   -rel2   Decrypt the SNG45 release version
#
# If unspecified, the default is rel2
#
# ******************************************************************************

from __future__ import print_function
import sys

print()
print("BBC 6502 Second Processor Elite decryption")

argv = sys.argv
release = 2
folder = "sng45"

for arg in argv[1:]:
    if arg == "-rel1":
        release = 1
        folder = "source-disc"
    if arg == "-rel2":
        release = 2
        folder = "sng45"

print("Elite Decryption")

data_block = bytearray()

# Load assembled code file

elite_file = open("extracted/" + folder + "/P.CODE.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()

print()
print("[ Read    ] extracted/" + folder + "/P.CODE.bin")

# Do decryption

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

print("[ Decrypt ] extracted/" + folder + "/P.CODE.bin")

# Write output file for P.CODE.decrypt

output_file = open("extracted/" + folder + "/P.CODE.decrypt.bin", "wb")
output_file.write(data_block)
output_file.close()

print("[ Save    ] extracted/" + folder + "/P.CODE.decrypt.bin")
print()
