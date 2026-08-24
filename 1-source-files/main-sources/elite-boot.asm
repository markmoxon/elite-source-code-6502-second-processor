\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE I/O !BOOT SOURCE
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code in this file is identical to the source discs released on Ian Bell's
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
\ This source file contains the first of two game loaders for 6502 Second
\ Processor Elite.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * BOOT.bin
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

 CODE% = &2000          \ The address where the code will be run

 LOAD% = &2000          \ The address where the code will be loaded

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\ ELITE BOOT FILE
\
\ ******************************************************************************

 ORG CODE%              \ Set the assembly address to CODE%

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for loading the Acornsoft screen
\
\ ******************************************************************************

.MESS2

 EQUS "LOAD SCREEN"
 EQUB 13

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Drawing the screen
\    Summary: VDU commands for setting the mode 7 loading screen
\
\ ******************************************************************************

.B%

 EQUB 22, 7             \ Switch to screen mode 7

 EQUB 23, 1, 0          \ Turn off the cursor by setting the cursor state to 0
 EQUB 0, 0, 0, 0
 EQUB 0, 0, 0, 0

 EQUB 13                \ Terminator byte

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for running the game
\
\ ******************************************************************************

.MESS3

 EQUS "RUN ELITE"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: The OS command string for turning off filing system messages
\
\ ******************************************************************************

.MESS1

 EQUS "OPT1 0"
 EQUB 13

\ ******************************************************************************
\
\       Name: ENTRY
\       Type: Subroutine
\   Category: Loader
\    Summary: The entry point for the boot file
\
\ ******************************************************************************

.ENTRY

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("OPT1 0")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1, which turns
                        \ off filing system messages

 LDA #114               \ Call OSBYTE with A = 114 and X = 1 to ensure we only
 LDX #1                 \ use shadow memory when the mode number is greater than
 JSR OSBYTE             \ 127, so this ensures we change to standard mode 7 and
                        \ not shadow mode 7 in the following loop

 LDX #255               \ We now work through the VDU commands in B%, so set a
                        \ byte counter in X, starting at 255 so the INX sets the
                        \ counter to 0 for the first iteration

.L203B

 INX                    \ Increment the byte counter in X

 LDA B%,X               \ Set A to the X-th byte from the B% table

 JSR OSWRCH             \ Print the VDU byte in A

 CMP #13                \ Loop back until we reach the terminator byte of 13
 BNE L203B

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("LOAD SCREEN")
 LDY #HI(MESS2)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS2, which loads
                        \ the Acornsoft mode 7 loading screen into screen memory

 LDX #&90               \ Call OSBYTE with A = 129, X = 144 and Y = 1 to scan
 LDY #1                 \ the keyboard for &190 centiseconds (4 seconds)
 LDA #129
 JSR OSBYTE

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("RUN ELITE")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which runs
                        \ the game and returns from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\ Save BOOT.bin
\
\ ******************************************************************************

 PRINT "S.BOOT ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/BOOT.bin", CODE%, P%, LOAD%