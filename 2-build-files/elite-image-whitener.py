#!/usr/bin/env python
#
# ******************************************************************************
#
# 6502 SECOND PROCESSOR ELITE IMAGE WHITENER
#
# Written by Mark Moxon
#
# This script converts the loading screen title mode 2 dashboard images into
# pure white, for use with the anaglyph 3D version of Elite
#
# We need to do this for the title screen as the original images are not white,
# and if we decided to whiten them using the palette, this would cause an
# unpleasant colour flip as the palettes are not set up until the I/O processor
# code has loaded.
#
# We need to do this for the dashboard as otherwise the top line of the dash
# gets shown in the wrong colour, as in the original image it is in colour 3,
# and that is cyan in the anaglyph 3D view, not white.
#
# ******************************************************************************


def convert_to_white(data_block):
    for n in range(0, len(data_block)):
        low = data_block[n] & 0xF
        high = (data_block[n] & 0xF0) >> 4
        white = low | high
        data_block[n] = white + (white << 4)


print()
print("BBC 6502 Second Processor Elite dashboard whitener")

# Convert dashboard image

data_block = bytearray()
elite_file = open("1-source-files/images/P.DIALS2P.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()
convert_to_white(data_block)
output_file = open("1-source-files/images/P.DIALSW.bin", "wb")
output_file.write(data_block)
output_file.close()

# Convert Acornsoft image

data_block = bytearray()
elite_file = open("1-source-files/images/Z.ACSOFT.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()
convert_to_white(data_block)
output_file = open("1-source-files/images/Z.ACSOFTW.bin", "wb")
output_file.write(data_block)
output_file.close()

# Convert copyright image

data_block = bytearray()
elite_file = open("1-source-files/images/Z.(C)ASFT.bin", "rb")
data_block.extend(elite_file.read())
elite_file.close()
convert_to_white(data_block)
output_file = open("1-source-files/images/Z.(C)ASFTW.bin", "wb")
output_file.write(data_block)
output_file.close()
