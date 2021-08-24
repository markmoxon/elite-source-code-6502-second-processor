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
# running the script with "python 2-build-files/elite-decrypt.py"
#
# You can decrypt specific releases by adding the following arguments, as in
# "python 2-build-files/elite-decrypt.py -rel1" for example:
#
#   -rel1   Decrypt the source disc release from Ian Bell's site
#   -rel2   Decrypt the SNG45 release
#   -rel3   Decrypt the Executive version
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
    if arg == "-rel3":
        release = 3
        folder = "executive"

print("Elite Decryption")

data_block = bytearray()

# Load assembled code file

elite_file = open("4-reference-binaries/" + folder + "/P.CODE.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()

print()
print("[ Read    ] 4-reference-binaries/" + folder + "/P.CODE.bin")

# Do decryption

# Third part: V, which reverses the order of bytes between G% and F%-1
# Can be reversed by simply repeating the reversal
#
# These values can be calculated from the unused code at prtblock,
# which contains a CMP F%-1 instruction

if release == 1:
    # Source disc
    g = 0x10D1
    f = 0x81B0 - 1
elif release == 2:
    # SNG45
    g = 0x10D1
    f = 0x818F - 1
elif release == 3:
    # Executive
    g = 0x10D3
    f = 0x82e7 - 1

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

print("[ Decrypt ] 4-reference-binaries/" + folder + "/P.CODE.bin")

# Write output file for P.CODE.decrypt

output_file = open("4-reference-binaries/" + folder + "/P.CODE.decrypt.bin", "wb")
output_file.write(data_block)
output_file.close()

print("[ Save    ] 4-reference-binaries/" + folder + "/P.CODE.decrypt.bin")
print()
