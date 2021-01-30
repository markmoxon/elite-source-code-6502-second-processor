BEEBASM?=beebasm
PYTHON?=python

# Change the release by adding 'release-6502sp=source-disc' to the make command, e.g.
#
#   make encrypt verify
#
# will build the SNG45 version of 6502SP Elite, while:
#
#   make encrypt verify release-6502sp=source-disc
#
# will build the version from the source disc

ifeq ($(release-6502sp), source-disc)
  rel-6502sp=1
  folder-6502sp='/source-disc'
else
  rel-6502sp=2
  folder-6502sp='/sng45'
endif

.PHONY:build
build:
	echo _VERSION=3 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-6502sp) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=FALSE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -u -rel$(rel-6502sp)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:encrypt
encrypt:
	echo _VERSION=3 > sources/elite-header.h.asm
	echo _RELEASE=$(rel-6502sp) >> sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -rel$(rel-6502sp)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder-6502sp) output
