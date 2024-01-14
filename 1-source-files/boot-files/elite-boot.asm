\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE BOOT FILE
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
\   * ELITESP.bin
\
\ ******************************************************************************

 GUARD &4000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 OSCLI = &FFF7          \ The address for the OSCLI routine

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
\       Name: Elite boot command
\       Type: Subroutine
\   Category: Loader
\    Summary: Does the job of the !BOOT file but in a machine code file so it
\             can be run with a star-command from a BBC Micro
\
\ ******************************************************************************

.ENTRY

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.LIBRARY")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the library folder

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("RUN ELTSP")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the game in ELTSP, returning from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: Switch to the library directory
\
\ ******************************************************************************

.MESS1

 EQUS "DIR $.LIBRARY"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run Elite
\
\ ******************************************************************************

.MESS2

 EQUS "RUN ELTSP"
 EQUB 13

\ ******************************************************************************
\
\ Save ELITESP.bin
\
\ ******************************************************************************

 PRINT "S.ELITE ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/ELITESP.bin", CODE%, P%, LOAD%