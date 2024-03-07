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
\ https://www.bbcelite.com/terminology
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

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _SOURCE_DISC           = (_VARIANT = 1)
 _SNG45                 = (_VARIANT = 2)
 _EXECUTIVE             = (_VARIANT = 3)

 GUARD &F800             \ Guard against assembling over MOS memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE% = &1000          \ The address where the main game code file (P.CODE) is
                        \ run in the parasite

 LOAD% = &1000          \ The load address of the main game code file, which is
                        \ the same as the load address as it doesn't get moved
                        \ after loading

\ ******************************************************************************
\
\ Load the compiled binaries to create the Big Code File
\
\ ******************************************************************************

 ORG CODE%

IF _MATCH_ORIGINAL_BINARIES

 IF _SNG45

  EQUB &2E, &20         \ These bytes appear to be unused and just contain
  EQUB &3C, &30         \ random workspace noise left over from the BBC Micro
  EQUB &31, &39         \ assembly process
  EQUB &3E, &57
  EQUB &45, &20
  EQUB &48, &41

 ELIF _EXECUTIVE

  EQUB &2E, &20         \ These bytes appear to be unused and just contain
  EQUB &3C, &30         \ random workspace noise left over from the BBC Micro
  EQUB &31, &39         \ assembly process
  EQUB &3E, &57
  EQUB &45, &20
  EQUB &48, &41
  EQUB &3C, &32

 ELIF _SOURCE_DISC

  EQUB &00, &00
  EQUB &04, &0C         \ random workspace noise left over from the BBC Micro
  EQUB &0F, &00         \ assembly process
  EQUB &00, &00
  EQUB &00, &00
  EQUB &04, &0C

 ENDIF

ELSE

 IF _SNG45

  SKIP 12

 ELIF _EXECUTIVE

  SKIP 14

 ELIF _SOURCE_DISC

  SKIP 12

 ENDIF

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

IF _MATCH_ORIGINAL_BINARIES

 IF _SNG45

  EQUB &A6, &A0, &80, &84, &31, &C8, &84, &30   \ These bytes appear to be
  EQUB &98, &60, &20, &85, &A3, &20, &99, &A6   \ unused and just contain random
  EQUB &D0, &3A, &20, &DA, &A1, &F0, &09, &20   \ workspace noise left over from
  EQUB &1E, &A2, &20, &B5, &A3, &D0, &37, &60   \ the BBC Micro assembly process
  EQUB &4C, &A7, &99, &20, &FA, &92, &20, &D3
  EQUB &A9, &A5, &4A, &48, &20, &E9, &A7, &20
  EQUB &8D, &A3, &E6, &4A, &20, &9E, &A9, &20
  EQUB &E9, &A7, &20, &D6, &A4, &68, &85, &4A
  EQUB &20, &9E, &A9, &20, &E9, &A7, &20, &E7
  EQUB &A6, &A9, &FF, &60, &20, &DA, &A1, &F0
  EQUB &AC, &20, &4E, &A3, &F0, &CA, &A5, &2E
  EQUB &45, &3B, &85, &2E, &38, &A5, &30, &E5
  EQUB &3D, &B0, &03, &C6, &2F, &38, &69, &80
  EQUB &85, &30, &90, &03, &E6, &2F, &18, &A2
  EQUB &20, &B0, &18, &A5, &31, &C5, &3E, &D0
  EQUB &10, &A5, &32, &C5, &3F, &D0, &0A, &A5
  EQUB &33, &C5, &40, &D0, &04, &A5, &34, &C5
  EQUB &41, &90, &19, &A5, &34, &E5, &41, &85
  EQUB &34, &A5, &33, &E5, &40, &85, &33, &A5
  EQUB &32, &E5, &3F, &85, &32, &A5, &31, &E5
  EQUB &3E, &85, &31, &38, &26, &46, &26, &45
  EQUB &26, &44, &26, &43, &06, &34, &26, &33
  EQUB &26, &32, &26, &31, &CA, &D0, &BA, &A2
  EQUB &07, &B0, &18, &A5, &31, &C5, &3E, &D0
  EQUB &10, &A5, &32, &C5, &3F, &D0, &0A, &A5
  EQUB &33, &C5, &40, &D0, &04, &A5, &34, &C5
  EQUB &41, &90, &19, &A5, &34, &E5, &41, &85
  EQUB &34, &A5, &33, &E5, &40, &85, &33, &A5
  EQUB &32, &E5, &3F, &85, &32, &A5, &31, &E5
  EQUB &3E, &85, &31, &38, &26, &35, &06, &34
  EQUB &26, &33, &26, &32

 ELIF _EXECUTIVE

  EQUB &D0, &02, &A9, &6C, &85, &4B, &A9, &04   \ These bytes appear to be
  EQUB &85, &4C, &60, &20, &FA, &92, &20, &DA   \ unused and just contain random
  EQUB &A1, &F0, &02, &10, &0C, &00, &16, &4C   \ workspace noise left over from
  EQUB &6F, &67, &20, &72, &61, &6E, &67, &65   \ the BBC Micro assembly process
  EQUB &00, &20, &53, &A4, &A0, &80, &84, &3B
  EQUB &84, &3E, &C8, &84, &3D, &A6, &30, &F0
  EQUB &06, &A5, &31, &C9, &B5, &90, &02, &E8
  EQUB &88, &8A, &48, &84, &30, &20, &05, &A5
  EQUB &A9, &7B, &20, &87, &A3, &A9, &73, &A0
  EQUB &A8, &20, &97, &A8, &20, &E9, &A7, &20
  EQUB &56, &A6, &20, &56, &A6, &20, &00, &A5
  EQUB &20, &85, &A3, &68, &38, &E9, &81, &20
  EQUB &ED, &A2, &A9, &6E, &85, &4B, &A9, &A8
  EQUB &85, &4C, &20, &56, &A6, &20, &F5, &A7
  EQUB &20, &00, &A5, &A9, &FF, &60, &7F, &5E
  EQUB &5B, &D8, &AA, &80, &31, &72, &17, &F8
  EQUB &06, &7A, &12, &38, &A5, &0B, &88, &79
  EQUB &0E, &9F, &F3, &7C, &2A, &AC, &3F, &B5
  EQUB &86, &34, &01, &A2, &7A, &7F, &63, &8E
  EQUB &37, &EC, &82, &3F, &FF, &FF, &C1, &7F
  EQUB &FF, &FF, &FF, &FF, &85, &4D, &84, &4E
  EQUB &20, &85, &A3, &A0, &00, &B1, &4D, &85
  EQUB &48, &E6, &4D, &D0, &02, &E6, &4E, &A5
  EQUB &4D, &85, &4B, &A5, &4E, &85, &4C, &20
  EQUB &B5, &A3, &20, &F5, &A7, &20, &AD, &A6
  EQUB &18, &A5, &4D, &69, &05, &85, &4D, &85
  EQUB &4B, &A5, &4E, &69, &00, &85, &4E, &85
  EQUB &4C, &20, &00, &A5, &C6, &48, &D0, &E2
  EQUB &60, &20, &DA, &A8, &4C, &27, &A9, &20
  EQUB &FA, &92, &20, &DA, &A1, &10, &08, &46
  EQUB &2E, &20, &EA, &A8

 ELIF _SOURCE_DISC

  EQUB &A7, &99, &20, &FA, &92, &20, &D3, &A9   \ These bytes appear to be
  EQUB &A5, &4A, &48, &20, &E9, &A7, &20, &8D   \ unused and just contain random
  EQUB &A3, &E6, &4A, &20, &9E, &A9, &20, &E9   \ workspace noise left over from
  EQUB &A7, &20, &D6, &A4, &68, &85, &4A, &20   \ the BBC Micro assembly process
  EQUB &9E, &A9, &20, &E9, &A7, &20, &E7, &A6
  EQUB &A9, &FF, &60, &20, &DA, &A1, &F0, &AC
  EQUB &20, &4E, &A3, &F0, &CA, &A5, &2E, &45
  EQUB &3B, &85, &2E, &38, &A5, &30, &E5, &3D
  EQUB &B0, &03, &C6, &2F, &38, &69, &80, &85
  EQUB &30, &90, &03, &E6, &2F, &18, &A2, &20
  EQUB &B0, &18, &A5, &31, &C5, &3E, &D0, &10
  EQUB &A5, &32, &C5, &3F, &D0, &0A, &A5, &33
  EQUB &C5, &40, &D0, &04, &A5, &34, &C5, &41
  EQUB &90, &19, &A5, &34, &E5, &41, &85, &34
  EQUB &A5, &33, &E5, &40, &85, &33, &A5, &32
  EQUB &E5, &3F, &85, &32, &A5, &31, &E5, &3E
  EQUB &85, &31, &38, &26, &46, &26, &45, &26
  EQUB &44, &26, &43, &06, &34, &26, &33, &26
  EQUB &32, &26, &31, &CA, &D0, &BA, &A2, &07
  EQUB &B0, &18, &A5, &31, &C5, &3E, &D0, &10
  EQUB &A5, &32, &C5, &3F, &D0, &0A, &A5, &33
  EQUB &C5, &40, &D0, &04, &A5, &34, &C5, &41
  EQUB &90, &19, &A5, &34, &E5, &41, &85, &34
  EQUB &A5, &33, &E5, &40, &85, &33, &A5, &32
  EQUB &E5, &3F, &85, &32, &A5, &31, &E5, &3E
  EQUB &85, &31, &38, &26, &35, &06, &34, &26
  EQUB &33, &26, &32, &26, &31, &CA, &D0, &C0
  EQUB &06, &35, &A5, &46, &85, &34, &A5, &45
  EQUB &85, &33, &A5, &44, &85, &32, &A5, &43
  EQUB &85, &31, &4C, &59, &A6, &00, &15, &2D
  EQUB &76, &65, &20, &72

 ENDIF

ELSE

 SKIP 244

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
