\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE GAME SOURCE (I/O PROCESSOR)
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
\ This source file produces the following binary file:
\
\   * I.CODE.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _SOURCE_DISC           = (_VARIANT = 1)
 _SNG45                 = (_VARIANT = 2)
 _EXECUTIVE             = (_VARIANT = 3)

 GUARD &4000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\CODE% = &2400          \ The assembly address of the main I/O processor code
\
\LOAD% = &2400          \ The load address of the main I/O processor code

                        \ --- And replaced by: -------------------------------->

 CODE% = &2300          \ The assembly address of the main I/O processor code

 LOAD% = &2300          \ The load address of the main I/O processor code

                        \ --- End of replacement ------------------------------>

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 MAX_PARALLAX_P = 1     \ The maximum number of pixels that we apply for
                        \ positive parallax (distant objects)

 MAX_PARALLAX_N = 2     \ The maximum number of pixels that we apply to each eye
                        \ for negative parallax (nearby objects)

                        \ --- End of added code ------------------------------->

                        \ --- Mod: Code added for speed control: -------------->

 SPEED = 3              \ The minimum number of vertical syncs we want to spend
                        \ in the main flight loop (there are 50 per second)
                        \
                        \ Higher figure = slower game speed

                        \ --- End of added code ------------------------------->

 VSCAN = 57             \ Defines the split position in the split-screen mode

 Y = 96                 \ The centre y-coordinate of the 256 x 192 space view

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\YELLOW  = %00001111    \ Four mode 1 pixels of colour 1 (yellow)
\
\RED     = %11110000    \ Four mode 1 pixels of colour 2 (red, magenta or white)
\
\CYAN    = %11111111    \ Four mode 1 pixels of colour 3 (cyan or white)
\
\GREEN   = %10101111    \ Four mode 1 pixels of colour 3, 1, 3, 1 (cyan/yellow)
\
\WHITE   = %11111010    \ Four mode 1 pixels of colour 3, 2, 3, 2 (cyan/red)
\
\MAGENTA = RED          \ Four mode 1 pixels of colour 2 (red, magenta or white)
\
\DUST    = WHITE        \ Four mode 1 pixels of colour 3, 2, 3, 2 (cyan/red)
\
\RED2    = %00000011    \ Two mode 2 pixels of colour 1    (red)
\
\GREEN2  = %00001100    \ Two mode 2 pixels of colour 2    (green)
\
\YELLOW2 = %00001111    \ Two mode 2 pixels of colour 3    (yellow)
\
\BLUE2   = %00110000    \ Two mode 2 pixels of colour 4    (blue)
\
\MAG2    = %00110011    \ Two mode 2 pixels of colour 5    (magenta)
\
\CYAN2   = %00111100    \ Two mode 2 pixels of colour 6    (cyan)
\
\WHITE2  = %00111111    \ Two mode 2 pixels of colour 7    (white)
\
\STRIPE  = %00100011    \ Two mode 2 pixels of colour 5, 1 (magenta/red)

                        \ --- And replaced by: -------------------------------->

 CYAN_3D = %00001111    \ Four mode 1 pixels of colour 1 (cyan)

 RED_3D  = %11110000    \ Four mode 1 pixels of colour 2 (red)

 WHITE_3D = %11111111   \ Four mode 1 pixels of colour 3 (white)

 CYAN2_3D = %00000011   \ Two mode 2 pixels of colour 1 (cyan)

 RED2_3D  = %00001100   \ Two mode 2 pixels of colour 2 (red)

 YELLOW  = %11111111    \ Set all non-3D colours to white
 RED     = %11111111
 CYAN    = %11111111
 GREEN   = %11111111
 WHITE   = %11111111
 MAGENTA = %11111111
 DUST    = %11111111
 RED2    = %11111111
 GREEN2  = %11111111
 YELLOW2 = %11111111
 BLUE2   = %11111111
 MAG2    = %11111111
 CYAN2   = %11111111
 WHITE2  = %11111111
 STRIPE  = %11111111

 RED2_M    = %00000011  \ Red identifier for missiles

 YELLOW2_M = %00001111  \ Yellow identifier for missiles

                        \ --- End of replacement ------------------------------>

 PARMAX = 15            \ The number of dashboard parameters transmitted with
                        \ the #RDPARAMS and OSWRCH 137 <param> commands

 IRQ1V = &0204          \ The IRQ1V vector that we intercept to implement the
                        \ split-screen mode

 WRCHV = &020E          \ The WRCHV vector that we intercept to implement our
                        \ own custom OSWRCH commands for communicating over the
                        \ Tube

 WORDV = &020C          \ The WORDV vector that we intercept to implement our
                        \ own custom OSWORD commands for communicating over the
                        \ Tube

 RDCHV = &0210          \ The RDCHV vector that we intercept to add validation
                        \ when reading characters using OSRDCH

 VIA = &FE00            \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

 NVOSWRCH = &FFCB       \ The address for the non-vectored OSWRCH routine

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

 OSWORD = &FFF1         \ The address for the OSWORD routine

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0080 to &0089
\   Category: Workspaces
\    Summary: Important variables used by the I/O processor
\
\ ******************************************************************************

 ORG &0080

.ZP

 SKIP 0                 \ The start of the zero page workspace

.P

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

.T1

 SKIP 1                 \ Temporary storage, used in a number of places

.COL

 SKIP 1                 \ Temporary storage, used to store colour information
                        \ when drawing pixels in the dashboard

.OSSC

 SKIP 2                 \ When the parasite sends an OSWORD command to the I/O
                        \ processor (i.e. an OSWORD with A = 240 to 255), then
                        \ the relevant handler routine in the I/O processor is
                        \ called with OSSC(1 0) pointing to the OSWORD parameter
                        \ block (i.e. OSSC(1 0) = (Y X) from the original call
                        \ in the I/O processor)

                        \ --- Mod: Code added for speed control: -------------->

.syncCounter

 SKIP 1                 \ A counter for vertical syncs, so we can control the
                        \ speed of the main flight loop independently of the
                        \ delay mechanism

                        \ --- End of added code ------------------------------->

 ORG &0090

.XX15

 SKIP 0                 \ Temporary storage, typically used for storing screen
                        \ coordinates in line-drawing routines
                        \
                        \ There are six bytes of storage, from XX15 TO XX15+5.
                        \ The first four bytes have the following aliases:
                        \
                        \   X1 = XX15
                        \   Y1 = XX15+1
                        \   X2 = XX15+2
                        \   Y2 = XX15+3
                        \
                        \ These are typically used for describing lines in terms
                        \ of screen coordinates, i.e. (X1, Y1) to (X2, Y2)
                        \
                        \ The last two bytes of XX15 do not have aliases

.X1

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y1

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

 SKIP 2                 \ The last 2 bytes of the XX15 block

.SC

 SKIP 1                 \ Screen address (low byte)
                        \
                        \ Elite draws on-screen by poking bytes directly into
                        \ screen memory, and SC(1 0) is typically set to the
                        \ address of the character block containing the pixel
                        \ we want to draw

.SCH

 SKIP 1                 \ Screen address (high byte)

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.V

 SKIP 1                 \ Temporary storage

.xCoreStart

 SKIP 1                 \ The x-coordinate of the left end of the white part of
                        \ the sun line being drawn in HLOIN

.xCoreEnd

 SKIP 1                 \ The x-coordinate of the right end of the white part of
                        \ the sun line being drawn in HLOIN

.xLeftStart

 SKIP 1                 \ The x-coordinate of the start of the left fringe

.xLeftEnd

 SKIP 1                 \ The x-coordinate of the end of the left fringe

.xRightStart

 SKIP 1                 \ The x-coordinate of the start of the left fringe

.xRightEnd

 SKIP 1                 \ The x-coordinate of the end of the left fringe

.xCoreStartNew

 SKIP 1                 \ The x-coordinate of the left end of the white part of
                        \ the sun line being drawn in HLOIN

.xCoreEndNew

 SKIP 1                 \ The x-coordinate of the right end of the white part of
                        \ the sun line being drawn in HLOIN

.xLeftStartNew

 SKIP 1                 \ The x-coordinate of the start of the left fringe

.xLeftEndNew

 SKIP 1                 \ The x-coordinate of the end of the left fringe

.xRightStartNew

 SKIP 1                 \ The x-coordinate of the start of the left fringe

.xRightEndNew

 SKIP 1                 \ The x-coordinate of the end of the left fringe

.xStart

 SKIP 1                 \ The start x-coordinate for a sun line

.xEnd

 SKIP 1                 \ The end x-coordinate for a sun line

.twoStageLine

 SKIP 1                 \ A flag to determine if this is a two-stage line
                        \
                        \ * 255 = this is a two-stage line
                        \
                        \ * Other value = this is not a two-stage line

.Tr

 SKIP 1                 \ The right-eye parallax value in the pixel routines

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: TINA
\       Type: Workspace
\    Address: &0B00-&0BFF
\   Category: Workspaces
\    Summary: The code block for the TINA hook
\  Deep dive: The TINA hook
\
\ ------------------------------------------------------------------------------
\
\ To use the TINA hook, this workspace should start with "TINA" and then be
\ followed by code that executes on the I/O processor before the main game code
\ terminates.
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   TINA+4              The code to run if the TINA hook is enabled
\
\ ******************************************************************************

 ORG &0B00

.TINA

 SKIP 4

\ ******************************************************************************
\
\       Name: TABLE
\       Type: Variable
\   Category: Drawing lines
\    Summary: The line buffer for line data transmitted from the parasite
\
\ ------------------------------------------------------------------------------
\
\ Lines are drawn by sending the line coordinates one byte at a time from the
\ parasite, using the OSWRCH 129 and 130 commands. As they are sent, they are
\ stored in the TABLE buffer, until all the points have been received, at which
\ point the line is drawn.
\
\ LINTAB points to the offset of the first free byte within TABLE, so the table
\ can be reset by setting LINTAB to 0.
\
\ ******************************************************************************

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\ORG &2300

                        \ --- And replaced by: -------------------------------->

 ORG &2200

                        \ --- End of replacement ------------------------------>

.TABLE

 SKIP 256

\ ******************************************************************************
\
\       Name: FONT%
\       Type: Variable
\   Category: Text
\    Summary: A copy of the character definition bitmap table from the MOS ROM
\
\ ------------------------------------------------------------------------------
\
\ This is used by the TT26 routine to save time looking up the character bitmaps
\ from the ROM. Note that FONT% contains just the high byte (i.e. the page
\ number) of the address of this table, rather than the full address.
\
\ The contents of the P.FONT.bin file included here are taken straight from the
\ following three pages in the BBC Micro OS 1.20 ROM:
\
\   ASCII 32-63  are defined in &C000-&C0FF (page 0)
\   ASCII 64-95  are defined in &C100-&C1FF (page 1)
\   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
\
\ The code could look these values up each time (as the cassette version does),
\ but it's quicker to use a lookup table, at the expense of three pages of
\ memory.
\
\ The Executive version uses a different font to the standard OS, which is
\ included in the P.FONTEX.bin file. This means all in-game text uses this new
\ font, which is based on the 1960s Westminster font. The font style is similar
\ to the machine-readable font on cheques, and is in a style that we would now
\ call "retro-futuristic" (though presumably it was just "futuristic" back in
\ 1984).
\
\ ******************************************************************************

 ORG CODE%

 FONT% = P% DIV 256

IF _SNG45 OR _SOURCE_DISC
 INCBIN "1-source-files/fonts/P.FONT.bin"
ELIF _EXECUTIVE
 INCBIN "1-source-files/fonts/P.FONTEX.bin"
ENDIF

\ ******************************************************************************
\
\       Name: log
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: Binary logarithm table (high byte)
\
\ ------------------------------------------------------------------------------
\
\ At byte n, the table contains the high byte of:
\
\   &2000 * log10(n) / log10(2) = 32 * 256 * log10(n) / log10(2)
\
\ where log10 is the logarithm to base 10. The change-of-base formula says that:
\
\   log2(n) = log10(n) / log10(2)
\
\ so byte n contains the high byte of:
\
\   32 * log2(n) * 256
\
\ ******************************************************************************

.log

IF _MATCH_ORIGINAL_BINARIES

 IF _SNG45

  EQUB &18              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ELIF _EXECUTIVE

  EQUB &FF              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ELIF _SOURCE_DISC

  EQUB &8E              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ENDIF

 EQUB &00, &20, &32, &40, &4A, &52, &59
 EQUB &5F, &65, &6A, &6E, &72, &76, &79, &7D
 EQUB &80, &82, &85, &87, &8A, &8C, &8E, &90
 EQUB &92, &94, &96, &98, &99, &9B, &9D, &9E
 EQUB &A0, &A1, &A2, &A4, &A5, &A6, &A7, &A9
 EQUB &AA, &AB, &AC, &AD, &AE, &AF, &B0, &B1
 EQUB &B2, &B3, &B4, &B5, &B6, &B7, &B8, &B9
 EQUB &B9, &BA, &BB, &BC, &BD, &BD, &BE, &BF
 EQUB &BF, &C0, &C1, &C2, &C2, &C3, &C4, &C4
 EQUB &C5, &C6, &C6, &C7, &C7, &C8, &C9, &C9
 EQUB &CA, &CA, &CB, &CC, &CC, &CD, &CD, &CE
 EQUB &CE, &CF, &CF, &D0, &D0, &D1, &D1, &D2
 EQUB &D2, &D3, &D3, &D4, &D4, &D5, &D5, &D5
 EQUB &D6, &D6, &D7, &D7, &D8, &D8, &D9, &D9
 EQUB &D9, &DA, &DA, &DB, &DB, &DB, &DC, &DC
 EQUB &DD, &DD, &DD, &DE, &DE, &DE, &DF, &DF
 EQUB &E0, &E0, &E0, &E1, &E1, &E1, &E2, &E2
 EQUB &E2, &E3, &E3, &E3, &E4, &E4, &E4, &E5
 EQUB &E5, &E5, &E6, &E6, &E6, &E7, &E7, &E7
 EQUB &E7, &E8, &E8, &E8, &E9, &E9, &E9, &EA
 EQUB &EA, &EA, &EA, &EB, &EB, &EB, &EC, &EC
 EQUB &EC, &EC, &ED, &ED, &ED, &ED, &EE, &EE
 EQUB &EE, &EE, &EF, &EF, &EF, &EF, &F0, &F0
 EQUB &F0, &F1, &F1, &F1, &F1, &F1, &F2, &F2
 EQUB &F2, &F2, &F3, &F3, &F3, &F3, &F4, &F4
 EQUB &F4, &F4, &F5, &F5, &F5, &F5, &F5, &F6
 EQUB &F6, &F6, &F6, &F7, &F7, &F7, &F7, &F7
 EQUB &F8, &F8, &F8, &F8, &F9, &F9, &F9, &F9
 EQUB &F9, &FA, &FA, &FA, &FA, &FA, &FB, &FB
 EQUB &FB, &FB, &FB, &FC, &FC, &FC, &FC, &FC
 EQUB &FD, &FD, &FD, &FD, &FD, &FD, &FE, &FE
 EQUB &FE, &FE, &FE, &FF, &FF, &FF, &FF, &FF

ELSE

 SKIP 1

 FOR I%, 1, 255

  EQUB INT(&2000 * LOG(I%) / LOG(2) + 0.5) DIV 256

 NEXT

ENDIF

\ ******************************************************************************
\
\       Name: logL
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: Binary logarithm table (low byte)
\
\ ------------------------------------------------------------------------------
\
\ At byte n, the table contains the high byte of:
\
\   &2000 * log10(n) / log10(2) = 32 * 256 * log10(n) / log10(2)
\
\ where log10 is the logarithm to base 10. The change-of-base formula says that:
\
\   log2(n) = log10(n) / log10(2)
\
\ so byte n contains the low byte of:
\
\   32 * log2(n) * 256
\
\ ******************************************************************************

.logL

IF _MATCH_ORIGINAL_BINARIES

 IF _SNG45

  EQUB &86              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ELIF _EXECUTIVE

  EQUB &FF              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ELIF _SOURCE_DISC

  EQUB &00              \ This byte appears to be unused and just contains
                        \ random workspace noise left over from the BBC Micro
                        \ assembly process

 ENDIF

 EQUB &00, &00, &B8, &00, &4D, &B8, &D5
 EQUB &FF, &70, &4D, &B3, &B8, &6A, &D5, &05
 EQUB &00, &CC, &70, &EF, &4D, &8D, &B3, &C1
 EQUB &B8, &9A, &6A, &28, &D5, &74, &05, &88
 EQUB &00, &6B, &CC, &23, &70, &B3, &EF, &22
 EQUB &4D, &71, &8D, &A3, &B3, &BD, &C1, &BF
 EQUB &B8, &AB, &9A, &84, &6A, &4B, &28, &00
 EQUB &D5, &A7, &74, &3E, &05, &C8, &88, &45
 EQUB &FF, &B7, &6B, &1D, &CC, &79, &23, &CA
 EQUB &70, &13, &B3, &52, &EF, &89, &22, &B8
 EQUB &4D, &E0, &71, &00, &8D, &19, &A3, &2C
 EQUB &B3, &39, &BD, &3F, &C1, &40, &BF, &3C
 EQUB &B8, &32, &AB, &23, &9A, &10, &84, &F7
 EQUB &6A, &DB, &4B, &BA, &28, &94, &00, &6B
 EQUB &D5, &3E, &A7, &0E, &74, &DA, &3E, &A2
 EQUB &05, &67, &C8, &29, &88, &E7, &45, &A3
 EQUB &00, &5B, &B7, &11, &6B, &C4, &1D, &75
 EQUB &CC, &23, &79, &CE, &23, &77, &CA, &1D
 EQUB &70, &C1, &13, &63, &B3, &03, &52, &A1
 EQUB &EF, &3C, &89, &D6, &22, &6D, &B8, &03
 EQUB &4D, &96, &E0, &28, &71, &B8, &00, &47
 EQUB &8D, &D4, &19, &5F, &A3, &E8, &2C, &70
 EQUB &B3, &F6, &39, &7B, &BD, &FE, &3F, &80
 EQUB &C1, &01, &40, &80, &BF, &FD, &3C, &7A
 EQUB &B8, &F5, &32, &6F, &AB, &E7, &23, &5F
 EQUB &9A, &D5, &10, &4A, &84, &BE, &F7, &31
 EQUB &6A, &A2, &DB, &13, &4B, &82, &BA, &F1
 EQUB &28, &5E, &94, &CB, &00, &36, &6B, &A0
 EQUB &D5, &0A, &3E, &73, &A7, &DA, &0E, &41
 EQUB &74, &A7, &DA, &0C, &3E, &70, &A2, &D3
 EQUB &05, &36, &67, &98, &C8, &F8, &29, &59
 EQUB &88, &B8, &E7, &16, &45, &74, &A3, &D1

ELSE

 SKIP 1

 FOR I%, 1, 255

  EQUB INT(&2000 * LOG(I%) / LOG(2) + 0.5) MOD 256

 NEXT

ENDIF

\ ******************************************************************************
\
\       Name: antilog
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: Binary antilogarithm table
\
\ ------------------------------------------------------------------------------
\
\ At byte n, the table contains:
\
\   2^((n / 2 + 128) / 16) / 256
\
\ which equals:
\
\   2^(n / 32 + 8) / 256
\
\ ******************************************************************************

.antilog

IF _MATCH_ORIGINAL_BINARIES

 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &02, &02, &02, &02, &02, &02, &02, &02
 EQUB &02, &02, &02, &02, &02, &02, &02, &02
 EQUB &02, &02, &02, &03, &03, &03, &03, &03
 EQUB &03, &03, &03, &03, &03, &03, &03, &03
 EQUB &04, &04, &04, &04, &04, &04, &04, &04
 EQUB &04, &04, &04, &05, &05, &05, &05, &05
 EQUB &05, &05, &05, &06, &06, &06, &06, &06
 EQUB &06, &06, &07, &07, &07, &07, &07, &07
 EQUB &08, &08, &08, &08, &08, &08, &09, &09
 EQUB &09, &09, &09, &0A, &0A, &0A, &0A, &0B
 EQUB &0B, &0B, &0B, &0C, &0C, &0C, &0C, &0D
 EQUB &0D, &0D, &0E, &0E, &0E, &0E, &0F, &0F
 EQUB &10, &10, &10, &11, &11, &11, &12, &12
 EQUB &13, &13, &13, &14, &14, &15, &15, &16
 EQUB &16, &17, &17, &18, &18, &19, &19, &1A
 EQUB &1A, &1B, &1C, &1C, &1D, &1D, &1E, &1F
 EQUB &20, &20, &21, &22, &22, &23, &24, &25
 EQUB &26, &26, &27, &28, &29, &2A, &2B, &2C
 EQUB &2D, &2E, &2F, &30, &31, &32, &33, &34
 EQUB &35, &36, &38, &39, &3A, &3B, &3D, &3E
 EQUB &40, &41, &42, &44, &45, &47, &48, &4A
 EQUB &4C, &4D, &4F, &51, &52, &54, &56, &58
 EQUB &5A, &5C, &5E, &60, &62, &64, &67, &69
 EQUB &6B, &6D, &70, &72, &75, &77, &7A, &7D
 EQUB &80, &82, &85, &88, &8B, &8E, &91, &94
 EQUB &98, &9B, &9E, &A2, &A5, &A9, &AD, &B1
 EQUB &B5, &B8, &BD, &C1, &C5, &C9, &CE, &D2
 EQUB &D7, &DB, &E0, &E5, &EA, &EF, &F5, &FA

ELSE

 FOR I%, 0, 255

  EQUB INT(2^((I% / 2 + 128) / 16) + 0.5) DIV 256

 NEXT

ENDIF

\ ******************************************************************************
\
\       Name: antilogODD
\       Type: Variable
\   Category: Maths (Arithmetic)
\    Summary: Binary antilogarithm table
\
\ ------------------------------------------------------------------------------
\
\ At byte n, the table contains:
\
\   2^((n / 2 + 128.25) / 16) / 256
\
\ which equals:
\
\   2^(n / 32 + 8.015625) / 256 = 2^(n / 32 + 8) * 2^(.015625) / 256
\                               = (2^(n / 32 + 8) + 1) / 256
\
\ ******************************************************************************

.antilogODD

IF _MATCH_ORIGINAL_BINARIES

 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &01, &01, &01, &01, &01, &01, &01, &01
 EQUB &02, &02, &02, &02, &02, &02, &02, &02
 EQUB &02, &02, &02, &02, &02, &02, &02, &02
 EQUB &02, &02, &02, &03, &03, &03, &03, &03
 EQUB &03, &03, &03, &03, &03, &03, &03, &03
 EQUB &04, &04, &04, &04, &04, &04, &04, &04
 EQUB &04, &04, &05, &05, &05, &05, &05, &05
 EQUB &05, &05, &05, &06, &06, &06, &06, &06
 EQUB &06, &06, &07, &07, &07, &07, &07, &07
 EQUB &08, &08, &08, &08, &08, &09, &09, &09
 EQUB &09, &09, &0A, &0A, &0A, &0A, &0A, &0B
 EQUB &0B, &0B, &0B, &0C, &0C, &0C, &0D, &0D
 EQUB &0D, &0D, &0E, &0E, &0E, &0F, &0F, &0F
 EQUB &10, &10, &10, &11, &11, &12, &12, &12
 EQUB &13, &13, &14, &14, &14, &15, &15, &16
 EQUB &16, &17, &17, &18, &18, &19, &1A, &1A
 EQUB &1B, &1B, &1C, &1D, &1D, &1E, &1E, &1F
 EQUB &20, &21, &21, &22, &23, &24, &24, &25
 EQUB &26, &27, &28, &29, &29, &2A, &2B, &2C
 EQUB &2D, &2E, &2F, &30, &31, &32, &34, &35
 EQUB &36, &37, &38, &3A, &3B, &3C, &3D, &3F
 EQUB &40, &42, &43, &45, &46, &48, &49, &4B
 EQUB &4C, &4E, &50, &52, &53, &55, &57, &59
 EQUB &5B, &5D, &5F, &61, &63, &65, &68, &6A
 EQUB &6C, &6F, &71, &74, &76, &79, &7B, &7E
 EQUB &81, &84, &87, &8A, &8D, &90, &93, &96
 EQUB &99, &9D, &A0, &A4, &A7, &AB, &AF, &B3
 EQUB &B6, &BA, &BF, &C3, &C7, &CB, &D0, &D4
 EQUB &D9, &DE, &E3, &E8, &ED, &F2, &F7, &FD

ELSE

 FOR I%, 0, 255

  EQUB INT(2^((I% / 2 + 128.25) / 16) + 0.5) DIV 256

 NEXT

ENDIF

\ ******************************************************************************
\
\       Name: ylookup
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Lookup table for converting pixel y-coordinate to page number of
\             screen address
\
\ ------------------------------------------------------------------------------
\
\ Elite's screen mode is based on mode 1, so it allocates two pages of screen
\ memory to each character row (where a character row is 8 pixels high). This
\ table enables us to convert a pixel y-coordinate in the range 0-247 into the
\ page number for the start of the character row containing that coordinate.
\
\ Screen memory is from &4000 to &7DFF, so the lookup works like this:
\
\   Y =   0 to  7,  lookup value = &40 (so row 1 is from &4000 to &41FF)
\   Y =   8 to 15,  lookup value = &42 (so row 2 is from &4200 to &43FF)
\   Y =  16 to 23,  lookup value = &44 (so row 3 is from &4400 to &45FF)
\   Y =  24 to 31,  lookup value = &46 (so row 4 is from &4600 to &47FF)
\
\   ...
\
\   Y = 232 to 239, lookup value = &7A (so row 31 is from &7A00 to &7BFF)
\   Y = 240 to 247, lookup value = &7C (so row 32 is from &7C00 to &7DFF)
\
\ There is also a lookup value for y-coordinates from 248 to 255, but that's off
\ the end of the screen, as the special Elite screen mode only has 31 character
\ rows.
\
\ ******************************************************************************

.ylookup

 FOR I%, 0, 255

  EQUB &40 + ((I% DIV 8) * 2)

 NEXT

\ ******************************************************************************
\
\       Name: TVT3
\       Type: Variable
\   Category: Drawing the screen
\    Summary: Palette data for the mode 1 part of the screen (the top part)
\
\ ------------------------------------------------------------------------------
\
\ The following table contains four different mode 1 palettes, each of which
\ sets a four-colour palette for the top part of the screen. Mode 1 supports
\ four colours on-screen and in Elite colour 0 is always set to black, so each
\ of the palettes in this table defines the three other colours (1 to 3).
\
\ There is some consistency between the palettes:
\
\   * Colour 0 is always black
\   * Colour 1 (#YELLOW) is always yellow
\   * Colour 2 (#RED) is normally red-like (i.e. red or magenta)
\              ... except in the title screen palette, when it is white
\   * Colour 3 (#CYAN) is always cyan-like (i.e. white or cyan)
\
\ The configuration variables of #YELLOW, #RED and #CYAN are a bit misleading,
\ but if you think of them in terms of hue rather than specific colours, they
\ work reasonably well (outside of the title screen palette, anyway).
\
\ The palettes are set in the IRQ1 handler that implements the split screen
\ mode, and can be changed by the parasite sending a #SETVDU19 <offset> command
\ to point to the offset of the new palette in this table.
\
\ This table must start on a page boundary (i.e. an address that ends in two
\ zeroes in hexadecimal). In the release version of the game TVT3 is at &2C00.
\ This is so the #SETVDU19 command can switch palettes properly, as it does this
\ by overwriting the low byte of the palette data address with a new offset, so
\ the low byte for first palette's address must be 0.
\
\ Palette data is given as a set of bytes, with each byte mapping a logical
\ colour to a physical one. In each byte, the logical colour is given in bits
\ 4-7 and the physical colour in bits 0-3. See p.379 of the Advanced User Guide
\ for details of how palette mapping works, as in modes 1 and 2 we have to do
\ multiple palette commands to change the colours correctly, and the physical
\ colour value is EOR'd with 7, just to make things even more confusing.
\
\ ******************************************************************************

.TVT3

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\EQUB &00, &34          \ 1 = yellow, 2 = red, 3 = cyan (space view)
\EQUB &24, &17          \
\EQUB &74, &64          \ Set with a #SETVDU19 0 command, after which:
\EQUB &57, &47          \
\EQUB &B1, &A1          \   #YELLOW = yellow
\EQUB &96, &86          \   #RED    = red
\EQUB &F1, &E1          \   #CYAN   = cyan
\EQUB &D6, &C6          \   #GREEN  = cyan/yellow stripe
\                       \   #WHITE  = cyan/red stripe

                        \ --- And replaced by: -------------------------------->

 EQUB &00, &31          \ 1 = cyan, 2 = red, 3 = white (anaglyph 3D space view)
 EQUB &21, &17          \
 EQUB &71, &61          \ Set with a #SETVDU19 16 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #CYAN_3D  = cyan
 EQUB &96, &86          \   #RED_3D   = red
 EQUB &F0, &E0          \   #WHITE_3D = white
 EQUB &D6, &C6

                        \ --- End of replacement ------------------------------>

 EQUB &00, &34          \ 1 = yellow, 2 = red, 3 = white (chart view)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 16 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #YELLOW = yellow
 EQUB &96, &86          \   #RED    = red
 EQUB &F0, &E0          \   #CYAN   = white
 EQUB &D6, &C6          \   #GREEN  = white/yellow stripe
                        \   #WHITE  = white/red stripe

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\EQUB &00, &34          \ 1 = yellow, 2 = white, 3 = cyan (title screen)
\EQUB &24, &17          \
\EQUB &74, &64          \ Set with a #SETVDU19 32 command, after which:
\EQUB &57, &47          \
\EQUB &B1, &A1          \   #YELLOW = yellow
\EQUB &90, &80          \   #RED    = white
\EQUB &F1, &E1          \   #CYAN   = cyan
\EQUB &D0, &C0          \   #GREEN  = cyan/yellow stripe
\                       \   #WHITE  = cyan/white stripe

                        \ --- And replaced by: -------------------------------->

 EQUB &00, &31          \ 1 = yellow, 2 = white, 3 = cyan (title screen)
 EQUB &21, &17          \
 EQUB &71, &61          \ Set with a #SETVDU19 32 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #CYAN_3D  = cyan
 EQUB &96, &86          \   #RED_3D   = red
 EQUB &F0, &E0          \   #WHITE_3D = white
 EQUB &D6, &C6

                        \ --- End of replacement ------------------------------>

 EQUB &00, &34          \ 1 = yellow, 2 = magenta, 3 = white (trade view)
 EQUB &24, &17          \
 EQUB &74, &64          \ Set with a #SETVDU19 48 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #YELLOW = yellow
 EQUB &92, &82          \   #RED    = magenta
 EQUB &F0, &E0          \   #CYAN   = white
 EQUB &D2, &C2          \   #GREEN  = white/yellow stripe
                        \   #WHITE  = white/magenta stripe

\ ******************************************************************************
\
\       Name: I/O variables
\       Type: Workspace
\    Address: &2C40 to &2C60
\   Category: Workspaces
\    Summary: Various variables used by the I/O processor
\
\ ******************************************************************************

.XC

 EQUB 1                 \ The x-coordinate of the text cursor (i.e. the text
                        \ column), set to an initial value of 1

.YC

 EQUB 1                 \ The y-coordinate of the text cursor (i.e. the text
                        \ row), set to an initial value of 1

.K3

 SKIP 1                 \ Temporary storage, used in a number of places

.U

 SKIP 1                 \ Temporary storage, used in a number of places

.LINTAB

 SKIP 1                 \ The offset of the first free byte in the TABLE buffer,
                        \ which stores bytes in the current line as they are
                        \ transmitted from the parasite using the OSWRCH 129 and
                        \ 130 commands

.LINMAX

 SKIP 1                 \ The number of points in the line currently being
                        \ transmitted from the parasite using the OSWRCH 129
                        \ and 130 commands

.YSAV

 SKIP 1                 \ Temporary storage for saving the value of the Y
                        \ register, used in a number of places

.svn

 SKIP 1                 \ "Saving in progress" flag
                        \
                        \   * Non-zero while the disc is being accessed (so this
                        \     is also the case for cataloguing, loading etc.)
                        \
                        \   * 0 otherwise

.PARANO

 SKIP 1                 \ PARANO points to the last free byte in PARAMS, which
                        \ is used as a buffer for bytes sent from the parasite
                        \ by the #RDPARAMS and OSWRCH 137 <param> commands when
                        \ updating the dashboard

.DL

 SKIP 1                 \ Vertical sync flag
                        \
                        \ DL gets set to 30 every time we reach vertical sync on
                        \ the video system, which happens 50 times a second
                        \ (50Hz). The WSCAN routine uses this to pause until the
                        \ vertical sync, by setting DL to 0 and then monitoring
                        \ its value until it changes to 30

.VEC

 SKIP 2                 \ VEC = &7FFE
                        \
                        \ This gets set to the value of the original IRQ1 vector
                        \ by the loading process

.HFX

 SKIP 1                 \ A flag that toggles the hyperspace colour effect
                        \
                        \   * 0 = no colour effect
                        \
                        \   * Non-zero = hyperspace colour effect enabled
                        \
                        \ When HFX is set to 1, the mode 1 screen that makes
                        \ up the top part of the display is temporarily switched
                        \ to mode 2 (the same screen mode as the dashboard),
                        \ which has the effect of blurring and colouring the
                        \ hyperspace rings in the top part of the screen. The
                        \ code to do this is in the LINSCN routine, which is
                        \ called as part of the screen mode routine at IRQ1.
                        \ It's in LINSCN that HFX is checked, and if it is
                        \ non-zero, the top part of the screen is not switched
                        \ to mode 1, thus leaving the top part of the screen in
                        \ the more colourful mode 2

.CATF

 SKIP 1                 \ The disc catalogue flag
                        \
                        \ Determines whether a disc catalogue is currently in
                        \ progress, so the TT26 print routine can format the
                        \ output correctly:
                        \
                        \   * 0 = disc is not currently being catalogued
                        \
                        \   * 1 = disc is currently being catalogued
                        \
                        \ Specifically, when CATF is non-zero, TT26 will omit
                        \ column 17 from the catalogue so that it will fit
                        \ on-screen (column 17 is blank column in the middle
                        \ of the catalogue, between the two lists of filenames,
                        \ so it can be dropped without affecting the layout)

.K

 SKIP 4                 \ Temporary storage, used in a number of places

.PARAMS

 SKIP 0                 \ PARAMS points to the start of the dashboard parameter
                        \ block that is populated by the parasite when it sends
                        \ the #RDPARAMS and OSWRCH 137 <param> commands
                        \
                        \ These commands update the dashboard, but because the
                        \ parameter block uses the same locations as the flight
                        \ variables, these commands also have the effect of
                        \ updating the following variables, from ENERGY to ESCP

.ENERGY

 SKIP 1                 \ Energy bank status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ALP1

 SKIP 1                 \ Magnitude of the roll angle alpha, i.e. |alpha|,
                        \ which is a positive value between 0 and 31

.ALP2

 SKIP 1                 \ Bit 7 of ALP2 = sign of the roll angle in ALPHA

.BETA

 SKIP 1                 \ The current pitch angle beta, which is reduced from
                        \ JSTY to a sign-magnitude value between -8 and +8
                        \
                        \ This describes how fast we are pitching our ship, and
                        \ determines how fast the universe pitches around us
                        \
                        \ The sign bit is also stored in BET2, while the
                        \ opposite sign is stored in BET2+1

.BET1

 SKIP 1                 \ The magnitude of the pitch angle beta, i.e. |beta|,
                        \ which is a positive value between 0 and 8

.DELTA

 SKIP 1                 \ Our current speed, in the range 1-40

.ALTIT

 SKIP 1                 \ Our altitude above the surface of the planet or sun
                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
                        \     planet/sun is at (x_hi, y_hi, z_hi), and the
                        \     radius of the planet/sun is 6
                        \
                        \   * 0 = we have crashed into the surface

.MCNT

 SKIP 1                 \ The main loop counter
                        \
                        \ This counter determines how often certain actions are
                        \ performed within the main loop. See the deep dive on
                        \ "Scheduling tasks with the main loop counter" for more
                        \ details

.FSH

 SKIP 1                 \ Forward shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ASH

 SKIP 1                 \ Aft shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.QQ14

 SKIP 1                 \ Our current fuel level (0-70)
                        \
                        \ The fuel level is stored as the number of light years
                        \ multiplied by 10, so QQ14 = 1 represents 0.1 light
                        \ years, and the maximum possible value is 70, for 7.0
                        \ light years

.GNTMP

 SKIP 1                 \ Laser temperature (or "gun temperature")
                        \
                        \ If the laser temperature exceeds 242 then the laser
                        \ overheats and cannot be fired again until it has
                        \ cooled down

.CABTMP

 SKIP 1                 \ Cabin temperature
                        \
                        \ The ambient cabin temperature in deep space is 30,
                        \ which is displayed as one notch on the dashboard bar
                        \
                        \ We get higher temperatures closer to the sun
                        \
                        \ CABTMP shares a location with MANY, but that's OK as
                        \ MANY+0 would contain the number of ships of type 0,
                        \ and as there is no ship type 0 (they start at 1), the
                        \ byte at MANY+0 is not used for storing a ship type
                        \ and can be used for the cabin temperature instead

.FLH

 SKIP 1                 \ Flashing console bars configuration setting
                        \
                        \   * 0 = static bars (default)
                        \
                        \   * &FF = flashing bars
                        \
                        \ Toggled by pressing "F" when paused, see the DKS3
                        \ routine for details

.ESCP

 SKIP 1                 \ Escape pod
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

\ ******************************************************************************
\
\       Name: JMPTAB
\       Type: Variable
\   Category: Tube
\    Summary: The lookup table for OSWRCH jump commands (128-147)
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ Once they have finished, routines in this table should reset WRCHV to point
\ back to USOSWRCH again by calling the PUTBACK routine with a JMP as their last
\ instruction.
\
\ ******************************************************************************

.JMPTAB

 EQUW USOSWRCH          \              128 (&80)     0 = Put back to USOSWRCH
 EQUW BEGINLIN          \              129 (&81)     1 = Begin drawing a line
 EQUW ADDBYT            \              130 (&82)     2 = Add line byte/draw line
 EQUW DOFE21            \ #DOFE21    = 131 (&83)     3 = Show energy bomb effect
 EQUW DOHFX             \ #DOhfx     = 132 (&84)     4 = Show hyperspace colours
 EQUW SETXC             \ #SETXC     = 133 (&85)     5 = Set text cursor column
 EQUW SETYC             \ #SETYC     = 134 (&86)     6 = Set text cursor row
 EQUW CLYNS             \ #clyns     = 135 (&87)     7 = Clear bottom of screen
 EQUW RDPARAMS          \ #RDPARAMS  = 136 (&88)     8 = Update dashboard
 EQUW ADPARAMS          \              137 (&89)     9 = Add dashboard parameter
 EQUW DODIALS           \ #DODIALS   = 138 (&8A)    10 = Show or hide dashboard
 EQUW DOVIAE            \ #VIAE      = 139 (&8B)    11 = Set 6522 System VIA IER
 EQUW DOBULB            \ #DOBULB    = 140 (&8C)    12 = Toggle dashboard bulb
 EQUW DOCATF            \ #DOCATF    = 141 (&8D)    13 = Set disc catalogue flag
 EQUW DOCOL             \ #SETCOL    = 142 (&8E)    14 = Set the current colour
 EQUW SETVDU19          \ #SETVDU19  = 143 (&8F)    15 = Change mode 1 palette
 EQUW DOSVN             \ #DOsvn     = 144 (&90)    16 = Set file saving flag
 EQUW DOBRK             \              145 (&91)    17 = Execute BRK instruction
 EQUW printer           \ #printcode = 146 (&92)    18 = Write to printer/screen
 EQUW prilf             \ #prilf     = 147 (&93)    19 = Blank line on printer

\ ******************************************************************************
\
\       Name: STARTUP
\       Type: Subroutine
\   Category: Loader
\    Summary: Set the various vectors, interrupts and timers, and terminate the
\             loading process so the vector handlers can take over
\
\ ******************************************************************************

.STARTUP

 LDA RDCHV              \ Store the current RDCHV vector in newosrdch(2 1),
 STA newosrdch+1        \ which modifies the address portion of the JSR &FFFF
 LDA RDCHV+1            \ instruction at the start of the newosrdch routine and
 STA newosrdch+2        \ changes it to a JSR to the existing RDCHV address

 LDA #LO(newosrdch)     \ Disable interrupts and set WRCHV to newosrdch, so
 SEI                    \ calls to OSRDCH are now handled by newosrdch, which
 STA RDCHV              \ lets us implement all our custom OSRDCH commands
 LDA #HI(newosrdch)
 STA RDCHV+1

 LDA #%00111001         \ Set 6522 System VIA interrupt enable register IER
 STA VIA+&4E            \ (SHEILA &4E) bits 0 and 3-5 (i.e. disable the Timer1,
                        \ CB1, CB2 and CA2 interrupts from the System VIA)

IF _SNG45 OR _SOURCE_DISC

 LDA #%01111111         \ Set 6522 User VIA interrupt enable register IER
 STA &FE6E              \ (SHEILA &6E) bits 0-7 (i.e. disable all hardware
                        \ interrupts from the User VIA)

ELIF _EXECUTIVE

 LDA #%01111111         \ At this point, the other 6502SP versions set the 6522
                        \ User VIA interrupt enable register IER to this value
                        \ to disable all hardware interrupts from the User VIA,
                        \ but the Executive version is missing the STA &FE6E
                        \ instruction, so it doesn't disable all the interrupts.
                        \ This is because the Watford Electronics Beeb Speech
                        \ Synthesiser that the Executive version supports plugs
                        \ into the user port, which is controlled by the 6522
                        \ User VIA, so this ensures we don't disable the speech
                        \ synthesiser if one is fitted

ENDIF

 LDA IRQ1V              \ Store the current IRQ1V vector in VEC, so VEC(1 0) now
 STA VEC                \ contains the original address of the IRQ1 handler
 LDA IRQ1V+1
 STA VEC+1

 LDA #LO(IRQ1)          \ Set the IRQ1V vector to IRQ1, so IRQ1 is now the
 STA IRQ1V              \ interrupt handler
 LDA #HI(IRQ1)
 STA IRQ1V+1

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA VIA+&45            \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14592 at a rate of 1 MHz (this is
                        \ a different value to the main game code and to the
                        \ loader's IRQ1 routine in the cassette version)

 CLI                    \ Enable interrupts again

.NOINT

 LDA WORDV              \ Store the current WORDV vector in notours(2 1)
 STA notours+1
 LDA WORDV+1
 STA notours+2

 LDA #LO(NWOSWD)        \ Disable interrupts and set WORDV to NWOSWD, so calls
 SEI                    \ to OSWORD are now handled by NWOSWD, which lets us
 STA WORDV              \ implement all our custom OSWORD commands
 LDA #HI(NWOSWD)
 STA WORDV+1

 CLI                    \ Enable interrupts again

 LDA #&FF               \ Set the text and graphics colour to cyan
 STA COL

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 LDA #0                 \ Reset the two-stage line flag to indicate normal
 STA twoStageLine       \ one-stage lines

                        \ --- End of added code ------------------------------->

 LDA TINA               \ If the contents of locations TINA to TINA+3 are "TINA"
 CMP #'T'               \ then keep going, otherwise jump to PUTBACK to point
 BNE PUTBACK            \ WRCHV to USOSWRCH, and then end the program, as from
 LDA TINA+1             \ now on the handlers pointed to by the vectors will
 CMP #'I'               \ handle everything
 BNE PUTBACK
 LDA TINA+2
 CMP #'N'
 BNE PUTBACK
 LDA TINA+3
 CMP #'A'
 BNE PUTBACK
 
 JSR TINA+4             \ TINA to TINA+3 contains the string "TINA", so call the
                        \ subroutine at TINA+4
                        \
                        \ This allows us to add a code hook into the start-up
                        \ process by populating the TINW workspace at &0B00 with
                        \ "TINA" followed by the code for a subroutine, and it
                        \ will be called just before the setup code terminates
                        \ on the I/O processor

                        \ Fall through into PUTBACK to point WRCHV to USOSWRCH,
                        \ and then end the program, as from now on the handlers
                        \ pointed to by the vectors will handle everything

\ ******************************************************************************
\
\       Name: PUTBACK
\       Type: Subroutine
\   Category: Tube
\    Summary: Reset the OSWRCH vector in WRCHV to point to USOSWRCH
\  Deep dive: 6502 Second Processor Tube communication
\
\ ******************************************************************************

.PUTBACK

 LDA #128               \ Set A = 128 to denote the first entry in JMPTAB, i.e.
                        \ USOSWRCH

                        \ Fall through into USOSWRCH to set WRCHV to the first
                        \ entry in JMPTAB - in other words, put WRCHV back to
                        \ its original value of USOSWRCH

\ ******************************************************************************
\
\       Name: USOSWRCH
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSWRCH routine for writing characters and implementing
\             jump table commands
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ WRCHV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads (it's set via a call to PUTBACK).
\
\ This routine prints characters to the I/O processor's screen. For special jump
\ table commands with characters in the range 128-147, the routine calls the
\ corresponding routines in the JMPTAB table; all other characters are printed
\ normally using TT26.
\
\ To implement the special jump table commands, this routine sets the address
\ in WRCHV so that calls to OSWRCH get vectored via the appropriate address from
\ JMPTAB. The routine does the following, depending on the value in A:
\
\   * If A is in the range 128-147, it sets WRCHV to entry number A - 128 in
\     the JMPTAB table (so 128 is the first entry, 129 the second, and so on)
\
\   * Otherwise it prints the character in A by calling TT26
\
\ The vector can be reset to USOSWRCH by calling the PUTBACK routine, which is
\ done at the end of all of the routines that are pointed to by JMPTAB.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to print:
\
\                         * 128-147: Run the jump command in A (see JMPTAB)
\
\                         * All others: Print the character in A
\
\ ******************************************************************************

.USOSWRCH

 STX SC                 \ Store X in SC so we can retrieve it later

 TAX                    \ Store A in X

 BPL OHMYGOD            \ If A < 128 jump to OHMYGOD to print the character in A

 ASL A                  \ Set X = A << 2
 TAX                    \       = (A - 128) * 2 (because A >= 128)
                        \
                        \ so X can be used as an index into a jump table, where
                        \ the table entries correspond to original values of A
                        \ of 128 for entry 0, 129 for entry 1, 130 for entry 2,
                        \ and so on

 CPX #39                \ If X >= 39 then it is past the end of the jump table
 BCS OHMYGOD            \ (JMPTAB contains addresses 0-19, so the last entry is
                        \ for X = 38), so jump to OHMYGOD to print the
                        \ character in A

 LDA JMPTAB,X           \ Fetch the low byte of the jump table address pointed
                        \ to by X from JMPTAB + X

 SEI                    \ Disable interrupts while we update the WRCHV vector

 STA WRCHV              \ Store the low byte of the jump table entry in the low
                        \ byte of WRCHV

 LDA JMPTAB+1,X         \ Fetch the high byte of the jump table address pointed
 STA WRCHV+1            \ to by X from JMPTAB+1 + X, and store it in the high
                        \ byte of WRCHV

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

.OHMYGOD

 LDX SC                 \ Retrieve X from SC

 JMP TT26               \ Jump to TT26 to print the character in A, returning
                        \ from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DODIALS
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Implement the #DODIALS <rows> command (show or hide the dashboard)
\
\ ------------------------------------------------------------------------------
\
\ This routine sets the screen to show the number of text rows given in X.
\
\ It is used when we are killed, as reducing the number of rows from the usual
\ 31 to 24 has the effect of hiding the dashboard, leaving a monochrome image
\ of ship debris and explosion clouds. Increasing the rows back up to 31 makes
\ the dashboard reappear, as the dashboard's screen memory doesn't get touched
\ by this process.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The number of text rows to display on the screen (24
\                       will hide the dashboard, 31 will make it reappear)
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   A is set to 6
\
\ ******************************************************************************

.DODIALS

 TAX                    \ Copy the number of rows to display into X

 LDA #6                 \ Set A to 6 so we can update 6845 register R6 below

 SEI                    \ Disable interrupts so we can update the 6845

 STA VIA+&00            \ Set 6845 register R6 to the value in X. Register R6
 STX VIA+&01            \ is the "vertical displayed" register, which sets the
                        \ number of rows shown on the screen

 CLI                    \ Re-enable interrupts

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOFE21
\       Type: Subroutine
\   Category: Flight
\    Summary: Implement the #DOFE21 <flag> command (show the energy bomb effect)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOFE21 <flag> command. It takes
\ the argument and stores it in SHEILA &21 to change the palette.
\
\ See p.379 of the Advanced User Guide for an explanation of palette bytes.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new value of SHEILA &21
\
\ ******************************************************************************

.DOFE21

 STA &FE21              \ Store the new value in SHEILA &21

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOHFX
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Implement the #DOHFX <flag> command (update the hyperspace effect
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOHFX <flag> command. It
\ updates the hyperspace effect flag in HFX.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new value of the hyperspace effect flag:
\
\                         * 0 = no colour effect
\
\                         * Non-zero = enable hyperspace colour effect
\
\ ******************************************************************************

.DOHFX

 STA HFX                \ Store the new hyperspace effect flag in HFX

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOVIAE
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the #VIAE <flag> command (enable/disable interrupts)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #VIAE <flag> command. It updates
\ the 6522 System VIA interrupt enable register (IER) at SHEILA &4E, which
\ allows us to enable and disable interrupts. It is used for enabling and
\ disabling the keyboard interrupt.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new value of the interrupt enable register (IER)
\
\ ******************************************************************************

.DOVIAE

 STA VIA+&4E            \ Store A in SHEILA &4E

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOCATF
\       Type: Subroutine
\   Category: Save and load
\    Summary: Implement the #DOCATF <flag> command (update the disc catalogue
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOCATF <flag> command. It
\ updates the disc catalogue flag in CATF.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new value of the disc catalogue flag:
\
\                         * 0 = disc is not currently being catalogued
\
\                         * 1 = disc is currently being catalogued
\
\ ******************************************************************************

.DOCATF

 STA CATF               \ Store the new value in CATF

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOCOL
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #SETCOL <colour> command (set the current colour)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETCOL <colour> command. It
\ updates the current colour in COL.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new colour
\
\ ******************************************************************************

.DOCOL

 STA COL                \ Store the new colour in COL

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOSVN
\       Type: Subroutine
\   Category: Save and load
\    Summary: Implement the #DOSVN <flag> command (update the "save in progress"
\             flag)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOSVN <flag> command. It
\ updates the "save in progress" flag in svn
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The new value of the "save in progress" flag
\
\ ******************************************************************************

.DOSVN

 STA svn                \ Store the new "save in progress" flag in svn

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOBRK
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Implement the OSWRCH 145 command (execute a BRK instruction)
\
\ ------------------------------------------------------------------------------
\
\ This command doesn't appear to be used, but it would execute a BRK on the I/O
\ processor, causing a call to BRKV. This typically  points to BRBR or MEBRK,
\ both of which print out the current system error, if there is one.
\
\ ******************************************************************************

.DOBRK

 BRK                    \ Execute a BRK instruction

 EQUB &54               \ Error number

 EQUS "TEST"            \ A carriage-return-terminated test string, which
 EQUB 13                \ doesn't appear to be used anywhere

 BRK                    \ End of the test string

\ ******************************************************************************
\
\       Name: printer
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #printcode <char> command (print a character on the
\             printer and screen)
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to print on the printer and screen
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   sent                Turn the printer off and restore the USOSWRCH handler,
\                       returning from the subroutine using a tail call
\
\ ******************************************************************************

.printer

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to TT26

 JSR TT26               \ Call TT26 to print the character in A on-screen

 PLA                    \ Retrieve A from the stack

 CMP #11                \ If A = 11, which normally means "move the cursor up
 BEQ nottosend          \ one line", jump to nottosend to skip sending this
                        \ character to the printer, as you can't roll back time
                        \ when you're printing hard copy

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to NVOSWRCH

 LDA #2                 \ Print ASCII 2 using the non-vectored OSWRCH, which
 JSR NVOSWRCH           \ means "start sending characters to the printer"

 PLA                    \ Retrieve A from the stack, though this is a bit
                        \ pointless given the next instruction, as they cancel
                        \ each other out

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following calls to POSWRCH and/or NVOSWRCH

 CMP #' '               \ If A is greater than ASCII " ", then it's a printable
 BCS tosend             \ character, so jump to tosend to print the character
                        \ and jump back to sent to turn the printer off and
                        \ finish

 CMP #10                \ If we are printing a line feed, jump to tosend2 to
 BEQ tosend2            \ send it to POSWRCH

 LDA #13                \ Otherwise print a carriage return instead of whatever
 JSR POSWRCH            \ was in A, and jump to sent to turn the printer off and
 JMP sent               \ finish

.tosend2

\CMP #13                \ These instructions are commented out in the original
\BEQ sent               \ source; perhaps they were replaced by the above JMP
                        \ instruction at some point, which does a similar thing
                        \ but in fewer bytes (and without the risk of POSWRCH
                        \ corrupting the value of A)

 LDA #10                \ Call POSWRCH to send a line feed to the printer
 JSR POSWRCH

.sent

 LDA #3                 \ Print ASCII 3 using the non-vectored OSWRCH, which
 JSR NVOSWRCH           \ means "stop sending characters to the printer"

 PLA                    \ Retrieve A from the stack

.nottosend

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: POSWRCH
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character on the printer only
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to send to the printer
\
\ ******************************************************************************

.POSWRCH

 PHA                    \ Store A on the stack so we can retrieve it after the
                        \ following call to NVOSWRCH

 LDA #1                 \ Send ASCII 1 to the printer using the non-vectored
 JSR NVOSWRCH           \ OSWRCH, which means "send the next character to the
                        \ printer only"

 PLA                    \ Retrieve A from the stack

 JMP NVOSWRCH           \ Send the character in A to the printer using the
                        \ non-vectored OSWRCH, which prints the character on the
                        \ printer, and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: tosend
\       Type: Subroutine
\   Category: Text
\    Summary: Print a printable character and return to the printer routine
\
\ ******************************************************************************

.tosend

 JSR POSWRCH            \ Call POSWRCH to print the character in A on the
                        \ printer only

 JMP sent               \ Jump to sent to turn the printer off and restore the
                        \ USOSWRCH handler, returning from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: prilf
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #prilf command (print a blank line on the printer)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #prilf command. It prints a
\ blank line on the printer by printing two line feeds.
\
\ ******************************************************************************

.prilf

 LDA #2                 \ Print ASCII 2 using the non-vectored OSWRCH, which
 JSR NVOSWRCH           \ means "start sending characters to the printer"

 LDA #10                \ Send ASCII 10 to the printer twice using the POSWRCH
 JSR POSWRCH            \ routine, which prints a blank line below the current
 JSR POSWRCH            \ line as ASCII 10 is the line feed character

 LDA #3                 \ Print ASCII 3 using the non-vectored OSWRCH, which
 JSR NVOSWRCH           \ means "stop sending characters to the printer"

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DOBULB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOBULB 0 command (draw the space station indicator
\             bulb)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOBULB 0 command. It draws
\ (or erases) the space station indicator bulb ("S") on the dashboard.
\
\ ******************************************************************************

.DOBULB

 TAX                    \ If the parameter to the #DOBULB command is non-zero,
 BNE ECBLB              \ i.e. this is a #DOBULB 255 command, jump to ECBLB to
                        \ draw the E.C.M. bulb instead

 LDA #16*8              \ The space station bulb is in character block number 48
 STA SC                 \ (counting from the left edge of the screen), with the
                        \ first half of the row in one page, and the second half
                        \ in another. We want to set the screen address to point
                        \ to the second part of the row, as the bulb is in that
                        \ half, so that's character block number 16 within that
                        \ second half (as the first half takes up 32 character
                        \ blocks, so given that each character block takes up 8
                        \ bytes, this sets the low byte of the screen address
                        \ of the character block we want to draw to

 LDA #&7B               \ Set the high byte of SC(1 0) to &7B, as the bulbs are
 STA SC+1               \ both in the character row from &7A00 to &7BFF, and the
                        \ space station bulb is in the right half, which is from
                        \ &7B00 to &7BFF

 LDY #15                \ Now to poke the bulb bitmap into screen memory, and
                        \ there are two character blocks' worth, each with eight
                        \ lines of one byte, so set a counter in Y for 16 bytes

.BULL

 LDA SPBT,Y             \ Fetch the Y-th byte of the bulb bitmap

 EOR (SC),Y             \ EOR the byte with the current contents of screen
                        \ memory, so drawing the bulb when it is already
                        \ on-screen will erase it

 STA (SC),Y             \ Store the Y-th byte of the bulb bitmap in screen
                        \ memory

 DEY                    \ Decrement the loop counter

 BPL BULL               \ Loop back to poke the next byte until we have done
                        \ all 16 bytes across two character blocks

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: ECBLB
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOBULB 255 command (draw the E.C.M. indicator bulb)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DOBULB 255 command. It draws
\ (or erases) the E.C.M. indicator bulb ("E") on the dashboard.
\
\ ******************************************************************************

.ECBLB

 LDA #8*14              \ The E.C.M. bulb is in character block number 14 with
 STA SC                 \ each character taking 8 bytes, so this sets the low
                        \ byte of the screen address of the character block we
                        \ want to draw to

 LDA #&7A               \ Set the high byte of SC(1 0) to &7A, as the bulbs are
 STA SC+1               \ both in the character row from &7A00 to &7BFF, and the
                        \ E.C.M. bulb is in the left half, which is from &7A00
                        \ to &7AFF

 LDY #15                \ Now to poke the bulb bitmap into screen memory, and
                        \ there are two character blocks' worth, each with eight
                        \ lines of one byte, so set a counter in Y for 16 bytes

.BULL2

 LDA ECBT,Y             \ Fetch the Y-th byte of the bulb bitmap

 EOR (SC),Y             \ EOR the byte with the current contents of screen
                        \ memory, so drawing the bulb when it is already
                        \ on-screen will erase it

 STA (SC),Y             \ Store the Y-th byte of the bulb bitmap in screen
                        \ memory

 DEY                    \ Decrement the loop counter

 BPL BULL2              \ Loop back to poke the next byte until we have done
                        \ all 16 bytes across two character blocks

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SPBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The bitmap definition for the space station indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The bitmap definition for the space station indicator's "S" bulb that gets
\ displayed on the dashboard.
\
\ The bulb is four pixels wide, so it covers two mode 2 character blocks, one
\ containing the left half of the "S", and the other the right half, which are
\ displayed next to each other. Each pixel is in mode 2 colour 7 (%1111), which
\ is white.
\
\ ******************************************************************************

.SPBT

                        \ Left half of the "S" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Right half of the "S" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %01010101         \ . x
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Combined "S" bulb
                        \
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x
                        \ . . . x
                        \ x x x x
                        \ x x x x

\ ******************************************************************************
\
\       Name: ECBT
\       Type: Variable
\   Category: Dashboard
\    Summary: The character bitmap for the E.C.M. indicator bulb
\
\ ------------------------------------------------------------------------------
\
\ The character bitmap for the E.C.M. indicator's "E" bulb that gets displayed
\ on the dashboard.
\
\ The bulb is four pixels wide, so it covers two mode 2 character blocks, one
\ containing the left half of the "E", and the other the right half, which are
\ displayed next to each other. Each pixel is in mode 2 colour 7 (%1111), which
\ is white.
\
\ ******************************************************************************

.ECBT

                        \ Left half of the "E" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %10101010         \ x .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Right half of the "E" bulb
                        \
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x
 EQUB %00000000         \ . .
 EQUB %11111111         \ x x
 EQUB %11111111         \ x x

                        \ Combined "E" bulb
                        \
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x
                        \ x . . .
                        \ x x x x
                        \ x x x x

\ ******************************************************************************
\
\       Name: DOT
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOdot command (draw a dash on the compass)
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The screen pixel x-coordinate of the dash
\
\                         * Byte #3 = The screen pixel x-coordinate of the dash
\
\                         * Byte #4 = The colour of the dash
\
\ ******************************************************************************

.DOT

 LDY #2                 \ Fetch byte #2 from the parameter block (the dash's
 LDA (OSSC),Y           \ x-coordinate) and store it in X1
 STA X1

 INY                    \ Fetch byte #3 from the parameter block (the dash's
 LDA (OSSC),Y           \ y-coordinate) and store it in X1
 STA Y1

 INY                    \ Fetch byte #3 from the parameter block (the dash's
 LDA (OSSC),Y           \ colour) and store it in COL
 STA COL

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\CMP #WHITE2            \ If the dash's colour is not white, jump to CPIX2 to
\BNE CPIX2              \ draw a single-height dash in the compass, as it is
\                       \ showing that the planet or station is behind us
\
\                       \ Otherwise the dash is white, which is in front of us,
\                       \ so fall through into CPIX4 to draw a double-height
\                       \ dash in the compass

                        \ --- And replaced by: -------------------------------->

 CMP #WHITE2            \ If the dash's colour is white, jump to CPIX4 to draw
 BEQ CPIX4              \ draw a double-height dash in the compass, as it is
                        \ showing that the planet or station is in front of us

 LDA #WHITE2            \ Otherwise the dash is behind us, so set the colour to
 STA COL                \ white and jump to CPIX2 to draw a single-height dash
 BNE CPIX2              \ in the compass

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: CPIX4
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a double-height dot on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ Draw a double-height mode 2 dot (2 pixels high, 2 pixels wide).
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the bottom-left corner
\                       of the dot
\
\   Y1                  The screen pixel y-coordinate of the bottom-left corner
\                       of the dot
\
\   COL                 The colour of the dot as a mode 2 character row byte
\
\ ******************************************************************************

.CPIX4

 JSR CPIX2              \ Call CPIX2 to draw a single-height dash at (X1, Y1)

 DEC Y1                 \ Decrement Y1

                        \ Fall through into CPIX2 to draw a second single-height
                        \ dash on the pixel row above the first one, to create a
                        \ double-height dot

\ ******************************************************************************
\
\       Name: CPIX2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single-height dash on the dashboard
\
\ ------------------------------------------------------------------------------
\
\ Draw a single-height mode 2 dash (1 pixel high, 2 pixels wide).
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X1                  The screen pixel x-coordinate of the dash
\
\   Y1                  The screen pixel y-coordinate of the dash
\
\   COL                 The colour of the dash as a mode 2 character row byte
\
\ ******************************************************************************

.CPIX2

 LDA Y1                 \ Fetch the y-coordinate into A

 TAY                    \ Store the y-coordinate in Y

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

 LDA X1                 \ Each character block contains 8 pixel rows, so to get
 AND #%11111100         \ the address of the first byte in the character block
 ASL A                  \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-1 and shift left to double
                        \ it (as each character row contains two pages of bytes,
                        \ or 512 bytes, which cover 256 pixels). This also
                        \ shifts bit 7 of X1 into the C flag

 STA SC                 \ Store the address of the character block in the low
                        \ byte of SC(1 0), so now SC(1 0) points to the
                        \ character block we need to draw into

 BCC P%+5               \ If the C flag is clear then skip the next two
                        \ instructions

 INC SC+1               \ The C flag is set, which means bit 7 of X1 was set
                        \ before the ASL above, so the x-coordinate is in the
                        \ right half of the screen (i.e. in the range 128-255).
                        \ Each row takes up two pages in memory, so the right
                        \ half is in the second page but SC+1 contains the value
                        \ we looked up from ylookup, which is the page number of
                        \ the first memory page for the row... so we need to
                        \ increment SC+1 to point to the correct page

 CLC                    \ Clear the C flag

 TYA                    \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 LDA X1                 \ Copy bit 1 of X1 to bit 1 of X. X will now be either
 AND #%00000010         \ 0 or 2, and will be double the pixel number in the
 TAX                    \ character row for the left pixel in the dash (so 0
                        \ means the left pixel in the 2-pixel character row,
                        \ while 2 means the right pixel)

 LDA CTWOS,X            \ Fetch a mode 2 1-pixel byte with the pixel position
 AND COL                \ at X/2, and AND with the colour byte so that pixel
                        \ takes on the colour we want to draw (i.e. A is acting
                        \ as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 LDA CTWOS+2,X          \ Fetch a mode 2 1-pixel byte with the pixel position
                        \ at (X+1)/2, so we can draw the right pixel of the dash

 BPL CP1                \ The CTWOS table has 2 extra rows at the end of it that
                        \ repeat the first values, %10101010, so if we have not
                        \ fetched that value, then the right pixel of the dash
                        \ is in the same character block as the left pixel, so
                        \ jump to CP1 to draw it

 LDA SC                 \ Otherwise the left pixel we drew was at the last
 ADC #8                 \ position of four in this character block, so we add
 STA SC                 \ 8 to the screen address to move onto the next block
                        \ along (as there are 8 bytes in a character block).
                        \ The C flag was cleared above, so this ADC is correct

 BCC P%+4               \ If the addition we just did overflowed, then increment
 INC SC+1               \ the high byte of SC(1 0), as this means we just moved
                        \ into the right half of the screen row

 LDA CTWOS+2,X          \ Re-fetch the mode 2 1-pixel byte, as we just overwrote
                        \ A (the byte will still be the fifth or sixth byte from
                        \ the table, which is correct as we want to draw the
                        \ leftmost pixel in the next character along as the
                        \ dash's right pixel)

.CP1

 AND COL                \ Apply the colour mask to the pixel byte, as above

 EOR (SC),Y             \ Draw the dash's right pixel according to the mask in
 STA (SC),Y             \ A, with the colour in COL, using EOR logic, just as
                        \ above

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SC48
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #onescan command (draw a ship on the 3D scanner)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #onescan command with parameters
\ in the block at OSSC(1 0). It draws a ship on the 3D scanner. The parameters
\ match those put into the SCANpars block in the parasite.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The sign of the stick height (in bit 7)
\
\                         * Byte #3 = The stick height for this ship on the
\                                     scanner
\
\                         * Byte #4 = The colour of the ship on the scanner
\
\                         * Byte #5 = The screen x-coordinate of the dot on the
\                                     scanner
\
\                         * Byte #6 = The screen y-coordinate of the dot on the
\                                     scanner
\
\ ******************************************************************************

.SC48

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 LDY #3                 \ Set A to byte #3 from the parameter block (the stick
 LDA (OSSC),Y           \ height) and store it in Q
 STA Q

 DEY                    \ Fetch byte #2 from the parameter block (the sign of
 LDA (OSSC),Y           \ the stick height) and shift bit 7 into the C flag, so
 ASL A                  \ C now contains the sign of the stick height

 LDY #6                 \ Fetch byte #6 from the parameter block (the screen
 LDA (OSSC),Y           \ y-coordinate)

 BCS scan1              \ If the stick direction is negative (i.e. it goes
                        \ upwards from the dot, jump to scan1

 SEC                    \ The stick direction is positive (i.e. it goes upwards
 SBC Q                  \ from the dot), so we get the y-coordinate of the
                        \ bottom of the stick by subtracting the stick height
                        \ from the dot's y-coordinate

 JMP scan2              \ Jump to scan2 to continue

.scan1

 CLC                    \ The stick direction is negative (i.e. it goes
 ADC Q                  \ downwards from the dot), so we get the y-coordinate of
                        \ the top of the stick by adding the stick height to the
                        \ dot's y-coordinate

.scan2

                        \ By this point A contains the y-coordinate of the end
                        \ of the stick as it touches the 3D ellipse, which we
                        \ can use to determine the z-distance of the ship's dot
                        \ on the scanner
                        \
                        \ The centre line of the scanner is at y-coordinate 220,
                        \ so we can apply 0, 1 or 2 pixels of parallax as
                        \ follows, depending on the value in A:
                        \
                        \   * ...-210 = 2 pixels of positive parallax
                        \   * 211-216 = 1 pixel of positive parallax
                        \   * 217-223 = no parallax
                        \   * 224-231 = 1 pixel of negative parallax
                        \   * 232-... = 2 pixels of negative parallax
                        \
                        \ So we now calculate the amount of parallax

 LDY #0                 \ Set Y = 0 to store the amount of parallax

 CMP #224               \ If A >= 224, jump to scan4 to calculate negative
 BCS scan4              \ parallax

 CMP #217               \ If A >= 217 then A is in the range 217 to 223, so jump
 BCS scan6              \ to scan6 as there is no parallax to apply, so we only
                        \ draw the ship once on the scanner, in white

 INY                    \ If we get here then A < 217, so increment Y to 1

 CMP #211               \ If A >= 211, jump to scan5 as we are done (Y = 1)
 BCS scan5

 INY                    \ If we get here then A < 211, so increment Y to 2

 BCC scan5              \ Jump to scan5 as we are done (Y = 2) (this BCC is
                        \ effectively a JMP as we just passed through a BCS)

.scan4

 DEY                    \ If we get here then A >= 224, so decrement Y to -1

 CMP #232               \ If A < 232, jump to scan5 as we are done (Y = -1)
 BCC scan5

 DEY                    \ If we get here then A >= 232, so decrement Y to -2

.scan5

                        \ If we get here then there is some parallax to apply

 STY U                  \ Store the amount of parallax in U

 LDY #5                 \ Fetch byte #5 from the parameter block (the screen
 LDA (OSSC),Y           \ x-coordinate) and store it in V
 STA V

                        \ We now draw the ship twice, once for each eye,
                        \ starting with the left eye in red

 SEC                    \ Subtract the parallax from the x-coordinate and store
 SBC U                  \ in X1 (so for positive parallax the left eye goes left
 STA X1                 \ and for negative parallax it goes right)

 LDA #RED2_3D           \ Set the colour to red
 STA COL

 LDY #6                 \ Call scan7+1 to draw the stick (we set Y = 6 so the
 JSR scan7+1            \ code at the start of the subroutine fetches byte #6)

                        \ And now we do the right eye in cyan

 LDA V                  \ Add the parallax to the x-coordinate and store in X1
 CLC                    \ (so for positive parallax the right eye goes right and
 ADC U                  \ for negative parallax it goes left)
 STA X1

 LDA #CYAN2_3D          \ Set the colour to cyan
 STA COL

 LDY #6                 \ Call scan7+1 to draw the stick, returning from the
 JMP scan7+1            \ subroutine using a tail call (we set Y = 6 so the code
                        \ at the start of the subroutine fetches byte #6)

.scan6

                        \ --- End of added code ------------------------------->

 LDY #4                 \ Fetch byte #4 from the parameter block (the colour)
 LDA (OSSC),Y           \ and store it in COL
 STA COL

 INY                    \ Fetch byte #5 from the parameter block (the screen
 LDA (OSSC),Y           \ x-coordinate) and store it in X1
 STA X1

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.scan7

                        \ --- End of added code ------------------------------->

 INY                    \ Fetch byte #6 from the parameter block (the screen
 LDA (OSSC),Y           \ y-coordinate) and store it in Y1
 STA Y1

 JSR CPIX4              \ Draw a double-height mode 2 dot at (X1, Y1). This also
                        \ leaves the following variables set up for the dot's
                        \ top-right pixel, the last pixel to be drawn (as the
                        \ dot gets drawn from the bottom up):
                        \
                        \   SC(1 0) = screen address of the pixel's character
                        \             block
                        \
                        \   Y = number of the character row containing the pixel
                        \
                        \   X = the pixel's number (0-3) in that row
                        \
                        \ We can use there as the starting point for drawing the
                        \ stick, if there is one

 LDA CTWOS+2,X          \ Load the same mode 2 1-pixel byte that we just used
 AND COL                \ for the top-right pixel, and mask it with the same
 STA X1                 \ colour, storing the result in X1, so we can use it as
                        \ the character row byte for the stick

 STY Q                  \ Store Y in Q so we can retrieve it after fetching the
                        \ stick details

 LDY #2                 \ Fetch byte #2 from the parameter block (the sign of
 LDA (OSSC),Y           \ the stick height) and shift bit 7 into the C flag, so
 ASL A                  \ C now contains the sign of the stick height

 INY                    \ Set A to byte #3 from the parameter block (the stick
 LDA (OSSC),Y           \ height)

 BEQ RTS                \ If the stick height is zero, then there is no stick to
                        \ draw, so return from the subroutine (as RTS contains
                        \ an RTS)

 LDY Q                  \ Restore the value of Y from Q, so Y now contains the
                        \ character row containing the dot we drew above

 TAX                    \ Copy the stick height into X

 BCC RTS+1              \ If the C flag is clear then the stick height in A is
                        \ negative, so jump down to RTS+1

.VLL1

                        \ If we get here then the stick length is positive (so
                        \ the dot is below the ellipse and the stick is above
                        \ the dot, and we need to draw the stick upwards from
                        \ the dot)

 DEY                    \ We want to draw the stick upwards, so decrement the
                        \ pixel row in Y

 BPL VL1                \ If Y is still positive then it correctly points at the
                        \ line above, so jump to VL1 to skip the following

 LDY #7                 \ We just decremented Y up through the top of the
                        \ character block, so we need to move it to the last row
                        \ in the character above, so set Y to 7, the number of
                        \ the last row

 DEC SC+1               \ Decrement the high byte of the screen address twice to
 DEC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VL1

 LDA X1                 \ Set A to the character row byte for the stick, which
                        \ we stored in X1 above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y

 DEX                    \ Decrement (positive) the stick height in X

 BNE VLL1               \ If we still have more stick to draw, jump up to VLL1
                        \ to draw the next pixel

.RTS

 RTS                    \ Return from the subroutine

                        \ If we get here then the stick length is negative (so
                        \ the dot is above the ellipse and the stick is below
                        \ the dot, and we need to draw the stick downwards from
                        \ the dot)

 INY                    \ We want to draw the stick downwards, so we first
                        \ increment the row counter so that it's pointing to the
                        \ bottom-right pixel in the dot (as opposed to the top-
                        \ right pixel that the call to CPIX4 finished on)

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE VLL2               \ correctly points at the next line down, so jump to
                        \ VLL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address twice to
 INC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VLL2

 INY                    \ We want to draw the stick itself, heading downwards,
                        \ so increment the pixel row in Y

 CPY #8                 \ If the row number in Y is less than 8, then it
 BNE VL2                \ correctly points at the next line down, so jump to
                        \ VL2 to skip the following

 LDY #0                 \ We just incremented Y down through the bottom of the
                        \ character block, so we need to move it to the first
                        \ row in the character below, so set Y to 0, the number
                        \ of the first row

 INC SC+1               \ Increment the high byte of the screen address twice to
 INC SC+1               \ move to the character block above (we do this twice as
                        \ there are two pages in memory per character row)

.VL2

 LDA X1                 \ Set A to the character row byte for the stick, which
                        \ we stored in X1 above, and which has the same pixel
                        \ pattern as the bottom-right pixel of the dot (so the
                        \ stick comes out of the right side of the dot)

 EOR (SC),Y             \ Draw the stick on row Y of the character block using
 STA (SC),Y

 INX                    \ Decrement the (negative) stick height in X

 BNE VLL2               \ If we still have more stick to draw, jump up to VLL2
                        \ to draw the next pixel

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BEGINLIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWRCH 129 <size> command (start receiving a new
\             line to draw)
\
\ ------------------------------------------------------------------------------
\
\ The parasite asks the I/O processor to draw a line by first sending an OSWRCH
\ 129 command to the I/O processor, to tell it to start receiving a new line to
\ draw. That call runs this routine on the receiving I/O processor. The next
\ parameter to this call (sent with the next OSWRCH) contains the number of
\ bytes we are going to send containing the line's coordinates, plus 1.
\
\ This routine then executes an OSWRCH 130 command, which calls the ADDBYT
\ routine to start the I/O processor listening for more bytes from the parasite.
\ These get added to the TABLE buffer, and when the parasite has sent all the
\ coordinates, we draw the line.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The number of points in the new line + 1
\
\ ******************************************************************************

.BEGINLIN

 STA LINMAX             \ Set LINMAX to the number of points in the new line + 1

 LDA #0                 \ Set LINTAB = 0 to point to the position of the next
 STA LINTAB             \ free byte in the TABLE buffer (i.e. the first byte, as
                        \ we have just reset the buffer)

 LDA #130               \ Execute a USOSWRCH 130 command so subsequent OSWRCH
 JMP USOSWRCH           \ calls from the parasite can send coordinates that get
                        \ added to TABLE, and return from the subroutine using a
                        \ tail call

\ ******************************************************************************
\
\       Name: ADDBYT
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWRCH 130 <byte> command (add a byte to a line and
\             draw it when all bytes are received)
\
\ ------------------------------------------------------------------------------
\
\ This routine receives bytes from the parasite, each of which is a coordinate
\ in the line that is currently being drawn (following a call from the parasite
\ to OSWRCH 129, which starts the I/O processor listening for line bytes). They
\ are stored in the buffer at TABLE, where LINTAB points to the first free byte
\ in the table, and LINMAX contains double the number of points we are expecting
\ plus 1.
\
\ If the byte received is the last one in the line, then the line segments are
\ drawn by sending them to the LOIN routine.
\
\ If a laser line is sent by the parasite, it will be the first line segment
\ sent, and will be preceded by a dummy pair of coordinates where the Y2 value
\ is 255, which is not in the space view (as the maximum y-coordinate in the
\ space view is 191). Laser lines are drawn in red.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The byte to be added to the line that's currently being
\                       transmitted to the I/O processor
\
\ ******************************************************************************

.RTS1

 RTS                    \ Return from the subroutine (this is called below)

.ADDBYT

 INC LINTAB             \ LINTAB points to the last free byte in TABLE, which is
                        \ where we're about to store the new byte in A, so
                        \ increment LINTAB to point to the byte after this one

 LDX LINTAB             \ Store the new byte in A at position LINTAB-1 in TABLE
 STA TABLE-1,X          \ (which was the last free byte before we incremented
                        \ LINTAB above)

 INX                    \ Increment X, so it now points to the byte after the
                        \ last free byte in TABLE (i.e. LINTAB + 1)

 CPX LINMAX             \ If X < LINMAX, jump up to RTS1 to return from the
 BCC RTS1               \ subroutine, as the line isn't complete yet (because
                        \ LINMAX contains the 2 * number of points + 1)

                        \ If we get here then X = LINMAX and we have received
                        \ all the line's points from the parasite, so now we
                        \ draw it

 LDY #0                 \ We are going to loop through all the points in the
                        \ line, so set a counter in Y, starting from 0

 DEC LINMAX             \ Decrement LINMAX so it now contains 2 * number of
                        \ points

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA TABLE+3            \ If TABLE+3 = 255, jump to doalaser to draw this line,
\CMP #255               \ as this denotes that the following segment is a laser
\BEQ doalaser           \ line, which should be drawn in red

                        \ --- End of removed code ----------------------------->

.LL27

                        \ --- Mod: Code added for anaglyph 3D: ----------------

 LDA TABLE+3,Y          \ If Y2 = 255, jump to nullLine to skip drawing this
 CMP #255               \ line, as this denotes that the following segment is a
 BEQ nullLine           \ null line that should not be drawn

                        \ --- End of added code ------------------------------->

 LDA TABLE,Y            \ Set X1 to the Y-th byte from TABLE
 STA X1

 LDA TABLE+1,Y          \ Set Y1 to the Y+1-th byte from TABLE
 STA Y1

 LDA TABLE+2,Y          \ Set X2 to the Y+2-th byte from TABLE
 STA X2

 LDA TABLE+3,Y          \ Set Y2 to the Y+3-th byte from TABLE
 STA Y2

 STY T1                 \ Store the loop counter in T1 so we can retrieve it
                        \ after the call to LOIN

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 LDA T1                 \ Retrieve the loop counter from T1

 CLC                    \ Set A = A + 4
 ADC #4

.Ivedonealaser

 TAY                    \ Transfer the updated loop counter from A into Y

 CMP LINMAX             \ Loop back to LL27 to draw the next line segment, until
 BCC LL27               \ we the loop counter has reached LINMAX (which contains
                        \ 2 * number of points, so this is when we have run out
                        \ of points)

.DRLR1

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

.doalaser

 LDA COL                \ Store the current line colour on the stack, so we can
 PHA                    \ restore it below

 LDA #RED               \ Set the laser colour to red
 STA COL

                        \ The coordinates at bytes Y to Y+3 were used up with
                        \ the indicator bytes to say this is a laser line, so
                        \ we need to fetch the following bytes to get the line's
                        \ coordinates to draw

 LDA TABLE+4            \ Set X1 to the Y+4-th byte from TABLE
 STA X1

 LDA TABLE+5            \ Set Y1 to the Y+5-th byte from TABLE
 STA Y1

 LDA TABLE+6            \ Set X2 to the Y+6-th byte from TABLE
 STA X2

 LDA TABLE+7            \ Set Y2 to the Y+7-th byte from TABLE
 STA Y2

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 PLA                    \ Restore the original line colour from the stack
 STA COL

 LDA #8                 \ Jump up to Ivedonealaser with A set to 8, which will
 BNE Ivedonealaser      \ point to the rest of the lines as the laser line is
                        \ always the first to be transmitted from the parasite
                        \ (this BNE is effectively a JMP as A is never zero)

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.nullLine

 TYA                    \ Set A = Y + 4
 CLC
 ADC #4

 JMP Ivedonealaser      \ Jump up to Ivedonealaser with A set to the next point
                        \ in the queue

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 1
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 1 (the top part of the
\ split screen).
\
\ ******************************************************************************

.TWOS

 EQUB %10001000
 EQUB %01000100
 EQUB %00100010
 EQUB %00010001

\ ******************************************************************************
\
\       Name: TWOS2
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made double-pixel character row bytes for mode 1
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting two-pixel dashes in mode 1 (the top part of the
\ split screen).
\
\ ******************************************************************************

.TWOS2

 EQUB %11001100
 EQUB %01100110
 EQUB %00110011
 EQUB %00110011

\ ******************************************************************************
\
\       Name: CTWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 2
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 2 (the bottom part of
\ the split screen).
\
\ In mode 2, each character row is one byte, which is two pixels. Rows 0 and 1
\ of the table contain a character row byte with just the left pixel plotted,
\ while rows 2 and 3 contain a character row byte with just the right pixel
\ plotted.
\
\ In other words, looking up row X will return a character row byte with pixel
\ X/2 plotted (if the pixels are numbered 0 and 1).
\
\ There are two extra rows to support the use of CTWOS+2,X indexing in the CPIX2
\ routine. The extra rows are repeats of the first two rows, and save us from
\ having to work out whether CTWOS+2+X needs to be wrapped around when drawing a
\ two-pixel dash that crosses from one character block into another. See CPIX2
\ for more details.
\
\ ******************************************************************************

.CTWOS

 EQUB %10101010
 EQUB %10101010
 EQUB %01010101
 EQUB %01010101
 EQUB %10101010
 EQUB %10101010

\ ******************************************************************************
\
\       Name: HLOIN2
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line in a specific colour
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X1                  The screen x-coordinate of the start of the line
\
\   X2                  The screen x-coordinate of the end of the line
\
\   Y1                  The screen y-coordinate of the line
\
\   COL                 The line colour
\
\ ******************************************************************************

.HLOIN2

 LDX X1                 \ Set X = X1

 STY Y2                 \ Set Y2 = Y, the offset within the line buffer of the

 INY                    \ Set Q = Y + 1, so the call to HLOIN3 only draws one
 STY Q                  \ line

 LDA COL                \ Set A to the line colour

 JMP HLOIN3             \ Jump to HLOIN3 to draw a line from (X, Y1) to (X2, Y1)
                        \ in the colour given in A

\ ******************************************************************************
\
\       Name: LOIN (Part 1 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Calculate the line gradient in the form of deltas
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ This stage calculates the line deltas.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X1                  The screen x-coordinate of the start of the line
\
\   Y1                  The screen y-coordinate of the start of the line
\
\   X2                  The screen x-coordinate of the end of the line
\
\   Y2                  The screen y-coordinate of the end of the line
\
\ ******************************************************************************

                        \ In the cassette and disc versions of Elite, LL30 and
                        \ LOIN are synonyms for the same routine, presumably
                        \ because the two developers each had their own line
                        \ routines to start with, and then chose one of them for
                        \ the final game
                        \
                        \ In the 6502 Second Processor version, there are three
                        \ different routines. In the parasite, LL30 draws a
                        \ one-segment line, while LOIN draws multi-segment
                        \ lines. Both of these ask the I/O processor to do the
                        \ actual drawing, and it uses a routine called... wait
                        \ for it... LOIN
                        \
                        \ This, then, is the I/O processor's LOIN routine, which
                        \ is not the same as LL30, or the other LOIN. Got that?

.LOIN

 LDA #128               \ Set S = 128, which is the starting point for the
 STA S                  \ slope error (representing half a pixel)

 ASL A                  \ Set SWAP = 0, as %10000000 << 1 = 0
 STA SWAP

 LDA X2                 \ Set A = X2 - X1
 SBC X1                 \       = delta_x
                        \
                        \ This subtraction works as the ASL A above sets the C
                        \ flag

 BCS LI1                \ If X2 > X1 then A is already positive and we can skip
                        \ the next three instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

 SEC                    \ Set the C flag, ready for the subtraction below

.LI1

 STA P                  \ Store A in P, so P = |X2 - X1|, or |delta_x|

 LDA Y2                 \ Set A = Y2 - Y1
 SBC Y1                 \       = delta_y
                        \
                        \ This subtraction works as we either set the C flag
                        \ above, or we skipped that SEC instruction with a BCS

 BEQ HLOIN2             \ If A = 0 then Y1 = Y2, which means the line is
                        \ horizontal, so jump to HLOIN2 to draw a horizontal
                        \ line instead of applying Bresenham's line algorithm

 BCS LI2                \ If Y2 > Y1 then A is already positive and we can skip
                        \ the next two instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

.LI2

 STA Q                  \ Store A in Q, so Q = |Y2 - Y1|, or |delta_y|

 CMP P                  \ If Q < P, jump to STPX to step along the x-axis, as
 BCC STPX               \ the line is closer to being horizontal than vertical

 JMP STPY               \ Otherwise Q >= P so jump to STPY to step along the
                        \ y-axis, as the line is closer to being vertical than
                        \ horizontal

\ ******************************************************************************
\
\       Name: LOIN (Part 2 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a shallow gradient, step right along x-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| < |delta_x|
\
\   * The line is closer to being horizontal than vertical
\
\   * We are going to step right along the x-axis
\
\   * We potentially swap coordinates to make sure X1 < X2
\
\ ******************************************************************************

.STPX

 LDX X1                 \ Set X = X1

 CPX X2                 \ If X1 < X2, jump down to LI3, as the coordinates are
 BCC LI3                \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

                        \ By this point we know the line is horizontal-ish and
                        \ X1 < X2, so we're going from left to right as we go
                        \ from X1 to X2

 LDY Y1                 \ Look up the page number of the character row that
 LDA ylookup,Y          \ contains the pixel with the y-coordinate in Y1, and
 STA SC+1               \ store it in SC+1, so the high byte of SC is set
                        \ correctly for drawing our line

 LDA Y1                 \ Set Y = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw the start of
 TAY                    \ our line (as each character block has 8 rows)

 TXA                    \ Set A = 2 * bits 2-6 of X1
 AND #%11111100         \
 ASL A                  \ and shift bit 7 of X1 into the C flag

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw the
                        \ start of our line on

 BCC P%+4               \ If bit 7 of X1 was set, so X1 > 127, increment the
 INC SC+1               \ high byte of SC(1 0) to point to the second page on
                        \ this screen row, as this page contains the right half
                        \ of the row

 TXA                    \ Set R = X1 mod 4, which is the horizontal pixel number
 AND #3                 \ within the character block where the line starts (as
 STA R                  \ each pixel line in the character block is 4 pixels
                        \ wide)

                        \ The following section calculates:
                        \
                        \   Q = Q / P
                        \     = |delta_y| / |delta_x|
                        \
                        \ using the log tables at logL and log to calculate:
                        \
                        \   A = log(Q) - log(P)
                        \     = log(|delta_y|) - log(|delta_x|)
                        \
                        \ by first subtracting the low bytes of the logarithms
                        \ from the table at LogL, and then subtracting the high
                        \ bytes from the table at log, before applying the
                        \ antilog to get the result of the division and putting
                        \ it in Q

 LDX Q                  \ Set X = |delta_y|

 BEQ LIlog7             \ If |delta_y| = 0, jump to LIlog7 to return 0 as the
                        \ result of the division

 LDA logL,X             \ Set A = log(Q) - log(P)
 LDX P                  \       = log(|delta_y|) - log(|delta_x|)
 SEC                    \
 SBC logL,X             \ by first subtracting the low bytes of log(Q) - log(P)

 BMI LIlog4             \ If A > 127, jump to LIlog4

 LDX Q                  \ And then subtracting the high bytes of log(Q) - log(P)
 LDA log,X              \ so now A contains the high byte of log(Q) - log(P)
 LDX P
 SBC log,X

 BCS LIlog5             \ If the subtraction fitted into one byte and didn't
                        \ underflow, then log(Q) - log(P) < 256, so we jump to
                        \ LIlog5 to return a result of 255

 TAX                    \ Otherwise we set A to the A-th entry from the antilog
 LDA antilog,X          \ table so the result of the division is now in A

 JMP LIlog6             \ Jump to LIlog6 to return the result

.LIlog5

 LDA #255               \ The division is very close to 1, so set A to the
 BNE LIlog6             \ closest possible answer to 256, i.e. 255, and jump to
                        \ LIlog6 to return the result (this BNE is effectively a
                        \ JMP as A is never zero)

.LIlog7

 LDA #0                 \ The numerator in the division is 0, so set A to 0 and
 BEQ LIlog6             \ jump to LIlog6 to return the result (this BEQ is
                        \ effectively a JMP as A is always zero)

.LIlog4

 LDX Q                  \ Subtract the high bytes of log(Q) - log(P) so now A
 LDA log,X              \ contains the high byte of log(Q) - log(P)
 LDX P
 SBC log,X

 BCS LIlog5             \ If the subtraction fitted into one byte and didn't
                        \ underflow, then log(Q) - log(P) < 256, so we jump to
                        \ LIlog5 to return a result of 255

 TAX                    \ Otherwise we set A to the A-th entry from the
 LDA antilogODD,X       \ antilogODD so the result of the division is now in A

.LIlog6

 STA Q                  \ Store the result of the division in Q, so we have:
                        \
                        \   Q = |delta_y| / |delta_x|

 LDX P                  \ Set X = P
                        \       = |delta_x|

 BEQ LIEXS              \ If |delta_x| = 0, return from the subroutine, as LIEXS
                        \ contains a BEQ LIEX instruction, and LIEX contains an
                        \ RTS

 INX                    \ Set X = P + 1
                        \       = |delta_x| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA Y2                 \ If Y2 < Y1 then skip the following instruction
 CMP Y1
 BCC P%+5

 JMP DOWN               \ Y2 >= Y1, so jump to DOWN, as we need to draw the line
                        \ to the right and down

\ ******************************************************************************
\
\       Name: LOIN (Part 3 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and up or left and down
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and up (no swap) or left and down (swap)
\
\   * X1 < X2 and Y1 > Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right, omitting the
\     first pixel
\
\ This routine looks complex, but that's because the loop that's used in the
\ cassette and disc versions has been unrolled to speed it up. The algorithm is
\ unchanged, it's just a lot longer.
\
\ ******************************************************************************

 LDA #%10001000         \ Modify the value in the LDA instruction at LI100 below
 AND COL                \ to contain a pixel mask for the first pixel in the
 STA LI100+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%01000100         \ Modify the value in the LDA instruction at LI110 below
 AND COL                \ to contain a pixel mask for the second pixel in the
 STA LI110+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%00100010         \ Modify the value in the LDA instruction at LI120 below
 AND COL                \ to contain a pixel mask for the third pixel in the
 STA LI120+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%00010001         \ Modify the value in the LDA instruction at LI130 below
 AND COL                \ to contain a pixel mask for the fourth pixel in the
 STA LI130+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

                        \ We now work our way along the line from left to right,
                        \ using X as a decreasing counter, and at each count we
                        \ plot a single pixel using the pixel mask in R

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI190              \ so jump down to LI190 to plot the first pixel

                        \ If we get here then we want to omit the first pixel

 LDA R                  \ Fetch the pixel byte from R, which we set in part 2 to
                        \ the horizontal pixel number within the character block
                        \ where the line starts (so it's 0, 1, 2 or 3)

 BEQ LI100+6            \ If R = 0, jump to LI100+6 to start plotting from the
                        \ second pixel in this byte (LI100+6 points to the DEX
                        \ instruction after the EOR/STA instructions, so the
                        \ pixel doesn't get plotted but we join at the right
                        \ point to decrement X correctly to plot the next three)

 CMP #2                 \ If R < 2 (i.e. R = 1), jump to LI110+6 to skip the
 BCC LI110+6            \ first two pixels but plot the next two

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

 BEQ LI120+6            \ If R = 2, jump to LI120+6 to skip the first three
                        \ pixels but plot the last one

 BNE LI130+6            \ If we get here then R must be 3, so jump to LI130+6 to
                        \ skip plotting any of the pixels, but making sure we
                        \ join the routine just after the plotting instructions

.LI190

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

 LDA R                  \ Fetch the pixel byte from R, which we set in part 2 to
                        \ the horizontal pixel number within the character block
                        \ where the line starts (so it's 0, 1, 2 or 3)

 BEQ LI100              \ If R = 0, jump to LI100 to start plotting from the
                        \ first pixel in this byte

 CMP #2                 \ If R < 2 (i.e. R = 1), jump to LI110 to start plotting
 BCC LI110              \ from the second pixel in this byte

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

 BEQ LI120              \ If R = 2, jump to LI120 to start plotting from the
                        \ third pixel in this byte

 JMP LI130              \ If we get here then R must be 3, so jump to LI130 to
                        \ start plotting from the fourth pixel in this byte

.LI100

 LDA #%10001000         \ Set a mask in A to the first pixel in the 4-pixel byte
                        \ (note that this value is modified by the code at the
                        \ start of this section to be a bit mask for the colour
                        \ in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

.LIEXS

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI110              \ If the addition didn't overflow, jump to LI110

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 DEY                    \ decrement Y to move to the pixel line above

 BMI LI101              \ If Y is negative we need to move up into the character
                        \ block above, so jump to LI101 to decrement the screen
                        \ address accordingly (jumping back to LI110 afterwards)

.LI110

 LDA #%01000100         \ Set a mask in A to the second pixel in the 4-pixel
                        \ byte (note that this value is modified by the code at
                        \ the start of this section to be a bit mask for the
                        \ colour in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI120              \ If the addition didn't overflow, jump to LI120

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 DEY                    \ decrement Y to move to the pixel line above

 BMI LI111              \ If Y is negative we need to move up into the character
                        \ block above, so jump to LI111 to decrement the screen
                        \ address accordingly (jumping back to LI120 afterwards)

.LI120

 LDA #%00100010         \ Set a mask in A to the third pixel in the 4-pixel byte
                        \ (note that this value is modified by the code at the
                        \ start of this section to be a bit mask for the colour
                        \ in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI130              \ If the addition didn't overflow, jump to LI130

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 DEY                    \ decrement Y to move to the pixel line above

 BMI LI121              \ If Y is negative we need to move up into the character
                        \ block above, so jump to LI121 to decrement the screen
                        \ address accordingly (jumping back to LI130 afterwards)

.LI130

 LDA #%00010001         \ Set a mask in A to the fourth pixel in the 4-pixel
                        \ byte (note that this value is modified by the code at
                        \ the start of this section to be a bit mask for the
                        \ colour in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI140              \ If the addition didn't overflow, jump to LI140

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 DEY                    \ decrement Y to move to the pixel line above

 BMI LI131              \ If Y is negative we need to move up into the character
                        \ block above, so jump to LI131 to decrement the screen
                        \ address accordingly (jumping back to LI140 afterwards)

.LI140

 DEX                    \ Decrement the counter in X

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

 BCC LI100              \ If the addition didn't overflow, jump back to LI100
                        \ to plot the next pixel

 INC SC+1               \ Otherwise the low byte of SC(1 0) just overflowed, so
                        \ increment the high byte SC+1 as we just crossed over
                        \ into the right half of the screen

 CLC                    \ Clear the C flag to avoid breaking any arithmetic

 BCC LI100              \ Jump back to LI100 to plot the next pixel

.LI101

 DEC SC+1               \ If we get here then we need to move up into the
 DEC SC+1               \ character block above, so we decrement the high byte
 LDY #7                 \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the last line in
                        \ that character block

 BPL LI110              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI111

 DEC SC+1               \ If we get here then we need to move up into the
 DEC SC+1               \ character block above, so we decrement the high byte
 LDY #7                 \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the last line in
                        \ that character block

 BPL LI120              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI121

 DEC SC+1               \ If we get here then we need to move up into the
 DEC SC+1               \ character block above, so we decrement the high byte
 LDY #7                 \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the last line in
                        \ that character block

 BPL LI130              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI131

 DEC SC+1               \ If we get here then we need to move up into the
 DEC SC+1               \ character block above, so we decrement the high byte
 LDY #7                 \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the last line in
                        \ that character block

 BPL LI140              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LIEX

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 4 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and down or left and up
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and down (no swap) or left and up (swap)
\
\   * X1 < X2 and Y1 <= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right, omitting the
\     first pixel
\
\ This routine looks complex, but that's because the loop that's used in the
\ cassette and disc versions has been unrolled to speed it up. The algorithm is
\ unchanged, it's just a lot longer.
\
\ ******************************************************************************

.DOWN

 LDA #%10001000         \ Modify the value in the LDA instruction at LI200 below
 AND COL                \ to contain a pixel mask for the first pixel in the
 STA LI200+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%01000100         \ Modify the value in the LDA instruction at LI210 below
 AND COL                \ to contain a pixel mask for the second pixel in the
 STA LI210+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%00100010         \ Modify the value in the LDA instruction at LI220 below
 AND COL                \ to contain a pixel mask for the third pixel in the
 STA LI220+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA #%00010001         \ Modify the value in the LDA instruction at LI230 below
 AND COL                \ to contain a pixel mask for the fourth pixel in the
 STA LI230+1            \ 4-pixel byte, in the colour COL, so that it draws in
                        \ the correct colour

 LDA SC                 \ Set SC(1 0) = SC(1 0) - 248
 SBC #248
 STA SC
 LDA SC+1
 SBC #0
 STA SC+1

 TYA                    \ Set bits 3-7 of Y, which contains the pixel row within
 EOR #%11111000         \ the character, and is therefore in the range 0-7, so
 TAY                    \ this does Y = 248 + Y
                        \
                        \ We therefore have the following:
                        \
                        \   SC(1 0) + Y = SC(1 0) - 248 + 248 + Y
                        \               = SC(1 0) + Y
                        \
                        \ so the screen location we poke hasn't changed, but Y
                        \ is now a larger number and SC is smaller. This means
                        \ we can increment Y to move down a line, as per usual,
                        \ but we can test for when it reaches the bottom of the
                        \ character block with a simple BEQ rather than checking
                        \ whether it's reached 8, so this appears to be a code
                        \ optimisation

                        \ We now work our way along the line from left to right,
                        \ using X as a decreasing counter, and at each count we
                        \ plot a single pixel using the pixel mask in R

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI191              \ so jump down to LI191 to plot the first pixel

                        \ If we get here then we want to omit the first pixel

 LDA R                  \ Fetch the pixel byte from R, which we set in part 2 to
                        \ the horizontal pixel number within the character block
                        \ where the line starts (so it's 0, 1, 2 or 3)

 BEQ LI200+6            \ If R = 0, jump to LI200+6 to start plotting from the
                        \ second pixel in this byte (LI200+6 points to the DEX
                        \ instruction after the EOR/STA instructions, so the
                        \ pixel doesn't get plotted but we join at the right
                        \ point to decrement X correctly to plot the next three)

 CMP #2                 \ If R < 2 (i.e. R = 1), jump to LI210+6 to skip the
 BCC LI210+6            \ first two pixels but plot the next two

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

 BEQ LI220+6            \ If R = 2, jump to LI220+6 to skip the first three
                        \ pixels but plot the last one

 BNE LI230+6            \ If we get here then R must be 3, so jump to LI230+6 to
                        \ skip plotting any of the pixels, but making sure we
                        \ join the routine just after the plotting instructions

.LI191

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

 LDA R                  \ Fetch the pixel byte from R, which we set in part 2 to
                        \ the horizontal pixel number within the character block
                        \ where the line starts (so it's 0, 1, 2 or 3)

 BEQ LI200              \ If R = 0, jump to LI200 to start plotting from the
                        \ first pixel in this byte

 CMP #2                 \ If R < 2 (i.e. R = 1), jump to LI210 to start plotting
 BCC LI210              \ from the second pixel in this byte

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

 BEQ LI220              \ If R = 2, jump to LI220 to start plotting from the
                        \ third pixel in this byte

 BNE LI230              \ If we get here then R must be 3, so jump to LI130 to
                        \ start plotting from the fourth pixel in this byte
                        \ (this BNE is effectively a JMP as by now R is never
                        \ zero)

.LI200

 LDA #%10001000         \ Set a mask in A to the first pixel in the 4-pixel byte
                        \ (note that this value is modified by the code at the
                        \ start of this section to be a bit mask for the colour
                        \ in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI210              \ If the addition didn't overflow, jump to LI210

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 INY                    \ increment Y to move to the pixel line below

 BEQ LI201              \ If Y is zero we need to move down into the character
                        \ block below, so jump to LI201 to increment the screen
                        \ address accordingly (jumping back to LI210 afterwards)

.LI210

 LDA #%01000100         \ Set a mask in A to the second pixel in the 4-pixel
                        \ byte (note that this value is modified by the code at
                        \ the start of this section to be a bit mask for the
                        \ colour in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX               \ If we have just reached the right end of the line,
                        \ jump to LIEX to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI220              \ If the addition didn't overflow, jump to LI220

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 INY                    \ increment Y to move to the pixel line below

 BEQ LI211              \ If Y is zero we need to move down into the character
                        \ block below, so jump to LI211 to increment the screen
                        \ address accordingly (jumping back to LI220 afterwards)

.LI220

 LDA #%00100010         \ Set a mask in A to the third pixel in the 4-pixel byte
                        \ (note that this value is modified by the code at the
                        \ start of this section to be a bit mask for the colour
                        \ in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX2              \ If we have just reached the right end of the line,
                        \ jump to LIEX2 to return from the subroutine

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI230              \ If the addition didn't overflow, jump to LI230

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 INY                    \ increment Y to move to the pixel line below

 BEQ LI221              \ If Y is zero we need to move down into the character
                        \ block below, so jump to LI221 to increment the screen
                        \ address accordingly (jumping back to LI230 afterwards)

.LI230

 LDA #%00010001         \ Set a mask in A to the fourth pixel in the 4-pixel
                        \ byte (note that this value is modified by the code at
                        \ the start of this section to be a bit mask for the
                        \ colour in COL)

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LI240              \ If the addition didn't overflow, jump to LI240

 CLC                    \ Otherwise we just overflowed, so clear the C flag and
 INY                    \ increment Y to move to the pixel line below

 BEQ LI231              \ If Y is zero we need to move down into the character
                        \ block below, so jump to LI231 to increment the screen
                        \ address accordingly (jumping back to LI240 afterwards)

.LI240

 DEX                    \ Decrement the counter in X

 BEQ LIEX2              \ If we have just reached the right end of the line,
                        \ jump to LIEX2 to return from the subroutine

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

 BCC LI200              \ If the addition didn't overflow, jump back to LI200
                        \ to plot the next pixel

 INC SC+1               \ Otherwise the low byte of SC(1 0) just overflowed, so
                        \ increment the high byte SC+1 as we just crossed over
                        \ into the right half of the screen

 CLC                    \ Clear the C flag to avoid breaking any arithmetic

 BCC LI200              \ Jump back to LI200 to plot the next pixel

.LI201

 INC SC+1               \ If we get here then we need to move down into the
 INC SC+1               \ character block below, so we increment the high byte
 LDY #248               \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the first line in that
                        \ character block (as we subtracted 248 from SC above)

 BNE LI210              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI211

 INC SC+1               \ If we get here then we need to move down into the
 INC SC+1               \ character block below, so we increment the high byte
 LDY #248               \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the first line in that
                        \ character block (as we subtracted 248 from SC above)

 BNE LI220              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI221

 INC SC+1               \ If we get here then we need to move down into the
 INC SC+1               \ character block below, so we increment the high byte
 LDY #248               \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the first line in that
                        \ character block (as we subtracted 248 from SC above)

 BNE LI230              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LI231

 INC SC+1               \ If we get here then we need to move down into the
 INC SC+1               \ character block below, so we increment the high byte
 LDY #248               \ of the screen twice (as there are two pages per screen
                        \ row) and set the pixel line to the first line in that
                        \ character block (as we subtracted 248 from SC above)

 BNE LI240              \ Jump back to the instruction after the BMI that called
                        \ this routine

.LIEX2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 5 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a steep gradient, step up along y-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| >= |delta_x|
\
\   * The line is closer to being vertical than horizontal
\
\   * We are going to step up along the y-axis
\
\   * We potentially swap coordinates to make sure Y1 >= Y2
\
\ ******************************************************************************

.STPY

 LDY Y1                 \ Set A = Y = Y1
 TYA

 LDX X1                 \ Set X = X1

 CPY Y2                 \ If Y1 >= Y2, jump down to LI15, as the coordinates are
 BCS LI15               \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 STA Y1
 STY Y2

 TAY                    \ Set Y = A = Y1

.LI15

                        \ By this point we know the line is vertical-ish and
                        \ Y1 >= Y2, so we're going from top to bottom as we go
                        \ from Y1 to Y2

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y1, and
                        \ store it in the high byte of SC(1 0) at SC+1, so the
                        \ high byte of SC is set correctly for drawing our line

 TXA                    \ Set A = 2 * bits 2-6 of X1
 AND #%11111100         \
 ASL A                  \ and shift bit 7 of X1 into the C flag

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw the
                        \ start of our line on

 BCC P%+4               \ If bit 7 of X1 was set, so X1 > 127, increment the
 INC SC+1               \ high byte of SC(1 0) to point to the second page on
                        \ this screen row, as this page contains the right half
                        \ of the row

 TXA                    \ Set X = X1 mod 4, which is the horizontal pixel number
 AND #3                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 4 pixels
                        \ wide)

 LDA TWOS,X             \ Fetch a 1-pixel byte from TWOS where pixel X is set,
 STA R                  \ and store it in R

                        \ The following section calculates:
                        \
                        \   P = P / Q
                        \     = |delta_x| / |delta_y|
                        \
                        \ using the log tables at logL and log to calculate:
                        \
                        \   A = log(P) - log(Q)
                        \     = log(|delta_x|) - log(|delta_y|)
                        \
                        \ by first subtracting the low bytes of the logarithms
                        \ from the table at LogL, and then subtracting the high
                        \ bytes from the table at log, before applying the
                        \ antilog to get the result of the division and putting
                        \ it in P

 LDX P                  \ Set X = |delta_x|

 BEQ LIfudge            \ If |delta_x| = 0, jump to LIfudge to return 0 as the
                        \ result of the division

 LDA logL,X             \ Set A = log(P) - log(Q)
 LDX Q                  \       = log(|delta_x|) - log(|delta_y|)
 SEC                    \
 SBC logL,X             \ by first subtracting the low bytes of log(P) - log(Q)

 BMI LIloG              \ If A > 127, jump to LIloG

 LDX P                  \ And then subtracting the high bytes of log(P) - log(Q)
 LDA log,X              \ so now A contains the high byte of log(P) - log(Q)
 LDX Q
 SBC log,X

 BCS LIlog3             \ If the subtraction fitted into one byte and didn't
                        \ underflow, then log(P) - log(Q) < 256, so we jump to
                        \ LIlog3 to return a result of 255

 TAX                    \ Otherwise we set A to the A-th entry from the antilog
 LDA antilog,X          \ table so the result of the division is now in A

 JMP LIlog2             \ Jump to LIlog2 to return the result

.LIlog3

 LDA #255               \ The division is very close to 1, so set A to the
 BNE LIlog2             \ closest possible answer to 256, i.e. 255, and jump to
                        \ LIlog2 to return the result (this BNE is effectively a
                        \ JMP as A is never zero)

.LIloG

 LDX P                  \ Subtract the high bytes of log(P) - log(Q) so now A
 LDA log,X              \ contains the high byte of log(P) - log(Q)
 LDX Q
 SBC log,X

 BCS LIlog3             \ If the subtraction fitted into one byte and didn't
                        \ underflow, then log(P) - log(Q) < 256, so we jump to
                        \ LIlog3 to return a result of 255

 TAX                    \ Otherwise we set A to the A-th entry from the
 LDA antilogODD,X       \ antilogODD so the result of the division is now in A

.LIlog2

 STA P                  \ Store the result of the division in P, so we have:
                        \
                        \   P = |delta_x| / |delta_y|

.LIfudge

 LDX Q                  \ Set X = Q
                        \       = |delta_y|

 BEQ LIEX7              \ If |delta_y| = 0, jump down to LIEX7 to return from
                        \ the subroutine

 INX                    \ Set X = Q + 1
                        \       = |delta_y| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA X2                 \ Set A = X2 - X1
 SEC
 SBC X1

 BCS P%+6               \ If X2 >= X1 then skip the following two instructions

 JMP LFT                \ If X2 < X1 then jump to LFT, as we need to draw the
                        \ line to the left and down

.LIEX7

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 6 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and left or down and right
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and left (no swap) or down and right (swap)
\
\   * X1 < X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right, omitting the
\     first pixel
\
\ This routine looks complex, but that's because the loop that's used in the
\ cassette and disc versions has been unrolled to speed it up. The algorithm is
\ unchanged, it's just a lot longer.
\
\ ******************************************************************************

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI290              \ so jump down to LI290 to plot the first pixel

 TYA                    \ Fetch bits 0-2 of the y-coordinate, so Y contains the
 AND #7                 \ y-coordinate mod 8
 TAY

 BNE P%+5               \ If Y = 0, jump to LI307+8 to start plotting from the
 JMP LI307+8            \ pixel above the top row of this character block
                        \ (LI307+8 points to the DEX instruction after the
                        \ EOR/STA instructions, so the pixel at row 0 doesn't
                        \ get plotted but we join at the right point to
                        \ decrement X and Y correctly to continue plotting from
                        \ the character row above)

 CPY #2                 \ If Y < 2 (i.e. Y = 1), jump to LI306+8 to start
 BCS P%+5               \ plotting from row 0 of this character block, missing
 JMP LI306+8            \ out row 1

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 2, jump to LI305+8 to start plotting from row
 JMP LI305+8            \ 1 of this character block, missing out row 2

 CPY #4                 \ If Y < 4 (i.e. Y = 3), jump to LI304+8 to start
 BCS P%+5               \ plotting from row 2 of this character block, missing
 JMP LI304+8            \ out row 3

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 4, jump to LI303+8 to start plotting from row
 JMP LI303+8            \ 3 of this character block, missing out row 4

 CPY #6                 \ If Y < 6 (i.e. Y = 5), jump to LI302+8 to start
 BCS P%+5               \ plotting from row 4 of this character block, missing
 JMP LI302+8            \ out row 5

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ P%+5               \ If Y <> 6 (i.e. Y = 7), jump to LI300+8 to start
 JMP LI300+8            \ plotting from row 6 of this character block, missing
                        \ out row 7

 JMP LI301+8            \ Otherwise Y = 6, so jump to LI301+8 to start plotting
                        \ from row 5 of this character block, missing out row 6

.LI290

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

 TYA                    \ Fetch bits 0-2 of the y-coordinate, so Y contains the
 AND #7                 \ y-coordinate mod 8
 TAY

 BNE P%+5               \ If Y = 0, jump to LI307 to start plotting from row 0
 JMP LI307              \ of this character block

 CPY #2                 \ If Y < 2 (i.e. Y = 1), jump to LI306 to start plotting
 BCS P%+5               \ from row 1 of this character block
 JMP LI306

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 2, jump to LI305 to start plotting from row 2
 JMP LI305              \ of this character block

 CPY #4                 \ If Y < 4 (i.e. Y = 3), jump to LI304 (via LI304S) to
 BCC LI304S             \ start plotting from row 3 of this character block

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ LI303S             \ If Y = 4, jump to LI303 (via LI303S) to start plotting
                        \ from row 4 of this character block

 CPY #6                 \ If Y < 6 (i.e. Y = 5), jump to LI302 (via LI302S) to
 BCC LI302S             \ start plotting from row 5 of this character block

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ LI301S             \ If Y = 6, jump to LI301 (via LI301S) to start plotting
                        \ from row 6 of this character block

 JMP LI300              \ Otherwise Y = 7, so jump to LI300 to start plotting
                        \ from row 7 of this character block

.LI310

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI300, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI301              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI301 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI301              \ If the addition didn't overflow, jump to LI301 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI301S

 BCC LI301              \ Jump to LI301 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI311

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI301, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI302              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI302 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI302              \ If the addition didn't overflow, jump to LI302 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI302S

 BCC LI302              \ Jump to LI302 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI312

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI302, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI303              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI303 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI303              \ If the addition didn't overflow, jump to LI303 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI303S

 BCC LI303              \ Jump to LI303 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI313

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI303, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI304              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI304 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI304              \ If the addition didn't overflow, jump to LI304 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI304S

 BCC LI304              \ Jump to LI304 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LIEX3

 RTS                    \ Return from the subroutine

.LI300

                        \ Plot a pixel on row 7 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX3              \ If we have just reached the right end of the line,
                        \ jump to LIEX3 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI310              \ If the addition overflowed, jump to LI310 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI301 below

.LI301

                        \ Plot a pixel on row 6 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX3              \ If we have just reached the right end of the line,
                        \ jump to LIEX3 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI311              \ If the addition overflowed, jump to LI311 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI302 below

.LI302

                        \ Plot a pixel on row 5 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX3              \ If we have just reached the right end of the line,
                        \ jump to LIEX3 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI312              \ If the addition overflowed, jump to LI312 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI303 below

.LI303

                        \ Plot a pixel on row 4 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX3              \ If we have just reached the right end of the line,
                        \ jump to LIEX3 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI313              \ If the addition overflowed, jump to LI313 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI304 below

.LI304

                        \ Plot a pixel on row 3 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX4              \ If we have just reached the right end of the line,
                        \ jump to LIEX4 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI314              \ If the addition overflowed, jump to LI314 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI305 below

.LI305

                        \ Plot a pixel on row 2 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX4              \ If we have just reached the right end of the line,
                        \ jump to LIEX4 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI315              \ If the addition overflowed, jump to LI315 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI306 below

.LI306

                        \ Plot a pixel on row 1 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX4              \ If we have just reached the right end of the line,
                        \ jump to LIEX4 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI316              \ If the addition overflowed, jump to LI316 to move to
                        \ the pixel in the next character block along, which
                        \ returns us to LI307 below

.LI307

                        \ Plot a pixel on row 0 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX4              \ If we have just reached the right end of the line,
                        \ jump to LIEX4 to return from the subroutine

 DEC SC+1               \ We just reached the top of the character block, so
 DEC SC+1               \ decrement the high byte in SC(1 0) twice to point to
 LDY #7                 \ the screen row above (as there are two pages per
                        \ screen row) and set Y to point to the last row in the
                        \ new character block

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS P%+5               \ If the addition didn't overflow, jump to LI300 to
 JMP LI300              \ continue plotting in the next character block along

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI307 above, so shift the
                        \ single pixel in R to the right, so the next pixel we
                        \ plot will be at the next x-coordinate

 BCS P%+5               \ If the pixel didn't fall out of the right end of R
 JMP LI300              \ into the C flag, then jump to LI400 to continue
                        \ plotting in the next character block along

 LDA #%10001000         \ Otherwise we need to move over to the next character
 STA R                  \ along, so set a mask in R to the first pixel in the
                        \ 4-pixel byte

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ took the above BCS, so the ADC adds 8)

 BCS P%+5               \ If the addition didn't overflow, ump to LI300 to
 JMP LI300              \ continue plotting in the next character block along

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 JMP LI300              \ Jump to LI300 to continue plotting in the next
                        \ character block along

.LIEX4

 RTS                    \ Return from the subroutine

.LI314

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI304, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI305              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI305 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI305              \ If the addition didn't overflow, jump to LI305 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BCC LI305              \ Jump to LI305 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI315

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI305, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI306              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI306 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI306              \ If the addition didn't overflow, jump to LI306 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BCC LI306              \ Jump to LI306 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI316

 LSR R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI306, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LI307              \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI307 to plot the pixel
                        \ on the next character row up

 LDA #%10001000         \ Set a mask in R to the first pixel in the 4-pixel byte
 STA R

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #7                 \ character along to the right (the C flag is set as we
 STA SC                 \ didn't take the above BCC, so the ADC adds 8)

 BCC LI307              \ If the addition didn't overflow, jump to LI307 to plot
                        \ the pixel on the next character row up

 INC SC+1               \ The addition overflowed, so increment the high byte in
                        \ SC(1 0) to move to the next page in screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BCC LI307              \ Jump to LI307 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

\ ******************************************************************************
\
\       Name: LOIN (Part 7 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and right or down and left
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and right (no swap) or down and left (swap)
\
\   * X1 >= X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right, omitting the
\     first pixel
\
\ This routine looks complex, but that's because the loop that's used in the
\ cassette and disc versions has been unrolled to speed it up. The algorithm is
\ unchanged, it's just a lot longer.
\
\ ******************************************************************************

.LFT

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI291              \ so jump down to LI291 to plot the first pixel

 TYA                    \ Fetch bits 0-2 of the y-coordinate, so Y contains the
 AND #7                 \ y-coordinate mod 8
 TAY

 BNE P%+5               \ If Y = 0, jump to LI407+8 to start plotting from the
 JMP LI407+8            \ pixel above the top row of this character block
                        \ (LI407+8 points to the DEX instruction after the
                        \ EOR/STA instructions, so the pixel at row 0 doesn't
                        \ get plotted but we join at the right point to
                        \ decrement X and Y correctly to continue plotting from
                        \ the character row above)

 CPY #2                 \ If Y < 2 (i.e. Y = 1), jump to LI406+8 to start
 BCS P%+5               \ plotting from row 0 of this character block, missing
 JMP LI406+8            \ out row 1

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 2, jump to LI405+8 to start plotting from row
 JMP LI405+8            \ 1 of this character block, missing out row 2

 CPY #4                 \ If Y < 4 (i.e. Y = 3), jump to LI404+8 to start
 BCS P%+5               \ plotting from row 2 of this character block, missing
 JMP LI404+8            \ out row 3

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 4, jump to LI403+8 to start plotting from row
 JMP LI403+8            \ 3 of this character block, missing out row 4

 CPY #6                 \ If Y < 6 (i.e. Y = 5), jump to LI402+8 to start
 BCS P%+5               \ plotting from row 4 of this character block, missing
 JMP LI402+8            \ out row 5

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ P%+5               \ If Y <> 6 (i.e. Y = 7), jump to LI400+8 to start
 JMP LI400+8            \ plotting from row 6 of this character block, missing
                        \ out row 7

 JMP LI401+8            \ Otherwise Y = 6, so jump to LI401+8 to start plotting
                        \ from row 5 of this character block, missing out row 6

.LI291

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

 TYA                    \ Fetch bits 0-2 of the y-coordinate, so Y contains the
 AND #7                 \ y-coordinate mod 8
 TAY

 BNE P%+5               \ If Y = 0, jump to LI407 to start plotting from row 0
 JMP LI407              \ of this character block

 CPY #2                 \ If Y < 2 (i.e. Y = 1), jump to LI406 to start plotting
 BCS P%+5               \ from row 1 of this character block
 JMP LI406

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BNE P%+5               \ If Y = 2, jump to LI405 to start plotting from row 2
 JMP LI405              \ of this character block

 CPY #4                 \ If Y < 4 (i.e. Y = 3), jump to LI404 (via LI404S) to
 BCC LI404S             \ start plotting from row 3 of this character block

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ LI403S             \ If Y = 4, jump to LI403 (via LI403S) to start plotting
                        \ from row 4 of this character block

 CPY #6                 \ If Y < 6 (i.e. Y = 5), jump to LI402 (via LI402S) to
 BCC LI402S             \ start plotting from row 5 of this character block

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BEQ LI401S             \ If Y = 6, jump to LI401 (via LI401S) to start plotting
                        \ from row 6 of this character block

 JMP LI400              \ Otherwise Y = 7, so jump to LI400 to start plotting
                        \ from row 7 of this character block

.LI410

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI400, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI401              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI401 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI401S

 BCC LI401              \ Jump to LI401 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI411

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI410, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI402              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI402 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI402S

 BCC LI402              \ Jump to LI402 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI412

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI420, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI403              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI403 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI403S

 BCC LI403              \ Jump to LI403 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI413

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI430, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI404              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI404 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

.LI404S

 BCC LI404              \ Jump to LI404 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LIEX5

 RTS                    \ Return from the subroutine

.LI400

                        \ Plot a pixel on row 7 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX5              \ If we have just reached the right end of the line,
                        \ jump to LIEX5 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI410              \ If the addition overflowed, jump to LI410 to move to
                        \ the pixel in the row above, which returns us to LI401
                        \ below

.LI401

                        \ Plot a pixel on row 6 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX5              \ If we have just reached the right end of the line,
                        \ jump to LIEX5 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI411              \ If the addition overflowed, jump to LI411 to move to
                        \ the pixel in the row above, which returns us to LI402
                        \ below

.LI402

                        \ Plot a pixel on row 5 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX5              \ If we have just reached the right end of the line,
                        \ jump to LIEX5 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI412              \ If the addition overflowed, jump to LI412 to move to
                        \ the pixel in the row above, which returns us to LI403
                        \ below

.LI403

                        \ Plot a pixel on row 4 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX5              \ If we have just reached the right end of the line,
                        \ jump to LIEX5 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI413              \ If the addition overflowed, jump to LI413 to move to
                        \ the pixel in the row above, which returns us to LI404
                        \ below

.LI404

                        \ Plot a pixel on row 3 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX6              \ If we have just reached the right end of the line,
                        \ jump to LIEX6 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI414              \ If the addition overflowed, jump to LI414 to move to
                        \ the pixel in the row above, which returns us to LI405
                        \ below

.LI405

                        \ Plot a pixel on row 2 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX6              \ If we have just reached the right end of the line,
                        \ jump to LIEX6 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI415              \ If the addition overflowed, jump to LI415 to move to
                        \ the pixel in the row above, which returns us to LI406
                        \ below

.LI406

                        \ Plot a pixel on row 1 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX6              \ If we have just reached the right end of the line,
                        \ jump to LIEX6 to return from the subroutine

 DEY                    \ Decrement Y to step up along the y-axis

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS LI416              \ If the addition overflowed, jump to LI416 to move to
                        \ the pixel in the row above, which returns us to LI407
                        \ below

.LI407

                        \ Plot a pixel on row 0 of this character block

 LDA R                  \ Fetch the pixel byte from R and apply the colour in
 AND COL                \ COL to it

 EOR (SC),Y             \ Store A into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

 DEX                    \ Decrement the counter in X

 BEQ LIEX6              \ If we have just reached the right end of the line,
                        \ jump to LIEX6 to return from the subroutine

 DEC SC+1               \ We just reached the top of the character block, so
 DEC SC+1               \ decrement the high byte in SC(1 0) twice to point to
 LDY #7                 \ the screen row above (as there are two pages per
                        \ screen row) and set Y to point to the last row in the
                        \ new character block

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCS P%+5               \ If the addition didn't overflow, jump to LI400 to
 JMP LI400              \ continue plotting from row 7 of the new character
                        \ block

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI407 above, so shift the
                        \ single pixel in R to the left, so the next pixel we
                        \ plot will be at the previous x-coordinate

 BCS P%+5               \ If the pixel didn't fall out of the left end of R
 JMP LI400              \ into the C flag, then jump to LI400 to continue
                        \ plotting from row 7 of the new character block

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 JMP LI400              \ Jump to LI400 to continue plotting from row 7 of the
                        \ new character block

.LIEX6

 RTS                    \ Return from the subroutine

.LI414

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI440, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI405              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI405 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BCC LI405              \ Jump to LI405 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI415

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI450, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI406              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI406 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 BCC LI406              \ Jump to LI406 to rejoin the pixel plotting routine
                        \ (this BCC is effectively a JMP as the C flag is clear)

.LI416

 ASL R                  \ If we get here then the slope error just overflowed
                        \ after plotting the pixel in LI460, so shift the single
                        \ pixel in R to the left, so the next pixel we plot will
                        \ be at the previous x-coordinate

 BCC LI407              \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LI407 to plot the pixel
                        \ on the next character row up

 LDA #%00010001         \ Otherwise we need to move over to the next character
 STA R                  \ block to the left, so set a mask in R to the fourth
                        \ pixel in the 4-pixel byte

 LDA SC                 \ Subtract 8 from SC, so SC(1 0) now points to the
 SBC #8                 \ previous character along to the left
 STA SC

 BCS P%+4               \ If the subtraction underflowed, decrement the high
 DEC SC+1               \ byte in SC(1 0) to move to the previous page in
                        \ screen memory

 CLC                    \ Clear the C flag so it doesn't affect the arithmetic
                        \ below

 JMP LI407              \ Jump to LI407 to rejoin the pixel plotting routine

\ ******************************************************************************
\
\       Name: HLOIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Implement the OSWORD 247 command (draw the sun lines in the
\             horizontal line buffer in orange)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends an OSWORD 247 command with
\ parameters in the block at OSSC(1 0). It draws a horizontal orange line (or a
\ collection of lines) in the space view.
\
\ The parameters match those put into the HBUF block in the parasite. Each line
\ is drawn from (X1, Y1) to (X2, Y1), and lines are drawn in orange.
\
\ We do not draw a pixel at the right end of the line.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #0 = The size of the parameter block being sent
\
\                         * Byte #2 = The x-coordinate of the first line's
\                                     starting point
\
\                         * Byte #3 = The x-coordinate of the first line's end
\                                     point
\
\                         * Byte #4 = The y-coordinate of the first line
\
\                         * Byte #5 = The x-coordinate of the second line's
\                                     starting point
\
\                         * Byte #6 = The x-coordinate of the second line's end
\                                     point
\
\                         * Byte #7 = The y-coordinate of the second line
\
\                       and so on
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   HLOIN3              Draw a line from (X1, Y1) to (X2, Y1) in the current
\                       colour (we need to set Q = Y2 + 1 before calling
\                       HLOIN3 so only one line is drawn)
\
\ ******************************************************************************

.HLOIN

 LDY #0                 \ Fetch byte #0 from the parameter block (which gives
 LDA (OSSC),Y           \ size of the parameter block) and store it in Q
 STA Q

 INY                    \ Increment Y to point to byte #2, which is where the
 INY                    \ line coordinates start

.HLLO

 LDA (OSSC),Y           \ Fetch the Y-th byte from the parameter block (the
 STA X1                 \ line's X1 coordinate) and store it in X1 and X
 TAX

 INY                    \ Fetch the Y+1-th byte from the parameter block (the
 LDA (OSSC),Y           \ line's X2 coordinate) and store it in X2
 STA X2

 INY                    \ Fetch the Y+2-th byte from the parameter block (the
 LDA (OSSC),Y           \ line's Y1 coordinate) and store it in Y1
 STA Y1

 STY Y2                 \ Store the parameter block offset for this line's Y1
                        \ coordinate in Y2, so we know where to fetch the next
                        \ line from in the parameter block once we have drawn
                        \ this one

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\AND #3                 \ Set A to the correct order of red/yellow pixels to
\TAY                    \ make this line an orange colour (by using bits 0-1 of
\LDA orange,Y           \ the pixel y-coordinate as the index into the orange
                        \ lookup table)

                        \ --- And replaced by: -------------------------------->

 LDA #WHITE_3D          \ Set A to white rather than orange

                        \ --- End of replacement ------------------------------>

.HLOIN3

 STA S                  \ Store the line colour in S

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\CPX X2                 \ If X1 = X2 then the start and end points are the same,
\BEQ HL6                \ so jump to HL6 to move on to the next line

                        \ --- And replaced by: -------------------------------->

 CPX X2                 \ If X1 <> X2 then jump to hori2 to skip the following
 BNE hori2

                        \ If we get here then X1 = X2, so the start and end
                        \ points are the same and we do not have a line to draw

 LDA Y1                 \ If Y1 <> 255 then jump to hori1 to skip the following
 CMP #255
 BNE hori1

 STX xLeftStart         \ This is the first part in a two-part line and the line
 STX xLeftEnd           \ in the first part (the new line) is blank, so set the
 STX xCoreStart         \ coordinates of the new line to pass the fact that it
 STX xCoreEnd           \ is blank to the second part (by ensuring the start and
 STX xRightStart        \ end coordinates are the same)
 STX xRightEnd

.hori1

 JMP hori7              \ Jump to hori7 to move on to the next line, as there is
                        \ no line to draw

.hori2
                        \ --- End of replacement ------------------------------>

 BCC HL5                \ If X1 < X2, jump to HL5 to skip the following code, as
                        \ (X1, Y1) is already the left point

 LDA X2                 \ Swap the values of X1 and X2, so we know that (X1, Y1)
 STA X1                 \ is on the left and (X2, Y1) is on the right
 STX X2

 TAX                    \ Set X = X1

.HL5

 DEC X2                 \ Decrement X2 so we do not draw a pixel at the end
                        \ point

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 LDA COL                \ If COL >= CYAN_3D then we have passed a real colour to
 CMP #CYAN_3D           \ the routine, so jump to hori6 to skip the anaglyph
 BCC hori3              \ code and draw the line in the specified colour
 JMP hori6

.hori3

                        \ If we get here then we need to draw this line in
                        \ anaglyph 3D, applying MAX_PARALLAX_P parallax

 LDA twoStageLine       \ If twoStageLine <> 255, then this is not the second
 CMP #255               \ line in a two-stage line so jump to hori4
 BNE hori4

                        \ This is the second line in a two-stage line

 LDA xCoreStart         \ Copy the values from the previous call into the
 STA xCoreStartNew      \ variables for the new line (as the new line was the
 LDA xCoreEnd           \ first to be sent)
 STA xCoreEndNew
 LDA xLeftStart
 STA xLeftStartNew
 LDA xLeftEnd
 STA xLeftEndNew
 LDA xRightStart
 STA xRightStartNew
 LDA xRightEnd
 STA xRightEndNew

.hori4

 LDA X1                 \ Store the original x-coordinates in xStart and xEnd
 STA xStart
 LDA X2
 STA xEnd

 JSR DrawFringes        \ Calculate the coordinates for the fringes and core
                        \ white line for this sun line, and draw them (but only
                        \ if Y1 <> 255, so we don't draw anything on the first
                        \ stage of a two-stage line)

 LDA Y1                 \ If Y1 = 255 then skip drawing the core white line and
 CMP #255               \ move on to the next line
 BEQ hori7

 LDA twoStageLine       \ If twoStageLine <> 255, then this is not the second
 CMP #255               \ line in a two-stage line so jump to hori4
 BNE hori5

                        \ This is the second line in a two-stage line

 JMP DrawWhiteLine      \ Draw the core white line, returning to hori8 once done

.hori5

 LDA #WHITE_3D          \ Set the colour to white for the central portion
 STA S

 LDA xCoreStart         \ If the start coordinate of the white portion is on or
 CMP xCoreEnd           \ after the end coordinate, jump to hori7 to skip
 BCS hori7              \ drawing the line centre, as the eyes do not overlap

 STA X1                 \ Set X1 = xCoreStart as the start of the white portion

 LDA xCoreEnd           \ Set X2 = xCoreEnd as the end of the white portion
 STA X2

.hori6

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.hori7

 LDY Y1                 \ Set twoStageLine to Y1, so it will be 255 if this line
 STY twoStageLine       \ was the first in a two-stage line

.hori8

 LDY Y2                 \ Set Y to the parameter block offset for this line's Y1
                        \ coordinate, which we stored in Y2 before we drew the
                        \ line

 INY                    \ Increment Y so that it points to the first parameter
                        \ for the next line in the parameter block

 CPY Q                  \ If Y = Q then we have drawn all the lines in the
 BEQ P%+5               \ parameter block, so skip the next instruction to
                        \ return from the subroutine

 JMP HLLO               \ There is another line in the parameter block after the
                        \ one we just drew, so jump to HLLO with Y pointing to
                        \ the new line's coordinates, so we can draw it

 RTS                    \ Return from the subroutine

.hori9

                        \ The horizontal line code is now a subroutine, as we
                        \ have terminated it with an RTS below

 LDX X1                 \ Set X = X1

                        \ --- End of added code ------------------------------->

 LDY Y1                 \ Look up the page number of the character row that
 LDA ylookup,Y          \ contains the pixel with the y-coordinate in Y1, and
 STA SC+1               \ store it in SC+1, so the high byte of SC is set
                        \ correctly for drawing our line

 TYA                    \ Set A = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw our line (as
                        \ each character block has 8 rows)

 STA SC                 \ Store this value in SC, so SC(1 0) now contains the
                        \ screen address of the far left end (x-coordinate = 0)
                        \ of the horizontal pixel row that we want to draw our
                        \ horizontal line on

 TXA                    \ Set Y = 2 * bits 2-6 of X1
 AND #%11111100         \
 ASL A                  \ and shift bit 7 of X1 into the C flag
 TAY

 BCC P%+4               \ If bit 7 of X1 was set, so X1 > 127, increment the
 INC SC+1               \ high byte of SC(1 0) to point to the second page on
                        \ this screen row, as this page contains the right half
                        \ of the row

.HL1

 TXA                    \ Set T = bits 2-7 of X1, which will contain the
 AND #%11111100         \ character number of the start of the line * 4
 STA T

 LDA X2                 \ Set A = bits 2-7 of X2, which will contain the
 AND #%11111100         \ character number of the end of the line * 4

 SEC                    \ Set A = A - T, which will contain the number of
 SBC T                  \ character blocks we need to fill - 1 * 4

 BEQ HL2                \ If A = 0 then the start and end character blocks are
                        \ the same, so the whole line fits within one block, so
                        \ jump down to HL2 to draw the line

                        \ Otherwise the line spans multiple characters, so we
                        \ start with the left character, then do any characters
                        \ in the middle, and finish with the right character

 LSR A                  \ Set R = A / 4, so R now contains the number of
 LSR A                  \ character blocks we need to fill - 1
 STA R

 LDA X1                 \ Set X = X1 mod 4, which is the horizontal pixel number
 AND #3                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 4 pixels
                        \ wide)

 LDA TWFR,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ right end of the byte (so the filled pixels start at
                        \ point X and go all the way to the end of the byte),
                        \ which is the shape we want for the left end of the
                        \ line

 AND S                  \ Apply the pixel mask in A to the four-pixel block of
                        \ coloured pixels in S, so we now know which bits to set
                        \ in screen memory to paint the relevant pixels in the
                        \ required colour

 EOR (SC),Y             \ Store this into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen,
                        \ so we have now drawn the line's left cap

 TYA                    \ Set Y = Y + 8 so (SC),Y points to the next character
 ADC #8                 \ block along, on the same pixel row as before
 TAY

 BCS HL7                \ If the above addition overflowed, then we have just
                        \ crossed over from the left half of the screen into the
                        \ right half, so call HL7 to increment the high byte in
                        \ SC+1 so that SC(1 0) points to the page in screen
                        \ memory for the right half of the screen row. HL7 also
                        \ clears the C flag and jumps back to HL8, so this acts
                        \ like a conditional JSR instruction

.HL8

 LDX R                  \ Fetch the number of character blocks we need to fill
                        \ from R

 DEX                    \ Decrement the number of character blocks in X

 BEQ HL3                \ If X = 0 then we only have the last block to do (i.e.
                        \ the right cap), so jump down to HL3 to draw it

 CLC                    \ Otherwise clear the C flag so we can do some additions
                        \ while we draw the character blocks with full-width
                        \ lines in them

.HLL1

 LDA S                  \ Store a full-width 4-pixel horizontal line of colour S
 EOR (SC),Y             \ in SC(1 0) so that it draws the line on-screen, using
 STA (SC),Y             \ EOR logic so it merges with whatever is already
                        \ on-screen

 TYA                    \ Set Y = Y + 8 so (SC),Y points to the next character
 ADC #8                 \ block along, on the same pixel row as before
 TAY

 BCS HL9                \ If the above addition overflowed, then we have just
                        \ crossed over from the left half of the screen into the
                        \ right half, so call HL9 to increment the high byte in
                        \ SC+1 so that SC(1 0) points to the page in screen
                        \ memory for the right half of the screen row. HL9 also
                        \ clears the C flag and jumps back to HL10, so this acts
                        \ like a conditional JSR instruction

.HL10

 DEX                    \ Decrement the number of character blocks in X

 BNE HLL1               \ Loop back to draw more full-width lines, if we have
                        \ any more to draw

.HL3

 LDA X2                 \ Now to draw the last character block at the right end
 AND #3                 \ of the line, so set X = X2 mod 3, which is the
 TAX                    \ horizontal pixel number where the line ends

 LDA TWFL,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ left end of the byte (so the filled pixels start at
                        \ the left edge and go up to point X), which is the
                        \ shape we want for the right end of the line

 AND S                  \ Apply the pixel mask in A to the four-pixel block of
                        \ coloured pixels in S, so we now know which bits to set
                        \ in screen memory to paint the relevant pixels in the
                        \ required colour

 EOR (SC),Y             \ Store this into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen,
                        \ so we have now drawn the line's right cap

.HL6

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDY Y2                 \ Set Y to the parameter block offset for this line's Y1
\                       \ coordinate, which we stored in Y2 before we drew the
\                       \ line
\
\INY                    \ Increment Y so that it points to the first parameter
\                       \ for the next line in the parameter block
\
\CPY Q                  \ If Y = Q then we have drawn all the lines in the
\BEQ P%+5               \ parameter block, so skip the next instruction to
\                       \ return from the subroutine
\
\JMP HLLO               \ There is another line in the parameter block after the
\                       \ one we just drew, so jump to HLLO with Y pointing to
\                       \ the new line's coordinates, so we can draw it

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

.HL2

                        \ If we get here then the entire horizontal line fits
                        \ into one character block

 LDA X1                 \ Set X = X1 mod 4, which is the horizontal pixel number
 AND #3                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 4 pixels
                        \ wide)

 LDA TWFR,X             \ Fetch a ready-made byte with X pixels filled in at the
 STA T                  \ right end of the byte (so the filled pixels start at
                        \ point X and go all the way to the end of the byte)

 LDA X2                 \ Set X = X2 mod 4, which is the horizontal pixel number
 AND #3                 \ where the line ends
 TAX

 LDA TWFL,X             \ Fetch a ready-made byte with X pixels filled in at the
                        \ left end of the byte (so the filled pixels start at
                        \ the left edge and go up to point X)

 AND T                  \ We now have two bytes, one (T) containing pixels from
                        \ the starting point X1 onwards, and the other (A)
                        \ containing pixels up to the end point at X2, so we can
                        \ get the actual line we want to draw by AND'ing them
                        \ together. For example, if we want to draw a line from
                        \ point 1 to point 2 (within the row of 4 pixels
                        \ numbered from 0 to 3), we would have this:
                        \
                        \   T       = %00111111
                        \   A       = %11111100
                        \   T AND A = %00111100
                        \
                        \ So we can stick T AND A in screen memory to get the
                        \ line we want, which is what we do here by setting
                        \ A = A AND T

 AND S                  \ Apply the pixel mask in A to the four-pixel block of
                        \ coloured pixels in S, so we now know which bits to set
                        \ in screen memory to paint the relevant pixels in the
                        \ required colour

 EOR (SC),Y             \ Store our horizontal line byte into screen memory at
 STA (SC),Y             \ SC(1 0), using EOR logic so it merges with whatever is
                        \ already on-screen

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDY Y2                 \ Set Y to the parameter block offset for this line's Y1
\                       \ coordinate, which we stored in Y2 before we drew the
\                       \ line
\
\INY                    \ Increment Y so that it points to the first parameter
\                       \ for the next line in the parameter block
\
\CPY Q                  \ If Y = Q then we have drawn all the lines in the
\BEQ P%+5               \ parameter block, so skip the next instruction to
\                       \ return from the subroutine
\
\JMP HLLO               \ There is another line in the parameter block after the
\                       \ one we just drew, so jump to HLLO with Y pointing to
\                       \ the new line's coordinates, so we can draw it

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

.HL7

 INC SC+1               \ We have just crossed over from the left half of the
                        \ screen into the right half, so increment the high byte
                        \ in SC+1 so that SC(1 0) points to the page in screen
                        \ memory for the right half of the screen row

 CLC                    \ Clear the C flag (as HL7 is called with the C flag
                        \ set, which this instruction reverts)

 JMP HL8                \ Jump back to HL8, just after the instruction that
                        \ called HL7

.HL9

 INC SC+1               \ We have just crossed over from the left half of the
                        \ screen into the right half, so increment the high byte
                        \ in SC+1 so that SC(1 0) points to the page in screen
                        \ memory for the right half of the screen row

 CLC                    \ Clear the C flag (as HL9 is called with the C flag
                        \ set, which this instruction reverts)

 JMP HL10               \ Jump back to HL10, just after the instruction that
                        \ called HL9

\ ******************************************************************************
\
\       Name: SwapCoordsAndDraw
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Ensure line coordinates are the right way around and draw the line
\
\ ******************************************************************************

.SwapCoordsAndDraw

 LDX X1                 \ If X1 < X2 then jump to swap1 to draw the line, as
 CPX X2                 \ the coordinates are already ordered correctly
 BCC swap1
 
 BEQ swap2              \ If X1 = X2 then jump to swap2 to skip drawing the line

 LDA X2                 \ Swap X1 and X2 so that X1 < X2
 STX X2
 STA X1

.swap1

 DEC X2                 \ Decrement the new end point, so we don't draw the last
                        \ pixel

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.swap2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawWhiteLine
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw the white part of a sun line but without the flicker
\
\ ******************************************************************************

.DrawWhiteLine

 LDA #WHITE_3D          \ Set the colour to white for the central portion
 STA S

 LDA xCoreStartNew      \ If there is a new line, jump to whit1
 CMP xCoreEndNew
 BCC whit1

 LDA xCoreStart         \ If there is no old line, jump to whit3
 CMP xCoreEnd
 BCS whit3

                        \ If we get here there is an old line but no new line

 LDA xCoreStart         \ Set X1 and X2 to the old line, so we erase it
 STA X1
 LDA xCoreEnd
 STA X2

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

 JMP whit3              \ Jump to whit3 to draw the fringes, if any

.whit1

                        \ If we get here there is a new line

 LDA xCoreStart         \ If there is an old line, jump to whit2
 CMP xCoreEnd
 BCC whit2

                        \ If we get here there is a new line but no old line

 LDA xCoreStartNew      \ Set X1 and X2 to the new line, so we erase it
 STA X1
 LDA xCoreEndNew
 STA X2

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

 JMP whit3              \ Jump to whit3 to draw the fringes, if any

.whit2

                        \ If we get here there are both old and new lines so we
                        \ apply the clever logic from part 3 of SUN in the
                        \ parasite code
                        \
                        \ Old line = xCoreStart to xCoreEnd (XX to XX+1)
                        \ New line = xCoreStartNew to xCoreEndNew (X1 to X2)

 INC xCoreEndNew        \ Add the final pixel back to the end of each line, as
 INC xCoreEnd           \ we removed them above

 LDA xCoreStartNew      \ Draw the left portion of the line
 STA X1
 LDA xCoreStart
 STA X2

 JSR SwapCoordsAndDraw  \ Make sure the coordinates are ordered properly and
                        \ draw the line

 LDA xCoreEndNew        \ Draw the right portion of the line
 STA X1
 LDA xCoreEnd
 STA X2

 JSR SwapCoordsAndDraw  \ Make sure the coordinates are ordered properly and
                        \ draw the line

.whit3

                        \ We also need to draw the fringes of the first line in
                        \ the two-stage process, as we didn't draw them first
                        \ time around (this is the new line)

 LDA xLeftStartNew      \ If there is no left fringe, jump to whit4 to skip the
 CMP xLeftEndNew        \ following
 BCS whit4

 STA X1                 \ Set X1 = xLeftStartNew as the start of the left
                        \ fringe

 LDA xLeftEndNew        \ Set X2 = xLeftEndNew as the end of the left fringe
 STA X2

 LDA #RED_3D            \ Set the colour of the left fringe (left eye) to red
 STA S

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.whit4

 LDA xRightStartNew     \ If there is no left fringe, jump to whit5 to skip the
 CMP xRightEndNew       \ following
 BCS whit5

 STA X1                 \ Set X1 = xRightStartNew as the start of the right
                        \ fringe

 LDA xRightEndNew       \ Set X2 = xRightEndNew as the end of the right fringe
 STA X2

 LDA #CYAN_3D           \ Set the colour of the right fringe (right eye) to cyan
 STA S

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.whit5

 LDA #0                 \ Reset the flag as we have now drawn the second line
 STA twoStageLine

 JMP hori8              \ Rejoin the sun line loop to move on to the next
                        \ line

\ ******************************************************************************
\
\       Name: DrawFringes
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw the fringes for a sun line and calculate the coordinates of
\             the white part
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   xStart              The x-coordinate of the start of the line
\
\   xEnd                The x-coordinate of the end of the line
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   xLeftStart          The x-coordinate of the start of the left fringe
\
\   xLeftEnd            The x-coordinate of the end of the left fringe
\
\   xCoreStart          The x-coordinate of the start of the white part of the
\                       sun line (the core)
\
\   xCoreEnd            The x-coordinate of the end of the white part of the
\                       sun line (the core)
\
\   xRightStart         The x-coordinate of the start of the right fringe
\
\   xRightEnd           The x-coordinate of the end of the right fringe
\
\ ******************************************************************************

.DrawFringes

                        \ We start with the left fringe

 LDA xStart             \ If the sun is not up against the left edge, jump to
 CMP #MAX_PARALLAX_P+1  \ frin1 to draw the left fringe
 BCS frin1

 STA xCoreStart         \ The sun is up against the left edge, so set the left
 STA xLeftStart         \ fringe and the start of the core to the original
 STA xLeftEnd           \ x-coordinate in xStart

 BCC frin5              \ Jump to frin5 to skip the left fringe calculation
                        \ (this BCC is effectively a JMP as we passed through a
                        \ BCS above)

.frin1

                        \ Calculate and draw the left fringe

 SEC                    \ Set A = xStart - MAX_PARALLAX_P, keeping the result
 SBC #MAX_PARALLAX_P    \ above 0
 BCS frin2
 LDA #0

.frin2

 STA X1                 \ Store the result in X1, so this is the x-coordinate of
                        \ the left end of the left fringe

 STA xLeftStart         \ Store the result in xLeftStart

 LDA xStart             \ Set X2 = xStart + MAX_PARALLAX_P, keeping the result
 CLC                    \ below 255
 ADC #MAX_PARALLAX_P
 BCC frin3
 LDA #254

.frin3

 STA X2                 \ Store the result in X2, so this is the x-coordinate of
                        \ the right end of the left fringe

 STA xLeftEnd           \ Store the result in xLeftStart

 TAX                    \ Increment the x-coordinate, keeping the result below
 INX                    \ 254
 BNE frin4
 LDX #254

.frin4

 STX xCoreStart         \ Store the x-coordinate in xCoreStart to use as the
                        \ start of the white line in the middle

 LDA Y1                 \ If Y1 = 255 then skip drawing the line
 CMP #255
 BEQ frin5

 LDA #RED_3D            \ Set the colour of the left fringe (left eye) to red
 STA S

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.frin5

                        \ Now we do the right fringe

 LDA xEnd                   \ If the sun is not up against the left edge, jump
 CMP #255-MAX_PARALLAX_P    \ to frin6 to draw the left fringe
 BCC frin6

 STA xCoreEnd           \ The sun is up against the right edge, so set the right
 STA xRightStart        \ fringe and the end of the core to the original
 STA xRightEnd          \ x-coordinate in xEnd

 BCS frin10             \ Jump to frin10 to skip the right fringe calculation
                        \ (this BCS is effectively a JMP as we passed through a
                        \ BCC above)

.frin6

                        \ Calculate and draw the right fringe

 SEC                    \ Set A = xEnd - MAX_PARALLAX_P, keeping the result
 SBC #MAX_PARALLAX_P    \ above 0
 BCS frin7
 LDA #0

.frin7

 STA X1                 \ Store the result in X1, so this is the x-coordinate of
                        \ the left end of the right fringe

 STA xRightStart        \ Store the result in xRightStart

 TAX                    \ Decrement the x-coordinate, keeping the result above 0
 BEQ frin8
 DEX

.frin8

 STX xCoreEnd           \ Store the x-coordinate in xCoreEnd to use as the end
                        \ of the white line in the middle

 LDA xEnd               \ Set A = xEnd + MAX_PARALLAX_P, keeping the result
 CLC                    \ below 254
 ADC #MAX_PARALLAX_P
 BCC frin9
 LDA #254

.frin9

 STA X2                 \ Store the result in X2, so this is the x-coordinate of
                        \ the right end of the right fringe

 STA xRightEnd          \ Store the result in xRightEnd

 LDA Y1                 \ If Y1 = 255 then skip drawing the line
 CMP #255
 BEQ frin10

 LDA #CYAN_3D           \ Set the colour of the right fringe (right eye) to cyan
 STA S

 JSR hori9              \ Draw a horizontal line from (X1, Y1) on the left to
                        \ (X2, Y1) on the right

.frin10

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TWFL
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made character rows for the left end of a horizontal line
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting horizontal line end caps in mode 1 (the top part
\ of the split screen). This table provides a byte with pixels at the left end,
\ which is used for the right end of the line.
\
\ See the HLOIN routine for details.
\
\ ******************************************************************************

.TWFL

 EQUB %10001000
 EQUB %11001100
 EQUB %11101110
 EQUB %11111111

\ ******************************************************************************
\
\       Name: TWFR
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made character rows for the right end of a horizontal line
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting horizontal line end caps in mode 1 (the top part
\ of the split screen). This table provides a byte with pixels at the left end,
\ which is used for the right end of the line.
\
\ See the HLOIN routine for details.
\
\ ******************************************************************************

.TWFR

 EQUB %11111111
 EQUB %01110111
 EQUB %00110011
 EQUB %00010001

\ ******************************************************************************
\
\       Name: orange
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Lookup table for 2-pixel mode 1 orange pixels for the sun
\
\ ------------------------------------------------------------------------------
\
\ Blocks of orange (as used when drawing the sun) have alternate red and yellow
\ pixels in a cross-hatch pattern. The cross-hatch pattern is made up of offset
\ rows that are 2 pixels high, and it is made up of red and yellow rectangles,
\ each of which is 2 pixels high and 1 pixel wide. The result looks like this:
\
\   ...ryryryryryryryry...
\   ...ryryryryryryryry...
\   ...yryryryryryryryr...
\   ...yryryryryryryryr...
\   ...ryryryryryryryry...
\   ...ryryryryryryryry...
\
\ and so on, repeating every four pixel rows.
\
\ This is implemented with the following lookup table, where bits 0-1 of the
\ pixel y-coordinate are used as the index, to fetch the correct pattern to use.
\
\ Rows with y-coordinates ending in %00 or %01 fetch the red/yellow pattern from
\ the table, while rows with y-coordinates ending in %10 or %11 fetch the
\ yellow/red pattern, so the pattern repeats every four pixel rows.
\
\ ******************************************************************************

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\.orange
\
\EQUB %10100101         \ Four mode 1 pixels of colour 2, 1, 2, 1 (red/yellow)
\EQUB %10100101
\EQUB %01011010         \ Four mode 1 pixels of colour 1, 2, 1, 2 (yellow/red)
\EQUB %01011010

                        \ --- End of removed code ----------------------------->

\ ******************************************************************************
\
\       Name: PIXEL
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Implement the OSWORD 241 command (draw space view pixels)
\  Deep dive: Drawing colour pixels in mode 5
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends an OSWORD 241 command with
\ parameters in the block at OSSC(1 0). It draws a dot (or collection of dots)
\ in the space view.
\
\ It can draw two types of dot, depending on bits 0-2 of the dot's distance:
\
\   * Draw the dot using the dot's distance to determine both the dot's colour
\     and size. This draws a 1-pixel dot, 2-pixel dash or 4-pixel square in a
\     colour that's determined by the distance (as per the colour table in
\     PXCL). These kinds of dot are sent by the PIXEL3 routine in the parasite,
\     which is used to draw explosion particles.
\
\   * Draw the dot using the dot's distance to determine the dot's size, either
\     a 2-pixel dash or 4-pixel square. The dot is always drawn in white (which
\     is actually a cyan/red stripe). These kinds of dot are sent by the PIXEL
\     routine in the parasite, which is used to draw stardust particles and dots
\     on the Long-range Chart.
\
\ The parameters match those put into the PBUF/pixbl block in the parasite.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #0 = The size of the pixel buffer being sent
\
\                         * Byte #2 = The distance of the first dot
\
\                           * Bits 0-2 clear = Draw a 2-pixel dash or 4-pixel
\                             square, as determined by the distance, in white
\                             (cyan/red)
\
\                           * Any of bits 0-2 set = Draw a 1-pixel dot, 2-pixel
\                             dash or 4-pixel square in the correct colour, as
\                             determined by the distance
\
\                         * Byte #3 = The x-coordinate of the first dot
\
\                         * Byte #4 = The y-coordinate of the first dot
\
\                         * Byte #5 = The distance of the second dot
\
\                         * Byte #6 = The x-coordinate of the second dot
\
\                         * Byte #7 = The y-coordinate of the second dot
\
\                       and so on
\
\ ******************************************************************************

.PIXEL

 LDY #0                 \ Set Q to byte #0 from the block pointed to by OSSC,
 LDA (OSSC),Y           \ which contains the size of the pixel buffer
 STA Q

 INY                    \ Increment Y to 2, so y now points at the data for the
 INY                    \ first pixel in the command block

.PXLO

 LDA (OSSC),Y           \ Set P to byte #2 from the Y-th pixel block in OSSC,
 STA P                  \ which contains the point's distance value (ZZ)

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\AND #%00000111         \ If ZZ is a multiple of 8 (which will be the case for
\BEQ PX5                \ pixels sent by the parasite's PIXEL routine), jump to
\                       \ PX5 to draw stardust particles and dots on the
\                       \ Long-range Chart

                        \ --- And replaced by: -------------------------------->

 AND #%00000111         \ If ZZ is a multiple of 8 (which will be the case for
 BNE P%+5               \ pixels sent by the parasite's PIXEL routine), jump to
 JMP PX5                \ PX5 to draw stardust particles and dots on the
                        \ Long-range Chart

                        \ The code at PX5 draws stardust particles (when COL is
                        \ non-zero) and dots on the Long-range Chart (when COL
                        \ is zero)
                        \
                        \ The following code draws explosion particles

                        \ --- End of replacement ------------------------------>

                        \ Otherwise this pixel was sent by the parasite's PIXEL3
                        \ routine and will have an odd value of ZZ, and we use
                        \ the distance value to determine the dot's colour and
                        \ size, as this is an explosion particle

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\TAX                    \ Set S to the ZZ-th value from the PXCL table, to get
\LDA PXCL,X             \ the correct colour byte for this pixel, depending on
\STA S                  \ the distance
\
\INY                    \ Increment Y to 3
\
\LDA (OSSC),Y           \ Set X to byte #3 from the Y-th pixel block in OSSC,
\TAX                    \ contains the pixel's x-coordinate

                        \ --- And replaced by: -------------------------------->

 STA P                  \ Store bits 0 to 2 of byte #2 in P, so it contains a
                        \ random number in bits 0 and 1, with bit 2 set

 LDX #0                 \ Set A = 0 to use as a source of clear bit 7s when
                        \ shifting positive parallax

 LDA (OSSC),Y           \ Set T to byte #2 from the Y-th pixel block in OSSC,
 STA T                  \ which contains the amount of parallax in bits 3 to 7

 BPL expl1              \ If A is negative, set X = %11111111 to use as a
 LDX #%11111111         \ source of set bit 7s when shifting negative parallax

.expl1

 TXA                    \ Set A to the source of bit 7s for shifting the
                        \ parallax

 LSR A                  \ Shift (A T) right by 3 bits, so that T contains the
 ROR T                  \ amount of parallax as a signed integer in pixels
 LSR A
 ROR T
 LSR A
 ROR T

 INY                    \ Increment Y to 3

 LDA (OSSC),Y           \ Set X to byte #3 from the Y-th pixel block in OSSC,
 TAX                    \ which contains the pixel's x-coordinate

 PHA                    \ Store the x-coordinate on the stack to use in the
                        \ right-eye calculation below

                        \ We now do the left-eye x-coordinate calculation

 SEC                    \ Set X = A - T to apply the left-eye parallax
 SBC T
 TAX

 LDA #RED_3D            \ Set S to red
 STA S

 JSR expl3              \ Draw the left-eye explosion particle

 LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
                        \ in the command block, which we stored in T1 in expl3

 DEY                    \ Decrement Y back to the previous coordinate

.expl2

                        \ We now do the right-eye x-coordinate calculation

 PLA                    \ Fetch the x-coordinate from the stack

 CLC                    \ Set X = A + T to apply the right-eye parallax
 ADC T
 TAX

 LDA #CYAN_3D           \ Set S to cyan
 STA S

 JSR expl3              \ Draw the right-eye explosion particle

 LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
                        \ in the command block, which we stored in T1 above

 INY                    \ Increment Y, so it now points to the first byte of
                        \ the next pixel in the command block

 CPY Q                  \ If the index hasn't reached the value in Q (which
 BNE PXLO               \ contains the size of the pixel buffer), loop back to
                        \ PXLO to draw the next pixel in the buffer

 RTS                    \ Return from the subroutine

.expl3

                        \ We call this subroutine to draw a dot with the
                        \ x-coordinate in X

                        \ --- End of replacement ------------------------------>

 INY                    \ Increment Y to 4

 LDA (OSSC),Y           \ Set Y to byte #4 from the Y-th pixel block in OSSC,
 STY T1                 \ which contains the pixel's y-coordinate, and store Y,
 TAY                    \ the index of this pixel's y-coordinate, in T1

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

 TXA                    \ Each character block contains 8 pixel rows, so to get
 AND #%11111100         \ the address of the first byte in the character block
 ASL A                  \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-1 and shift left to double
                        \ it (as each character row contains two pages of bytes,
                        \ or 512 bytes, which cover 256 pixels). This also
                        \ shifts bit 7 of the x-coordinate into the C flag

 STA SC                 \ Store the address of the character block in the low
                        \ byte of SC(1 0), so now SC(1 0) points to the
                        \ character block we need to draw into

 BCC P%+4               \ If the C flag is clear then skip the next instruction

 INC SC+1               \ The C flag is set, which means bit 7 of X1 was set
                        \ before the ASL above, so the x-coordinate is in the
                        \ right half of the screen (i.e. in the range 128-255).
                        \ Each row takes up two pages in memory, so the right
                        \ half is in the second page but SC+1 contains the value
                        \ we looked up from ylookup, which is the page number of
                        \ the first memory page for the row... so we need to
                        \ increment SC+1 to point to the correct page

 TYA                    \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 TXA                    \ Copy bits 0-1 of the x-coordinate to bits 0-1 of X,
 AND #%00000011         \ which will now be in the range 0-3, and will contain
 TAX                    \ the two pixels to show in the character row

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA P                  \ If the pixel's ZZ distance, which we stored in P, is
\BMI PX3                \ greater than 127, jump to PX3 to plot a 1-pixel dot
\
\CMP #80                \ If the pixel's ZZ distance is < 80, then the dot is
\BCC PX2                \ pretty close, so jump to PX2 to draw a four-pixel
                        \ square

                        \ --- And replaced by: -------------------------------->

                        \ P contains a random number in bits 0 and 1, with bit 2
                        \ set

 LDA P                  \ For 50% of the time, jump to PX3 to plot a 1-pixel
 CMP #%00000110         \ (i.e. when P is %00000101 or %00000100)
 BCC PX3

 CMP #%00000110         \ For 25% of the time, jump to PX2 to draw a four-pixel
 BEQ PX2                \ square (this isn't quite the 31% chance of the
                        \ existing algorithm, but it's not far off)

                        \ --- End of replacement ------------------------------>

 LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
 AND S                  \ X, and AND with the colour byte we fetched into S
                        \ so that pixel takes on the colour we want to draw
                        \ (i.e. A is acting as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
\                       \ in the command block, which we stored in T1 above
\
\INY                    \ Increment Y, so it now points to the first byte of
\                       \ the next pixel in the command block
\
\CPY Q                  \ If the index hasn't reached the value in Q (which
\BNE PXLO               \ contains the size of the pixel buffer), loop back to
\                       \ PXLO to draw the next pixel in the buffer

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

.PX2

                        \ If we get here, we need to plot a 4-pixel square in
                        \ in the correct colour for this pixel's distance

 LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
 AND S                  \ X, and AND with the colour byte we fetched into S
                        \ so that pixel takes on the colour we want to draw
                        \ (i.e. A is acting as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 DEY                    \ Reduce Y by 1 to point to the pixel row above the one
 BPL P%+4               \ we just plotted, and if it is still positive, skip the
                        \ next instruction

 LDY #1                 \ Reducing Y by 1 made it negative, which means Y was
                        \ 0 before we did the DEY above, so set Y to 1 to point
                        \ to the pixel row after the one we just plotted

                        \ We now draw our second dash

 LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
 AND S                  \ X, and AND with the colour byte we fetched into S
                        \ so that pixel takes on the colour we want to draw
                        \ (i.e. A is acting as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
\                       \ in the command block, which we stored in T1 above
\
\INY                    \ Increment Y, so it now points to the first byte of
\                       \ the next pixel in the command block
\
\CPY Q                  \ If the index hasn't reached the value in Q (which
\BNE PXLO               \ contains the size of the pixel buffer), loop back to
\                       \ PXLO to draw the next pixel in the buffer

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

.PX3

                        \ If we get here, the dot is a long way away (at a
                        \ distance that is > 127), so we want to draw a 1-pixel
                        \ dot

 LDA TWOS,X             \ Fetch a mode 1 1-pixel byte with the pixel set as in
 AND S                  \ X, and AND with the colour byte we fetched into S
                        \ so that pixel takes on the colour we want to draw
                        \ (i.e. A is acting as a mask on the colour byte)

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
\                       \ in the command block, which we stored in T1 above
\
\INY                    \ Increment Y, so it now points to the first byte of
\                       \ the next pixel in the command block
\
\CPY Q                  \ If the index hasn't reached the value in Q (which
\BNE PXLO               \ contains the size of the pixel buffer), loop back to
\                       \ PXLO to draw the next pixel in the buffer

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

.PX5

                        \ If we get here then the pixel's distance value (ZZ) is
                        \ a multiple of 8, as set by the parasite's PIXEL
                        \ routine

 INY                    \ Increment Y to 3

 LDA (OSSC),Y           \ Set X to byte #3 from the Y-th pixel block in OSSC,
 TAX                    \ contains the pixel's x-coordinate

 INY                    \ Increment Y to 4

 LDA (OSSC),Y           \ Set Y to byte #4 from the Y-th pixel block in OSSC,
 STY T1                 \ which contains the pixel's y-coordinate, and store Y,
 TAY                    \ the index of this pixel's y-coordinate, in T1

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 LDA COL                \ If the colour is non-zero then this is stardust, so
 BNE dust1              \ jump to dust1 to keep going

                        \ If we get here then this is a system chart, so we draw
                        \ the pixel once and in white

 LDA #WHITE_3D          \ Set the colour to white
 STA COL

 JSR dust6              \ Call the pixel-plotting code below, which we have
                        \ turned into a subroutine, to draw the dot

 LDA #0                 \ Reset the colour to 0 for the next dot
 STA COL

 JMP dust7              \ Jump down to dust7 draw the next dot

.dust1

                        \ We interrupt this part of the pixel-plotting routine
                        \ to draw stardust particles using anaglyph 3D, using
                        \ the particle distance in ZZ to determine the amount
                        \ of parallax to add

 TYA                    \ Store the pixel's y-coordinate on the stack so we can
 PHA                    \ retrieve it below for the right eye

 TXA                    \ Store the x-coordinate on the stack and in A
 PHA

                        \ We now calculate the amount of parallax from the
                        \ particle distance in ZZ, which we copied into P above
                        \
                        \ Particles are spawned with a random distance in ZZ
                        \ of 144 to 248, which is reduced each frame until the
                        \ particle goes off the side of the screen, or ZZ
                        \ reaches 16
                        \
                        \ As this is a stardust particle rather than an
                        \ explosion particle, the distance is a multiple of 8
                        \ and the last three bits are always zero
                        \
                        \ Stardust particles are plotted in two sizes:
                        \
                        \   * ZZ >= 80 -> 2 pixels wide, 1 pixel high
                        \   * ZZ  < 80 -> 2 pixels wide, 2 pixels high
                        \
                        \ We add positive parallax (left eye goes right) when
                        \ ZZ >= 80 and negative parallax (left eye goes left)
                        \ when ZZ < 80

 LDA P                  \ Set A = the pixel's distance in ZZ

 SEC                    \ Set A = ZZ - 80
 SBC #80                \
                        \ So this is positive when ZZ >= 80 and negative when
                        \ ZZ < 80, which is the correct sign for our parallax
                        \
                        \ ZZ is therefore in the ranges:
                        \
                        \   * 0 to 168 for positive parallax
                        \
                        \   * -1 to -64 for negative parallax
                        \
                        \ We now scale this result into the number of pixels of
                        \ parallax to apply

 BCS dust4              \ If the subtraction didn't underflow then the result
                        \ is positive, so jump to dust4 to scale the positive
                        \ parallax

                        \ If we get here then the result is negative and in the
                        \ range -1 to -64 (%11111111 to %11000000)

 LDX #%11111111         \ Scale T to the range -1 to -4 by left-shifting the top
 STX T                  \ four bits of T into bits 0 to 3 of %11111111
 ASL A                  \
 ROL T                  \ So %11111111 to %11000000 (-1 to -64) gets scaled to
 ASL A                  \ %11111111 to %11111100 (-1 to -4)
 ROL T
 ASL A
 ROL T
 ASL A
 ROL T

 INC T                  \ Increment T to the range 0 to -3

 LDX T                  \ If T is non-zero, jump to dust2 to cap the value to
 BNE dust2              \ the maximum allowed

 STX Tr                 \ Otherwise set Tr to zero as well so we don't apply
                        \ any parallax to the right eye

 BEQ dust5              \ Jump to dust5 to apply the parallax in T and Tr (this
                        \ BEQ is effectively a JMP as X is always zero)

.dust2

 CPX #256-MAX_PARALLAX_N    \ Cap T to the range 0 to -MAX_PARALLAX_N
 BCS dust3
 LDX #256-MAX_PARALLAX_N

.dust3

 STX T                  \ Store the capped value of T

                        \ We now calculate the number of pixels of parallax
                        \ using the following calculation to spread the pixels
                        \ evenly between each eye, one pixel per eye at a time:
                        \
                        \   * Right eye: add (parallax + 1) >> 1
                        \
                        \   * Left eye:  subtract parallax >> 1
                        \
                        \ We calculate the right eye in Tr and the left eye in T

 INX                    \ Set Tr = (T + 1) >> 1
 TXA
 ASL A
 TXA
 ROR A
 STA Tr

 SEC                    \ Set T = T >> 1
 ROR T

 JMP dust5              \ Jump to dust5 to apply the parallax in T

.dust4

                        \ If we get here then the result is positive and in the
                        \ range 0 to 168 (%00000000 to %10101000)

 LDX #%00000000         \ Scale T to the range 0 to 2 by left-shifting the top
 STX T                  \ two bits of T into bits 0 to 1 of %00000000
 ASL A                  \
 ROL T                  \ So %00000000 to %10101000 (0 to 168) gets scaled to
 ASL A                  \ %00000000 to %00000010 (0 to 2)
 ROL T

 INC T                  \ Increment T to the range 1 to 3

                        \ We now calculate the number of pixels of parallax
                        \ using the following calculation to spread the pixels
                        \ evenly between each eye, one pixel per eye at a time:
                        \
                        \   * Right eye: add (parallax + 1) >> 1
                        \
                        \   * Left eye:  subtract parallax >> 1
                        \
                        \ We calculate the right eye in Tr and the left eye in
                        \ T, starting with the total amount of parallax T, which
                        \ is in the range -3 to +3

 LDX T                  \ Set Tr = (T + 1) >> 1
 INX
 TXA
 LSR A
 STA Tr

 LSR T                  \ Set T = T >> 1

.dust5

                        \ By the time we get get here, T and Tr contain the
                        \ parallax to apply to each eye in pixels, so we can
                        \ simply shift each eye by this amount

                        \ We start by drawing the left-eye dot in red

 PLA                    \ Fetch the x-coordinate from the stack and into A,
 PHA                    \ leaving it on the stack for later

 SEC                    \ Apply parallax to the left-eye dot
 SBC T
 TAX

 LDA #RED_3D            \ Set the left-eye dot colour to red
 STA COL

 JSR dust6              \ Call the pixel-plotting code below, which we have
                        \ turned into a subroutine, to draw the left-eye dot

                        \ And now we draw the right-eye dot in cyan

 PLA                    \ Retrieve the x-coordinate from the stack into A

 CLC                    \ Apply parallax to the right-eye dot
 ADC Tr
 TAX

 LDA #CYAN_3D           \ Set the right-eye dot colour to cyan
 STA COL

 PLA                    \ Retrieve the y-coordinate from the stack into Y
 TAY

 JSR dust6              \ Call the pixel-plotting code below, which we have
                        \ turned into a subroutine, to draw the right-eye dot

 JMP dust7              \ Jump down to dust7 draw the next particle

.dust6

                        \ --- End of added code ------------------------------->

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

 TXA                    \ Each character block contains 8 pixel rows, so to get
 AND #%11111100         \ the address of the first byte in the character block
 ASL A                  \ that we need to draw into, as an offset from the start
                        \ of the row, we clear bits 0-1 and shift left to double
                        \ it (as each character row contains two pages of bytes,
                        \ or 512 bytes, which cover 256 pixels). This also
                        \ shifts bit 7 of the x-coordinate into the C flag

 STA SC                 \ Store the address of the character block in the low
                        \ byte of SC(1 0), so now SC(1 0) points to the
                        \ character block we need to draw into

 BCC P%+4               \ If the C flag is clear then skip the next instruction

 INC SC+1               \ The C flag is set, which means bit 7 of X1 was set
                        \ before the ASL above, so the x-coordinate is in the
                        \ right half of the screen (i.e. in the range 128-255).
                        \ Each row takes up two pages in memory, so the right
                        \ half is in the second page but SC+1 contains the value
                        \ we looked up from ylookup, which is the page number of
                        \ the first memory page for the row... so we need to
                        \ increment SC+1 to point to the correct page

 TYA                    \ Set Y to just bits 0-2 of the y-coordinate, which will
 AND #%00000111         \ be the number of the pixel row we need to draw into
 TAY                    \ within the character block

 TXA                    \ Copy bits 0-1 of the x-coordinate to bits 0-1 of X,
 AND #%00000011         \ which will now be in the range 0-3, and will contain
 TAX                    \ the two pixels to show in the character row

 LDA P                  \ Fetch the pixel's distance into P

 CMP #80                \ If the pixel's ZZ distance is >= 80, then the dot is
 BCS PX6                \ a medium distance away, so jump to PX6 to draw a
                        \ single pixel

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
\AND #WHITE             \ X, and AND with #WHITE to make it white (i.e.
\                       \ cyan/red)
\
\EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
\STA (SC),Y             \ remove it later without ruining the background that's
\                       \ already on-screen

                        \ --- And replaced by: -------------------------------->

 JSR DrawAccurateDash   \ Draw a two-pixel dash, overflowing into the next pixel
                        \ byte if required

                        \ --- End of replacement ------------------------------>

 DEY                    \ Reduce Y by 1 to point to the pixel row above the one
 BPL P%+4               \ we just plotted, and if it is still positive, skip the
                        \ next instruction

 LDY #1                 \ Reducing Y by 1 made it negative, which means Y was
                        \ 0 before we did the DEY above, so set Y to 1 to point
                        \ to the pixel row after the one we just plotted

                        \ We now draw our second dash

.PX6

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
\AND #WHITE             \ X, and AND with #WHITE to make it white (i.e.
\                       \ cyan/red)
\
\EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
\STA (SC),Y             \ remove it later without ruining the background that's
\                       \ already on-screen

                        \ --- And replaced by: -------------------------------->

 JMP DrawAccurateDash   \ Draw a two-pixel dash, overflowing into the next pixel
                        \ byte if required, and return from the subroutine using
                        \ a tail call

.dust7

                        \ --- End of replacement ------------------------------>

 LDY T1                 \ Set Y to the index of this pixel's y-coordinate byte
                        \ in the command block, which we stored in T1 above

 INY                    \ Increment Y, so it now points to the first byte of
                        \ the next pixel in the command block

 CPY Q                  \ If the index has reached the value in Q (which
 BEQ P%+5               \ contains the size of the pixel buffer), skip the next
                        \ instruction

 JMP PXLO               \ We haven't reached the end of the buffer, so loop back
                        \ to PXLO to draw the next pixel in the buffer

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawAccurateDash
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a two-pixel dash that can run over into the next pixel byte
\             if required (unlike normal stardust dashes)
\
\ ******************************************************************************

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.DrawAccurateDash

 CPX #3                 \ If the dash does not start in the last pixel of the
 BNE dash2              \ pixel byte, jump to dash2 to draw a normal dash using
                        \ TWOS2

                        \ Otherwise we need to plot one pixel in this pixel
                        \ byte and another in the next byte along, so we start
                        \ with the 

 LDA #%00010001         \ Fetch a mode 1 1-pixel byte with the last pixel set
 AND COL                \ and AND with COL to make it anaglyph cyan or red

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 TYA                    \ Store the value of Y on the stack
 PHA

 CLC                    \ Set Y = Y + 8 to move on to the next byte along,
 ADC #8                 \ skipping the following if the addition overflows
 BCS dash1
 TAY

 LDA #%10001000         \ Fetch a mode 1 1-pixel byte with the first pixel set
 AND COL                \ and AND with COL to make it anaglyph cyan or red,

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

.dash1

 PLA                    \ Restore the value of Y that we stored on the stack
 TAY

 RTS                    \ Return from the subroutine

.dash2

 LDA TWOS2,X            \ Fetch a mode 1 2-pixel byte with the pixels set as in
 AND COL                \ X, and AND with COL to make it anaglyph cyan or red

 EOR (SC),Y             \ Draw the pixel on-screen using EOR logic, so we can
 STA (SC),Y             \ remove it later without ruining the background that's
                        \ already on-screen

 RTS                    \ Return from the subroutine

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: PXCL
\       Type: Variable
\   Category: Drawing pixels
\    Summary: A four-colour mode 1 pixel byte that represents a dot's distance
\
\ ------------------------------------------------------------------------------
\
\ The following table contains colour bytes for 2-pixel mode 1 pixels, with the
\ index into the table representing distance. Closer pixels are at the top, so
\ the closest pixels are cyan/red, then yellow, then red, then red/yellow, then
\ yellow.
\
\ That said, this table is only used with odd distance values, as set in the
\ parasite's PIXEL3 routine, so in practice the four distances are yellow, red,
\ red/yellow, yellow.
\
\ ******************************************************************************

.PXCL

 EQUB WHITE             \ Four mode 1 pixels of colour 3, 2, 3, 2 (cyan/red)
 EQUB %00001111         \ Four mode 1 pixels of colour 1 (yellow)
 EQUB %00001111         \ Four mode 1 pixels of colour 1 (yellow)
 EQUB %11110000         \ Four mode 1 pixels of colour 2 (red)
 EQUB %11110000         \ Four mode 1 pixels of colour 2 (red)
 EQUB %10100101         \ Four mode 1 pixels of colour 2, 1, 2, 1 (red/yellow)
 EQUB %10100101         \ Four mode 1 pixels of colour 2, 1, 2, 1 (red/yellow)
 EQUB %00001111         \ Four mode 1 pixels of colour 1, 1, 1, 1 (yellow)

\ ******************************************************************************
\
\       Name: newosrdch
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSRDCH routine for reading characters
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ RDCHV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads. It uses the standard OSRDCH routine to
\ read characters from the input stream, and bolts on logic to check for valid
\ and invalid characters.
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   The character that is read:
\
\                         * Valid input: The character's ASCII value
\
\                         * Invalid input: 7
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.newosrdch

 JSR &FFFF              \ This address is overwritten by the STARTUP routine to
                        \ contain the original value of RDCHV, so this call acts
                        \ just like a standard JSR OSRDCH call, and reads a
                        \ character from the current input stream and stores it
                        \ in A

 CMP #128               \ If A < 128 then skip the following three instructions,
 BCC P%+6               \ otherwise the character is invalid, so fall through
                        \ into badkey to deal with it

.badkey

                        \ If we get here then the character we read is invalid,
                        \ so we return a beep character

 LDA #7                 \ Set A to the beep character

 CLC                    \ Clear the C flag

 RTS                    \ Return from the subroutine

                        \ If we get here then A < 128

 CMP #' '               \ If A >= ASCII " " then this is a valid alphanumerical
 BCS coolkey            \ key press (as A is in the range 32 to 127), so jump
                        \ down to coolkey to return this key press

 CMP #13                \ If A = 13 then this is the return character, so jump
 BEQ coolkey            \ down to coolkey to return this key press

 CMP #21                \ If A <> 21 jump up to badkey
 BNE badkey

.coolkey

                        \ If we get here then the character we read is valid, so
                        \ return it

 CLC                    \ Clear the C flag

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ADD
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A X) = (A P) + (S R)
\  Deep dive: Adding sign-magnitude numbers
\
\ ------------------------------------------------------------------------------
\
\ Add two 16-bit sign-magnitude numbers together, calculating:
\
\   (A X) = (A P) + (S R)
\
\ ******************************************************************************

.ADD

 STA T1                 \ Store argument A in T1

 AND #%10000000         \ Extract the sign (bit 7) of A and store it in T
 STA T

 EOR S                  \ EOR bit 7 of A with S. If they have different bit 7s
 BMI MU8                \ (i.e. they have different signs) then bit 7 in the
                        \ EOR result will be 1, which means the EOR result is
                        \ negative. So the AND, EOR and BMI together mean "jump
                        \ to MU8 if A and S have different signs"

                        \ If we reach here, then A and S have the same sign, so
                        \ we can add them and set the sign to get the result

 LDA R                  \ Add the least significant bytes together into X:
 CLC                    \
 ADC P                  \   X = P + R
 TAX

 LDA S                  \ Add the most significant bytes together into A. We
 ADC T1                 \ stored the original argument A in T1 earlier, so we
                        \ can do this with:
                        \
                        \   A = A  + S + C
                        \     = T1 + S + C

 ORA T                  \ If argument A was negative (and therefore S was also
                        \ negative) then make sure result A is negative by
                        \ OR'ing the result with the sign bit from argument A
                        \ (which we stored in T)

 RTS                    \ Return from the subroutine

.MU8

                        \ If we reach here, then A and S have different signs,
                        \ so we can subtract their absolute values and set the
                        \ sign to get the result

 LDA S                  \ Clear the sign (bit 7) in S and store the result in
 AND #%01111111         \ U, so U now contains |S|
 STA U

 LDA P                  \ Subtract the least significant bytes into X:
 SEC                    \
 SBC R                  \   X = P - R
 TAX

 LDA T1                 \ Restore the A of the argument (A P) from T1 and
 AND #%01111111         \ clear the sign (bit 7), so A now contains |A|

 SBC U                  \ Set A = |A| - |S|

                        \ At this point we have |A P| - |S R| in (A X), so we
                        \ need to check whether the subtraction above was the
                        \ right way round (i.e. that we subtracted the smaller
                        \ absolute value from the larger absolute value)

 BCS MU9                \ If |A| >= |S|, our subtraction was the right way
                        \ round, so jump to MU9 to set the sign

                        \ If we get here, then |A| < |S|, so our subtraction
                        \ above was the wrong way round (we actually subtracted
                        \ the larger absolute value from the smaller absolute
                        \ value). So let's subtract the result we have in (A X)
                        \ from zero, so that the subtraction is the right way
                        \ round

 STA U                  \ Store A in U

 TXA                    \ Set X = 0 - X using two's complement (to negate a
 EOR #&FF               \ number in two's complement, you can invert the bits
 ADC #1                 \ and add one - and we know the C flag is clear as we
 TAX                    \ didn't take the BCS branch above, so the ADC will do
                        \ the correct addition)

 LDA #0                 \ Set A = 0 - A, which we can do this time using a
 SBC U                  \ subtraction with the C flag clear

 ORA #%10000000         \ We now set the sign bit of A, so that the EOR on the
                        \ next line will give the result the opposite sign to
                        \ argument A (as T contains the sign bit of argument
                        \ A). This is the same as giving the result the same
                        \ sign as argument S (as A and S have different signs),
                        \ which is what we want, as S has the larger absolute
                        \ value

.MU9

 EOR T                  \ If we get here from the BCS above, then |A| >= |S|,
                        \ so we want to give the result the same sign as
                        \ argument A, so if argument A was negative, we flip
                        \ the sign of the result with an EOR (to make it
                        \ negative)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HANGER
\       Type: Subroutine
\   Category: Ship hangar
\    Summary: Implement the OSWORD 248 command (display the ship hangar)
\
\ ------------------------------------------------------------------------------
\
\ This command is sent after the ships in the hangar have been drawn, so all it
\ has to do is draw the hangar's background.
\
\ The hangar background is made up of two parts:
\
\   * The hangar floor consists of 11 screen-wide horizontal lines, which start
\     out quite spaced out near the bottom of the screen, and bunch ever closer
\     together as the eye moves up towards the horizon, where they merge to give
\     a sense of perspective
\
\   * The back wall of the hangar consists of 15 equally spaced vertical lines
\     that join the horizon to the top of the screen
\
\ The ships in the hangar have already been drawn by this point, so the lines
\ are drawn so they don't overlap anything that's already there, which makes
\ them look like they are behind and below the ships. This is achieved by
\ drawing the lines in from the screen edges until they bump into something
\ already on-screen. For the horizontal lines, when there are multiple ships in
\ the hangar, this also means drawing lines between the ships, as well as in
\ from each side.
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   HA3                 Contains an RTS
\
\ ******************************************************************************

.HANGER

                        \ We start by drawing the floor

 LDX #2                 \ We start with a loop using a counter in T that goes
                        \ from 2 to 12, one for each of the 11 horizontal lines
                        \ in the floor, so set the initial value in X

.HAL1

 STX T                  \ Store the loop counter in T

 LDA #130               \ Set A = 130

 STX Q                  \ Set Q to the value of the loop counter

 JSR DVID4              \ Calculate the following:
                        \
                        \   (P R) = 256 * A / Q
                        \         = 256 * 130 / Q
                        \
                        \ so P = 130 / Q, and as the counter Q goes from 2 to
                        \ 12, P goes 65, 43, 32 ... 13, 11, 10, with the
                        \ difference between two consecutive numbers getting
                        \ smaller as P gets smaller
                        \
                        \ We can use this value as a y-coordinate to draw a set
                        \ of horizontal lines, spaced out near the bottom of the
                        \ screen (high value of P, high y-coordinate, lower down
                        \ the screen) and bunching up towards the horizon (low
                        \ value of P, low y-coordinate, higher up the screen)

 LDA P                  \ Set Y = #Y + P
 CLC                    \
 ADC #Y                 \ where #Y is the y-coordinate of the centre of the
 TAY                    \ screen, so Y is now the horizontal pixel row of the
                        \ line we want to draw to display the hangar floor

 LDA ylookup,Y          \ Look up the page number of the character row that
 STA SC+1               \ contains the pixel with the y-coordinate in Y, and
                        \ store it in the high byte of SC(1 0) at SC+1

 STA R                  \ Also store the page number in R

 LDA P                  \ Set the low byte of SC(1 0) to the y-coordinate mod 7,
 AND #7                 \ which determines the pixel row in the character block
 STA SC                 \ we need to draw in (as each character row is 8 pixels
                        \ high), so SC(1 0) now points to the address of the
                        \ start of the horizontal line we want to draw

 LDY #0                 \ Set Y = 0 so the call to HAS2 starts drawing the line
                        \ in the first byte of the screen row, at the left edge
                        \ of the screen

 JSR HAS2               \ Draw a horizontal line from the left edge of the
                        \ screen, going right until we bump into something
                        \ already on-screen, at which point stop drawing

 LDY R                  \ Fetch the page number of the line from R, increment it
 INY                    \ so it points to the right half of the character row
 STY SC+1               \ (as each row takes up 2 pages), and store it in the
                        \ high byte of SC(1 0) at SC+1

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #%01000000         \ Now to draw the same line but from the right edge of
\                       \ the screen, so set a pixel mask in A to check the
\                       \ second pixel of the last byte, so we skip the 2-pixel
\                       \ screen border at the right edge of the screen

                        \ --- And replaced by: -------------------------------->

 LDA #%00010001         \ Now to draw the same line but from the right edge of
                        \ the screen, so set a pixel mask in A to check the
                        \ second pixel of the last byte, so we start at the
                        \ right edge of the screen

                        \ --- End of replacement ------------------------------>

 LDY #248               \ Set Y = 248 so the call to HAS3 starts drawing the
                        \ line in the last byte of the screen row, at the right
                        \ edge of the screen

 JSR HAS3               \ Draw a horizontal line from the right edge of the
                        \ screen, going left until we bump into something
                        \ already on-screen, at which point stop drawing

 LDY #2                 \ Fetch byte #2 from the parameter block, which tells us
 LDA (OSSC),Y           \ whether the ship hangar contains just one ship, or
 TAY                    \ multiple ships

 BEQ HA2                \ If byte #2 is zero, jump to HA2 to skip the following
                        \ as there is only one ship in the hangar

                        \ If we get here then there are multiple ships in the
                        \ hangar, so we also need to draw the horizontal line in
                        \ the gap between the ships

 LDY #0                 \ First we draw the line from the centre of the screen
                        \ to the right. SC(1 0) points to the start address of
                        \ the second half of the screen row, so we set Y to 0 so
                        \ the call to HAL3 starts drawing from the first
                        \ character in that second half

 LDA #%10001000         \ We want to start drawing from the first pixel, so we
                        \ set a mask in A to the first pixel in the 4-pixel byte

 JSR HAL3               \ Call HAL3, which draws a line from the halfway point
                        \ across the right half of the screen, going right until
                        \ we bump into something already on-screen, at which
                        \ point it stops drawing

 DEC SC+1               \ Decrement the high byte of SC(1 0) in SC+1 to point to
                        \ the previous page (i.e. the left half of this screen
                        \ row)

 LDY #248               \ We now draw the line from the centre of the screen
                        \ to the left. SC(1 0) points to the start address of
                        \ the first half of the screen row, so we set Y to 248
                        \ so the call to HAS3 starts drawing from the last
                        \ character in that first half

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #%00010000         \ We want to start drawing from the last pixel, so we
                        \ set a mask in A to the last pixel in the 4-pixel byte

                        \ --- And replaced by: -------------------------------->

 LDA #%00010001         \ We want to start drawing from the last pixel, so we
                        \ set a mask in A to the last pixel in the 4-pixel byte

                        \ --- End of replacement ------------------------------>

 JSR HAS3               \ Call HAS3, which draws a line from the halfway point
                        \ across the left half of the screen, going left until
                        \ we bump into something already on-screen, at which
                        \ point it stops drawing

.HA2

                        \ We have finished threading our horizontal line behind
                        \ the ships already on-screen, so now for the next line

 LDX T                  \ Fetch the loop counter from T and increment it
 INX

 CPX #13                \ If the loop counter is less than 13 (i.e. 2 to 12)
 BCC HAL1               \ then loop back to HAL1 to draw the next line

                        \ The floor is done, so now we move on to the back wall

 LDA #60                \ Set S = 60, so we run the following 60 times (though I
 STA S                  \ have no idea why it's 60 times, when it should be 15,
                        \ as this has the effect of drawing each vertical line
                        \ four times, each time starting one character row lower
                        \ on-screen)

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #16                \ We want to draw 15 vertical lines, one every 16 pixels
\                       \ across the screen, with the first at x-coordinate 16,
\                       \ so set this in A to act as the x-coordinate of each
\                       \ line as we work our way through them from left to
\                       \ right, incrementing by 16 for each new line

                        \ --- And replaced by: -------------------------------->

 LDA #0                 \ We want to draw 16 vertical lines, one every 16 pixels
                        \ across the screen, with the first at x-coordinate 0,
                        \ so set this in A to act as the x-coordinate of each
                        \ line as we work our way through them from left to
                        \ right, incrementing by 16 for each new line

                        \ --- End of replacement ------------------------------>

 LDX #&40               \ Set X = &40, the high byte of the start of screen
 STX R                  \ memory (the screen starts at location &4000) and the
                        \ page number of the first screen row

.HAL6

 LDX R                  \ Set the high byte of SC(1 0) to R
 STX SC+1

 STA T                  \ Store A in T so we can retrieve it later

 AND #%11111100         \ A contains the x-coordinate of the line to draw, and
 STA SC                 \ each character block is 4 pixels wide, so setting the
                        \ low byte of SC(1 0) to A mod 4 points SC(1 0) to the
                        \ correct character block on the top screen row for this
                        \ x-coordinate

 LDX #%10001000         \ Set a mask in X to the first pixel in the 4-pixel byte

 LDY #1                 \ We are going to start drawing the line from the second
                        \ pixel from the top (to avoid drawing on the 1-pixel
                        \ border), so set Y to 1 to point to the second row in
                        \ the first character block

.HAL7

 TXA                    \ Copy the pixel mask to A

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA6                \ mask), then this means it already contains something,
                        \ so jump to HA6 to stop drawing this line

 TXA                    \ Copy the pixel mask to A again

 AND #RED               \ Apply the pixel mask in A to a four-pixel block of
                        \ red pixels, so we now know which bits to set in screen
                        \ memory

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 INY                    \ Increment Y to point to the next row in the character
                        \ block, i.e. the next pixel down

 CPY #8                 \ Loop back to HAL7 to draw this next pixel until we
 BNE HAL7               \ have drawn all 8 in the character block

 INC SC+1               \ There are two pages of memory for each character row,
 INC SC+1               \ so we increment the high byte of SC(1 0) twice to
                        \ point to the same character but in the next row down

 LDY #0                 \ Set Y = 0 to point to the first row in this character
                        \ block

 BEQ HAL7               \ Loop back up to HAL7 to keep drawing the line (this
                        \ BEQ is effectively a JMP as Y is always zero)

.HA6

 LDA T                  \ Fetch the x-coordinate of the line we just drew from T
 CLC                    \ into A, and add 16 so that A contains the x-coordinate
 ADC #16                \ of the next line to draw

 BCC P%+4               \ If the addition overflowed, increment the page number
 INC R                  \ in R to point to the second half of the screen row

 DEC S                  \ Decrement the loop counter in S

 BNE HAL6               \ Loop back to HAL6 until we have run through the loop
                        \ 60 times, by which point we are most definitely done

.HA3

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: HAS2
\       Type: Subroutine
\   Category: Ship hangar
\    Summary: Draw a hangar background line from left to right
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line to the right, starting with the third pixel of the
\ pixel row at screen address SC(1 0), and aborting if we bump into something
\ that's already on-screen.
\
\ HAL2 draws from the left edge of the screen to the halfway point, and then
\ HAL3 takes over to draw from the halfway point across the right half of the
\ screen.
\
\ ******************************************************************************

.HAS2

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #%00100010         \ Set A to the pixel pattern for a mode 1 character row
\                       \ byte with the third pixel set, so we start drawing the
\                       \ horizontal line just to the right of the 2-pixel
\                       \ border along the edge of the screen

                        \ --- And replaced by: -------------------------------->

 LDA #%00010001         \ Set A to the pixel pattern for a mode 1 character row
                        \ byte with the fourth pixel set, so we start drawing the
                        \ horizontal line from the right edge of the screen

                        \ --- End of replacement ------------------------------>

.HAL2

 TAX                    \ Store A in X so we can retrieve it after the following
                        \ check and again after updating screen memory

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA3                \ mask), then this means it already contains something,
                        \ so we stop drawing because we have run into something
                        \ that's already on-screen, and return from the
                        \ subroutine (as HA3 contains an RTS)

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 AND #RED               \ Apply the pixel mask in A to a four-pixel block of
                        \ red pixels, so we now know which bits to set in screen
                        \ memory

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 LSR A                  \ Shift A to the right to move on to the next pixel

 BCC HAL2               \ If bit 0 before the shift was clear (i.e. we didn't
                        \ just do the fourth pixel in this block), loop back to
                        \ HAL2 to check and draw the next pixel

 TYA                    \ Set Y = Y + 8 (as we know the C flag is set) to point
 ADC #7                 \ to the next character block along
 TAY

 LDA #%10001000         \ Reset the pixel mask in A to the first pixel in the
                        \ new 4-pixel character block

 BCC HAL2               \ If the above addition didn't overflow, jump back to
                        \ HAL2 to keep drawing the line in the next character
                        \ block

 INC SC+1               \ The addition overflowed, so we have reached the last
                        \ character block in this page of memory, so increment
                        \ the high byte of SC(1 0) in SC+1 to point to the next
                        \ page (i.e. the right half of this screen row) and fall
                        \ into HAL3 to repeat the performance

\ ******************************************************************************
\
\       Name: HAL3
\       Type: Subroutine
\   Category: Ship hangar
\    Summary: Draw a hangar background line from left to right, stopping when it
\             bumps into existing on-screen content
\
\ ******************************************************************************

.HAL3

 TAX                    \ Store A in X so we can retrieve it after the following
                        \ check and again after updating screen memory

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA3                \ mask), then this means it already contains something,
                        \ so we stop drawing because we have run into something
                        \ that's already on-screen, and return from the
                        \ subroutine (as HA3 contains an RTS)

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 AND #RED               \ Apply the pixel mask in A to a four-pixel block of
                        \ red pixels, so we now know which bits to set in screen
                        \ memory

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 LSR A                  \ Shift A to the right to move on to the next pixel

 BCC HAL3               \ If bit 0 before the shift was clear (i.e. we didn't
                        \ just do the fourth pixel in this block), loop back to
                        \ HAL3 to check and draw the next pixel

 TYA                    \ Set Y = Y + 8 (as we know the C flag is set) to point
 ADC #7                 \ to the next character block along
 TAY

 LDA #%10001000         \ Reset the pixel mask in A to the first pixel in the
                        \ new 4-pixel character block

 BCC HAL3               \ If the above addition didn't overflow, jump back to
                        \ HAL3 to keep drawing the line in the next character
                        \ block

 RTS                    \ The addition overflowed, so we have reached the last
                        \ character block in this page of memory, which is the
                        \ end of the line, so we return from the subroutine

\ ******************************************************************************
\
\       Name: HAS3
\       Type: Subroutine
\   Category: Ship hangar
\    Summary: Draw a hangar background line from right to left
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line to the left, starting with the pixel mask in A at
\ screen address SC(1 0) and character block offset Y, and aborting if we bump
\ into something that's already on-screen.
\
\ ******************************************************************************

.HAS3

 TAX                    \ Store A in X so we can retrieve it after the following
                        \ check and again after updating screen memory

 AND (SC),Y             \ If the pixel we want to draw is non-zero (using A as a
 BNE HA3                \ mask), then this means it already contains something,
                        \ so we stop drawing because we have run into something
                        \ that's already on-screen, and return from the
                        \ subroutine (as HA3 contains an RTS)

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 ORA (SC),Y             \ OR the byte with the current contents of screen
                        \ memory, so the pixel we want is set to red (because
                        \ we know the bits are already 0 from the above test)

 STA (SC),Y             \ Store the updated pixel in screen memory

 TXA                    \ Retrieve the value of A we stored above, so A now
                        \ contains the pixel mask again

 ASL A                  \ Shift A to the left to move to the next pixel to the
                        \ left

 BCC HAS3               \ If bit 7 before the shift was clear (i.e. we didn't
                        \ just do the first pixel in this block), loop back to
                        \ HAS3 to check and draw the next pixel to the left

 TYA                    \ Set Y = Y - 8 (as we know the C flag is set) to point
 SBC #8                 \ to the next character block to the left
 TAY

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #%00010000         \ Set a mask in A to the last pixel in the 4-pixel byte

                        \ --- And replaced by: -------------------------------->

 LDA #%00010001         \ Set a mask in A to the last pixel in the 4-pixel byte

                        \ --- End of replacement ------------------------------>

 BCS HAS3               \ If the above subtraction didn't underflow, jump back
                        \ to HAS3 to keep drawing the line in the next character
                        \ block to the left

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DVID4
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (P R) = 256 * A / Q
\  Deep dive: Shift-and-subtract division
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following division and remainder:
\
\   P = A / Q
\
\   R = remainder as a fraction of Q, where 1.0 = 255
\
\ Another way of saying the above is this:
\
\   (P R) = 256 * A / Q
\
\ This uses the same shift-and-subtract algorithm as TIS2, but this time we
\ keep the remainder.
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   C flag              The C flag is cleared
\
\ ******************************************************************************

.DVID4

 LDX #8                 \ Set a counter in X to count the 8 bits in A

 ASL A                  \ Shift A left and store in P (we will build the result
 STA P                  \ in P)

 LDA #0                 \ Set A = 0 for us to build a remainder

.DVL4

 ROL A                  \ Shift A to the left

 BCS DV8                \ If the C flag is set (i.e. bit 7 of A was set) then
                        \ skip straight to the subtraction

 CMP Q                  \ If A < Q skip the following subtraction
 BCC DV5

.DV8

 SBC Q                  \ A >= Q, so set A = A - Q

.DV5

 ROL P                  \ Shift P to the left, pulling the C flag into bit 0

 DEX                    \ Decrement the loop counter

 BNE DVL4               \ Loop back for the next bit until we have done all 8
                        \ bits of P

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ADPARAMS
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the OSWRCH 137 <param> command (add a dashboard
\             parameter and update the dashboard when all are received)
\
\ ******************************************************************************

.ADPARAMS

 INC PARANO             \ PARANO points to the last free byte in PARAMS, which
                        \ is where we're about to store the new byte in A, so
                        \ increment PARANO to point to the byte after this one

 LDX PARANO             \ Store the new byte in A at position PARANO-1 in TABLE
 STA PARAMS-1,X         \ (which was the last free byte before we incremented
                        \ PARANO above)

 CPX #PARMAX            \ If X >= #PARMAX, skip the following instruction, as we
 BCS P%+3               \ have now received all the parameters we need to update
                        \ the dashboard

 RTS                    \ Otherwise we still have more parameters to receive, so
                        \ return from the subroutine

 JSR DIALS              \ Call DIALS to update the dashboard with the parameters
                        \ in PARAMS

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: RDPARAMS
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #RDPARAMS command (start receiving a new set of
\             parameters for updating the dashboard)
\
\ ******************************************************************************

.RDPARAMS

 LDA #0                 \ Set PARANO = 0 to point to the position of the next
 STA PARANO             \ free byte in the PARAMS buffer (i.e. reset the buffer)

 LDA #137               \ Execute a USOSWRCH 137 command so subsequent OSWRCH
 JMP USOSWRCH           \ calls from the parasite can send parameters that get
                        \ added to PARAMS, and return from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: DKS4
\       Type: Macro
\   Category: Keyboard
\    Summary: Scan the keyboard to see if a specific key is being pressed
\  Deep dive: The key logger
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The internal number of the key to check (see p.142 of
\                       the Advanced User Guide for a list of internal key
\                       numbers)
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   If the key in A is being pressed, A contains the
\                       original argument A, but with bit 7 set (i.e. A + 128).
\                       If the key in A is not being pressed, the value in A is
\                       unchanged
\
\ ******************************************************************************

MACRO DKS4

 LDX #3                 \ Set X to 3, so it's ready to send to SHEILA once
                        \ interrupts have been disabled

 SEI                    \ Disable interrupts so we can scan the keyboard
                        \ without being hijacked

 STX VIA+&40            \ Set 6522 System VIA output register ORB (SHEILA &40)
                        \ to %00000011 to stop auto scan of keyboard

 LDX #%01111111         \ Set 6522 System VIA data direction register DDRA
 STX VIA+&43            \ (SHEILA &43) to %01111111. This sets the A registers
                        \ (IRA and ORA) so that:
                        \
                        \   * Bits 0-6 of ORA will be sent to the keyboard
                        \
                        \   * Bit 7 of IRA will be read from the keyboard

 STA VIA+&4F            \ Set 6522 System VIA output register ORA (SHEILA &4F)
                        \ to A, the key we want to scan for; bits 0-6 will be
                        \ sent to the keyboard, of which bits 0-3 determine the
                        \ keyboard column, and bits 4-6 the keyboard row

 LDA VIA+&4F            \ Read 6522 System VIA output register IRA (SHEILA &4F)
                        \ into A; bit 7 is the only bit that will have changed.
                        \ If the key is pressed, then bit 7 will be set,
                        \ otherwise it will be clear

 LDX #%00001011         \ Set 6522 System VIA output register ORB (SHEILA &40)
 STX VIA+&40            \ to %00001011 to restart auto scan of keyboard

 CLI                    \ Allow interrupts again

ENDMACRO

\ ******************************************************************************
\
\       Name: KYTB
\       Type: Variable
\   Category: Keyboard
\    Summary: Lookup table for in-flight keyboard controls
\  Deep dive: The key logger
\
\ ------------------------------------------------------------------------------
\
\ Keyboard table for in-flight controls. This table contains the internal key
\ codes for the flight keys (see p.142 of the Advanced User Guide for a list of
\ internal key numbers).
\
\ The pitch, roll, speed and laser keys (i.e. the seven primary flight
\ control keys) have bit 7 set, so they have 128 added to their internal
\ values. This doesn't appear to be used anywhere.
\
\ Note that KYTB actually points to the byte before the start of the table, so
\ the offset of the first key value is 1 (i.e. KYTB+1), not 0.
\
\ ******************************************************************************

.KYTB

 EQUB 0                 \ Pad the table out so that the first key is at KYTB+1

                        \ These are the primary flight controls (pitch, roll,
                        \ speed and lasers):

 EQUB &68 + 128         \ ?         KYTB+1      Slow down
 EQUB &62 + 128         \ Space     KYTB+2      Speed up
 EQUB &66 + 128         \ <         KYTB+3      Roll left
 EQUB &67 + 128         \ >         KYTB+4      Roll right
 EQUB &42 + 128         \ X         KYTB+5      Pitch up
 EQUB &51 + 128         \ S         KYTB+6      Pitch down
 EQUB &41 + 128         \ A         KYTB+7      Fire lasers

                        \ These are the secondary flight controls:

 EQUB &60               \ TAB       KYTB+8      Energy bomb
 EQUB &70               \ ESCAPE    KYTB+9      Launch escape pod
 EQUB &23               \ T         KYTB+10     Arm missile
 EQUB &35               \ U         KYTB+11     Unarm missile
 EQUB &65               \ M         KYTB+12     Fire missile
 EQUB &22               \ E         KYTB+13     E.C.M.
 EQUB &45               \ J         KYTB+14     In-system jump
 EQUB &52               \ C         KYTB+15     Docking computer

 NOP                    \ In the parasite's version of this table, this byte
                        \ maps to "P", the key to cancel the docking computer,
                        \ but because the I/O processor only uses this table for
                        \ the primary flight keys, this byte isn't used

\ ******************************************************************************
\
\       Name: KEYBOARD
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the OSWORD 240 command (scan the keyboard and joystick
\             and log the results)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends an OSWORD 240 command. It scans
\ the keyboard and joystick and stores the results in the key logger buffer
\ pointed to by OSSC, which is then sent across the Tube to the parasite's own
\ key logger buffer at KTRAN.
\
\ First, it scans the keyboard for the primary flight keys. If any of the
\ primary flight keys are pressed, the corresponding byte in the key logger is
\ set to &FF, otherwise it is set to 0. If multiple flight keys are being
\ pressed, they are all logged.
\
\ Next, it scans the keyboard for any other key presses, starting with internal
\ key number 16 ("Q") and working through the set of internal key numbers (see
\ p.142 of the Advanced User Guide for a list of internal key numbers). If a key
\ press is detected, the internal key number is stored in byte #2 of the key
\ logger table and scanning stops.
\
\ Finally, the joystick is read for X, Y and fire button values. The rotation
\ value is also read from the Bitstik.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC                The address of the table in which to log the key presses
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   OSSC                The table is updated as follows:
\
\                         * Byte #2: If a non-primary flight control key is
\                           being pressed, its internal key number is put here
\
\                         * Byte #3: "?" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #4: Space is being pressed (0 = no, &FF = yes)
\
\                         * Byte #5: "<" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #6: ">" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #7: "X" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #8: "S" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #9: "A" is being pressed (0 = no, &FF = yes)
\
\                         * Byte #10: Joystick X value (high byte)
\
\                         * Byte #11: Joystick Y value (high byte)
\
\                         * Byte #12: Bitstik rotation value (high byte)
\
\                         * Byte #14: Joystick 1 fire button is being pressed
\                           (Bit 4 set = no, Bit 4 clear = yes)
\
\ ******************************************************************************

.KEYBOARD

 LDY #9                 \ We're going to loop through the seven primary flight
                        \ controls in KYTB and update the block pointed to by
                        \ OSSC with their details. We want to store the seven
                        \ results in bytes #2 to #9 in the block, so we set a
                        \ loop counter in Y to count down from 9 to 3, so we can
                        \ use this as an index into both the OSSC block and the
                        \ KYTB table

.DKL2

 LDA KYTB-2,Y           \ Set A to the relevant internal key number from the
                        \ KYTB table (we add Y to KYTB-2 rather than KYTB as Y
                        \ is looping from 9 down to 3, so this grabs the key
                        \ numbers from 7 to 1, i.e. from "A" to "?"

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 ASL A                  \ Shift bit 7 of A into the C flag

 LDA #0                 \ Set A = 0 + &FF + C
 ADC #&FF               \
                        \ If the C flag is set (i.e. the key is being pressed)
                        \ then this sets A = 0, otherwise it sets A = &FF

 EOR #%11111111         \ Flip all the bits in A, so now A = &FF if the key is
                        \ being pressed, or A = 0 if it isn't

 STA (OSSC),Y           \ Store A in the Y-th byte of the block pointed to by
                        \ OSSC

 DEY                    \ Decrement the loop counter

 CPY #2                 \ Loop back until we have processed all seven primary
 BNE DKL2               \ flight keys, leaving the loop with Y = 2

                        \ We're now going to scan the keyboard to see if any
                        \ other keys are being pressed

 LDA #16                \ We start scanning from internal key number 16 ("Q"),
                        \ so we set A as a loop counter

 SED                    \ Set the D flag to enter decimal mode. Because
                        \ internal key numbers are all valid BCD (Binary Coded
                        \ Decimal) numbers, setting this flag ensures we only
                        \ loop through valid key numbers. To put this another
                        \ way, when written in hexadecimal, internal key numbers
                        \ only use the digits 0-9 and none of the letters A-F,
                        \ and setting the D flag makes the following loop
                        \ iterate through the following values of A:
                        \
                        \ &10, &11, &12, &13, &14, &15, &16, &17, &18, &19,
                        \ &20, &21, &22, &23, &24, &25, &26, &27, &28, &29,
                        \ &30, &31...
                        \
                        \ and so on up to &79, and then &80, at which point the
                        \ loop terminates. This lets us efficiently work our
                        \ way through all the internal key numbers without
                        \ wasting time on numbers that aren't valid in BCD

.DKL3

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 TAX                    \ Copy the key press result into X

 BMI DK1                \ If bit 7 is set, i.e. the key is being pressed, skip
                        \ to DK1

 CLC                    \ Otherwise this key is not being pressed, so increment
 ADC #1                 \ the loop counter in A. We couldn't use an INX or INY
                        \ instruction here because the only instructions that
                        \ support decimal mode are ADC and SBC. INX and INY
                        \ always increment in binary mode, whatever the setting
                        \ of the D flag, so instead we have to use an ADC

 BPL DKL3               \ Loop back to test the next key, ending the loop when
                        \ A is negative (i.e. A = &80 = 128 = %10000000)

.DK1

 CLD                    \ Clear the D flag to return to binary mode

 EOR #%10000000         \ EOR A with #%10000000 to flip bit 7, so A now contains
                        \ 0 if no key has been pressed, or the internal key
                        \ number if a key has been pressed

 STA (OSSC),Y           \ We exited the first loop above with Y = 2, so this
                        \ stores the "other key" result in byte #2 of the block
                        \ pointed to by OSSC

                        \ We now check the joystick or Bitstik

 LDX #1                 \ Call OSBYTE with A = 128 to fetch the 16-bit value
 LDA #128               \ from ADC channel 1 (the joystick X value), returning
 JSR OSBYTE             \ the value in (Y X)
                        \
                        \   * Channel 1 is the x-axis: 0 = right, 65520 = left

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #10                \ Store the high byte of the joystick X value in byte
 STA (OSSC),Y           \ #10 of the block pointed to by OSSC

 LDX #2                 \ Call OSBYTE with A = 128 to fetch the 16-bit value
 LDA #128               \ from ADC channel 2 (the joystick Y value), returning
 JSR OSBYTE             \ the value in (Y X)
                        \
                        \   * Channel 2 is the y-axis: 0 = down,  65520 = up

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #11                \ Store the high byte of the joystick Y value in byte
 STA (OSSC),Y           \ #11 of the block pointed to by OSSC

 LDX #3                 \ Call OSBYTE with A = 128 to fetch the 16-bit value
 LDA #128               \ from ADC channel 3 (the Bitstik rotation value),
 JSR OSBYTE             \ returning the value in (Y X)

 TYA                    \ Copy Y to A, so the result is now in (A X)

 LDY #12                \ Store the high byte of the Bitstik rotation value in
 STA (OSSC),Y           \ byte #12 of the block pointed to by OSSC

 LDY #14                \ Read 6522 System VIA input register IRB (SHEILA &40),
 LDA &FE40              \ which has bit 4 clear if joystick 1's fire button is
 STA (OSSC),Y           \ pressed (otherwise it's set), and store the value in
                        \ byte #14 of the block pointed to by OSSC

.DK2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: OSWVECS
\       Type: Variable
\   Category: Tube
\    Summary: The lookup table for OSWORD jump commands (240-255)
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ On entry into these routines, OSSC(1 0) points to the parameter block passed
\ to the OSWORD call in (Y X). OSSC must not be changed by the routines, as it
\ is used by NWOSWD to preserve the values of X and Y through the revectored
\ OSWORD call. OSSC(1 0) can be copied into SC(1 0) to avoid changing it.
\
\ ******************************************************************************

.OSWVECS

 EQUW KEYBOARD          \            240 (&F0)     0 = Scan the keyboard
 EQUW PIXEL             \            241 (&F1)     1 = Draw space view pixels
 EQUW MSBAR             \ #DOmsbar = 242 (&F2)     2 = Update missile indicators
 EQUW WSCAN             \ #wscn    = 243 (&F3)     3 = Wait for vertical sync
 EQUW SC48              \ #onescan = 244 (&F4)     4 = Draw ship on 3D scanner
 EQUW DOT               \ #DOdot   = 245 (&F5)     5 = Draw a dot on the compass
 EQUW DODKS4            \ #DODKS4  = 246 (&F6)     6 = Scan for a specific key
 EQUW HLOIN             \            247 (&F7)     7 = Draw orange sun lines
 EQUW HANGER            \            248 (&F8)     8 = Display the hangar

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\EQUW SOMEPROT          \            249 (&F9)     9 = Copy protection

                        \ --- And replaced by: -------------------------------->

 EQUW SAFE              \            249 (&F9)     9 = Do nothing

                        \ --- End of replacement ------------------------------>

 EQUW SAFE              \            250 (&FA)    10 = Do nothing
 EQUW SAFE              \            251 (&FB)    11 = Do nothing
 EQUW SAFE              \            252 (&FC)    12 = Do nothing
 EQUW SAFE              \            253 (&FD)    13 = Do nothing
 EQUW SAFE              \            254 (&FE)    14 = Do nothing

                        \ --- Mod: Code removed for speed control: ------------>

\EQUW SAFE              \            255 (&FF)    15 = Do nothing

                        \ --- And replaced by: -------------------------------->

 EQUW SpeedControl      \            255 (&FF)    15 = Control the game speed

                        \ --- End of replacement ------------------------------>

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\EQUW SAFE              \ These addresses are never used and have no effect, as
\EQUW SAFE              \ they are out of range for one-byte OSWORD numbers
\EQUW SAFE

                        \ --- End of removed code ----------------------------->

\ ******************************************************************************
\
\       Name: NWOSWD
\       Type: Subroutine
\   Category: Tube
\    Summary: The custom OSWORD routine
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ WORDV is set to point to this routine in the STARTUP routine that runs when
\ the I/O processor code first loads.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The OSWORD call to perform:
\
\                         * 240-255: Run the jump command in A (see OSWVECS)
\
\                         * All others: Call the standard OSWORD routine
\
\   (Y X)               The address of the associated OSWORD parameter block
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   SAFE                Contains an RTS
\
\ ******************************************************************************

.NWOSWD

 BIT svn                \ If bit 7 of svn is set, jump to notours to process
 BMI notours            \ this call with the standard OSWORD handler

 CMP #240               \ If A < 240, this is not a special jump command call,
 BCC notours            \ so jump to notours to pass it to the standard OSWORD
                        \ handler

 STX OSSC               \ Store X in OSCC so we can retrieve it later

 STY OSSC+1             \ Store Y in OSCC+1 so we can retrieve it later

 PHA                    \ Store A on the stack so we can retrieve it later

 SBC #240               \ Set X = (A - 240) * 2
 ASL A                  \
 TAX                    \ so X can be used as an index into a jump table, where
                        \ the table entries correspond to original values of A
                        \ of 240 for entry 0, 241 for entry 1, 242 for entry 2,
                        \ and so on

 LDA OSWVECS,X          \ Fetch the OSWVECS jump table address pointed to by X,
 STA JSRV+1             \ and store it in JSRV(2 1). This modifies the address
 LDA OSWVECS+1,X        \ of the JSR instruction at JSRV below, so it will call
 STA JSRV+2             \ the subroutine from the jump table

 LDX OSSC               \ Restore the value of X we stored in OSSC, so now both
                        \ X and Y have the values from the original OSWORD call

.JSRV

 JSR &FFFC              \ This address is overwritten by the code above to point
                        \ to the relevant jump command from the OSWVECS jump
                        \ table, so this instruction runs the jump command

 PLA                    \ Retrieve A from the stack

 LDX OSSC               \ Retrieve X from OSSC

 LDY OSSC+1             \ Retrieve Y from OSSC+1

.SAFE

 RTS                    \ Return from the subroutine

.notours

 JMP &FFFC              \ This address is overwritten by the STARTUP routine to
                        \ contain the original value of WORDV, so this call acts
                        \ just like a standard JMP OSWORD call and is used to
                        \ process OSWORD calls that aren't our custom calls

\ ******************************************************************************
\
\       Name: MSBAR
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Implement the #DOmsbar command (draw a specific indicator in the
\             dashboard's missile bar)
\
\ ------------------------------------------------------------------------------
\
\ Each indicator is a rectangle that's 3 pixels wide and 5 pixels high. If the
\ indicator is set to black, this effectively removes a missile.
\
\ This routine is run when the parasite sends a #DOmsbar command with parameters
\ in the block at OSSC(1 0). It draws a specific indicator in the dashboard's
\ missile bar. The parameters match those put into the msbpars block in the
\ parasite.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The number of the missile indicator to
\                           update (counting from right to left, so indicator
\                           NOMSL is the leftmost indicator)
\
\                         * Byte #3 = The colour of the missile indicator:
\
\                           * &00 = black (no missile)
\
\                           * #RED2 = red (armed and locked)
\
\                           * #YELLOW2 = yellow/white (armed)
\
\                           * #GREEN2 = green (disarmed)
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   X                   X is preserved
\
\   Y                   Y is set to 0
\
\ ******************************************************************************

.MSBAR

 LDY #2                 \ Fetch byte #2 from the parameter block (the number of
 LDA (OSSC),Y           \ the missile indicator) into A

 ASL A                  \ Set T = A * 16
 ASL A
 ASL A
 ASL A
 STA T

 LDA #97                \ Set SC = 97 - T
 SBC T                  \        = 96 + 1 - (X * 16)
 STA SC

                        \ So the low byte of SC(1 0) contains the row address
                        \ for the rightmost missile indicator, made up as
                        \ follows:
                        \
                        \   * 96 (character block 14, as byte #14 * 8 = 96), the
                        \     character block of the rightmost missile
                        \
                        \   * 1 (so we start drawing on the second row of the
                        \     character block)
                        \
                        \   * Move left one character (8 bytes) for each count
                        \     of X, so when X = 0 we are drawing the rightmost
                        \     missile, for X = 1 we hop to the left by one
                        \     character, and so on

 LDA #&7C               \ Set the high byte of SC(1 0) to &7C, the character row
 STA SCH                \ that contains the missile indicators (i.e. the bottom
                        \ row of the screen)

 LDY #3                 \ Fetch byte #2 from the parameter block (the indicator
 LDA (OSSC),Y           \ colour) into A. This is one of #GREEN2, #YELLOW2 or
                        \ #RED2, or 0 for black, so this is a 2-pixel wide mode
                        \ 2 character row byte in the specified colour

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 STA T1                 \ Store the indicator colour in T1

 BEQ miss1              \ Set A to the correct colour byte for the missile
 LDA #%00111111         \ (i.e. black or white)

.miss1

                        \ --- End of added code ------------------------------->

 LDY #5                 \ We now want to draw this line five times to do the
                        \ left two pixels of the indicator, so set a counter in
                        \ Y

.MBL1

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\STA (SC),Y             \ Draw the 3-pixel row, and as we do not use EOR logic,
\                       \ this will overwrite anything that is already there
\                       \ (so drawing a black missile will delete what's there)

                        \ --- And replaced by: -------------------------------->

 CPY #3                 \ If this is not the middle row of the indicator (Y = 3)
 BNE miss3              \ or this is not a red or yellow indicator, jump to
 LDX T1                 \ miss3
 CPX #RED2_M
 BEQ miss2
 CPX #YELLOW2_M
 BNE miss3

 PHA                    \ Store the missile colour on the stack

 LDA #%10101010         \ If we get here then this is the middle row of the
 STA (SC),Y             \ indicator and the indicator is yellow, so draw a white
                        \ and black pixel in the first two pixels of the row

 PLA                    \ Retrieve the missile colour

 JMP miss4              \ Jump to miss4 to skip the following

.miss2

 PHA                    \ Store the missile colour on the stack

 LDA #0                 \ If we get here then this is the middle row of the
 STA (SC),Y             \ indicator and the indicator is red, so draw two black
                        \ pixels in the first two pixels of the row

 PLA                    \ Retrieve the missile colour

 JMP miss4              \ Jump to miss4 to skip the following

.miss3

 STA (SC),Y             \ Draw the 3-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

.miss4

                        \ --- End of replacement ------------------------------>

 DEY                    \ Decrement the counter for the next row

 BNE MBL1               \ Loop back to MBL1 if have more rows to draw

 PHA                    \ Store the value of A on the stack so we can retrieve
                        \ it after the following addition

 LDA SC                 \ Set SC = SC + 8
 CLC                    \
 ADC #8                 \ so SC(1 0) now points to the next character block on
 STA SC                 \ the row (for the right half of the indicator)

 PLA                    \ Retrieve A from the stack

 AND #%10101010         \ Mask the character row to plot just the first pixel
                        \ in the next character block, as we already did a
                        \ two-pixel wide band in the previous character block,
                        \ so we need to plot just one more pixel, width-wise

 LDY #5                 \ We now want to draw this line five times, so set a
                        \ counter in Y

.MBL2

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\STA (SC),Y             \ Draw the 1-pixel row, and as we do not use EOR logic,
\                       \ this will overwrite anything that is already there
\                       \ (so drawing a black missile will delete what's there)

                        \ --- And replaced by: -------------------------------->

 CPY #3                 \ If this is not the middle row of the indicator (Y = 3)
 BNE miss5              \ or this is not a red indicator, jump to miss3
 LDX T1
 CPX #RED2_M
 BNE miss5

 PHA                    \ Store the missile colour on the stack

 LDA #0                 \ If we get here then this is the middle row of the
 STA (SC),Y             \ indicator and the indicator is red, so draw a black
                        \ pixel in the left pixel of the row

 PLA                    \ Retrieve the missile colour

 JMP miss6              \ Jump to miss6 to skip the following

.miss5

 STA (SC),Y             \ Draw the 1-pixel row, and as we do not use EOR logic,
                        \ this will overwrite anything that is already there
                        \ (so drawing a black missile will delete what's there)

.miss6

                        \ --- End of replacement ------------------------------>

 DEY                    \ Decrement the counter for the next row

 BNE MBL2               \ Loop back to MBL2 if have more rows to draw

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: WSCAN
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Implement the #wscn command (wait for the vertical sync)
\
\ ------------------------------------------------------------------------------
\
\ Wait for vertical sync to occur on the video system - in other words, wait
\ for the screen to start its refresh cycle, which it does 50 times a second
\ (50Hz).
\
\ ******************************************************************************

.WSCAN

 LDA #0                 \ Set DL to 0
 STA DL

.WSCAN1

 LDA DL                 \ Loop round these two instructions until DL is no
 BEQ WSCAN1             \ longer 0 (DL gets set to 30 in the LINSCN routine,
                        \ which is run when vertical sync has occurred on the
                        \ video system, so DL will change to a non-zero value
                        \ at the start of each screen refresh)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DODKS4
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Implement the #DODKS4 command (scan the keyboard to see if a
\             specific key is being pressed)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #DODKS4 command with parameters
\ in the block at OSSC(1 0). It scans the keyboard to see if the specified key
\ is being pressed.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = The internal number of the key to check
\
\                       See p.142 of the Advanced User Guide for a list of
\                       internal key numbers
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   OSSC(1 0)           A parameter block as follows:
\
\                         * Byte #2 = If the key is being pressed, it contains
\                           the original key number from byte #2, but with bit 7
\                           set (i.e. key number + 128). If the key is not being
\                           pressed, it contains the unchanged key number
\
\ ******************************************************************************

.DODKS4

 LDY #2                 \ Fetch byte #2 from the block pointed to by OSSC, which
 LDA (OSSC),Y           \ contains the key to check, and store it in A

 DKS4                   \ Include macro DKS4 to check whether the key in A is
                        \ being pressed, and if it is, set bit 7 of A

 STA (OSSC),Y           \ Store the updated A in byte #2 of the block pointed to
                        \ by OSSC

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: cls
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Clear the top part of the screen and draw a white border
\
\ ******************************************************************************

.cls

 JSR TTX66              \ Call TTX66 to clear the top part of the screen and
                        \ draw a white border

 JMP RR4                \ Jump to RR4 to restore X and Y from the stack and A
                        \ from K3, and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: TT67
\       Type: Subroutine
\   Category: Text
\    Summary: Print a newline
\
\ ******************************************************************************

.TT67

 LDA #12                \ Set A to a carriage return character

                        \ Fall through into TT26 to print the newline

\ ******************************************************************************
\
\       Name: TT26
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor by poking into screen memory
\  Deep dive: Drawing text
\
\ ------------------------------------------------------------------------------
\
\ Print a character at the text cursor (XC, YC), do a beep, print a newline,
\ or delete left (backspace).
\
\ Calls to OSWRCH will end up here when A is not in the range 128-147, as those
\ are reserved for the special jump table OSWRCH commands.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10 (line feed)
\
\                         * 11 (clear the top part of the screen and draw a
\                           border)
\
\                         * 12-13 (carriage return)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\                         * 127 (delete the character to the left of the text
\                           cursor and move the cursor to the left)
\
\   XC                  Contains the text column to print at (the x-coordinate)
\
\   YC                  Contains the line number to print on (the y-coordinate)
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   A is preserved
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   RR4                 Restore the registers and return from the subroutine
\
\ ******************************************************************************

.TT26

 STA K3                 \ Store the A, X and Y registers, so we can restore
 TYA                    \ them at the end (so they don't get changed by this
 PHA                    \ routine)
 TXA
 PHA
 LDA K3

 TAY                    \ Set Y = the character to be printed

 BEQ RR4S               \ If the character is zero, which is typically a string
                        \ terminator character, jump down to RR4 (via the JMP in
                        \ RR4S) to restore the registers and return from the
                        \ subroutine using a tail call

 CMP #11                \ If this is control code 11 (clear screen), jump to cls
 BEQ cls                \ to clear the top part of the screen, draw a white
                        \ border and return from the subroutine via RR4

 CMP #7                 \ If this is not control code 7 (beep), skip the next
 BNE P%+5               \ instruction

 JMP R5                 \ This is control code 7 (beep), so jump to R5 to make
                        \ a beep and return from the subroutine via RR4

 CMP #32                \ If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                \ below, which will print the character, restore the
                        \ registers and return from the subroutine

 CMP #10                \ If this is control code 10 (line feed) then jump to
 BEQ RRX1               \ RRX1, which will move down a line, restore the
                        \ registers and return from the subroutine

 LDX #1                 \ If we get here, then this is control code 12 or 13,
 STX XC                 \ both of which are used. This code prints a newline,
                        \ which we can achieve by moving the text cursor
                        \ to the start of the line (carriage return) and down
                        \ one line (line feed). These two lines do the first
                        \ bit by setting XC = 1, and we then fall through into
                        \ the line feed routine that's used by control code 10

.RRX1

 CMP #13                \ If this is control code 13 (carriage return) then jump
 BEQ RR4S               \ to RR4 (via the JMP in RR4S) to restore the registers
                        \ and return from the subroutine using a tail call

 INC YC                 \ Increment the text cursor y-coordinate to move it
                        \ down one row

.RR4S

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

.RR1

                        \ If we get here, then the character to print is an
                        \ ASCII character in the range 32-95. The quickest way
                        \ to display text on-screen is to poke the character
                        \ pixel by pixel, directly into screen memory, so
                        \ that's what the rest of this routine does
                        \
                        \ The first step, then, is to get hold of the bitmap
                        \ definition for the character we want to draw on the
                        \ screen (i.e. we need the pixel shape of this
                        \ character). The MOS ROM contains bitmap definitions
                        \ of the system's ASCII characters, starting from &C000
                        \ for space (ASCII 32) and ending with the £ symbol
                        \ (ASCII 126)
                        \
                        \ To save time looking this information up from the MOS
                        \ ROM a copy of these bitmap definitions is embedded
                        \ into this source code at page FONT%, so page 0 of the
                        \ font is at FONT%, page 1 is at FONT%+1, and page 2 at
                        \ FONT%+3
                        \
                        \ There are definitions for 32 characters in each of the
                        \ three pages of MOS memory, as each definition takes up
                        \ 8 bytes (8 rows of 8 pixels) and 32 * 8 = 256 bytes =
                        \ 1 page. So:
                        \
                        \   ASCII 32-63  are defined in &C000-&C0FF (page 0)
                        \   ASCII 64-95  are defined in &C100-&C1FF (page 1)
                        \   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
                        \
                        \ The following code reads the relevant character
                        \ bitmap from the copied MOS bitmaps at FONT% and pokes
                        \ those values into the correct position in screen
                        \ memory, thus printing the character on-screen
                        \
                        \ It's a long way from 10 PRINT "Hello world!":GOTO 10

 TAY                    \ Copy the character number from A to Y, as we are
                        \ about to pull A apart to work out where this
                        \ character definition lives in memory

                        \ Now we want to set X to point to the relevant page
                        \ number for this character - i.e. FONT% to FONT%+2

                        \ The following logic is easier to follow if we look
                        \ at the three character number ranges in binary:
                        \
                        \   Bit #  76543210
                        \
                        \   32  = %00100000     Page 0 of bitmap definitions
                        \   63  = %00111111
                        \
                        \   64  = %01000000     Page 1 of bitmap definitions
                        \   95  = %01011111
                        \
                        \   96  = %01100000     Page 2 of bitmap definitions
                        \   125 = %01111101
                        \
                        \ We'll refer to this below

\BEQ RR4                \ This instruction is commented out in the original
                        \ source, but it would return from the subroutine if A
                        \ is zero

 BPL P%+5               \ If the character number is positive (i.e. A < 128)
                        \ then skip the following instruction

 JMP RR4                \ A >= 128, so jump to RR4 to restore the registers and
                        \ return from the subroutine using a tail call

 LDX #(FONT%-1)         \ Set X to point to the page before the first font page,
                        \ which is FONT% - 1

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC P%+4

 LDX #(FONT%+1)         \ A is 64-126, so set X to point to page FONT% + 1

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC P%+3               \ then skip the following instruction

 INX                    \ Increment X
                        \
                        \ By this point, we started with X = FONT%-1, and then
                        \ we did the following:
                        \
                        \   If A = 32-63:   skip        then INX  so X = FONT%
                        \   If A = 64-95:   X = FONT%+1 then skip so X = FONT%+1
                        \   If A = 96-126:  X = FONT%+1 then INX  so X = FONT%+2
                        \
                        \ In other words, X points to the relevant page. But
                        \ what about the value of A? That gets shifted to the
                        \ left three times during the above code, which
                        \ multiplies the number by 8 but also drops bits 7, 6
                        \ and 5 in the process. Look at the above binary
                        \ figures and you can see that if we cleared bits 5-7,
                        \ then that would change 32-53 to 0-31... but it would
                        \ do exactly the same to 64-95 and 96-125. And because
                        \ we also multiply this figure by 8, A now points to
                        \ the start of the character's definition within its
                        \ page (because there are 8 bytes per character
                        \ definition)
                        \
                        \ Or, to put it another way, X contains the high byte
                        \ (the page) of the address of the definition that we
                        \ want, while A contains the low byte (the offset into
                        \ the page) of the address

 STA Q                  \ R is the same location as Q+1, so this stores the
 STX R                  \ address of this character's definition in Q(1 0)

 LDA XC                 \ Fetch XC, the x-coordinate (column) of the text cursor
                        \ into A

 LDX CATF               \ If CATF = 0, jump to RR5, otherwise we are printing a
 BEQ RR5                \ disc catalogue

 CPY #' '               \ If the character we want to print in Y is a space,
 BNE RR5                \ jump to RR5

                        \ If we get here, then CATF is non-zero, so we are
                        \ printing a disc catalogue and we are not printing a
                        \ space, so we drop column 17 from the output so the
                        \ catalogue will fit on-screen (column 17 is a blank
                        \ column in the middle of the catalogue, between the
                        \ two lists of filenames, so it can be dropped without
                        \ affecting the layout). Without this, the catalogue
                        \ would be one character too wide for the square screen
                        \ mode (it's 34 characters wide, while the screen mode
                        \ is only 33 characters across)

 CMP #17                \ If A = 17, i.e. the text cursor is in column 17, jump
 BEQ RR4                \ to RR4 to restore the registers and return from the
                        \ subroutine, thus omitting this column

.RR5

 ASL A                  \ Multiply A by 8, and store in SC, so we now have:
 ASL A                  \
 ASL A                  \   SC = XC * 8
 STA SC

 LDA YC                 \ Fetch YC, the y-coordinate (row) of the text cursor

 CPY #127               \ If the character number (which is in Y) <> 127, then
 BNE RR2                \ skip to RR2 to print that character, otherwise this is
                        \ the delete character, so continue on

 DEC XC                 \ We want to delete the character to the left of the
                        \ text cursor and move the cursor back one, so let's
                        \ do that by decrementing YC. Note that this doesn't
                        \ have anything to do with the actual deletion below,
                        \ we're just updating the cursor so it's in the right
                        \ position following the deletion

 ASL A                  \ A contains YC (from above), so this sets A = YC * 2

 ASL SC                 \ Double the low byte of SC(1 0), catching bit 7 in the
                        \ C flag. As each character is 8 pixels wide, and the
                        \ special screen mode Elite uses for the top part of the
                        \ screen is 256 pixels across with two bits per pixel,
                        \ this value is not only double the screen address
                        \ offset of the text cursor from the left side of the
                        \ screen, it's also the least significant byte of the
                        \ screen address where we want to print this character,
                        \ as each row of on-screen pixels corresponds to two
                        \ pages. To put this more explicitly, the screen starts
                        \ at &4000, so the text rows are stored in screen
                        \ memory like this:
                        \
                        \   Row 1: &4000 - &41FF    YC = 1, XC = 0 to 31
                        \   Row 2: &4200 - &43FF    YC = 2, XC = 0 to 31
                        \   Row 3: &4400 - &45FF    YC = 3, XC = 0 to 31
                        \
                        \ and so on

 ADC #&3F               \ Set X = A
 TAX                    \       = A + &3F + C
                        \       = YC * 2 + &3F + C

                        \ Because YC starts at 0 for the first text row, this
                        \ means that X will be &3F for row 0, &41 for row 1 and
                        \ so on. In other words, X is now set to the page number
                        \ for the row before the one containing the text cursor,
                        \ and given that we set SC above to point to the offset
                        \ in memory of the text cursor within the row's page,
                        \ this means that (X SC) now points to the character
                        \ above the text cursor

 LDY #&F0               \ Set Y = &F0, so the following call to ZES2 will count
                        \ Y upwards from &F0 to &FF

 JSR ZES2               \ Call ZES2, which zero-fills from address (X SC) + Y to
                        \ (X SC) + &FF. (X SC) points to the character above the
                        \ text cursor, and adding &FF to this would point to the
                        \ cursor, so adding &F0 points to the character before
                        \ the cursor, which is the one we want to delete. So
                        \ this call zero-fills the character to the left of the
                        \ cursor, which erases it from the screen

 BEQ RR4                \ We are done deleting, so restore the registers and
                        \ return from the subroutine (this BNE is effectively
                        \ a JMP as ZES2 always returns with the Z flag set)

.RR2

                        \ Now to actually print the character

 INC XC                 \ Once we print the character, we want to move the text
                        \ cursor to the right, so we do this by incrementing
                        \ XC. Note that this doesn't have anything to do
                        \ with the actual printing below, we're just updating
                        \ the cursor so it's in the right position following
                        \ the print

 CMP #24                \ If the text cursor is on the screen (i.e. YC < 24, so
 BCC RR3                \ we are on rows 0-23), then jump to RR3 to print the
                        \ character

 PHA                    \ Store A on the stack so we can retrieve it below

 JSR TTX66              \ Otherwise we are off the bottom of the screen, so
                        \ clear the screen and draw a white border

 LDA #1                 \ Move the text cursor to column 1, row 1
 STA XC
 STA YC

 PLA                    \ Retrieve A from the stack... only to overwrite it with
                        \ the next instruction, so presumably we didn't need to
                        \ preserve it and this and the PHA above have no effect

 LDA K3                 \ Set A to the character to be printed, though again
                        \ this has no effect, as the following call to RR4 does
                        \ the exact same thing

 JMP RR4                \ And restore the registers and return from the
                        \ subroutine

.RR3

                        \ A contains the value of YC - the screen row where we
                        \ want to print this character - so now we need to
                        \ convert this into a screen address, so we can poke
                        \ the character data to the right place in screen
                        \ memory

 ASL A                  \ Set A = 2 * A
                        \       = 2 * YC

 ASL SC                 \ Back in RR5 we set SC = XC * 8, so this does the
                        \ following:
                        \
                        \   SC = SC * 2
                        \      = XC * 16
                        \
                        \ so SC contains the low byte of the screen address we
                        \ want to poke the character into, as each text
                        \ character is 8 pixels wide, and there are four pixels
                        \ per byte, so the offset within the row's 512 bytes
                        \ is XC * 8 pixels * 2 bytes for each 8 pixels = XC * 16

 ADC #&40               \ Set A = &40 + A
                        \       = &40 + (2 * YC)
                        \
                        \ so A contains the high byte of the screen address we
                        \ want to poke the character into, as screen memory
                        \ starts at &4000 (page &40) and each screen row takes
                        \ up 2 pages (512 bytes)

.RREN

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 LDA SC                 \ Set (T S) = SC(1 0) + 8
 CLC                    \
 ADC #8                 \ starting with the low bytes
 STA S

 LDA SC+1               \ And then adding the high bytes, so (T S) points to the
 STA T                  \ character block after the one pointed to by SC(1 0),
                        \ and because T = S+1, we have:
                        \
                        \   S(1 0) = SC(1 0) + 8

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.RRL1

                        \ We print the character's 8-pixel row in two parts,
                        \ starting with the first four pixels (one byte of
                        \ screen memory), and then the second four (a second
                        \ byte of screen memory)

 LDA (Q),Y              \ The character definition is at Q(1 0) - we set this up
                        \ above - so load the Y-th byte from Q(1 0), which will
                        \ contain the bitmap for the Y-th row of the character

 AND #%11110000         \ Extract the high nibble of the character definition
                        \ byte, so the first four pixels on this row of the
                        \ character are in the first nibble, i.e. xxxx 0000
                        \ where xxxx is the pattern of those four pixels in the
                        \ character

 STA U                  \ Set A = (A >> 4) OR A
 LSR A                  \
 LSR A                  \ which duplicates the high nibble into the low nibble
 LSR A                  \ to give xxxx xxxx
 LSR A
 ORA U

 AND COL                \ AND with the colour byte so that the pixels take on
                        \ the colour we want to draw (i.e. A is acting as a mask
                        \ on the colour byte)

 EOR (SC),Y             \ If we EOR this value with the existing screen
                        \ contents, then it's reversible (so reprinting the
                        \ same character in the same place will revert the
                        \ screen to what it looked like before we printed
                        \ anything); this means that printing a white pixel
                        \ onto a white background results in a black pixel, but
                        \ that's a small price to pay for easily erasable text

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

                        \ We now repeat the process for the second batch of four
                        \ pixels in this character row

 LDA (Q),Y              \ Fetch the bitmap for the Y-th row of the character
                        \ again

 AND #%00001111         \ This time we extract the low nibble of the character
                        \ definition, to get 0000 xxxx

 STA U                  \ Set A = (A << 4) OR A
 ASL A                  \
 ASL A                  \ which duplicates the low nibble into the high nibble
 ASL A                  \ to give xxxx xxxx
 ASL A
 ORA U

 AND COL                \ AND with the colour byte so that the pixels take on
                        \ the colour we want to draw (i.e. A is acting as a mask
                        \ on the colour byte)

 EOR (S),Y              \ EOR this value with the existing screen contents of
                        \ S(1 0), which is equal to SC(1 0) + 8, the next four
                        \ pixels along from the first four pixels we just
                        \ plotted in SC(1 0)

 STA (S),Y              \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 PLA                    \ We're done printing, so restore the values of the
 TAX                    \ A, X and Y registers that we saved above, so
 PLA                    \ everything is back to how it was
 TAY
 LDA K3

.rT9

 RTS                    \ Return from the subroutine

.R5

 LDX #LO(BELI)          \ Set (Y X) to point to the parameter block below
 LDY #HI(BELI)

 JSR OSWORD             \ We call this from above with A = 7, so this calls
                        \ OSWORD 7 to make a short, high beep

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

.BELI

 EQUW &0012             \ The SOUND block for a short, high beep:
 EQUW &FFF1             \
 EQUW &00C8             \   SOUND &12, -15, &C8, &02
 EQUW &0002             \
                        \ This makes a sound with flush control 1 on channel 2,
                        \ and with amplitude &F1 (-15), pitch &C8 (200) and
                        \ duration &02 (2). This is a louder, higher and longer
                        \ beep than that generated by the NOISE routine with
                        \ A = 32 (a short, high beep)

\ ******************************************************************************
\
\       Name: TTX66
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Clear the top part of the screen and draw a white border
\
\ ------------------------------------------------------------------------------
\
\ Clear the top part of the screen (the space view) and draw a white border
\ along the top and sides.
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   BOX                 Just draw the white border along the top and sides
\
\ ******************************************************************************

.TTX66

 LDX #&40               \ Set X to point to page &40, which is the start of the
                        \ screen memory at &4000

.BOL1

 JSR ZES1               \ Call ZES1 to zero-fill the page in X, which will clear
                        \ half a character row

 INX                    \ Increment X to point to the next page in screen
                        \ memory

 CPX #&70               \ Loop back to keep clearing character rows until we
 BNE BOL1               \ have cleared up to &7000, which is where the dashboard
                        \ starts

.BOX

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #%00001111         \ Set COL = %00001111 to act as a four-pixel yellow
\STA COL                \ character byte (i.e. set the line colour to yellow)
\
\LDY #1                 \ Move the text cursor to row 1
\STY YC
\
\LDY #11                \ Move the text cursor to column 11
\STY XC
\
\LDX #0                 \ Set X1 = Y1 = Y2 = 0
\STX X1
\STX Y1
\STX Y2
\
\\STX QQ17              \ This instruction is commented out in the original
\                       \ source
\
\DEX                    \ Set X2 = 255
\STX X2
\
\JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2), so that's from
\                       \ (0, 0) to (255, 0), along the very top of the screen
\
\LDA #2                 \ Set X1 = X2 = 2
\STA X1
\STA X2
\
\JSR BOS2               \ Call BOS2 below, which will call BOS1 twice, and then
\                       \ fall through into BOS2 again, so we effectively do
\                       \ BOS1 four times, decrementing X1 and X2 each time
\                       \ before calling LOIN, so this whole loop-within-a-loop
\                       \ mind-bender ends up drawing these four lines:
\                       \
\                       \   (1, 0)   to (1, 191)
\                       \   (0, 0)   to (0, 191)
\                       \   (255, 0) to (255, 191)
\                       \   (254, 0) to (254, 191)
\                       \
\                       \ So that's a 2-pixel wide vertical border along the
\                       \ left edge of the upper part of the screen, and a
\                       \ 2-pixel wide vertical border along the right edge
\
\.BOS2
\
\JSR BOS1               \ Call BOS1 below and then fall through into it, which
\                       \ ends up running BOS1 twice. This is all part of the
\                       \ loop-the-loop border-drawing mind-bender explained
\                       \ above
\
\.BOS1
\
\LDA #0                 \ Set Y1 = 0
\STA Y1
\
\LDA #2*Y-1             \ Set Y2 = 2 * #Y - 1. The constant #Y is 96, the
\STA Y2                 \ y-coordinate of the mid-point of the space view, so
\                       \ this sets Y2 to 191, the y-coordinate of the bottom
\                       \ pixel row of the space view
\
\DEC X1                 \ Decrement X1 and X2
\DEC X2
\
\JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)
\
\LDA #%00001111         \ Set locations &4000 &41F8 to %00001111, as otherwise
\STA &4000              \ the top-left and top-right corners will be black (as
\STA &41F8              \ the lines overlap at the corners, and the EOR logic
\                       \ used by LOIN will otherwise make them black)

                        \ --- End of removed code ----------------------------->

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ZES1
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill the page whose number is in X
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The page we want to zero-fill
\
\ ******************************************************************************

.ZES1

 LDY #0                 \ If we set Y = SC = 0 and fall through into ZES2
 STY SC                 \ below, then we will zero-fill 255 bytes starting from
                        \ SC - in other words, we will zero-fill the whole of
                        \ page X

\ ******************************************************************************
\
\       Name: ZES2
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Zero-fill a specific page
\
\ ------------------------------------------------------------------------------
\
\ Zero-fill from address (X SC) + Y to (X SC) + &FF.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The high byte (i.e. the page) of the starting point of
\                       the zero-fill
\
\   Y                   The offset from (X SC) where we start zeroing, counting
\                       up to &FF
\
\   SC                  The low byte (i.e. the offset into the page) of the
\                       starting point of the zero-fill
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   Z flag              Z flag is set
\
\ ******************************************************************************

.ZES2

 LDA #0                 \ Load A with the byte we want to fill the memory block
                        \ with - i.e. zero

 STX SC+1               \ We want to zero-fill page X, so store this in the
                        \ high byte of SC, so the 16-bit address in SC and
                        \ SC+1 is now pointing to the SC-th byte of page X

.ZEL1

 STA (SC),Y             \ Zero the Y-th byte of the block pointed to by SC,
                        \ so that's effectively the Y-th byte before SC

 INY                    \ Increment the loop counter

 BNE ZEL1               \ Loop back to zero the next byte

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SETXC
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #SETXC <column> command (move the text cursor to a
\             specific column)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETXC <column> command. It
\ updates the text cursor x-coordinate (i.e. the text column) in XC.
\
\ Arguments:
\
\   A                   The text column
\
\ ******************************************************************************

.SETXC

 STA XC                 \ Store the new text column in XC

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SETYC
\       Type: Subroutine
\   Category: Text
\    Summary: Implement the #SETYC <row> command (move the text cursor to a
\             specific row)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETYC <row> command. It updates
\ the text cursor y-coordinate (i.e. the text row) in YC.
\
\ Arguments:
\
\   A                   The text row
\
\ ******************************************************************************

.SETYC

 STA YC                 \ Store the new text row in YC

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SOMEPROT
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Implement the OSWORD 249 command (some copy protection)
\  Deep dive: 6502 Second Processor Tube communication
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends an OSWORD 249 command with a
\ parameter block at OSSC(1 0). The parameter block is empty when the command is
\ sent, and this routine copies the code between do65202 and end65C02 to the
\ parameter block, just after the two size bytes.
\
\ ******************************************************************************

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\.SOMEPROT
\
\LDY #2                 \ Set a counter in Y to go from 2 to 2 + protlen, so
\                       \ we copy bytes from do65202 to end65C02 into byte #2
\                       \ onwards in the parameter block pointed to by OSSC
\
\.SMEPRTL
\
\LDA do65C02-2,Y        \ Copy the Y-th byte of do65202 to the Y+2-th byte of
\STA (OSSC),Y           \ the OSWORD parameter block
\
\INY                    \ Increment the loop counter
\
\CPY #protlen+2         \ Loop back to copy the next byte until we have copied
\BCC SMEPRTL            \ the whole of do65202 to end65C02 to the OSWORD block,
\                       \ so it can be run by the parasite
\
\RTS                    \ Return from the subroutine

                        \ --- End of removed code ----------------------------->

\ ******************************************************************************
\
\       Name: CLYNS
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Implement the #clyns command (clear the bottom of the screen)
\
\ ******************************************************************************

.CLYNS

 LDA #20                \ Move the text cursor to row 20, near the bottom of
 STA YC                 \ the screen

 LDA #&6A               \ Set SC+1 = &6A, for the high byte of SC(1 0)
 STA SC+1

 JSR TT67               \ Print a newline

 LDA #0                 \ Set SC = 0, so now SC(1 0) = &6A00
 STA SC

 LDX #3                 \ We want to clear three text rows, so set a counter in
                        \ X for 3 rows

.CLYL

 LDY #8                 \ We want to clear each text row, starting from the
                        \ left, but we don't want to overwrite the border, so we
                        \ start from the second character block, which is byte
                        \ #8 from the edge, so set Y to 8 to act as the byte
                        \ counter within the row

.EE2

 STA (SC),Y             \ Zero the Y-th byte from SC(1 0), which clears it by
                        \ setting it to colour 0, black

 INY                    \ Increment the byte counter in Y

 BNE EE2                \ Loop back to EE2 to blank the next byte along, until
                        \ we have done one page's worth (from byte #8 to #255)

 INC SC+1               \ We have just finished the first page - which covers
                        \ the left half of the text row - so we increment SC+1
                        \ so SC(1 0) points to the start of the next page, or
                        \ the start of the right half of the row

 STA (SC),Y             \ Clear the byte at SC(1 0), as that won't be caught by
                        \ the next loop

 LDY #247               \ The second page covers the right half of the text row,
                        \ and as before we don't want to overwrite the border,
                        \ which we can do by starting from the last-but-one
                        \ character block and working our way left towards the
                        \ centre of the row. The last-but-one character block
                        \ ends at byte 247 (that's 255 - 8, as each character
                        \ is 8 bytes), so we put this in Y to act as a byte
                        \ counter, as before

.EE3

 STA (SC),Y             \ Zero the Y-th byte from SC(1 0), which clears it by
                        \ setting it to colour 0, black

 DEY                    \ Decrement the byte counter in Y

 BNE EE3                \ Loop back to EE2 to blank the next byte to the left,
                        \ until we have done one page's worth (from byte #247 to
                        \ #1)

 INC SC+1               \ We have now blanked a whole text row, so increment
                        \ SC+1 so that SC(1 0) points to the next row

 DEX                    \ Decrement the row counter in X

 BNE CLYL               \ Loop back to blank another row, until we have done the
                        \ number of rows in X

\INX                    \ These instructions are commented out in the original
\STX SC                 \ source

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DIALS (Part 1 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: speed indicator
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This routine updates the dashboard. First we draw all the indicators in the
\ right part of the dashboard, from top (speed) to bottom (energy banks), and
\ then we move on to the left part, again drawing from top (forward shield) to
\ bottom (altitude).
\
\ This first section starts us off with the speedometer in the top right.
\
\ ******************************************************************************

.DIALS

 LDA #%00000001         \ Set 6522 System VIA interrupt enable register IER
 STA VIA+&4E            \ (SHEILA &4E) bit 1 (i.e. disable the CA2 interrupt,
                        \ which comes from the keyboard)

 LDA #&A0               \ Set SC(1 0) = &71A0, which is the screen address for
 STA SC                 \ the character block containing the left end of the
 LDA #&71               \ top indicator in the right part of the dashboard, the
 STA SC+1               \ one showing our speed

 JSR PZW2               \ Call PZW2 to set A to the colour for dangerous values
                        \ and X to the colour for safe values, suitable for
                        \ non-striped indicators

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #14                \ Set T1 to 14, the threshold at which we change the
\STA T1                 \ indicator's colour

                        \ --- And replaced by: -------------------------------->

 LDA #21                \ Set T1 to 21, the threshold at which we change the
 STA T1                 \ indicator's colour (this stops the speed indicator
                        \ flashing when at full speed, as that's just annoying)

                        \ --- End of replacement ------------------------------>

 LDA DELTA              \ Fetch our ship's speed into A, in the range 0-40

\LSR A                  \ Draw the speed indicator using a range of 0-31, and
 JSR DIL-1              \ increment SC to point to the next indicator (the roll
                        \ indicator). The LSR is commented out as it isn't
                        \ required with a call to DIL-1, so perhaps this was
                        \ originally a call to DIL that got optimised

\ ******************************************************************************
\
\       Name: DIALS (Part 2 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: pitch and roll indicators
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #0                 \ Set R = P = 0 for the low bytes in the call to the ADD
 STA R                  \ routine below
 STA P

 LDA #8                 \ Set S = 8, which is the value of the centre of the
 STA S                  \ roll indicator

 LDA ALP1               \ Fetch the roll angle alpha as a value between 0 and
 LSR A                  \ 31, and divide by 4 to get a value of 0 to 7
 LSR A

 ORA ALP2               \ Apply the roll sign to the value, and flip the sign,
 EOR #%10000000         \ so it's now in the range -7 to +7, with a positive
                        \ roll angle alpha giving a negative value in A

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position. We use the ADD
                        \ routine like this:
                        \
                        \ (A X) = (A 0) + (S 0)
                        \
                        \ and just take the high byte of the result. We use ADD
                        \ rather than a normal ADC because ADD separates out the
                        \ sign bit and does the arithmetic using absolute values
                        \ and separate sign bits, which we want here rather than
                        \ the two's complement that ADC uses

 JSR DIL2               \ Draw a vertical bar on the roll indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ pitch indicator)

 LDA BETA               \ Fetch the pitch angle beta as a value between -8 and
                        \ +8

 LDX BET1               \ Fetch the magnitude of the pitch angle beta, and if it
 BEQ P%+4               \ is 0 (i.e. we are not pitching), skip the next
                        \ instruction

 SBC #1                 \ The pitch angle beta is non-zero, so set A = A - 1
                        \ (the C flag is set by the call to DIL2 above, so we
                        \ don't need to do a SEC). This gives us a value of A
                        \ from -7 to +7 because these are magnitude-based
                        \ numbers with sign bits, rather than two's complement
                        \ numbers

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position (see the JSR ADD
                        \ above for more on this)

 JSR DIL2               \ Draw a vertical bar on the pitch indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ four energy banks)

\ ******************************************************************************
\
\       Name: DIALS (Part 3 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: four energy banks
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This and the next section only run once every four iterations of the main
\ loop, so while the speed, pitch and roll indicators update every iteration,
\ the other indicators update less often.
\
\ ******************************************************************************

 LDY #0                 \ Set Y = 0, for use in various places below

 JSR PZW                \ Call PZW to set A to the colour for dangerous values
                        \ and X to the colour for safe values

 STX K                  \ Set K (the colour we should show for high values) to X
                        \ (the colour to use for safe values)

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for low values and yellow/white for high values, which
                        \ we use not only for the energy banks, but also for the
                        \ shield levels and current fuel

 LDX #3                 \ Set up a counter in X so we can zero the four bytes at
                        \ XX15, so we can then calculate each of the four energy
                        \ banks' values before drawing them later

 STX T1                 \ Set T1 to 3, the threshold at which we change the
                        \ indicator's colour

.DLL23

 STY XX15,X             \ Set the X-th byte of XX15 to 0

 DEX                    \ Decrement the counter

 BPL DLL23              \ Loop back for the next byte until the four bytes at
                        \ XX12 are all zeroed

 LDX #3                 \ Set up a counter in X to loop through the 4 energy
                        \ bank indicators, so we can calculate each of the four
                        \ energy banks' values and store them in XX12

 LDA ENERGY             \ Set A = Q = ENERGY / 4, so they are both now in the
 LSR A                  \ range 0-63 (so that's a maximum of 16 in each of the
 LSR A                  \ banks, and a maximum of 15 in the top bank)

 STA Q                  \ Set Q to A, so we can use Q to hold the remaining
                        \ energy as we work our way through each bank, from the
                        \ full ones at the bottom to the empty ones at the top

.DLL24

 SEC                    \ Set A = A - 16 to reduce the energy count by a full
 SBC #16                \ bank

 BCC DLL26              \ If the C flag is clear then A < 16, so this bank is
                        \ not full to the brim, and is therefore the last one
                        \ with any energy in it, so jump to DLL26

 STA Q                  \ This bank is full, so update Q with the energy of the
                        \ remaining banks

 LDA #16                \ Store this bank's level in XX15 as 16, as it is full,
 STA XX15,X             \ with XX15+3 for the bottom bank and XX15+0 for the top

 LDA Q                  \ Set A to the remaining energy level again

 DEX                    \ Decrement X to point to the next bank, i.e. the one
                        \ above the bank we just processed

 BPL DLL24              \ Loop back to DLL24 until we have either processed all
                        \ four banks, or jumped out early to DLL26 if the top
                        \ banks have no charge

 BMI DLL9               \ Jump to DLL9 as we have processed all four banks (this
                        \ BMI is effectively a JMP as A will never be positive)

.DLL26

 LDA Q                  \ If we get here then the bank we just checked is not
 STA XX15,X             \ fully charged, so store its value in XX15 (using Q,
                        \ which contains the energy of the remaining banks -
                        \ i.e. this one)

                        \ Now that we have the four energy bank values in XX12,
                        \ we can draw them, starting with the top bank in XX12
                        \ and looping down to the bottom bank in XX12+3, using Y
                        \ as a loop counter, which was set to 0 above

.DLL9

 LDA XX15,Y             \ Fetch the value of the Y-th indicator, starting from
                        \ the top

 STY P                  \ Store the indicator number in P for retrieval later

 JSR DIL                \ Draw the energy bank using a range of 0-15, and
                        \ increment SC to point to the next indicator (the
                        \ next energy bank down)

 LDY P                  \ Restore the indicator number into Y

 INY                    \ Increment the indicator number

 CPY #4                 \ Check to see if we have drawn the last energy bank

 BNE DLL9               \ Loop back to DLL9 if we have more banks to draw,
                        \ otherwise we are done

\ ******************************************************************************
\
\       Name: DIALS (Part 4 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: shields, fuel, laser & cabin temp, altitude
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #&70               \ Set SC(1 0) = &7020, which is the screen address for
 STA SC+1               \ the character block containing the left end of the
 LDA #&20               \ top indicator in the left part of the dashboard, the
 STA SC                 \ one showing the forward shield

 LDA FSH                \ Draw the forward shield indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the aft shield)

 LDA ASH                \ Draw the aft shield indicator using a range of 0-255,
 JSR DILX               \ and increment SC to point to the next indicator (the
                        \ fuel level)

 LDA #YELLOW2           \ Set K (the colour we should show for high values) to
 STA K                  \ yellow

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ yellow, so the fuel indicator always shows in this
                        \ colour

 LDA QQ14               \ Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             \ and increment SC to point to the next indicator (the
                        \ cabin temperature)

 JSR PZW2               \ Call PZW2 to set A to the colour for dangerous values
                        \ and X to the colour for safe values, suitable for
                        \ non-striped indicators

 STX K+1                \ Set K+1 (the colour we should show for low values) to
                        \ X (the colour to use for safe values)

 STA K                  \ Set K (the colour we should show for high values) to
                        \ A (the colour to use for dangerous values)

                        \ The above sets the following indicators to show red
                        \ for high values and yellow/white for low values, which
                        \ we use for the cabin and laser temperature bars

 LDX #11                \ Set T1 to 11, the threshold at which we change the
 STX T1                 \ cabin and laser temperature indicators' colours

 LDA CABTMP             \ Draw the cabin temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the laser temperature)

 LDA GNTMP              \ Draw the laser temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the altitude)

 LDA #240               \ Set T1 to 240, the threshold at which we change the
 STA T1                 \ altitude indicator's colour. As the altitude has a
                        \ range of 0-255, pixel 16 will not be filled in, and
                        \ 240 would change the colour when moving between pixels
                        \ 15 and 16, so this effectively switches off the colour
                        \ change for the altitude indicator

 LDA #YELLOW2           \ Set K (the colour we should show for high values) to
 STA K                  \ yellow

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ yellow, so the altitude indicator always shows in this
                        \ colour

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255,
 JMP DILX               \ returning from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: PZW2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Fetch the current dashboard colours for non-striped indicators, to
\             support flashing
\
\ ******************************************************************************

.PZW2

 LDX #WHITE2            \ Set X to white, so we can return that as the safe
                        \ colour in PZW below

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &A9 &23, or BIT &23A9, which does nothing apart
                        \ from affect the flags

                        \ Fall through into PZW to fetch the current dashboard
                        \ colours, returning white for safe colours rather than
                        \ stripes

\ ******************************************************************************
\
\       Name: PZW
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Fetch the current dashboard colours, to support flashing
\
\ ------------------------------------------------------------------------------
\
\ Set A and X to the colours we should use for indicators showing dangerous and
\ safe values respectively. This enables us to implement flashing indicators,
\ which is one of the game's configurable options.
\
\ If flashing is enabled, the colour returned in A (dangerous values) will be
\ red for 8 iterations of the main loop, and green for the next 8, before
\ going back to red. If we always use PZW to decide which colours we should use
\ when updating indicators, flashing colours will be automatically taken care of
\ for us.
\
\ The values returned are #GREEN2 for green and #RED2 for red. These are mode 2
\ bytes that contain 2 pixels, with the colour of each pixel given in four bits.
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   The colour to use for indicators with dangerous values
\
\   X                   The colour to use for indicators with safe values
\
\ ******************************************************************************

.PZW

 LDX #STRIPE            \ Set X to the dashboard stripe colour, which is stripe
                        \ 5-1 (magenta/red)

 LDA MCNT               \ A will be non-zero for 8 out of every 16 main loop
 AND #%00001000         \ counts, when bit 4 is set, so this is what we use to
                        \ flash the "danger" colour

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\AND FLH                \ A will be zeroed if flashing colours are disabled

                        \ --- End of removed code ----------------------------->

 BEQ P%+5               \ If A is zero, skip the next two instructions

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA #GREEN2            \ Otherwise flashing colours are enabled and it's the
\RTS                    \ main loop iteration where we flash them, so set A to
\                       \ dashboard colour 2 (green) and return from the
\                       \ subroutine

                        \ --- And replaced by: -------------------------------->

 LDA #0                 \ Otherwise flashing colours are enabled and it's the
 RTS                    \ main loop iteration where we flash them, so set A to
                        \ black and return from the subroutine

                        \ --- End of replacement ------------------------------>

 LDA #RED2              \ Set A to dashboard colour 1 (red)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DILX
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update a bar-based indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The range of values shown on the indicator depends on which entry point is
\ called. For the default entry point of DILX, the range is 0-255 (as the value
\ passed in A is one byte). The other entry points are shown below.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The value to be shown on the indicator (so the larger
\                       the value, the longer the bar)
\
\   T1                  The threshold at which we change the indicator's colour
\                       from the low value colour to the high value colour. The
\                       threshold is in pixels, so it should have a value from
\                       0-16, as each bar indicator is 16 pixels wide
\
\   K                   The colour to use when A is a high value, as a 2-pixel
\                       mode 2 character row byte
\
\   K+1                 The colour to use when A is a low value, as a 2-pixel
\                       mode 2 character row byte
\
\   SC(1 0)             The screen address of the first character block in the
\                       indicator
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   DILX+2              The range of the indicator is 0-64 (for the fuel
\                       indicator)
\
\   DIL-1               The range of the indicator is 0-32 (for the speed
\                       indicator)
\
\   DIL                 The range of the indicator is 0-16 (for the energy
\                       banks)
\
\ ******************************************************************************

.DILX

 LSR A                  \ If we call DILX, we set A = A / 16, so A is 0-15
 LSR A

 LSR A                  \ If we call DILX+2, we set A = A / 4, so A is 0-15

 LSR A                  \ If we call DIL-1, we set A = A / 2, so A is 0-15

.DIL

                        \ If we call DIL, we leave A alone, so A is 0-15

 STA Q                  \ Store the indicator value in Q, now reduced to 0-15,
                        \ which is the length of the indicator to draw in pixels

 LDX #&FF               \ Set R = &FF, to use as a mask for drawing each row of
 STX R                  \ each character block of the bar, starting with a full
                        \ character's width of 4 pixels

 CMP T1                 \ If A >= T1 then we have passed the threshold where we
 BCS DL30               \ change bar colour, so jump to DL30 to set A to the
                        \ "high value" colour

 LDA K+1                \ Set A to K+1, the "low value" colour to use

 BNE DL31               \ Jump down to DL31 (this BNE is effectively a JMP as A
                        \ will never be zero)

.DL30

 LDA K                  \ Set A to K, the "high value" colour to use

.DL31

 STA COL                \ Store the colour of the indicator in COL

 LDY #2                 \ We want to start drawing the indicator on the third
                        \ line in this character row, so set Y to point to that
                        \ row's offset

 LDX #7                 \ Set up a counter in X for the width of the indicator,
                        \ which is 8 characters (each of which is 2 pixels wide,
                        \ to give a total width of 16 pixels)

.DL1

 LDA Q                  \ Fetch the indicator value (0-15) from Q into A

 CMP #2                 \ If Q < 2, then we need to draw the end cap of the
 BCC DL2                \ indicator, which is less than a full character's
                        \ width, so jump down to DL2 to do this

 SBC #2                 \ Otherwise we can draw a 2-pixel wide block, so
 STA Q                  \ subtract 2 from Q so it contains the amount of the
                        \ indicator that's left to draw after this character

 LDA R                  \ Fetch the shape of the indicator row that we need to
                        \ display from R, so we can use it as a mask when
                        \ painting the indicator. It will be &FF at this point
                        \ (i.e. a full 4-pixel row)

.DL5

 AND COL                \ Fetch the 2-pixel mode 2 colour byte from COL, and
                        \ only keep pixels that have their equivalent bits set
                        \ in the mask byte in A

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 6 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #6                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 DEX                    \ Decrement the loop counter for the next character
                        \ block along in the indicator

 BMI DL6                \ If we just drew the last character block then we are
                        \ done drawing, so jump down to DL6 to finish off

 BPL DL1                \ Loop back to DL1 to draw the next character block of
                        \ the indicator (this BPL is effectively a JMP as A will
                        \ never be negative following the previous BMI)

.DL2

 EOR #1                 \ If we get here then we are drawing the indicator's
 STA Q                  \ end cap, so Q is < 2, and this EOR flips the bits, so
                        \ instead of containing the number of indicator columns
                        \ we need to fill in on the left side of the cap's
                        \ character block, Q now contains the number of blank
                        \ columns there should be on the right side of the cap's
                        \ character block

 LDA R                  \ Fetch the current mask from R, which will be &FF at
                        \ this point, so we need to turn Q of the columns on the
                        \ right side of the mask to black to get the correct end
                        \ cap shape for the indicator

.DL3

 ASL A                  \ Shift the mask left and clear bits 0, 2, 4 and 8,
 AND #%10101010         \ which has the effect of shifting zeroes from the left
                        \ into each two-bit segment (i.e. xx xx xx xx becomes
                        \ x0 x0 x0 x0, which blanks out the last column in the
                        \ 2-pixel mode 2 character block)

 DEC Q                  \ Decrement the counter for the number of columns to
                        \ blank out

 BPL DL3                \ If we still have columns to blank out in the mask,
                        \ loop back to DL3 until the mask is correct for the
                        \ end cap

 PHA                    \ Store the mask byte on the stack while we use the
                        \ accumulator for a bit

 LDA #0                 \ Change the mask so no bits are set, so the characters
 STA R                  \ after the one we're about to draw will be all blank

 LDA #99                \ Set Q to a high number (99, why not) so we will keep
 STA Q                  \ drawing blank characters until we reach the end of
                        \ the indicator row

 PLA                    \ Restore the mask byte from the stack so we can use it
                        \ to draw the end cap of the indicator

 JMP DL5                \ Jump back up to DL5 to draw the mask byte on-screen

.DL6

 INC SC+1               \ Increment the high byte of SC to point to the next
 INC SC+1               \ character row on-screen (as each row takes up exactly
                        \ two pages of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

.DL9

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DIL2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the roll or pitch indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The indicator can show a vertical bar in 16 positions, with a value of 8
\ showing the bar in the middle of the indicator.
\
\ In practice this routine is only ever called with A in the range 1 to 15, so
\ the vertical bar never appears in the leftmost position (though it does appear
\ in the rightmost).
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The offset of the vertical bar to show in the indicator,
\                       from 0 at the far left, to 8 in the middle, and 15 at
\                       the far right
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   C flag              The C flag is set
\
\ ******************************************************************************

.DIL2

 LDY #1                 \ We want to start drawing the vertical indicator bar on
                        \ the second line in the indicator's character block, so
                        \ set Y to point to that row's offset

 STA Q                  \ Store the offset of the vertical bar to draw in Q

                        \ We are now going to work our way along the indicator
                        \ on the dashboard, from left to right, working our way
                        \ along one character block at a time. Y will be used as
                        \ a pixel row counter to work our way through the
                        \ character blocks, so each time we draw a character
                        \ block, we will increment Y by 8 to move on to the next
                        \ block (as each character block contains 8 rows)

.DLL10

 SEC                    \ Set A = Q - 2, so that A contains the offset of the
 LDA Q                  \ vertical bar from the start of this character block
 SBC #2

 BCS DLL11              \ If Q >= 2 then the character block we are drawing does
                        \ not contain the vertical indicator bar, so jump to
                        \ DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX Q                  \ Set X to the offset of the vertical bar, which we know
                        \ is within this character block

 STA Q                  \ Set Q to a high number (&FF, why not) so we will keep
                        \ drawing blank characters after this one until we reach
                        \ the end of the indicator row

 LDA CTWOS,X            \ CTWOS is a table of ready-made 1-pixel mode 2 bytes,
                        \ just like the TWOS and TWOS2 tables for mode 1 (see
                        \ the PIXEL routine for details of how they work). This
                        \ fetches a mode 2 1-pixel byte with the pixel position
                        \ at X, so the pixel is at the offset that we want for
                        \ our vertical bar

 AND #WHITE2            \ The 2-pixel mode 2 byte in #WHITE2 represents two
                        \ pixels of colour %0111 (7), which is white in both
                        \ dashboard palettes. We AND this with A so that we only
                        \ keep the pixel that matches the position of the
                        \ vertical bar (i.e. A is acting as a mask on the
                        \ 2-pixel colour byte)

 BNE DLL12              \ Jump to DLL12 to skip the code for drawing a blank,
                        \ and move on to drawing the indicator (this BNE is
                        \ effectively a JMP as A is always non-zero)

.DLL11

                        \ If we get here then we want to draw a blank for this
                        \ character block

 STA Q                  \ Update Q with the new offset of the vertical bar, so
                        \ it becomes the offset after the character block we
                        \ are about to draw

 LDA #0                 \ Change the mask so no bits are set, so all of the
                        \ character blocks we display from now on will be blank
.DLL12

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the fourth pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 5 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #5                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 CPY #60                \ If Y < 60 then we still have some more character
 BCC DLL10              \ blocks to draw, so loop back to DLL10 to display the
                        \ next one along

 INC SC+1               \ Increment the high byte of SC to point to the next
 INC SC+1               \ character row on-screen (as each row takes up exactly
                        \ two pages of 256 bytes) - so this sets up SC to point
                        \ to the next indicator, i.e. the one below the one we
                        \ just drew

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TVT1
\       Type: Variable
\   Category: Drawing the screen
\    Summary: Palette data for the mode 2 part of the screen (the dashboard)
\
\ ------------------------------------------------------------------------------
\
\ This palette is applied in the IRQ1 routine. If we have an escape pod fitted,
\ then the first byte is changed to &30, which maps logical colour 3 to actual
\ colour 0 (black) instead of colour 4 (blue).
\
\ ******************************************************************************

.TVT1

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\EQUB &34, &43
\EQUB &25, &16
\EQUB &86, &70
\EQUB &61, &52
\EQUB &C3, &B4
\EQUB &A5, &96
\EQUB &07, &F0
\EQUB &E1, &D2

                        \ --- And replaced by: -------------------------------->

 EQUB &30, &40          \ Set all colours to white except 1 (cyan) and 2 (red)
 EQUB &26, &11          \ to set the dashboard to white
 EQUB &80, &70
 EQUB &60, &50
 EQUB &C0, &B0
 EQUB &A0, &90
 EQUB &07, &F0
 EQUB &E0, &D0

                        \ --- End of replacement ------------------------------>

\ ******************************************************************************
\
\       Name: TVT1a
\       Type: Variable
\   Category: Drawing the screen
\    Summary: Palette data for the dashboard in anaglyph 3D
\
\ ******************************************************************************

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.TVT1a

 EQUB &30, &40          \ Set all colours to white except 1 (cyan) and 2 (red)
 EQUB &26, &11          \ to set the dashboard to white
 EQUB &80, &70
 EQUB &60, &50
 EQUB &C0, &B0
 EQUB &A0, &90
 EQUB &07, &F0
 EQUB &E0, &D0

 EQUB &32, &42          \ Set all colours to magenta except 1 (blue) and 2 (red)
 EQUB &26, &13          \ to set the dashboard to magenta
 EQUB &82, &72
 EQUB &62, &52
 EQUB &C2, &B2
 EQUB &A2, &92
 EQUB &07, &F2
 EQUB &E2, &D2

 EQUB &34, &44          \ Set all colours to yellow except 1 (red) and 2 (green)
 EQUB &25, &16          \ to set the dashboard to yellow
 EQUB &84, &74
 EQUB &64, &54
 EQUB &C4, &B4
 EQUB &A4, &94
 EQUB &07, &F4
 EQUB &E4, &D4

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: TVT3a
\       Type: Variable
\   Category: Drawing the screen
\    Summary: Palette data for the space view in anaglyph 3D
\
\ ******************************************************************************

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

.TVT3a

 EQUB &00, &31          \ 1 = cyan, 2 = red, 3 = white (anaglyph 3D space view)
 EQUB &21, &17          \
 EQUB &71, &61          \ Set with a #SETVDU19 0 command, after which:
 EQUB &57, &47          \
 EQUB &B0, &A0          \   #CYAN_3D  = cyan
 EQUB &96, &86          \   #RED_3D   = red
 EQUB &F0, &E0          \   #WHITE_3D = white
 EQUB &D6, &C6

 EQUB &02, &33          \ 1 = blue, 2 = red, 3 = magenta (anaglyph 3D space view)
 EQUB &23, &17          \
 EQUB &73, &63          \ Set with a #SETVDU19 0 command, after which:
 EQUB &57, &47          \
 EQUB &B2, &A2          \   #CYAN_3D  = blue
 EQUB &96, &86          \   #RED_3D   = red
 EQUB &F2, &E2          \   #WHITE_3D = magenta
 EQUB &D6, &C6

 EQUB &04, &36          \ 1 = red, 2 = green, 3 = yellow (anaglyph 3D space view)
 EQUB &26, &17          \
 EQUB &76, &66          \ Set with a #SETVDU19 0 command, after which:
 EQUB &57, &47          \
 EQUB &B4, &A4          \   #CYAN_3D  = red
 EQUB &95, &85          \   #RED_3D   = green
 EQUB &F4, &E4          \   #WHITE_3D = yellow
 EQUB &D5, &C5

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: do65C02
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Reverse the order of all bytes between the addresses in (1 0) and
\             (3 2) and start the game
\
\ ------------------------------------------------------------------------------
\
\ This routine is copied into the parasite's memory when it sends an OSWORD 249
\ command to the I/O processor. The code is copied by returning it in the OSWORD
\ parameter block. It ends up at location prtblock+2 in the S% routine.
\
\ When run, this routine reverses the order of all bytes between the address in
\ (1 0) and the address in (3 2). It starts by swapping the bytes at each end of
\ the memory block, and moves towards the centre of the block, swapping as it
\ goes until the two ends meet in the middle, where it stops.
\
\ In the original source, the memory is reversed by the first call to routine
\ V in the Big Code File, though in the BeebAsm version this is populated by
\ elite-checksum.py.
\
\ The original 6502 assembly language version of the V routine can be found in
\ the elite-checksum.asm file.
\
\ ******************************************************************************

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\CPU 1                  \ Switch to 65C02 assembly, because although this
\                       \ routine forms part of the code that runs on the 6502
\                       \ CPU of the BBC Micro I/O processor, the do65C02
\                       \ routine gets transmitted across the Tube to the
\                       \ parasite, and it contains some 65C02 code
\
\.do65C02
\
\.whiz
\
\                       \ When the following code is run as part of the S%
\                       \ routine in the parasite, it is entered with the
\                       \ following set:
\                       \
\                       \   (1 0) = SC(1 0) = G%
\                       \
\                       \   (3 2) = F% - 1
\                       \
\                       \   X = SC
\                       \
\                       \ We can access the address in (1 0) via indirect
\                       \ addressing, as in LDA (0), which is the same as
\                       \ LDA (&0000), and loads the byte at the 16-bit address
\                       \ in locations &0000 and &0001, or (1 0). In the same
\                       \ way, LDA (2) loads the byte at the address in (3 2)
\
\LDA (0)                \ Swap the bytes at the addresses (1 0) and (3 2), so
\PHA                    \ this starts by swapping G% and F%-1, and moves on to
\LDA (2)                \ G%+1 and F%-2, then G%+2 and F%-3, and so on, until
\STA (0)                \ (1 0) and (3 2) meet in the middle
\PLA
\STA (2)
\
\\NOP
\\NOP
\\NOP
\\NOP
\
\INC 0                  \ Increment the low byte of (1 0) to move it on to the
\                       \ next byte
\
\BNE P%+4               \ If the low byte has not wrapped round to zero, skip
\                       \ the following instruction
\
\INC 1                  \ Increment the high byte of (1 0) to move it on to the
\                       \ first byte of the next page
\
\LDA 2                  \ Set A to the low byte of (3 2)
\
\BNE P%+4               \ If the low byte is not zero, skip the following
\                       \ instruction
\
\DEC 3                  \ Decrement the high byte of (3 2) to move it on to the
\                       \ last byte of the previous page
\
\DEC 2                  \ Decrement the low byte of (3 2) to move it on to the
\                       \ previous byte
\
\DEA                    \ Decrement A, which we set to the low byte of (3 2)
\                       \ above, so A now equals (2), the new low byte of (3 2)
\
\CMP 0                  \ If A < low byte of (1 0), i.e. low byte of (3 2) < low
\                       \ byte of (1 0), then clear the C flag, else set it
\
\LDA 3                  \ Set A = high byte of (3 2) - high byte of (1 0)
\SBC 1                  \         - 1 if low byte of (3 2) < low byte of (1 0)
\                       \
\                       \ so this subtraction will underflow and clear the C
\                       \ flag when the high bytes of (3 2) and (1 0) are equal
\                       \ and low byte of (3 2) < low byte of (1 0), which will
\                       \ happen when the two endpoints cross over in the
\                       \ middle
\
\BCS whiz               \ If the C flag is set then (1 0) < (3 2), so loop back
\                       \ to reverse more bytes, as we haven't yet crossed over
\                       \ in the middle
\
\JMP (0,X)              \ Jump to (0+X), which is the same as (X). We set X to
\                       \ SC in S% before entering this routine, so this jumps
\                       \ to the address in SC(1 0), which contains G%... so
\                       \ this jumps to G% to start the game
\
\.end65C02
\
\protlen = end65C02 - do65C02
\
\CPU 0                  \ Switch back to normal 6502 assembly

                        \ --- End of removed code ----------------------------->

\ ******************************************************************************
\
\       Name: IRQ1
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: The main screen-mode interrupt handler (IRQ1V points here)
\  Deep dive: The split-screen mode in BBC Micro Elite
\
\ ------------------------------------------------------------------------------
\
\ The main interrupt handler, which implements Elite's split-screen mode (see
\ the deep dive on "The split-screen mode in BBC Micro Elite" for details).
\
\ IRQ1V is set to point to IRQ1 by the loading process.
\
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   VNT3+1              Changing this byte modifies the palette-loading
\                       instruction at VNT3, to support the #SETVDU19 <offset>
\                       command for changing the mode 1 palette
\
\ ******************************************************************************

.IRQ1

 TYA                    \ Store Y on the stack
 PHA

 LDY #15                \ Set Y as a counter for 16 bytes, to use when setting
                        \ the dashboard palette below

 LDA #%00000010         \ Read the 6522 System VIA status byte bit 1 (SHEILA
 BIT VIA+&4D            \ &4D), which is set if vertical sync has occurred on
                        \ the video system

 BNE LINSCN             \ If we are on the vertical sync pulse, jump to LINSCN
                        \ to set up the timers to enable us to switch the
                        \ screen mode between the space view and dashboard

 BVC jvec               \ Read the 6522 System VIA status byte bit 6, which is
                        \ set if timer 1 has timed out. We set the timer in
                        \ LINSCN above, so this means we only run the next bit
                        \ if the screen redraw has reached the boundary between
                        \ the space view and the dashboard. Otherwise bit 6 is
                        \ clear and we aren't at the boundary, so we jump to
                        \ jvec to pass control to the next interrupt handler

 LDA #%00010100         \ Set the Video ULA control register (SHEILA &20) to
 STA VIA+&20            \ %00010100, which is the same as switching to mode 2,
                        \ (i.e. the bottom part of the screen) but with no
                        \ cursor

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\LDA ESCP               \ Set A = ESCP, which is &FF if we have an escape pod
\                       \ fitted, or 0 if we don't
\
\AND #4                 \ Set A = 4 if we have an escape pod fitted, or 0 if we
\                       \ don't
\
\EOR #&34               \ Set A = &30 if we have an escape pod fitted, or &34 if
\                       \ we don't
\
\STA &FE21              \ Store A in SHEILA &21 to map colour 3 (#YELLOW2) to
\                       \ white if we have an escape pod fitted, or yellow if we
\                       \ don't, so the outline colour of the dashboard changes
\                       \ from yellow to white if we have an escape pod fitted

                        \ --- End of removed code ----------------------------->

                        \ The following loop copies bytes #15 to #1 from TVT1 to
                        \ SHEILA &21, but not byte #0, as we just did that
                        \ colour mapping

.VNT2

 LDA TVT1,Y             \ Copy the Y-th palette byte from TVT1 to SHEILA &21
 STA &FE21              \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\BNE VNT2               \ Loop back to VNT2 until we have copied all the palette
\                       \ bytes bar the first one

                        \ --- And replaced by: -------------------------------->

 BPL VNT2               \ Loop back to VNT2 until we have copied all the palette
                        \ bytes, including the first one

                        \ --- End of replacement ------------------------------>

.jvec

 PLA                    \ Restore Y from the stack
 TAY

 JMP (VEC)              \ Jump to the address in VEC, which was set to the
                        \ original IRQ1V vector by the loading process, so this
                        \ instruction passes control to the next interrupt
                        \ handler

.LINSCN

                        \ This is called from the interrupt handler below, at
                        \ the start of each vertical sync (i.e. when the screen
                        \ refresh starts)

 LDA #30                \ Set the line scan counter to a non-zero value, so
 STA DL                 \ routines like WSCAN can set DL to 0 and then wait for
                        \ it to change to non-zero to catch the vertical sync

 STA VIA+&44            \ Set 6522 System VIA T1C-L timer 1 low-order counter
                        \ (SHEILA &44) to 30

 LDA #VSCAN             \ Set 6522 System VIA T1C-L timer 1 high-order counter
 STA VIA+&45            \ (SHEILA &45) to VSCAN (57) to start the T1 counter
                        \ counting down from 14622 at a rate of 1 MHz

                        \ --- Mod: Code added for speed control: -------------->

 LDA syncCounter        \ Decrement the sync counter that we use to control the
 BEQ P%+4               \ speed of the main flight loop, not going past zero
 DEC syncCounter

                        \ --- End of added code ------------------------------->

 LDA HFX                \ If the hyperspace effect flag in HFX is non-zero, then
 BNE jvec               \ jump up to jvec to pass control to the next interrupt
                        \ handler, instead of switching the palette to mode 1.
                        \ This will have the effect of blurring and colouring
                        \ the top screen in a mode 2 palette, making the
                        \ hyperspace rings turn multicoloured when we do a
                        \ hyperspace jump. This effect is triggered by the
                        \ parasite issuing a #DOHFX 1 command in routine LL164
                        \ and is disabled again by a #DOHFX 0 command

 LDA #%00011000         \ Set the Video ULA control register (SHEILA &20) to
 STA VIA+&20            \ %00011000, which is the same as switching to mode 1
                        \ (i.e. the top part of the screen) but with no cursor

.VNT3

                        \ The following instruction gets modified in-place by
                        \ the #SETVDU19 <offset> command, which changes the
                        \ value of TVT3+1 (i.e. the low byte of the address in
                        \ the LDA instruction). This changes the palette block
                        \ that gets copied to SHEILA &21, so a #SETVDU19 32
                        \ command applies the third palette from TVT3 in this
                        \ loop, for example

 LDA TVT3,Y             \ Copy the Y-th palette byte from TVT3 to SHEILA &21
 STA VIA+&21            \ to map logical to actual colours for the bottom part
                        \ of the screen (i.e. the dashboard)

 DEY                    \ Decrement the palette byte counter

 BNE VNT3               \ Loop back to VNT3 until we have copied all the
                        \ palette bytes

 PLA                    \ Otherwise restore Y from the stack
 TAY

 LDA VIA+&41            \ Read 6522 System VIA input register IRA (SHEILA &41)

 LDA &FC                \ Set A to the interrupt accumulator save register,
                        \ which restores A to the value it had on entering the
                        \ interrupt

 RTI                    \ Return from interrupts, so this interrupt is not
                        \ passed on to the next interrupt handler, but instead
                        \ the interrupt terminates here

\ ******************************************************************************
\
\       Name: SETVDU19
\       Type: Subroutine
\   Category: Drawing the screen
\    Summary: Implement the #SETVDU19 <offset> command (change mode 1 palette)
\
\ ------------------------------------------------------------------------------
\
\ This routine is run when the parasite sends a #SETVDU19 <offset> command.
\
\ This routine updates the VNT3+1 location in the IRQ1 handler to change the
\ palette that's applied to the top part of the screen (the four-colour mode 1
\ part). The parameter is the offset within the TVT3 palette block of the
\ desired palette.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The offset within the TVT3 table of palettes:
\
\                         * 0 = Yellow, red, cyan palette (space view)
\
\                         * 16 = Yellow, red, white palette (charts)
\
\                         * 32 = Yellow, white, cyan palette (title screen)
\
\                         * 48 = Yellow, magenta, white palette (trading)
\
\ ******************************************************************************

.SETVDU19

                        \ --- Mod: Code added for anaglyph 3D: ---------------->

 BPL svdu2              \ If this is a normal palette change then bit 7 will be
                        \ clear, so jump to svdu2 to process it

                        \ Bit 7 of the palette number is set, which means this
                        \ is a request to change the anaglyph 3D palette, so we
                        \ now copy the correct palettes from TVT1a and TVT3a
                        \ into TVT1 and TVT3

 AND #%01111111         \ Clear bit 7 of the palette number to leave 0, 16 or 32
                        \ in A

 STA U                  \ Store the palette number in U

 TXA                    \ Store X and Y on the stack so we can preserve them
 PHA
 TYA
 PHA

 LDX U                  \ We are going to copy all palette colours from the
                        \ relevant tables, so fetch the index into X

 LDY #0                 \ Set Y to 0 to use as a loop counter

.svdu1

 LDA TVT1a,X            \ Copy the X-th byte from TVT1a into the Y-th byte of
 STA TVT1,Y             \ TVT1 (for the dashboard)

 LDA TVT3a,X            \ Copy the X-th byte from TVT3a into the Y-th byte of
 STA TVT3,Y             \ TVT3 (for the space view), TVT3+16 (for the chart
 STA TVT3+16,Y          \ view), TVT3+32 (for the title screen) and TVT3+48
 STA TVT3+32,Y          \ (for the trade view)
 STA TVT3+48,Y

 INX                    \ Increment the index

 INY                    \ Increment the loop counter

 CPY #16                \ Loop back until we have copied all 16 bytes
 BNE svdu1

 PLA                    \ Restore X and Y from the stack
 TAY
 PLA
 TAX

 LDA #0                 \ Set A = 0 to switch to the space view palette (as we
                        \ only change the palette in the Universe file viewer)

.svdu2

                        \ --- End of added code ------------------------------->

 STA VNT3+1             \ Store the new colour in VNT3+1, in the IRQ1 routine,
                        \ which modifies which TVT3 palette block gets applied
                        \ to the mode 1 part of the screen

 JMP PUTBACK            \ Jump to PUTBACK to restore the USOSWRCH handler and
                        \ return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: SpeedControl
\       Type: Subroutine
\   Category: Music
\    Summary: Control the game speed
\
\ ******************************************************************************

                        \ --- Mod: Code added for speed control: -------------->

.SpeedControl

 LDY #2                 \ Fetch byte #2 from the parameter block, which contains
 LDA (OSSC),Y           \ the parameter that controls the operation

 CMP #1                 \ If the parameter is 1, jump to StartMainLoop to wait
 BEQ SlowDownMainLoop   \ until the sync counter counts down, returning from the
                        \ subroutine using a tail call

                        \ Otherwise the parameter must be 0, so fall through
                        \ into StartMainLoop to restart the sync counter

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: StartMainLoop
\       Type: Subroutine
\   Category: Main loop
\    Summary: Restart the sync counter
\
\ ******************************************************************************

                        \ --- Mod: Code added for speed control: -------------->

.StartMainLoop

 LDA #SPEED             \ Set syncCounter to SPEED, the minimum number of
 STA syncCounter        \ vertical syncs we want to spend in the main loop

 RTS                    \ Return from the subroutine

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\       Name: SlowDownMainLoop
\       Type: Subroutine
\   Category: Main loop
\    Summary: Pause until the sync counter reaches zero
\
\ ******************************************************************************

                        \ --- Mod: Code added for speed control: -------------->

.SlowDownMainLoop

 LDA syncCounter        \ Wait until the syncCounter reaches 0
 BNE SlowDownMainLoop

 RTS                    \ Return from the subroutine

                        \ --- End of added code ------------------------------->

\ ******************************************************************************
\
\ Save I.CODE.bin
\
\ ******************************************************************************

 PRINT "I.CODE"
 PRINT "Assembled at ", ~CODE%
 PRINT "Ends at ", ~P%
 PRINT "Code size is ", ~(P% - CODE%)
 PRINT "Execute at ", ~LOAD%
 PRINT "Reload at ", ~LOAD%

                        \ --- Mod: Code removed for anaglyph 3D: -------------->

\PRINT "protlen = ", ~protlen

                        \ --- End of removed code ----------------------------->

 PRINT "S.I.CODE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/I.CODE.bin", CODE%, P%, LOAD%
