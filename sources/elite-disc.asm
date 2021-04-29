\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE DISC IMAGE SCRIPT
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code on this site is identical to the version released on Ian Bell's
\ personal website at http://www.elitehomepage.org/
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
\ This source file produces the following SSD disc image:
\
\   * elite-6502sp.ssd
\
\ This can be loaded into an emulator or a real BBC Micro.
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

_SOURCE_DISC            = (_RELEASE = 1)
_SNG45                  = (_RELEASE = 2)

IF _SNG45
 PUTFILE "output/ELITE.bin", "ELITE", &FF1FDC, &FF2085
ELIF _SOURCE_DISC
 PUTFILE "output/ELITE.bin", "ELITE", &FF2000, &FF2085
ENDIF

PUTFILE "output/ELITEa.bin", "I.ELITEa", &FF2000, &FF2000

PUTFILE "output/I.CODE.bin", "I.CODE", &FF2400, &FF2C89

IF _REMOVE_CHECKSUMS
 PUTFILE "output/P.CODE.bin", "P.CODE", &1000, &10D1
ELSE
 PUTFILE "output/P.CODE.bin", "P.CODE", &1000, &106A
ENDIF
