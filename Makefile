BEEBASM?=beebasm
PYTHON?=python

# You can set the release that gets built by adding 'release=<rel>' to
# the make command, where <rel> is one of:
#
#   source-disc
#   sng45
#   executive
#
# So, for example:
#
#   make encrypt verify release=executive
#
# will build the Executive version. If you omit the release parameter,
# it will build the SNG45 version.

ifeq ($(release), source-disc)
  rel-6502sp=1
  folder-6502sp=/source-disc
  suffix-6502sp=-from-source-disc
else ifeq ($(release), executive)
  rel-6502sp=3
  folder-6502sp=/executive
  suffix-6502sp=-executive
else
  rel-6502sp=2
  folder-6502sp=/sng45
  suffix-6502sp=-sng45
endif

.PHONY:build
build:
	echo _VERSION=3 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-6502sp) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> 1-source-files/main-sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=FALSE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-z.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader1.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader2.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -u -rel$(rel-6502sp)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-6502sp$(suffix-6502sp).ssd -boot ELITE -title "E L I T E"

.PHONY:encrypt
encrypt:
	echo _VERSION=3 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-6502sp) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> 1-source-files/main-sources/elite-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-z.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader1.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader2.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -rel$(rel-6502sp)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-6502sp$(suffix-6502sp).ssd -boot ELITE -title "E L I T E"

.PHONY:verify
verify:
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries$(folder-6502sp) 3-assembled-output
