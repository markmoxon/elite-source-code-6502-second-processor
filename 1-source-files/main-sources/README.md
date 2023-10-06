# Annotated source code for the 6502 Second Processor version of Elite

This folder contains the annotated source code for the 6502 Second Processor version of Elite.

* Main source files:

  * [elite-source.asm](elite-source.asm) contains the main source for the game, which runs on the parasite

  * [elite-z.asm](elite-z.asm) contains the main source for the I/O processor

  * [elite-bcfs.asm](elite-bcfs.asm) contains the Big Code File source, which concatenates individually assembled binaries into the final game binary

* Other source files:

  * [elite-loader1.asm](elite-loader1.asm) contains the source for the first stage of the loader

  * [elite-loader2.asm](elite-loader2.asm) contains the source for the second stage of the loader

  * [elite-checksum.asm](elite-checksum.asm) contains 6502 source code for the checksum routines that are implemented in the elite-checksum.py script (and which were implemented by the S.PCODES BBC BASIC program in the original source discs); this file is purely for reference and is not used in the build process

  * [elite-disc.asm](elite-disc.asm) builds the SSD disc image from the assembled binaries and other source files

  * [elite-readme.asm](elite-readme.asm) generates a README file for inclusion on the SSD disc image

* Files that are generated during the build process:

  * [elite-build-options.asm](elite-build-options.asm) stores the make options in BeebAsm format so they can be included in the assembly process

---

Right on, Commanders!

_Mark Moxon_