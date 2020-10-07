BEEBASM?=beebasm
PYTHON?=python

.PHONY:build
build:
	echo _REMOVE_CHECKSUMS=TRUE > sources/tube-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=FALSE >> sources/tube-header.h.asm
	$(BEEBASM) -i sources/tube-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/tube-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/tube-checksum.py -u
	$(BEEBASM) -i sources/tube-disc.asm -do elite-tube.ssd -boot ELITE

.PHONY:encrypt
encrypt:
	echo _REMOVE_CHECKSUMS=FALSE > sources/tube-header.h.asm
	echo _MATCH_EXTRACTED_BINARIES=TRUE >> sources/tube-header.h.asm
	$(BEEBASM) -i sources/tube-source.asm -v > output/compile.txt
	$(BEEBASM) -i sources/tube-bcfs.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-z.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-loader1.asm -v >> output/compile.txt
	$(BEEBASM) -i sources/tube-loader2.asm -v >> output/compile.txt
	$(PYTHON) sources/tube-checksum.py
	$(BEEBASM) -i sources/tube-disc.asm -do elite-tube.ssd -boot ELITE

.PHONY:verify
verify:
	@$(PYTHON) sources/crc32.py extracted output
