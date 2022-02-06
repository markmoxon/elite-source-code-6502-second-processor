\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE README
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
\   * README.txt
\
\ ******************************************************************************

INCLUDE "1-source-files/main-sources/elite-header.h.asm"

_SOURCE_DISC            = (_VARIANT = 1)
_SNG45                  = (_VARIANT = 2)
_EXECUTIVE              = (_VARIANT = 3)

.readme

 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13
 EQUS "Acornsoft Elite (flicker-free version)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Version: BBC with 6502 Second Processor"
 EQUB 10, 13

IF _SOURCE_DISC

 EQUS "Variant: Ian Bell's source disc"
 EQUB 10, 13

ELIF _SNG45

 EQUS "Variant: Acornsoft SNG45 release"
 EQUB 10, 13
 EQUS "Product: Acornsoft SNG45"
 EQUB 10, 13
 EQUS "         Acornsoft SNG47"
 EQUB 10, 13

ELIF _EXECUTIVE

 EQUS "Variant: The Executive version"
 EQUB 10, 13

ENDIF

 EQUB 10, 13
 EQUS "Contains the flicker-free ship drawing"
 EQUB 10, 13
 EQUS "routines from the BBC Master version,"
 EQUB 10, 13
 EQUS "backported by Mark Moxon"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "See www.bbcelite.com for details"
 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13

SAVE "3-assembled-output/README.txt", readme, P%

