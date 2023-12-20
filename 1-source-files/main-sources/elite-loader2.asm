\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE I/O LOADER (PART 2) SOURCE
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
\ This source file produces the following binary file:
\
\   * ELITEa.bin
\
\ after reading in the following files:
\
\   * P.DIALS2P.bin
\   * P.DATE2P.bin
\   * Z.ACSOFT.bin
\   * Z.ELITE.bin
\   * Z.(C)ASFT.bin
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

 D% = &D000             \ The address where the ship blueprints get moved to
                        \ after loading, so they go from &D000 to &F200

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0090 to &0093
\   Category: Workspaces
\    Summary: Important variables used by the loader
\
\ ******************************************************************************

 ORG &0090

.Z1

 SKIP 2                 \ Temporary storage, used when moving code

.Z2

 SKIP 2                 \ Temporary storage, used when moving code

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

 CODE% = &2000
 LOAD% = &2000

 ORG CODE%

\ ******************************************************************************
\
\       Name: MVE
\       Type: Macro
\   Category: Utility routines
\    Summary: Move a one-page block of memory from one location to another
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to move a block of memory from one location to
\ another:
\
\   MVE S%, D%, PA%
\
\ It is used to move the component parts of the loading screen into screen
\ memory, such as the dashboard background and Acornsoft copyright message.
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   S%                  The source address of the block to move
\
\   D%                  The destination address of the block to move
\
\   PA%                 Number of pages of memory to move (1 page = 256 bytes)
\
\ ******************************************************************************

MACRO MVE S%, D%, PA%

 LDA #LO(S%)            \ Set Z1(1 0) = S%
 STA Z1
 LDA #HI(S%)
 STA Z1+1

 LDA #LO(D%)            \ Set Z1(1 0) = D%
 STA Z2
 LDA #HI(D%)
 STA Z2+1

 LDX #PA%               \ Set X = PA%

 JSR MVBL               \ Call MVBL to copy X pages from S% to D%

ENDMACRO

\ ******************************************************************************
\
\       Name: Elite loader (Part 1 of 2)
\       Type: Subroutine
\   Category: Loader
\    Summary: Move loading screen binaries into screen memory and load and run
\             the main game code
\
\ ******************************************************************************

.ENTRY

 MVE DIALS, &7000, &E   \ Move the binary at DIALS (the dashboard background) to
                        \ locations &7000-&7DFF in screen memory (14 pages)

\MVE DATE, &6000, &1    \ This instruction is commented out in the original
                        \ course, but it would move the binary at DATE to
                        \ locations &6000-&60FF in screen memory (1 page),
                        \ which would display the following message on the
                        \ loading screen: "2nd Pro ELITE -Finished 13/12/84"

 MVE ASOFT, &4200, &1   \ Move the binary at ASOFT (the "Acornsoft" heading) to
                        \ locations &4200-&42FF in screen memory (1 page)

 MVE ELITE, &4600, &1   \ Move the binary at ELITE (the "ELITE" heading) to
                        \ locations &4600-&46FF in screen memory (1 page)

 MVE CpASOFT, &6C00, &1 \ Move the binary at CpASOFT (the Acornsoft copyright
                        \ message) to locations &6C00-&6CFF in screen memory
                        \ (1 page)

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("R.I.CODE")
 LDY #HI(MESS2)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the main I/O processor game code in I.CODE

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("R.P.CODE")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the main parasite game code in P.CODE, returning from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for running the I/O processor's main game
\             code in file I.CODE
\
\ ******************************************************************************

.MESS2

 EQUS "R.I.CODE"        \ This is short for "*RUN I.CODE"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for running the parasite's main game code
\             in file P.CODE
\
\ ******************************************************************************

.MESS3

 EQUS "R.P.CODE"        \ This is short for "*RUN P.CODE"
 EQUB 13

\ ******************************************************************************
\
\       Name: MVBL
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Move a multi-page block of memory from one location to another
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   Z1(1 0)             The source address of the block to move
\
\   Z2(1 0)             The destination address of the block to move
\
\   X                   Number of pages of memory to move (1 page = 256 bytes)
\
\ ******************************************************************************

.MVPG

                        \ This subroutine is called from below to copy one page
                        \ of memory from the address in Z1(1 0) to the address
                        \ in Z2(1 0)

 LDY #0                 \ We want to move one page of memory, so set Y as a byte
                        \ counter

.MPL

 LDA (Z1),Y             \ Copy the Y-th byte of the Z1(1 0) memory block to the
 STA (Z2),Y             \ Y-th byte of the Z2(1 0) memory block

 DEY                    \ Decrement the byte counter

 BNE MPL                \ Loop back to copy the next byte until we have done a
                        \ whole page of 256 bytes

 RTS                    \ Return from the subroutine

.MVBL

 JSR MVPG               \ Call MVPG above to copy one page of memory from the
                        \ address in Z1(1 0) to the address in Z2(1 0)

 INC Z1+1               \ Increment the high byte of the source address to point
                        \ to the next page

 INC Z2+1               \ Increment the high byte of the destination address to
                        \ point to the next page

 DEX                    \ Decrement the page counter

 BPL MVBL               \ Loop back to copy the next page until we have done X
                        \ pages

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: Elite loader (Part 2 of 2)
\       Type: Subroutine
\   Category: Loader
\    Summary: Include binaries for loading screen and dashboard images
\
\ ------------------------------------------------------------------------------
\
\ The loader bundles a number of binary files in with the loader code, and moves
\ them to their correct memory locations in part 1 above.
\
\ There are five files, all containing images, which are all moved into screen
\ memory by the loader:
\
\   * Z.ACSOFT.bin contains the "ACORNSOFT" title across the top of the loading
\     screen, which gets moved to screen address &4200, on the second character
\     row of the mode 1 part of the screen (the top part)
\
\   * Z.ELITE.bin contains the "ELITE" title across the top of the loading
\     screen, which gets moved to screen address &4600, on the fourth character
\     row of the mode 1 part of the screen (the top part)
\
\   * Z.(C)ASFT.bin contains the "(C) Acornsoft 1984" title across the bottom
\     of the loading screen, which gets moved to screen address &6C00, the
\     penultimate character row of the top part of the screen, just above the
\     dashboard
\
\   * P.DIALS2P.bin contains the dashboard, which gets moved to screen address
\     &7000, which is the starting point of the eight-colour mode 2 portion at
\     the bottom of the split screen
\
\   * P.DATE2P.bin contains the version text "2nd Pro ELITE -Finished 13/12/84",
\     though the code to show this on-screen in part 1 is commented out, as this
\     was presumably used to identify versions of the game during development.
\     If the MVE macro instruction in part 1 is uncommented, then this binary
\     gets moved to screen address &6000, which displays the version message in
\     the middle of the top part of the screen
\
\ ******************************************************************************

.DIALS

 INCBIN "1-source-files/images/P.DIALS2P.bin"

.DATE

 INCBIN "1-source-files/images/P.DATE2P.bin"

.ASOFT

 INCBIN "1-source-files/images/Z.ACSOFT.bin"

.ELITE

 INCBIN "1-source-files/images/Z.ELITE.bin"

.CpASOFT

 INCBIN "1-source-files/images/Z.(C)ASFT.bin"

\ ******************************************************************************
\
\ Save ELITEa.bin
\
\ ******************************************************************************

 PRINT "S.ELITEa ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/ELITEa.bin", CODE%, P%, LOAD%
