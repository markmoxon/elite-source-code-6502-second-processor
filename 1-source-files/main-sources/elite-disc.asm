\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE DISC IMAGE SCRIPT
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code on this site is identical to the source discs released on Ian Bell's
\ personal website at http://www.elitehomepage.org/ (it's just been reformatted
\ to be more readable)
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces one of the following SSD disc images, depending on
\ which release is being built:
\
\   * elite-6502sp-sng45.ssd
\   * elite-6502sp-from-source-disc.ssd
\   * elite-6502sp-executive.ssd
\
\ This can be loaded into an emulator or a real BBC Micro.
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _SOURCE_DISC           = (_VARIANT = 1)
 _SNG45                 = (_VARIANT = 2)
 _EXECUTIVE             = (_VARIANT = 3)

IF _SNG45 OR _EXECUTIVE
 PUTFILE "3-assembled-output/ELITE.bin", "ELITE", &FF1FDC, &FF2085
ELIF _SOURCE_DISC
 PUTFILE "3-assembled-output/ELITE.bin", "ELITE", &FF2000, &FF2085
ENDIF

 PUTFILE "3-assembled-output/ELITEa.bin", "I.ELITEa", &FF2000, &FF2000

\ Load and execution addresses for I.CODE changed for anaglyph 3D

IF _SNG45 OR _SOURCE_DISC
 PUTFILE "3-assembled-output/I.CODE.bin", "I.CODE", &FF2300, &FF2B89
ELIF _EXECUTIVE
 PUTFILE "3-assembled-output/I.CODE.bin", "I.CODE", &032400, &032C89
ENDIF

\ Load and execution addresses for P.CODE changed for anaglyph 3D

PUTFILE "3-assembled-output/P.CODE.bin", "P.CODE", &000E20, &001065

IF _SNG45
 PUTFILE "1-source-files/boot-files/$.!BOOT.bin", "!BOOT", &002000, &00202B
 PUTFILE "1-source-files/boot-files/$.SCREEN.bin", "SCREEN", &FF7C00, &000000
ENDIF

 PUTFILE "3-assembled-output/README.txt", "README", &FFFFFF, &FFFFFF

 PUTFILE "1-source-files/universe-files/U.BOXART1.bin", "U.BOXART1", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.BOXART2.bin", "U.BOXART2", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.MANUAL.bin", "U.MANUAL", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.SHIPID.bin", "U.SHIPID", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.SHIPID6.bin", "U.SHIPID6", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.VIPERS.bin", "U.VIPERS", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.SPIRAL.bin", "U.SPIRAL", &000000, &000000
 PUTFILE "1-source-files/universe-files/U.PLANE.bin", "U.PLANE", &000000, &000000

 PUTFILE "1-source-files/other-files/E.MAX.bin", "E.MAX", &000000, &000000
 PUTFILE "1-source-files/other-files/E.MISS1.bin", "E.MISS1", &000000, &000000
 PUTFILE "1-source-files/other-files/E.MISS2.bin", "E.MISS2", &000000, &000000
 PUTFILE "1-source-files/other-files/E.FIGHT.bin", "E.FIGHT", &000000, &000000
