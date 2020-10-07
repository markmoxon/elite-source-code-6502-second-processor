\ ******************************************************************************
\
\ TUBE ELITE DISC IMAGE SCRIPT
\
\ The original 1984 source code is copyright Ian Bell and David Braben, and the
\ code on this site is identical to the version released by the authors on Ian
\ Bell's personal website at http://www.iancgbell.clara.net/elite/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ ******************************************************************************

INCLUDE "sources/tube-header.h.asm"

PUTFILE "output/ELITE.bin", "ELITE", &FF2000, &FF2085

PUTFILE "output/ELITEa.bin", "I.ELITEa", &FF2000, &FF2000

PUTFILE "output/I.CODE.bin", "I.CODE", &FF2400, &FF2C89

IF _REMOVE_CHECKSUMS
 PUTFILE "output/P.CODE.bin", "P.CODE", &1000, &10D1
ELSE
 PUTFILE "output/P.CODE.bin", "P.CODE", &1000, &106A
ENDIF
