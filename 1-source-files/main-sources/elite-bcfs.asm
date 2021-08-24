\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE BIG CODE FILE SOURCE
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
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary files:
\
\   * P.CODE.unprot.bin
\
\ after reading in the following files:
\
\   * ELTA.bin
\   * ELTB.bin
\   * ELTC.bin
\   * ELTD.bin
\   * ELTE.bin
\   * ELTF.bin
\   * ELTG.bin
\   * ELTH.bin
\   * ELTI.bin
\   * ELTJ.bin
\   * SHIPS.bin
\   * WORDS.bin
\
\ ******************************************************************************

INCLUDE "1-source-files/main-sources/elite-header.h.asm"

_SOURCE_DISC            = (_RELEASE = 1)
_SNG45                  = (_RELEASE = 2)
_EXECUTIVE              = (_RELEASE = 3)

GUARD &F800             \ Guard against assembling over MOS memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

CODE% = &1000           \ The address where the the main game code file (P.CODE)
                        \ is run in the parasite

LOAD% = &1000           \ The load address of the main game code file, which is
                        \ the same as the load address as it doesn't get moved
                        \ after loading

\ ******************************************************************************
\
\ Load the compiled binaries to create the Big Code File
\
\ ******************************************************************************

ORG CODE%

IF _SNG45
 INCBIN "4-reference-binaries/sng45/workspaces/BCFS-MOS.bin"
ELIF _EXECUTIVE
 INCBIN "4-reference-binaries/executive/workspaces/BCFS-MOS.bin"
ELIF _SOURCE_DISC
 INCBIN "4-reference-binaries/source-disc/workspaces/BCFS-MOS.bin"
ENDIF

.elitea

PRINT "elitea = ", ~P%
INCBIN "3-assembled-output/ELTA.bin"

.eliteb

PRINT "eliteb = ", ~P%
INCBIN "3-assembled-output/ELTB.bin"

.elitec

PRINT "elitec = ", ~P%
INCBIN "3-assembled-output/ELTC.bin"

.elited

PRINT "elited = ", ~P%
INCBIN "3-assembled-output/ELTD.bin"

.elitee

PRINT "elitee = ", ~P%
INCBIN "3-assembled-output/ELTE.bin"

.elitef

PRINT "elitef = ", ~P%
INCBIN "3-assembled-output/ELTF.bin"

.eliteg

PRINT "eliteg = ", ~P%
INCBIN "3-assembled-output/ELTG.bin"

.eliteh

PRINT "eliteh = ", ~P%
INCBIN "3-assembled-output/ELTH.bin"

.elitei

PRINT "elitei = ", ~P%
INCBIN "3-assembled-output/ELTI.bin"

.elitej

PRINT "elitej = ", ~P%
INCBIN "3-assembled-output/ELTJ.bin"

F% = P%
PRINT "F% = ", ~F%
PRINT "P% = ", ~P%

.words

PRINT "words = ", ~P%
INCBIN "3-assembled-output/WORDS.bin"

.ships

PRINT "ships = ", ~P%
INCBIN "3-assembled-output/SHIPS.bin"

IF _SNG45
 INCBIN "4-reference-binaries/sng45/workspaces/BCFS-SHIPS.bin"
ELIF _EXECUTIVE
 INCBIN "4-reference-binaries/executive/workspaces/BCFS-SHIPS.bin"
ELIF _SOURCE_DISC
 INCBIN "4-reference-binaries/source-disc/workspaces/BCFS-SHIPS.bin"
ENDIF

.end

\ ******************************************************************************
\
\ Save P.CODE.unprot.bin
\
\ ******************************************************************************

PRINT "P% = ", ~P%
PRINT "S.P.CODE ", ~LOAD%, ~(F% + &0400 + &2200), " ", ~LOAD%, ~LOAD%
SAVE "3-assembled-output/P.CODE.unprot.bin", CODE%, (F% + &0400 + &2200), LOAD%
