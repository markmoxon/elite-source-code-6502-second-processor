BEEBASM?=beebasm
PYTHON?=python

# Change the release by adding 'release=source-disc' to the make command, e.g.
#
#   make encrypt verify
#
# will build the SNG45 version of 6502SP Elite, while:
#
#   make encrypt verify release=source-disc
#
# will build the version from the source disc

ifeq ($(release), source-disc)
  rel=1
  folder='/source-disc'
else
  rel=2
  folder='/sng45'
endif

.PHONY:build
build:
	echo _REMOVE_CHECKSUMS=TRUE > sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=FALSE >> sources/elite-header.h.asm
	echo _RELEASE=$(rel) >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -u -rel$(rel)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:encrypt
encrypt:
	echo _REMOVE_CHECKSUMS=FALSE > sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/elite-header.h.asm
	echo _RELEASE=$(rel) >> sources/elite-header.h.asm
	$(BEEBASM) -i sources/elite-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/elite-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/elite-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/elite-checksum.py -rel$(rel)
	$(BEEBASM) -i sources/elite-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted$(folder) output
