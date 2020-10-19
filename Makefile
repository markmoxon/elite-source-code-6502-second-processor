BEEBASM?=beebasm
PYTHON?=python

.PHONY:build
build:
	echo _REMOVE_CHECKSUMS=TRUE > sources/6502sp-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=FALSE >> sources/6502sp-header.h.asm
	$(BEEBASM) -i sources/6502sp-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/6502sp-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/6502sp-checksum.py -u
	$(BEEBASM) -i sources/6502sp-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:encrypt
encrypt:
	echo _REMOVE_CHECKSUMS=FALSE > sources/6502sp-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/6502sp-header.h.asm
	$(BEEBASM) -i sources/6502sp-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/6502sp-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/6502sp-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/6502sp-checksum.py
	$(BEEBASM) -i sources/6502sp-disc.asm -do elite-6502sp.ssd -boot ELITE

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted output
